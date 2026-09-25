import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// Production implementation of [AuthRepository] communicating with FastAPI backend.
class RemoteAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  final ISecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  RemoteAuthRepository({
    required ApiClient apiClient,
    required ISecureStorageService secureStorage,
    required LocalStorageService localStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage,
        _localStorage = localStorage;

  @override
  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: {
        'email': email.trim(),
        'password': password,
      },
      requiresAuth: false,
    );

    final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);
    if (authResponse.accessToken != null) {
      await _secureStorage.saveToken(authResponse.accessToken!);
      // Fetch full profile to cache
      try {
        final profile = await getProfile();
        await _localStorage.saveCachedUser(profile.toJson());
      } catch (_) {}
    }
    return authResponse;
  }

  @override
  Future<AuthResponse> register(String fullName, String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      body: {
        'full_name': fullName.trim(),
        'email': email.trim(),
        'password': password,
      },
      requiresAuth: false,
    );

    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.userProfile);
    Map<String, dynamic> data = response is Map<String, dynamic> ? response : {};
    if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
      data = data['data'] as Map<String, dynamic>;
    }
    final user = UserModel.fromJson(data);
    await _localStorage.saveCachedUser(user.toJson());
    return user;
  }

  @override
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    final response = await _apiClient.put(
      ApiEndpoints.userProfile,
      body: updatedUser.toJson(),
    );
    Map<String, dynamic> data = response is Map<String, dynamic> ? response : {};
    if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
      data = data['data'] as Map<String, dynamic>;
    }
    final user = UserModel.fromJson(data);
    await _localStorage.saveCachedUser(user.toJson());
    return user;
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteToken();
    await _localStorage.clearCachedUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final json = await _localStorage.getCachedUser();
    if (json != null) {
      return UserModel.fromJson(json);
    }
    return null;
  }
}
