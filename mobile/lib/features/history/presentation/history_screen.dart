import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/localization/app_localizations.dart';
import 'package:ai_coach_gym/core/routing/app_routes.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_radius.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/utils/formatters.dart';
import 'package:ai_coach_gym/shared/widgets/app_card.dart';
import 'package:ai_coach_gym/shared/widgets/empty_state_view.dart';
import 'package:ai_coach_gym/shared/widgets/error_state_view.dart';
import 'package:ai_coach_gym/features/history/presentation/controllers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history = context.watch<HistoryProvider>();

    final filters = [
      {'key': 'All', 'label': context.tr('categoryAll')},
      {'key': 'Squat', 'label': 'Squat'},
      {'key': 'Push-up', 'label': 'Push-up'},
      {'key': 'Bicep Curl', 'label': 'Bicep Curl'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('historyTitle')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filterItem = filters[index];
                    final filterKey = filterItem['key']!;
                    final filterLabel = filterItem['label']!;
                    final isSelected = (history.selectedFilter == null && filterKey == 'All') ||
                        history.selectedFilter == filterKey;

                    return GestureDetector(
                      onTap: () {
                        history.setFilter(filterKey == 'All' ? null : filterKey);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppColors.primary : AppColors.primaryDark)
                              : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppColors.primary : AppColors.primaryDark)
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        child: Text(
                          filterLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.black
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Main Content Area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => history.fetchHistory(refresh: true),
                child: _buildBody(context, history, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HistoryProvider history, bool isDark) {
    if (history.isLoading && history.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (history.errorMessage != null && history.items.isEmpty) {
      return ErrorStateView(
        message: history.errorMessage!,
        onRetry: () => history.fetchHistory(refresh: true),
      );
    }

    if (history.items.isEmpty) {
      return EmptyStateView(
        icon: Icons.history_rounded,
        title: context.tr('noHistory'),
        description: context.tr('noRecentActivity'),
        actionLabel: context.tr('analyzeExercise'),
        onAction: () {
          Navigator.pushNamed(context, AppRoutes.exerciseSelection);
        },
      );
    }

    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: history.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = history.items[index];
        final score = item.score;
        final exerciseName = item.exercise;
        final reps = item.repCount;

        Color scoreColor;
        if (score >= 85) {
          scoreColor = AppColors.scoreExcellent;
        } else if (score >= 75) {
          scoreColor = AppColors.scoreGood;
        } else if (score >= 65) {
          scoreColor = AppColors.scoreModerate;
        } else {
          scoreColor = AppColors.scoreNeedsWork;
        }

        return AppCard(
          padding: const EdgeInsets.all(16),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.analysisDetail,
              arguments: item,
            );
          },
          child: Row(
            children: [
              // Score badge Enclosure
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedMd,
                  border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: scoreColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PTS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          exerciseName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$reps reps • ${Formatters.scoreLabel(score)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatDate(item.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.darkTextMuted),
            ],
          ),
        );
      },
    );
  }
}
