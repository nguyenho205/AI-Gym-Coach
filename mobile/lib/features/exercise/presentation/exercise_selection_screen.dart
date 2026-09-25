import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../analysis/presentation/controllers/analysis_provider.dart';
import '../data/models/exercise_model.dart';
import 'controllers/exercise_provider.dart';

class ExerciseSelectionScreen extends StatefulWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  State<ExerciseSelectionScreen> createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  ExerciseModel? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = context.read<AnalysisProvider>().selectedExercise;
      List<ExerciseModel> exercises = ExerciseModel.supportedExercises;
      try {
        final ep = Provider.of<ExerciseProvider?>(context, listen: false);
        if (ep != null) exercises = ep.exercises;
      } catch (_) {}

      if (mounted) {
        setState(() {
          _selected = current ?? (exercises.isNotEmpty ? exercises.first : null);
        });
      }
    });
  }

  void _onConfirm() {
    if (_selected == null) return;
    context.read<AnalysisProvider>().selectExercise(_selected!);
    Navigator.pushNamed(context, AppRoutes.videoSelection);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    List<ExerciseModel> exercises = ExerciseModel.supportedExercises;
    try {
      final ep = Provider.of<ExerciseProvider?>(context);
      if (ep != null) exercises = ep.exercises;
    } catch (_) {}

    if (_selected == null && exercises.isNotEmpty) {
      _selected = exercises.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('exerciseSelectionTitle')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: AppSpacing.pagePadding,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppBadge(
                      label: context.tr('heroBadge'),
                      icon: Icons.fitness_center_rounded,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.tr('whatTrainingToday'),
                    style: AppTextStyles.h1(isDark: isDark),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.tr('exerciseSelectionSubtitle'),
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Dynamic Exercise Cards from Database
                  ...exercises.map((exercise) {
                    final isChosen = _selected?.id == exercise.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: AppCard(
                        isSelected: isChosen,
                        padding: const EdgeInsets.all(16),
                        onTap: () {
                          setState(() => _selected = exercise);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: (isChosen
                                            ? (isDark ? AppColors.primary : AppColors.primaryDark)
                                            : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated))
                                        .withValues(alpha: isChosen ? 0.2 : 1.0),
                                    borderRadius: AppRadius.roundedMd,
                                    border: Border.all(
                                      color: isChosen
                                          ? (isDark ? AppColors.primary : AppColors.primaryDark)
                                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                    ),
                                  ),
                                  child: Icon(
                                    exercise.icon,
                                    size: 26,
                                    color: isChosen
                                        ? (isDark ? AppColors.primary : AppColors.primaryDark)
                                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        exercise.techniqueFocus,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.secondary : AppColors.secondaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isChosen)
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.primary : AppColors.primaryDark,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded, size: 16, color: Colors.black),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              exercise.shortDescription,
                              style: AppTextStyles.bodySmall(isDark: isDark),
                            ),
                            if (exercise.targetKeypoints.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: exercise.targetKeypoints.map((kp) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                                      ),
                                    ),
                                    child: Text(
                                      kp,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Confirm Selection Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AppButton(
                key: const Key('exercise_continue_button'),
                label: '${context.tr('continue')} (${_selected?.name ?? ""})',
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: _selected != null ? _onConfirm : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
