import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/routing/app_routes.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_radius.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/shared/widgets/app_button.dart';
import 'package:ai_coach_gym/shared/widgets/app_card.dart';
import 'package:ai_coach_gym/shared/widgets/score_gauge.dart';
import 'package:ai_coach_gym/features/analysis/data/models/technique_metric.dart';
import 'package:ai_coach_gym/features/analysis/presentation/controllers/analysis_provider.dart';
import 'package:ai_coach_gym/features/history/presentation/controllers/history_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AnalysisProvider>();
    final result = provider.result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No analysis result available'),
              const SizedBox(height: 16),
              AppButton(
                label: 'Return Home',
                width: 200,
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.main),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${result.exercise} Technique Report'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Done',
            icon: const Icon(Icons.check_rounded),
            onPressed: () {
              context.read<HistoryProvider>().fetchHistory(refresh: true);
              provider.reset();
              Navigator.pushReplacementNamed(context, AppRoutes.main);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clear Dev/Demo Banner if result is from development repository
              if (result.isDemoData) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedLg,
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo Mode • Simulated development data for UI verification. Production AI model connects in Phase 2.',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
              ],

              // 1. Overall Score & Rep Count Hero Card
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  children: [
                    ScoreGauge(
                      score: result.score,
                      size: 150,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatChip(
                          icon: Icons.repeat_rounded,
                          label: 'Rep Count',
                          value: '${result.repCount} reps',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 16),
                        _buildStatChip(
                          icon: Icons.timer_outlined,
                          label: 'Analysis Latency',
                          value: '${result.processingTime ?? 3.12}s',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 2. Technique Metrics Section
              Text('Biomechanical Metrics', style: AppTextStyles.h2(isDark: isDark)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Keypoint tracking evaluated against optimal biomechanical ranges.',
                style: AppTextStyles.bodySmall(isDark: isDark),
              ),
              const SizedBox(height: AppSpacing.sm),

              ...result.metrics.map((metric) {
                Color statusColor;
                IconData statusIcon;

                switch (metric.status) {
                  case MetricStatus.optimal:
                    statusColor = AppColors.success;
                    statusIcon = Icons.check_circle_outline_rounded;
                    break;
                  case MetricStatus.warning:
                    statusColor = AppColors.warning;
                    statusIcon = Icons.warning_amber_rounded;
                    break;
                  case MetricStatus.needsWork:
                    statusColor = AppColors.error;
                    statusIcon = Icons.highlight_off_rounded;
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: AppRadius.roundedMd,
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    metric.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      metric.value,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                metric.explanation,
                                style: AppTextStyles.bodySmall(isDark: isDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.xl),

              // 3. Detected Biomechanical Issues (Technique Errors)
              if (result.errors.isNotEmpty) ...[
                Text('Detected Issues', style: AppTextStyles.h2(isDark: isDark)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Form flaws identified that may reduce efficiency or increase strain.',
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...result.errors.map((err) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      borderColor: AppColors.error.withValues(alpha: 0.25),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: AppRadius.roundedMd,
                            ),
                            child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  err.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  err.description,
                                  style: AppTextStyles.bodySmall(isDark: isDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
              ],

              // 4. Actionable Suggestions & Coaching Cues
              if (result.suggestions.isNotEmpty) ...[
                Text('Corrective Coaching Cues', style: AppTextStyles.h2(isDark: isDark)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Apply these physical adjustments during your next set.',
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...result.suggestions.map((sug) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      borderColor: (isDark ? AppColors.secondary : AppColors.secondaryDark).withValues(alpha: 0.25),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.secondary : AppColors.secondaryDark).withValues(alpha: 0.12),
                              borderRadius: AppRadius.roundedMd,
                            ),
                            child: Icon(
                              Icons.lightbulb_outline_rounded,
                              color: isDark ? AppColors.secondary : AppColors.secondaryDark,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sug.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sug.description,
                                  style: AppTextStyles.bodySmall(isDark: isDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // Actions: Save & Analyze Another
              AppButton(
                key: const Key('result_done_button'),
                label: 'Save & Return to Dashboard',
                trailingIcon: Icons.home_rounded,
                onPressed: () {
                  context.read<HistoryProvider>().fetchHistory(refresh: true);
                  provider.reset();
                  Navigator.pushReplacementNamed(context, AppRoutes.main);
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                key: const Key('result_analyze_another_button'),
                label: 'Analyze Another Exercise',
                isOutlined: true,
                icon: Icons.refresh_rounded,
                onPressed: () {
                  provider.reset();
                  Navigator.pushReplacementNamed(context, AppRoutes.exerciseSelection);
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? AppColors.primary : AppColors.primaryDark),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
