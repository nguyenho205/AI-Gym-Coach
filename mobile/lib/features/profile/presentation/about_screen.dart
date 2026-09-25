import 'package:flutter/material.dart';
import 'package:ai_coach_gym/core/constants/app_constants.dart';
import 'package:ai_coach_gym/core/theme/app_colors.dart';
import 'package:ai_coach_gym/core/theme/app_spacing.dart';
import 'package:ai_coach_gym/core/theme/app_text_styles.dart';
import 'package:ai_coach_gym/shared/widgets/app_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('About AI-Coach-Gym')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isDark ? AppColors.primary : AppColors.primaryDark,
                            AppColors.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.fitness_center_rounded, size: 40, color: Colors.black),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(AppConstants.appName, style: AppTextStyles.h1(isDark: isDark)),
                    const SizedBox(height: 2),
                    Text(
                      'Version ${AppConstants.appVersion}',
                      style: AppTextStyles.bodySmall(isDark: isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              Text('Project Mission', style: AppTextStyles.h2(isDark: isDark)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'AI-Coach-Gym is an intelligent computer vision mobile assistant designed to democratize high-level biomechanical coaching. By tracking 33 skeletal landmarks during multi-joint exercises, it identifies movement faults, prevents injury, and accelerates athletic development.',
                style: AppTextStyles.bodyMedium(isDark: isDark),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Planned Biomechanical Pipeline', style: AppTextStyles.h2(isDark: isDark)),
              const SizedBox(height: AppSpacing.sm),
              const AppCard(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Flutter Mobile Client', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('↓ HTTPS REST API', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                    Text('FastAPI Orchestration Gateway', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('↓ Internal Microservice', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                    Text('MediaPipe Pose Landmark Extractor (33 points)', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('↓ Spatial-Temporal Skeletons', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                    Text('ST-GCN Graph Convolutional Network', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('↓ Kinesiology Rule Engine', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                    Text('Technique Evaluation & Corrective Feedback', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Graduation Project Disclaimer', style: AppTextStyles.h2(isDark: isDark)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This mobile application is built as part of the AI-Coach-Gym graduation project. The AI pipeline is abstracted through a repository service layer, allowing plug-and-play integration with the trained ST-GCN model upon completion of Phase 2 dataset training.',
                style: AppTextStyles.bodySmall(isDark: isDark),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
