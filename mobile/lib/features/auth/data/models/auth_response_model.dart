import 'user_model.dart';

/// Response payload from `/auth/login` and `/auth/register`.
class AuthResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? tokenType;
  final UserModel? user;

  const AuthResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.tokenType = 'Bearer',
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    UserModel? userObj;
    if (json['user'] is Map<String, dynamic>) {
      userObj = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    } else if (json['data'] is Map<String, dynamic> && (json['data'] as Map<String, dynamic>)['user'] is Map<String, dynamic>) {
      userObj = UserModel.fromJson((json['data'] as Map<String, dynamic>)['user'] as Map<String, dynamic>);
    }

    return AuthResponse(
      success: json['success'] as bool? ?? (json['access_token'] != null),
      message: json['message'] as String?,
      accessToken: json['access_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      user: userObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'access_token': accessToken,
      'token_type': tokenType,
      'user': user?.toJson(),
    };
  }
}
