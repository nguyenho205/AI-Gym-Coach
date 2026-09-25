import '../models/user_model.dart';
import '../models/auth_response_model.dart';

/// Abstract contract for user authentication and account management.
abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String fullName, String email, String password);
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UserModel updatedUser);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<UserModel?> getCachedUser();
}
