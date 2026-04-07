import 'package:flutter/material.dart';
import '../data/interventions_data.dart';
import '../theme/app_colors.dart';
import '../widgets/breathing_exercise.dart';

class InterventionsScreen extends StatefulWidget {
  const InterventionsScreen({super.key});

  @override
  State<InterventionsScreen> createState() => _InterventionsScreenState();
}

class _InterventionsScreenState extends State<InterventionsScreen> {
  int _promptIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 60, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calm',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Evidence-based wellbeing tools',
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Breathing
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Box Breathing', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.text)),
                const BreathingExercise(),
              ],
            ),
          ),

          // Mindfulness
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mindfulness', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 12),
                Text(
                  mindfulnessPrompts[_promptIndex],
                  style: const TextStyle(fontSize: 17, color: AppColors.text, fontStyle: FontStyle.italic, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _promptIndex = (_promptIndex + 1) % mindfulnessPrompts.length),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Next Prompt'),
                ),
              ],
            ),
          ),

          // Quick Actions
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Text('Quick Actions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _actionCard('🚶', 'Take a Walk', '10 min reset'),
                const SizedBox(width: 12),
                _actionCard('💬', 'Reach Out', 'Message a friend'),
              ],
            ),
          ),

          // Campus Resources
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Text('Campus Resources', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                for (int i = 0; i < campusResources.length; i++) ...[
                  _resourceRow(campusResources[i]),
                  if (i < campusResources.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _actionCard(String emoji, String title, String desc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _resourceRow(CampusResource resource) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(resource.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                if (resource.contact != null) ...[
                  const SizedBox(height: 4),
                  Text(resource.contact!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              resource.type,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}
