import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../data/data_engine.dart';
import '../data/mood_data.dart';
import '../models/daily_data.dart';

/// Unified Gemini AI service for all AI-powered features.
///
/// Pass the API key at build time:
///   flutter run --dart-define=GEMINI_API_KEY=your_key
///
/// Every method gracefully returns null / empty when no key is configured,
/// so callers can fall back to static content.
class GeminiService extends ChangeNotifier {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  GenerativeModel? _model;

  // ── Insight cache ──
  String? _insightCache;
  String? _insightCacheDate;
  bool _isGeneratingInsight = false;

  // ── Tool-reason cache ──
  Map<String, String>? _toolReasons;
  String? _toolReasonsDate;

  // ── Anomaly-rewrite cache ──
  Map<String, String>? _anomalyRewrites;
  String? _anomalyRewritesDate;

  bool get isAvailable => _apiKey.isNotEmpty;
  bool get isGeneratingInsight => _isGeneratingInsight;
  String? get cachedInsight => _insightCache;
  Map<String, String>? get toolReasons => _toolReasons;
  Map<String, String>? get anomalyRewrites => _anomalyRewrites;

  GenerativeModel get _gemini {
    _model ??= GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 200,
      ),
    );
    return _model!;
  }

  Future<String?> _call(String prompt) async {
    if (!isAvailable) return null;
    try {
      final response = await _gemini.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e) {
      debugPrint('GeminiService: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. Weekly Insight  (Insights tab + Dashboard summary)
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
  // 2. Thought Reframes  (CBT Thought Reframer tool)
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
  // 5a. Toolkit recommendation reasons  (cached per day)
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
  // 5b. Anomaly message rewrites  (cached per day)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> rewriteAnomalies(List<(String id, String title, String msg)> anomalies) async {
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
