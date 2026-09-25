import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/localization/app_localizations.dart';
import 'package:ai_coach_gym/core/routing/app_routes.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_radius.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/core/utils/formatters.dart';
import 'package:ai_coach_gym/shared/widgets/app_badge.dart';
import 'package:ai_coach_gym/shared/widgets/app_button.dart';
import 'package:ai_coach_gym/shared/widgets/app_card.dart';
import 'package:ai_coach_gym/features/analysis/presentation/controllers/analysis_provider.dart';
import 'package:ai_coach_gym/features/auth/presentation/controllers/auth_provider.dart';
import 'package:ai_coach_gym/features/exercise/data/models/exercise_model.dart';
import 'package:ai_coach_gym/features/exercise/presentation/controllers/exercise_provider.dart';
import 'package:ai_coach_gym/features/history/presentation/controllers/history_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<HistoryProvider>().fetchHistory();
      } catch (_) {}
      try {
        Provider.of<ExerciseProvider?>(context, listen: false)?.loadExercises();
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final history = context.watch<HistoryProvider>();
    List<ExerciseModel> exercises = ExerciseModel.supportedExercises;
    try {
      final ep = Provider.of<ExerciseProvider?>(context);
      if (ep != null) exercises = ep.exercises;
    } catch (_) {}
    final user = auth.currentUser;

    // Real dynamic user display name
    final String displayName = (user != null && user.fullName.trim().isNotEmpty)
        ? user.fullName
        : (user != null && user.email.trim().isNotEmpty)
            ? user.email.split('@').first
            : 'Athlete';

    // Real calculated statistics from actual backend history
    final hasHistory = history.items.isNotEmpty;
    final int totalReps = history.items.fold<int>(
      0,
      (sum, item) => sum + (item.result?.repCount ?? item.repCount),
    );
    final int avgScore = hasHistory
        ? (history.items.fold<int>(0, (sum, item) => sum + (item.result?.score ?? item.score)) ~/ history.items.length)
        : 0;

    final recentItems = history.items.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final ep = Provider.of<ExerciseProvider?>(context, listen: false);
            await history.fetchHistory(refresh: true);
            await ep?.loadExercises();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. User Header & Real Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('helloAthlete'),
                          style: AppTextStyles.eyebrow(isDark: isDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayName,
                          style: AppTextStyles.h2(isDark: isDark),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.settings);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          size: 22,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // 2. HERO BANNER: Primary Action
                AppCard(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                  borderColor: isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primaryDark.withValues(alpha: 0.25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppBadge(
                            label: context.tr('heroBadge'),
                            icon: Icons.auto_awesome_rounded,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              context.tr('ready'),
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        context.tr('heroTitle'),
                        style: AppTextStyles.h1(isDark: isDark),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.tr('heroSubtitle'),
                        style: AppTextStyles.bodyMedium(isDark: isDark),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        key: const Key('home_analyze_cta_button'),
                        label: context.tr('analyzeExercise'),
                        trailingIcon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.exerciseSelection);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // 3. Quick Stats Bento Row (Real Dynamic Metrics)
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('averageForm'),
                              style: AppTextStyles.eyebrow(isDark: isDark),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  hasHistory ? '$avgScore' : '--',
                                  style: AppTextStyles.metricValue(isDark: isDark),
                                ),
                                const SizedBox(width: 4),
                                const Text('/100', style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
                              ],
                            ),
                            Text(
                              hasHistory ? Formatters.scoreLabel(avgScore) : context.tr('noData'),
                              style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('repsEvaluated'),
                              style: AppTextStyles.eyebrow(isDark: isDark),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$totalReps',
                              style: AppTextStyles.metricValue(isDark: isDark).copyWith(
                                color: isDark ? AppColors.secondary : AppColors.secondaryDark,
                              ),
                            ),
                            Text(
                              '${history.items.length} ${context.tr('sessionsLogged')}',
                              style: AppTextStyles.bodySmall(isDark: isDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // 4. Supported Exercises Grid (Real Backend Loaded)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.tr('supportedExercises'), style: AppTextStyles.h2(isDark: isDark)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.exerciseSelection);
                      },
                      child: Text(
                        context.tr('viewAll'),
                        style: TextStyle(
                          color: isDark ? AppColors.primary : AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: exercises.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return SizedBox(
                        width: 200,
                        child: AppCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () {
                            context.read<AnalysisProvider>().selectExercise(exercise);
                            Navigator.pushNamed(context, AppRoutes.videoSelection);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(exercise.icon, size: 20, color: isDark ? AppColors.primary : AppColors.primaryDark),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.darkTextMuted),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    exercise.techniqueFocus,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // 5. Recent Analyses Section (Real Backend History)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.tr('recentActivity'), style: AppTextStyles.h2(isDark: isDark)),
                    if (recentItems.isNotEmpty)
                      Text(
                        '${recentItems.length} recent',
                        style: AppTextStyles.bodySmall(isDark: isDark),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                if (recentItems.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.video_collection_outlined, size: 36, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          const SizedBox(height: 10),
                          Text(
                            context.tr('noData'),
                            style: AppTextStyles.h3(isDark: isDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('noRecentActivity'),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall(isDark: isDark),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = recentItems[index];
                      final score = item.result?.score ?? item.score;
                      final isGood = score >= 80;

                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.analysisDetail,
                            arguments: item,
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: (isGood ? AppColors.scoreGood : AppColors.scoreModerate).withValues(alpha: 0.12),
                                borderRadius: AppRadius.roundedMd,
                              ),
                              child: Center(
                                child: Text(
                                  '$score',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isGood ? AppColors.scoreGood : AppColors.scoreModerate,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.result?.exercise ?? item.exercise,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.result?.repCount ?? item.repCount} reps • ${Formatters.formatDateShort(item.createdAt)}',
                                    style: AppTextStyles.bodySmall(isDark: isDark),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.darkTextMuted),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
