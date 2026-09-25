import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// Development/testing mock implementation of [AuthRepository].
/// Clearly isolated behind the repository abstraction.
class MockAuthRepository implements AuthRepository {
  final ISecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final bool simulatedDelay;

  UserModel _currentUser = const UserModel(
    id: 1,
    fullName: 'Alex Morgan',
    email: 'alex.morgan@example.com',
    gender: 'Male',
    heightCm: 178.0,
    weightKg: 74.5,
    avatarUrl: null,
  );

  MockAuthRepository({
    required ISecureStorageService secureStorage,
    required LocalStorageService localStorage,
    this.simulatedDelay = true,
  })  : _secureStorage = secureStorage,
        _localStorage = localStorage;

  @override
  Future<AuthResponse> login(String email, String password) async {
    if (simulatedDelay) {
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (email.contains('error@')) {
      throw const AuthenticationException('Invalid credentials. Please verify your email and password.');
    }

    _currentUser = _currentUser.copyWith(email: email);
    const mockToken = 'mock_jwt_token_for_testing';
    await _secureStorage.saveToken(mockToken);
    await _localStorage.saveCachedUser(_currentUser.toJson());

    return AuthResponse(
      success: true,
      message: 'Demo login successful',
      accessToken: mockToken,
      user: _currentUser,
    );
  }

  @override
  Future<AuthResponse> register(String fullName, String email, String password) async {
    if (simulatedDelay) {
      await Future.delayed(const Duration(milliseconds: 700));
    }

    if (email.contains('exists@')) {
      throw ValidationException('An account with this email address already exists.');
    }

    _currentUser = UserModel(
      id: 2,
      fullName: fullName,
      email: email,
      gender: 'Unspecified',
      heightCm: 175.0,
      weightKg: 70.0,
    );

    return const AuthResponse(
      success: true,
      message: 'Registration successful. You may now sign in.',
    );
  }

  @override
  Future<UserModel> getProfile() async {
    if (simulatedDelay) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return _currentUser;
  }

  @override
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    if (simulatedDelay) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    _currentUser = updatedUser;
    await _localStorage.saveCachedUser(_currentUser.toJson());
    return _currentUser;
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
    return _currentUser;
  }
}
