import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

/// State controller for authentication and user profile.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Checks if token exists and loads cached user on app start.
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        _currentUser = await _authRepository.getCachedUser();
        _status = AuthStatus.authenticated;
        // Refresh profile in background
        _refreshProfileSilently();
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshProfileSilently() async {
    try {
      final freshProfile = await _authRepository.getProfile();
      _currentUser = freshProfile;
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(email, password);
      if (response.success) {
        _currentUser = response.user ?? await _authRepository.getProfile();
        _status = AuthStatus.authenticated;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed. Please check your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during login.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.register(fullName, email, password);
      _isLoading = false;
      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Registration failed. Please check input values.';
        notifyListeners();
        return false;
      }
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during registration.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.updateProfile(updatedUser);
      _currentUser = result;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update profile.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
    } catch (_) {}

    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _isLoading = false;
    notifyListeners();
  }
}
