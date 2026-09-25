import 'package:flutter/material.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/utils/formatters.dart';

/// Circular score gauge displaying numerical score, color tier, and technique label.
class ScoreGauge extends StatelessWidget {
  final int score;
  final double size;
  final bool showLabel;

  const ScoreGauge({
    super.key,
    required this.score,
    this.size = 140,
    this.showLabel = true,
  });

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.scoreExcellent;
    if (score >= 80) return AppColors.scoreGood;
    if (score >= 70) return AppColors.scoreModerate;
    return AppColors.scoreNeedsWork;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getScoreColor(score);
    final percentage = (score / 100).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: size * 0.08,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  ),
                ),
              ),
              // Value track
              SizedBox(
                width: size,
                height: size,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: percentage),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: size * 0.08,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    );
                  },
                ),
              ),
              // Central Score Number
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: size * 0.32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      height: 1.0,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PTS',
                    style: TextStyle(
                      fontSize: size * 0.09,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(
              Formatters.scoreLabel(score),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
