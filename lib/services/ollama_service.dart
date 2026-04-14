import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/data_engine.dart';
import '../data/mood_data.dart';
import '../models/daily_data.dart';

/// Unified local-AI service backed by Ollama (https://ollama.com).
///
/// Runs Ollama on a machine reachable from the phone (your laptop on the
/// same Wi-Fi, or the emulator host). Default endpoint:
///
///   - Android emulator:  10.0.2.2:11434  (maps to host localhost)
///   - iOS simulator / macOS: localhost:11434
///   - Physical device: override via Settings → AI with the LAN IP
///     of the computer running `ollama serve`.
///
/// Build-time overrides (optional):
///   flutter run --dart-define=OLLAMA_HOST=192.168.1.42:11434 \
///               --dart-define=OLLAMA_MODEL=llama3.2:3b
///
/// Every method returns null / empty when Ollama is unreachable, so callers
/// transparently fall back to static content.
class OllamaService extends ChangeNotifier {
  static const _buildHost = String.fromEnvironment('OLLAMA_HOST');
  static const _buildModel = String.fromEnvironment(
    'OLLAMA_MODEL',
    defaultValue: 'llama3.2:3b',
  );

  static const _prefHost = 'ollama_host';
  static const _prefModel = 'ollama_model';

  String _host = '';
  String _model = _buildModel;
  bool _initialized = false;
  bool _reachable = false;

  // ── Caches (per-day, same shape the UI already uses) ──
  String? _insightCache;
  String? _insightCacheDate;
  bool _isGeneratingInsight = false;

  Map<String, String>? _toolReasons;
  String? _toolReasonsDate;

  Map<String, String>? _anomalyRewrites;
  String? _anomalyRewritesDate;

  OllamaService() {
    _loadSettings();
  }

  // ── Public getters ──
  String get host => _host;
  String get model => _model;
  bool get isInitialized => _initialized;
  bool get isAvailable => _initialized && _reachable;
  bool get isGeneratingInsight => _isGeneratingInsight;
  String? get cachedInsight => _insightCache;
  Map<String, String>? get toolReasons => _toolReasons;
  Map<String, String>? get anomalyRewrites => _anomalyRewrites;

  String get defaultHost {
    if (_buildHost.isNotEmpty) return _buildHost;
    if (!kIsWeb && Platform.isAndroid) return '10.0.2.2:11434';
    return 'localhost:11434';
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _host = prefs.getString(_prefHost) ?? defaultHost;
      _model = prefs.getString(_prefModel) ?? _buildModel;
    } catch (_) {
      _host = defaultHost;
      _model = _buildModel;
    }
    _initialized = true;
    notifyListeners();
    unawaited(_checkHealth());
  }

  Future<void> setHost(String host) async {
    _host = host.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefHost, _host);
    } catch (_) {}
    _invalidateCaches();
    _reachable = false;
    notifyListeners();
    unawaited(_checkHealth());
  }

  Future<void> setModel(String model) async {
    _model = model.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefModel, _model);
    } catch (_) {}
    _invalidateCaches();
    notifyListeners();
  }

  void _invalidateCaches() {
    _insightCache = null;
    _insightCacheDate = null;
    _toolReasons = null;
    _toolReasonsDate = null;
    _anomalyRewrites = null;
    _anomalyRewritesDate = null;
  }

  /// Pings `/api/tags` to see if Ollama is reachable. Call from the settings
  /// screen or before making a request. Updates [isAvailable].
  Future<bool> ping() => _checkHealth();

  Future<bool> _checkHealth() async {
    if (_host.isEmpty) {
      _reachable = false;
      notifyListeners();
      return false;
    }
    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 2);
      final req = await client.getUrl(Uri.parse('http://$_host/api/tags'));
      final resp = await req.close().timeout(const Duration(seconds: 3));
      _reachable = resp.statusCode == 200;
      // Drain to free the socket.
      await resp.drain<void>();
    } catch (e) {
      _reachable = false;
      debugPrint('Ollama health check failed: $e');
    } finally {
      client?.close(force: true);
    }
    notifyListeners();
    return _reachable;
  }

  /// Core HTTP call — POSTs to `/api/generate` and returns the trimmed
  /// `response` field, or null on any failure.
  Future<String?> _call(String prompt) async {
    if (!_initialized) return null;
    if (!_reachable) {
      final ok = await _checkHealth();
      if (!ok) return null;
    }

    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final req =
          await client.postUrl(Uri.parse('http://$_host/api/generate'));
      req.headers.contentType = ContentType.json;
      req.add(utf8.encode(jsonEncode({
        'model': _model,
        'prompt': prompt,
        'stream': false,
        'options': {
          'temperature': 0.7,
          'num_predict': 250,
        },
      })));
      final resp = await req.close().timeout(const Duration(seconds: 60));
      if (resp.statusCode != 200) {
        debugPrint('Ollama error ${resp.statusCode}');
        await resp.drain<void>();
        return null;
      }
      final body = await resp.transform(utf8.decoder).join();
      final obj = jsonDecode(body) as Map<String, dynamic>;
      return (obj['response'] as String?)?.trim();
    } catch (e) {
      debugPrint('OllamaService: $e');
      _reachable = false;
      notifyListeners();
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. Weekly Insight
  // ─────────────────────────────────────────────────────────────────────────

  Future<String?> generateInsight(
    List<DailyData> weeklyData, {
    int? realSteps,
  }) async {
    final today = _todayStr();
    if (_insightCacheDate == today && _insightCache != null) {
      return _insightCache;
    }

    _isGeneratingInsight = true;
    notifyListeners();

    final buf = StringBuffer()
      ..writeln(
        'You are a caring wellness coach for university students. '
        'Given this 7-day behavioral data, write a concise 2-sentence '
        'personalized wellness insight. Be warm, specific about trends '
        'you see, and give one actionable suggestion.',
      )
      ..writeln()
      ..writeln(
          'Day | Sleep(h) | Screen(h) | Active(min) | Focus(%) | Wellness | Mood')
      ..writeln(
          '--- | -------- | --------- | ----------- | -------- | -------- | ----');

    for (final d in weeklyData) {
      final focus = computeFocusScore(d.appSwitches);
      final mood = d.moodRating != null ? moodLabel(d.moodRating!) : '—';
      buf.writeln(
        '${d.dayLabel} | ${d.sleepHours} | ${d.screenTimeHours} | '
        '${d.activeMinutes} | $focus% | ${d.wellnessScore} | $mood',
      );
    }
    if (realSteps != null) buf.writeln("\nToday's step count: $realSteps");

    buf
      ..writeln('\nGuidelines:')
      ..writeln('- Maximum 2 sentences, under 60 words total')
      ..writeln('- Reference a specific trend from the data')
      ..writeln('- Sound like a supportive friend, not a clinical report')
      ..writeln('- Do NOT start with "Your" or "You"')
      ..writeln('- Do NOT use bullet points or markdown');

    _insightCache = await _call(buf.toString());
    _insightCacheDate = today;
    _isGeneratingInsight = false;
    notifyListeners();
    return _insightCache;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. Thought Reframes
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<String>> suggestReframes(
    String thought, {
    List<String>? distortions,
  }) async {
    final distCtx = distortions != null && distortions.isNotEmpty
        ? '\nCognitive distortions identified: ${distortions.join(', ')}'
        : '';

    final result = await _call(
      'A university student has this automatic negative thought:\n'
      '"$thought"$distCtx\n\n'
      'Suggest exactly 3 brief CBT-based cognitive reframes. '
      'Each reframe should be a single sentence (max 20 words). '
      'Separate them with newlines. Do NOT number them or use bullet points.',
    );

    if (result == null) return [];
    return result
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .take(3)
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. Check-in Affirmation
  // ─────────────────────────────────────────────────────────────────────────

  Future<String?> generateAffirmation(int mood, int energy) async {
    return _call(
      'A university student just checked in with mood $mood/5 and energy $energy/5. '
      'Write ONE warm, brief affirmation (max 12 words). '
      'Be compassionate, not patronizing. Do NOT start with "You".',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. Gratitude Follow-up
  // ─────────────────────────────────────────────────────────────────────────

  Future<String?> generateGratitudePrompt(String entry) async {
    return _call(
      'A student wrote this gratitude entry: "$entry"\n\n'
      'Generate ONE short follow-up question (max 15 words) that deepens '
      'their reflection. Be warm and curious. Do not repeat their words.',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5a. Toolkit recommendation reasons
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> generateToolReasons(DailyData data, List<String> toolIds) async {
    final today = _todayStr();
    if (_toolReasonsDate == today && _toolReasons != null) return;

    final toolList = toolIds.map((id) => '- $id: [reason]').join('\n');
    final result = await _call(
      'Student data: sleep ${data.sleepHours}h, screen ${data.screenTimeHours}h, '
      'active ${data.activeMinutes}min, wellness ${data.wellnessScore}/100, '
      'mood ${data.moodRating ?? "not reported"}/5.\n\n'
      'For each tool below, write a warm, personalized reason (max 12 words) '
      'why it would help today. Reference their specific data.\n$toolList\n\n'
      'Format exactly as: id: reason (one per line, no dashes or bullets)',
    );

    if (result != null) {
      _toolReasons = {};
      for (final line in result.split('\n')) {
        final idx = line.indexOf(':');
        if (idx > 0) {
          final id = line.substring(0, idx).trim().replaceAll('- ', '');
          final reason = line.substring(idx + 1).trim();
          if (reason.isNotEmpty) _toolReasons![id] = reason;
        }
      }
      _toolReasonsDate = today;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5b. Anomaly message rewrites
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> rewriteAnomalies(
      List<(String id, String title, String msg)> anomalies) async {
    final today = _todayStr();
    if (_anomalyRewritesDate == today && _anomalyRewrites != null) return;
    if (anomalies.isEmpty) return;

    final lines =
        anomalies.map((a) => '${a.$1}: "${a.$2} — ${a.$3}"').join('\n');
    final result = await _call(
      'Rewrite each wellness alert for a university student. Be warmer and '
      'more actionable. Keep each under 25 words. Sound like a caring friend.\n\n'
      '$lines\n\n'
      'Format exactly as: id: rewritten message (one per line)',
    );

    if (result != null) {
      _anomalyRewrites = {};
      for (final line in result.split('\n')) {
        final idx = line.indexOf(':');
        if (idx > 0) {
          final id = line.substring(0, idx).trim();
          final msg = line.substring(idx + 1).trim();
          if (msg.isNotEmpty) _anomalyRewrites![id] = msg;
        }
      }
      _anomalyRewritesDate = today;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}';
  }
}
