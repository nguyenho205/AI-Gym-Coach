import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/routing/app_routes.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/shared/widgets/app_badge.dart';
import 'package:ai_coach_gym/shared/widgets/app_card.dart';
import 'package:ai_coach_gym/shared/widgets/error_state_view.dart';
import 'package:ai_coach_gym/features/analysis/presentation/controllers/analysis_provider.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final List<String> _stages = const [
    'Uploading video to processing queue',
    'Preparing biomechanical pipeline',
    'Detecting anatomical movement',
    'Analyzing joint angles & technique',
    'Generating actionable coaching feedback',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAnalysis();
    });
  }

  Future<void> _runAnalysis() async {
    final provider = context.read<AnalysisProvider>();
    final success = await provider.startAnalysis();

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.result);
    }
  }

  int _getActiveStageIndex(double progress) {
    if (progress < 0.25) return 0;
    if (progress < 0.45) return 1;
    if (progress < 0.70) return 2;
    if (progress < 0.90) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AnalysisProvider>();
    final exercise = provider.selectedExercise;
    final progress = provider.progress;
    final activeStage = _getActiveStageIndex(progress);

    if (provider.status == AnalysisStepStatus.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Interrupted')),
        body: ErrorStateView(
          title: 'Analysis Incomplete',
          message: provider.errorMessage ?? 'Unable to finish biomechanical analysis.',
          retryLabel: 'Retry Pipeline',
          onRetry: _runAnalysis,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${exercise?.name ?? "Exercise"} Evaluation'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    const AppBadge(
                      label: 'Biomechanical Analysis',
                      icon: Icons.sports_gymnastics_rounded,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Central Animated Progress Radial
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                              backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? AppColors.primary : AppColors.primaryDark,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(progress * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.0,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                'PROCESSED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    Text(
                      provider.currentStage,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h2(isDark: isDark),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Please keep the app open while our pipeline evaluates your set.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall(isDark: isDark),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // 5-Stage Step Progress Visualizer
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Column(
                        children: List.generate(_stages.length, (index) {
                          final isCompleted = index < activeStage;
                          final isCurrent = index == activeStage;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? AppColors.success
                                        : (isCurrent
                                            ? (isDark ? AppColors.primary : AppColors.primaryDark)
                                            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: isCompleted
                                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                                      : (isCurrent
                                          ? const Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                              ),
                                            )
                                          : null),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    _stages[index],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                      color: isCompleted || isCurrent
                                          ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                          : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

              // Cancel button
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      provider.reset();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel Processing',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
