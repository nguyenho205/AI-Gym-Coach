/// Global application constants for AI-Coach-Gym.
class AppConstants {
  AppConstants._();

  static const String appName = 'AI Gym Coach';
  static const String appTagline = 'Smart Computer Vision Fitness Technique Analyzer';
  static const String appVersion = '1.0.0';

  // Video Constraints
  static const int maxVideoDurationSeconds = 60;
  static const int maxVideoFileSizeBytes = 100 * 1024 * 1024; // 100 MB
  static const List<String> supportedVideoFormats = ['mp4', 'mov'];

  // Storage Keys
  static const String tokenKey = 'ai_gym_auth_token';
  static const String userKey = 'ai_gym_cached_user';
  static const String onboardingKey = 'ai_gym_onboarding_completed';
  static const String themeModeKey = 'ai_gym_theme_mode';
  static const String baseUrlKey = 'ai_gym_api_base_url';
  static const String languageKey = 'ai_gym_selected_language';
  static const String defaultLanguage = 'en';

  // Default Network Configuration
  static const String defaultBaseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator localhost
  static const String fallbackLocalUrl = 'http://localhost:8000/api/v1';
  static const Duration requestTimeout = Duration(seconds: 45);
  static const Duration uploadTimeout = Duration(seconds: 120);

  // Demo / Dev Mode Flag
  /// When true, [MockAnalysisRepository] can be used if backend is unreachable
  /// or for offline UI development testing.
  static const bool allowDemoRepository = false;
}
