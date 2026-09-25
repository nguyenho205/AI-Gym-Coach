import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/presentation/controllers/auth_provider.dart';

/// Splash Screen initializing state, checking onboarding and session tokens.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Artificial slight delay for smooth visual presentation
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final localStorage = context.read<LocalStorageService>();
    final authProvider = context.read<AuthProvider>();

    final hasCompletedOnboarding = await localStorage.isOnboardingCompleted();
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    if (!hasCompletedOnboarding) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Double-bezel Machined Logo Container
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primaryDark.withValues(alpha: 0.08),
                    borderRadius: AppRadius.roundedXxl,
                    border: Border.all(
                      color: isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primaryDark.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isDark ? AppColors.primary : AppColors.primaryDark,
                          AppColors.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      size: 42,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  AppConstants.appName,
                  style: AppTextStyles.h1(isDark: isDark),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'AI Technique & Biomechanical Coach',
                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.primary : AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
