import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Half-arc semicircle wellness gauge — matches the mockup style.
///
/// The arc spans 180° from left to right, with the score number rendered
/// near the top of the arc and a subtle label centered just below it.
class WellnessGauge extends StatelessWidget {
  final int score;
  final double size;

  const WellnessGauge({super.key, required this.score, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getWellnessColor(score);
    final label = AppColors.getWellnessLabel(score);

    return Semantics(
      label: 'Wellness score $score out of 100. $label',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: score.toDouble()),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, animatedScore, _) {
          // Arc viewport is 1:0.7 (matches the SVG `viewBox="0 0 130 100"` ratio)
          final width = size;
          final height = size * 100 / 130;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: width,
                height: height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(width, height),
                      painter: _ArcPainter(score: animatedScore, color: color),
                    ),
                    // Score number sits inside the arc, near the top
                    Positioned(
                      top: height * 0.30,
                      child: Text(
                        '${animatedScore.toInt()}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                    // Subtle label just under the score
                    Positioned(
                      bottom: 6,
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double score;
  final Color color;

  _ArcPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    // Arc center sits horizontally centered, vertically near the bottom
    // (at y = 70 in the original 130×100 viewBox). The arc radius is 50.
    final cx = size.width / 2;
    final cy = size.height * 0.70;
    final radius = size.width * 50 / 130;
    final rect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: radius,
    );

    // Background track — top half of a circle, light grey
    final bgPaint = Paint()
      ..color = const Color(0xFFE5E5EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, pi, pi, false, bgPaint);

    // Foreground progress — same arc, drawn proportional to score
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweep = pi * (score / 100);
    canvas.drawArc(rect, pi, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.score != score || old.color != color;
}
