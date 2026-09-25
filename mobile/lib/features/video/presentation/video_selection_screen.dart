import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/constants/app_constants.dart';
import 'package:ai_coach_gym/core/routing/app_routes.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_radius.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/shared/widgets/app_badge.dart';
import 'package:ai_coach_gym/shared/widgets/app_card.dart';
import 'package:ai_coach_gym/features/analysis/presentation/controllers/analysis_provider.dart';
import 'package:ai_coach_gym/features/video/data/models/video_model.dart';

class VideoSelectionScreen extends StatefulWidget {
  const VideoSelectionScreen({super.key});

  @override
  State<VideoSelectionScreen> createState() => _VideoSelectionScreenState();
}

class _VideoSelectionScreenState extends State<VideoSelectionScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isValidating = false;
  String? _validationError;

  Future<void> _pickVideo(ImageSource source) async {
    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    try {
      final XFile? file = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: AppConstants.maxVideoDurationSeconds),
      );

      if (file == null) {
        setState(() => _isValidating = false);
        return;
      }

      final fileSizeBytes = await file.length();
      const durationSecs = 20;

      final validation = VideoModel.validateVideo(
        filePath: file.path,
        fileSizeBytes: fileSizeBytes,
        durationSeconds: durationSecs,
      );

      if (validation != null) {
        setState(() {
          _validationError = validation;
          _isValidating = false;
        });
        return;
      }

      if (!mounted) return;
      final analysisProvider = context.read<AnalysisProvider>();
      final exerciseType = analysisProvider.selectedExercise?.id ?? 'squat';

      final video = VideoModel(
        path: file.path,
        fileName: file.name,
        fileSizeBytes: fileSizeBytes,
        durationSeconds: durationSecs,
        exerciseType: exerciseType,
        selectedAt: DateTime.now(),
      );

      analysisProvider.setVideo(video);
      setState(() => _isValidating = false);

      Navigator.pushNamed(context, AppRoutes.videoPreview);
    } catch (e) {
      setState(() {
        _validationError = 'Error accessing video file: ${e.toString()}';
        _isValidating = false;
      });
    }
  }

  void _loadDemoVideo() {
    final analysisProvider = context.read<AnalysisProvider>();
    final exerciseType = analysisProvider.selectedExercise?.id ?? 'squat';

    final demoVideo = VideoModel(
      path: 'sample_workout_${exerciseType}_rep_set.mp4',
      fileName: 'sample_workout_${exerciseType}_rep_set.mp4',
      fileSizeBytes: 18 * 1024 * 1024,
      durationSeconds: 28,
      exerciseType: exerciseType,
      selectedAt: DateTime.now(),
    );

    analysisProvider.setVideo(demoVideo);
    Navigator.pushNamed(context, AppRoutes.videoPreview);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exercise = context.watch<AnalysisProvider>().selectedExercise;

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise != null ? '${exercise.name} Video' : 'Select Video'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBadge(
                label: 'Phase 02 • Footage Capture',
                icon: Icons.videocam_rounded,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Record or Select\nExercise Video',
                style: AppTextStyles.h1(isDark: isDark),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Upload a video up to ${AppConstants.maxVideoDurationSeconds} seconds. For best accuracy, ensure full body visibility and good lighting.',
                style: AppTextStyles.bodyMedium(isDark: isDark),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Validation Error Banner
              if (_validationError != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedLg,
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Camera Recording Option
              AppCard(
                key: const Key('record_camera_card'),
                onTap: _isValidating ? null : () => _pickVideo(ImageSource.camera),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.15),
                        borderRadius: AppRadius.roundedMd,
                      ),
                      child: Icon(
                        Icons.videocam_rounded,
                        size: 28,
                        color: isDark ? AppColors.primary : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Record New Video', style: AppTextStyles.h3(isDark: isDark)),
                          const SizedBox(height: 2),
                          Text(
                            'Open camera to record set directly (up to 60s)',
                            style: AppTextStyles.bodySmall(isDark: isDark),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.darkTextMuted),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Gallery Picker Option
              AppCard(
                key: const Key('select_gallery_card'),
                onTap: _isValidating ? null : () => _pickVideo(ImageSource.gallery),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.secondary : AppColors.secondaryDark).withValues(alpha: 0.15),
                        borderRadius: AppRadius.roundedMd,
                      ),
                      child: Icon(
                        Icons.photo_library_rounded,
                        size: 28,
                        color: isDark ? AppColors.secondary : AppColors.secondaryDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Choose from Gallery', style: AppTextStyles.h3(isDark: isDark)),
                          const SizedBox(height: 2),
                          Text(
                            'Select existing MP4 or MOV file from storage',
                            style: AppTextStyles.bodySmall(isDark: isDark),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.darkTextMuted),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Quick Sample Workout Video
              AppCard(
                key: const Key('select_sample_video_card'),
                onTap: _isValidating ? null : _loadDemoVideo,
                padding: const EdgeInsets.all(16),
                borderColor: isDark ? AppColors.tertiary.withValues(alpha: 0.3) : AppColors.tertiary.withValues(alpha: 0.2),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.15),
                        borderRadius: AppRadius.roundedMd,
                      ),
                      child: const Icon(Icons.play_circle_outline_rounded, size: 24, color: AppColors.tertiary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Use Test Workout Clip', style: AppTextStyles.h3(isDark: isDark)),
                          const SizedBox(height: 2),
                          Text(
                            'Load pre-calibrated set for quick UI evaluation',
                            style: AppTextStyles.bodySmall(isDark: isDark),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.tertiary),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Camera Guidelines & Angle Tips
              if (exercise != null && exercise.cameraGuidelines.isNotEmpty) ...[
                Text('Camera Guidelines for ${exercise.name}', style: AppTextStyles.h3(isDark: isDark)),
                const SizedBox(height: AppSpacing.sm),
                ...exercise.cameraGuidelines.map((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.secondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: AppTextStyles.bodyMedium(isDark: isDark),
                          ),
                        ),
                      ],
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
}
