import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_coach_gym/core/routing/app_routes.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/core/utils/formatters.dart';
import 'package:ai_coach_gym/shared/widgets/app_button.dart';
import 'package:ai_coach_gym/shared/widgets/app_card.dart';
import 'package:ai_coach_gym/features/analysis/presentation/controllers/analysis_provider.dart';

class VideoPreviewScreen extends StatefulWidget {
  const VideoPreviewScreen({super.key});

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  bool _isPlaying = false;

  void _onStartAnalysis() {
    Navigator.pushNamed(context, AppRoutes.processing);
  }

  void _onReplaceVideo() {
    context.read<AnalysisProvider>().clearVideo();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analysisProvider = context.watch<AnalysisProvider>();
    final video = analysisProvider.selectedVideo;
    final exercise = analysisProvider.selectedExercise;

    if (video == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Preview')),
        body: const Center(child: Text('No video selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Video'),
        actions: [
          IconButton(
            tooltip: 'Replace video',
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: _onReplaceVideo,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video Viewport Card
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              color: isDark ? const Color(0xFF0F141F) : const Color(0xFF1E293B),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      exercise?.icon ?? Icons.fitness_center_rounded,
                                      size: 56,
                                      color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${exercise?.name ?? "Exercise"} Set Ready',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Play/Pause Overlay Button
                            GestureDetector(
                              onTap: () {
                                setState(() => _isPlaying = !_isPlaying);
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24, width: 1.5),
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Badges overlay
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  exercise?.name.toUpperCase() ?? 'EXERCISE',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  Formatters.formatDuration(video.durationSeconds),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // File Information Breakdown
                    Text('Clip Metadata', style: AppTextStyles.h2(isDark: isDark)),
                    const SizedBox(height: AppSpacing.sm),

                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildMetaRow('File Name', video.fileName, isDark),
                          const Divider(height: 20),
                          _buildMetaRow('File Size', Formatters.formatBytes(video.fileSizeBytes), isDark),
                          const Divider(height: 20),
                          _buildMetaRow('Duration', '${video.durationSeconds} seconds', isDark),
                          const Divider(height: 20),
                          _buildMetaRow('Movement', exercise?.name ?? 'Unknown', isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Pipeline Target Notice
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 20,
                            color: isDark ? AppColors.primary : AppColors.primaryDark,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Next, the backend will process skeletal keypoints to calculate depth, alignment, and reps.',
                              style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  AppButton(
                    key: const Key('start_analysis_button'),
                    label: 'Start AI Analysis',
                    trailingIcon: Icons.bolt_rounded,
                    onPressed: _onStartAnalysis,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: _onReplaceVideo,
                      child: Text(
                        'Choose Different Video',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium(isDark: isDark)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
