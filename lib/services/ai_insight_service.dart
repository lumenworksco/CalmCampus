import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../data/data_engine.dart';
import '../data/mood_data.dart';
import '../models/daily_data.dart';

/// Generates wellness insights using Gemini (on-device where available,
/// cloud fallback).
///
/// Pass the API key at build time:
///   flutter run --dart-define=GEMINI_API_KEY=your_key
///
/// Falls back to the rule-based [getSmartInsight] when no key is provided
/// or when the API call fails.
class AiInsightService extends ChangeNotifier {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  String? _cached;
  String? _cachedDate;
  bool _isGenerating = false;

  bool get isAvailable => _apiKey.isNotEmpty;
  bool get isGenerating => _isGenerating;
  String? get cached => _cached;

  /// Generate an AI insight from 7-day wellness data.
  ///
  /// Returns the AI text, or `null` if unavailable (caller should fall back
  /// to [getSmartInsight]).
  Future<String?> generate(List<DailyData> weeklyData, {int? realSteps}) async {
    if (_apiKey.isEmpty) return null;

    // Return cached result if it's from today.
    final today = _todayStr();
    if (_cachedDate == today && _cached != null) return _cached;

    _isGenerating = true;
    notifyListeners();

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 120,
        ),
      );

      final prompt = _buildPrompt(weeklyData, realSteps);
      final response = await model.generateContent([Content.text(prompt)]);
      _cached = response.text?.trim();
      _cachedDate = today;
    } catch (e) {
      debugPrint('AiInsightService: $e');
      _cached = null;
    }

    _isGenerating = false;
    notifyListeners();
    return _cached;
  }

  String _buildPrompt(List<DailyData> week, int? realSteps) {
    final buf = StringBuffer();
    buf.writeln(
      'You are a caring wellness coach for university students. '
      'Given this 7-day behavioral data, write a concise 2-sentence '
      'personalized wellness insight. Be warm, specific about trends '
      'you see, and give one actionable suggestion.',
    );
    buf.writeln();
    buf.writeln('Day | Sleep(h) | Screen(h) | Active(min) | Focus(%) | Wellness | Mood');
    buf.writeln('--- | -------- | --------- | ----------- | -------- | -------- | ----');

    for (final d in week) {
      final focus = computeFocusScore(d.appSwitches);
      final mood = d.moodRating != null ? moodLabel(d.moodRating!) : '—';
      buf.writeln(
        '${d.dayLabel} | ${d.sleepHours} | ${d.screenTimeHours} | '
        '${d.activeMinutes} | $focus% | ${d.wellnessScore} | $mood',
      );
    }

    if (realSteps != null) {
      buf.writeln();
      buf.writeln("Today's step count: $realSteps");
    }

    buf.writeln();
    buf.writeln('Guidelines:');
    buf.writeln('- Maximum 2 sentences, under 60 words total');
    buf.writeln('- Reference a specific trend from the data');
    buf.writeln('- Sound like a supportive friend, not a clinical report');
    buf.writeln('- Do NOT start with "Your" or "You"');
    buf.writeln('- Do NOT use bullet points or markdown');

    return buf.toString();
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}';
  }
}
