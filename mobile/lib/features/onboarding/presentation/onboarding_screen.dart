import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _slides = const [
    _OnboardingItem(
      badge: 'Step 01 • Capture',
      title: 'Record or Upload\nExercise Video',
      description:
          'Set up your phone camera and record a set of Squats, Push-ups, or Bicep Curls. We support direct camera capture or gallery upload up to 60 seconds.',
      icon: Icons.videocam_rounded,
      accentColor: AppColors.primary,
    ),
    _OnboardingItem(
      badge: 'Step 02 • Biomechanics',
      title: 'Computer Vision\nAnalyzes Movement',
      description:
          'Our AI processing pipeline tracks 33 anatomical landmarks across each frame, evaluating joint angles, spinal curvature, and movement cadence.',
      icon: Icons.accessibility_new_rounded,
      accentColor: AppColors.secondary,
    ),
    _OnboardingItem(
      badge: 'Step 03 • Actionable Coaching',
      title: 'Receive Real-time\nTechnique Feedback',
      description:
          'Get an objective form score, rep count, detected biomechanical issues, and corrective cues tailored to enhance your performance safely.',
      icon: Icons.insights_rounded,
      accentColor: AppColors.tertiary,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final localStorage = context.read<LocalStorageService>();
    await localStorage.setOnboardingCompleted(true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(
              'Skip',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Enclosed Visual Icon Frame
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: slide.accentColor.withValues(alpha: 0.1),
                            borderRadius: AppRadius.roundedXxl,
                            border: Border.all(
                              color: slide.accentColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Icon(
                              slide.icon,
                              size: 56,
                              color: slide.accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppBadge(
                          label: slide.badge,
                          textColor: slide.accentColor,
                          backgroundColor: slide.accentColor.withValues(alpha: 0.12),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1(isDark: isDark),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                            height: 1.55,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pagination Dots + Next / Get Started CTA
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? (isDark ? AppColors.primary : AppColors.primaryDark)
                              : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    trailingIcon: Icons.arrow_forward_rounded,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final String badge;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const _OnboardingItem({
    required this.badge,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
