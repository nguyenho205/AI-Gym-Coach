import 'package:flutter/material.dart';
import '../../features/analysis/presentation/screens/analysis_detail_screen.dart';
import '../../features/analysis/presentation/screens/processing_screen.dart';
import '../../features/analysis/presentation/screens/result_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/exercise/presentation/exercise_selection_screen.dart';
import '../../features/home/presentation/main_shell_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/profile/presentation/about_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/video/presentation/video_preview_screen.dart';
import '../../features/video/presentation/video_selection_screen.dart';
import 'app_routes.dart';

/// Centralized route generator supporting named navigation and smooth transitions.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen(), settings);
      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);
      case AppRoutes.register:
        return _buildRoute(const RegisterScreen(), settings);
      case AppRoutes.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);
      case AppRoutes.main:
        return _buildRoute(const MainShellScreen(), settings);
      case AppRoutes.exerciseSelection:
        return _buildRoute(const ExerciseSelectionScreen(), settings);
      case AppRoutes.videoSelection:
        return _buildRoute(const VideoSelectionScreen(), settings);
      case AppRoutes.videoPreview:
        return _buildRoute(const VideoPreviewScreen(), settings);
      case AppRoutes.processing:
        return _buildRoute(const ProcessingScreen(), settings);
      case AppRoutes.result:
        return _buildRoute(const ResultScreen(), settings);
      case AppRoutes.analysisDetail:
        return _buildRoute(const AnalysisDetailScreen(), settings);
      case AppRoutes.editProfile:
        return _buildRoute(const EditProfileScreen(), settings);
      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen(), settings);
      case AppRoutes.about:
        return _buildRoute(const AboutScreen(), settings);
      default:
        return _buildRoute(
          Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.05, 0.0);
        const end = Offset.zero;
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: curve,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 260),
    );
  }
}
