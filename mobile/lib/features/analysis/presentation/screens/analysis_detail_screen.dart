import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/core/utils/formatters.dart';
import 'package:ai_coach_gym/shared/widgets/app_badge.dart';
import 'package:ai_coach_gym/shared/widgets/app_card.dart';
import 'package:ai_coach_gym/shared/widgets/score_gauge.dart';
import 'package:ai_coach_gym/features/analysis/data/models/analysis_model.dart';
import 'package:ai_coach_gym/features/analysis/data/models/technique_metric.dart';
import 'package:ai_coach_gym/features/history/data/models/history_item_model.dart';
import 'package:ai_coach_gym/features/history/presentation/controllers/history_provider.dart';

class AnalysisDetailScreen extends StatelessWidget {
  const AnalysisDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Object? rawArg = ModalRoute.of(context)?.settings.arguments;
    if (rawArg == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Session Report')),
        body: const Center(child: Text('No session data found.')),
      );
    }

    String exercise = 'Exercise';
    int score = 0;
    int reps = 0;
    DateTime createdAt = DateTime.now();
    int analysisId = 0;
    double? processingTime = 3.12;
    List<TechniqueMetric> metrics = [];
    List<dynamic> errors = [];
    List<dynamic> suggestions = [];

    if (rawArg is AnalysisModel) {
      analysisId = rawArg.id;
      exercise = rawArg.result?.exercise ?? rawArg.exercise;
      score = rawArg.result?.score ?? rawArg.score;
      reps = rawArg.result?.repCount ?? rawArg.repCount;
      createdAt = rawArg.createdAt;
      processingTime = rawArg.result?.processingTime ?? 3.12;
      metrics = rawArg.result?.metrics ?? [];
      errors = rawArg.result?.errors ?? [];
      suggestions = rawArg.result?.suggestions ?? [];
    } else if (rawArg is HistoryItemModel) {
      final historyItem = rawArg;
      analysisId = historyItem.analysisId;
      exercise = historyItem.detailedResult?.exercise ?? historyItem.exercise;
      score = historyItem.detailedResult?.score ?? historyItem.score;
      reps = historyItem.detailedResult?.repCount ?? historyItem.repCount;
      createdAt = historyItem.createdAt;
      processingTime = historyItem.detailedResult?.processingTime ?? 3.12;
      metrics = historyItem.detailedResult?.metrics ?? [];
      errors = historyItem.detailedResult?.errors ?? [];
      suggestions = historyItem.detailedResult?.suggestions ?? [];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$exercise Report'),
        actions: [
          IconButton(
            tooltip: 'Delete Record',
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Session'),
                  content: const Text('Are you sure you want to remove this workout record from your history?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await context.read<HistoryProvider>().deleteItem(analysisId);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
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
              // Timestamp & Exercise Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBadge(
                    label: exercise,
                    icon: Icons.fitness_center_rounded,
                  ),
                  Text(
                    Formatters.formatDate(createdAt),
                    style: AppTextStyles.bodySmall(isDark: isDark),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Overall Score Visual Card
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ScoreGauge(
                      score: score,
                      size: 150,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatTile('Repetitions', '$reps reps', isDark),
                        Container(width: 1, height: 32, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        _buildStatTile('Pipeline Latency', '${processingTime}s', isDark),
                        Container(width: 1, height: 32, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        _buildStatTile('Session ID', '#$analysisId', isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Metrics Evaluation
              if (metrics.isNotEmpty) ...[
                Text('Biomechanical Breakdown', style: AppTextStyles.h2(isDark: isDark)),
                const SizedBox(height: AppSpacing.sm),
                ...metrics.map((metric) {
                  final isOptimal = metric.status == MetricStatus.optimal;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
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
                                  color: (isOptimal ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  metric.value,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isOptimal ? AppColors.success : AppColors.warning,
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
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Issues & Suggestions
              if (errors.isNotEmpty) ...[
                Text('Technique Deviations', style: AppTextStyles.h2(isDark: isDark)),
                const SizedBox(height: AppSpacing.sm),
                ...errors.map((err) {
                  final title = err is String ? err : err.title;
                  final desc = err is String ? 'Technique flaw detected.' : err.description;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      borderColor: AppColors.error.withValues(alpha: 0.25),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(desc, style: AppTextStyles.bodySmall(isDark: isDark)),
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

              if (suggestions.isNotEmpty) ...[
                Text('Coaching Cues', style: AppTextStyles.h2(isDark: isDark)),
                const SizedBox(height: AppSpacing.sm),
                ...suggestions.map((sug) {
                  final title = sug is String ? sug : sug.title;
                  final desc = sug is String ? 'Focus on this cue during next repetition.' : sug.description;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      borderColor: (isDark ? AppColors.secondary : AppColors.secondaryDark).withValues(alpha: 0.25),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: isDark ? AppColors.secondary : AppColors.secondaryDark,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(desc, style: AppTextStyles.bodySmall(isDark: isDark)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ],
    );
  }
}
