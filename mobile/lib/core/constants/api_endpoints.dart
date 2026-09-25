/// Centralized API endpoint paths matching `docs/api_design.md`.
class ApiEndpoints {
  ApiEndpoints._();

  // Authentication
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // User Profile
  static const String userProfile = '/users/profile';

  // Video Management
  static const String videoUpload = '/videos/upload';
  static const String videos = '/videos';
  static String videoDetail(int videoId) => '/videos/$videoId';

  // Analysis
  static const String analysis = '/analysis';
  static String analysisDetail(int analysisId) => '/analysis/$analysisId';

  // History
  static const String history = '/history';
  static String historyItem(int analysisId) => '/history/$analysisId';
}
