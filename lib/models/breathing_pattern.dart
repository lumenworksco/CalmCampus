class BreathingPhase {
  final String label;
  final int durationSeconds;
  final bool isExpand;
  final bool isHold;

  const BreathingPhase({
    required this.label,
    required this.durationSeconds,
    this.isExpand = false,
    this.isHold = false,
  });
}

class BreathingPattern {
  final String name;
  final String description;
  final List<BreathingPhase> phases;

  const BreathingPattern({
    required this.name,
    required this.description,
    required this.phases,
  });

  int get totalDuration => phases.fold(0, (sum, p) => sum + p.durationSeconds);

  static const boxBreathing = BreathingPattern(
    name: 'Box Breathing',
    description: 'Equal timing promotes balance and calm focus',
    phases: [
      BreathingPhase(label: 'Breathe In', durationSeconds: 4, isExpand: true),
      BreathingPhase(label: 'Hold', durationSeconds: 4, isHold: true),
      BreathingPhase(label: 'Breathe Out', durationSeconds: 4),
      BreathingPhase(label: 'Hold', durationSeconds: 4, isHold: true),
    ],
  );

  static const relaxation478 = BreathingPattern(
    name: '4-7-8 Relaxation',
    description: 'Clinically validated for anxiety reduction',
    phases: [
      BreathingPhase(label: 'Breathe In', durationSeconds: 4, isExpand: true),
      BreathingPhase(label: 'Hold', durationSeconds: 7, isHold: true),
      BreathingPhase(label: 'Breathe Out', durationSeconds: 8),
    ],
  );

  static const physiologicalSigh = BreathingPattern(
    name: 'Physiological Sigh',
    description: 'Fastest way to calm your nervous system in real-time',
    phases: [
      BreathingPhase(label: 'Inhale', durationSeconds: 2, isExpand: true),
      BreathingPhase(label: 'Double Inhale', durationSeconds: 1, isExpand: true),
      BreathingPhase(label: 'Long Exhale', durationSeconds: 6),
    ],
  );
}
