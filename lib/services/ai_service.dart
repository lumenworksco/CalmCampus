import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/data_engine.dart';
import '../data/mood_data.dart';
import '../models/daily_data.dart';

/// Cloud AI service backed by Groq's OpenAI-compatible chat completion API.
///
/// Get a free API key at https://console.groq.com (email signup, no card).
///
/// Supply the key one of two ways:
///   - Build time: `flutter run --dart-define=GROQ_API_KEY=gsk_...`
///   - Runtime:    Settings → AI → API Key
///
/// The service is OpenAI-compatible, so switching to Hugging Face (or any
/// other compatible router) later is a URL + model change in one place —
/// [_baseUrl] and [_buildModel].
///
/// Every method returns null / empty when no key is set or the call fails,
/// so callers transparently fall back to static content.
class AiService extends ChangeNotifier {
  // ── Endpoint ──
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // ── Build-time config ──
  static const _buildApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const _buildModel = String.fromEnvironment(
    'GROQ_MODEL',
    defaultValue: 'llama-3.3-70b-versatile',
  );

  // ── SharedPreferences keys ──
  static const _prefApiKey = 'groq_api_key';
  static const _prefModel = 'groq_model';

  String _apiKey = '';
  String _model = _buildModel;
  bool _initialized = false;
  String? _lastError;

  // ── Per-day caches (same shape UI already consumes) ──
  String? _insightCache;
  String? _insightCacheDate;
  bool _isGeneratingInsight = false;

  Map<String, String>? _toolReasons;
  String? _toolReasonsDate;

  Map<String, String>? _anomalyRewrites;
  String? _anomalyRewritesDate;

  AiService() {
    _loadSettings();
  }

  // ── Public getters ──
  bool get isInitialized => _initialized;
  bool get hasKey => _apiKey.isNotEmpty;
  bool get isAvailable => _initialized && hasKey && _lastError == null;
  String? get lastError => _lastError;
  String get model => _model;
  String get maskedKey {
    if (_apiKey.isEmpty) return 'Not set';
    if (_apiKey.length <= 8) return '••••';
    return '${_apiKey.substring(0, 4)}…${_apiKey.substring(_apiKey.length - 4)}';
  }

  bool get isGeneratingInsight => _isGeneratingInsight;
  String? get cachedInsight => _insightCache;
  Map<String, String>? get toolReasons => _toolReasons;
  Map<String, String>? get anomalyRewrites => _anomalyRewrites;

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_prefApiKey);
      final savedModel = prefs.getString(_prefModel);
      // Build-time key wins over pref (handy for demos).
      _apiKey = _buildApiKey.isNotEmpty ? _buildApiKey : (savedKey ?? '');
      _model = savedModel ?? _buildModel;
    } catch (_) {
      _apiKey = _buildApiKey;
      _model = _buildModel;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key.trim();
    _lastError = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_apiKey.isEmpty) {
        await prefs.remove(_prefApiKey);
      } else {
        await prefs.setString(_prefApiKey, _apiKey);
      }
    } catch (_) {}
    _invalidateCaches();
    notifyListeners();
  }

  Future<void> setModel(String model) async {
    _model = model.trim().isEmpty ? _buildModel : model.trim();
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

  /// Round-trip a short probe to confirm key + network work.
  /// Returns true on HTTP 200, false (with [lastError] set) otherwise.
  Future<bool> ping() async {
    if (!hasKey) {
      _lastError = 'No API key';
      notifyListeners();
      return false;
    }
    final result = await _call('Reply with the single word: ok');
    return result != null;
  }

  /// Core HTTP call — POSTs a single user-message chat completion and returns
  /// the trimmed assistant text, or null on any failure. Updates [_lastError].
  Future<String?> _call(String prompt) async {
    if (!_initialized || !hasKey) return null;

    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      final req = await client.postUrl(Uri.parse(_baseUrl));
      req.headers.contentType = ContentType.json;
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_apiKey');
      req.add(utf8.encode(jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 250,
      })));
      final resp = await req.close().timeout(const Duration(seconds: 30));
      final body = await resp.transform(utf8.decoder).join();

      if (resp.statusCode != 200) {
        _lastError = _parseError(resp.statusCode, body);
        debugPrint('AiService ${resp.statusCode}: $body');
        notifyListeners();
        return null;
      }

      _lastError = null;
      final obj = jsonDecode(body) as Map<String, dynamic>;
      final choices = obj['choices'] as List?;
      if (choices == null || choices.isEmpty) return null;
      final msg = (choices.first as Map)['message'] as Map?;
      final text = msg?['content'] as String?;
      return text?.trim();
    } catch (e) {
      _lastError = e.toString();
      debugPrint('AiService: $e');
      notifyListeners();
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  String _parseError(int status, String body) {
    try {
      final obj = jsonDecode(body) as Map<String, dynamic>;
      final err = obj['error'];
      if (err is Map && err['message'] is String) {
        return '$status: ${err['message']}';
      }
    } catch (_) {}
    return 'HTTP $status';
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
