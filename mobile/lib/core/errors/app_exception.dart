/// Base exception class for all AI Gym Coach errors.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

/// Thrown when device has no network connectivity or request times out.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection. Please check your network and try again.'])
      : super(code: 'NETWORK_ERROR');
}

/// Thrown when backend returns 5xx error or unexpected server failure.
class ServerException extends AppException {
  final int? statusCode;
  const ServerException([super.message = 'Something went wrong on the server. Please try again later.', this.statusCode])
      : super(code: 'SERVER_ERROR', details: statusCode);
}

/// Thrown when JWT token is invalid, missing, or expired (401).
class AuthenticationException extends AppException {
  const AuthenticationException([super.message = 'Your session has expired. Please sign in again.'])
      : super(code: 'UNAUTHORIZED');
}

/// Thrown when input validation fails (e.g., 422 Unprocessable Entity or local form check).
class ValidationException extends AppException {
  final List<String> errors;
  ValidationException(super.message, {this.errors = const []})
      : super(code: 'VALIDATION_ERROR', details: errors);
}

/// Thrown when video upload fails due to size, format, or connection interruption.
class VideoUploadException extends AppException {
  const VideoUploadException([super.message = 'Unable to upload this video. Ensure it is MP4/MOV and under 60s.'])
      : super(code: 'UPLOAD_ERROR');
}

/// Thrown when video analysis pipeline encounters an error.
class AnalysisException extends AppException {
  const AnalysisException([super.message = 'Analysis could not be completed. Please try with another video.'])
      : super(code: 'ANALYSIS_ERROR');
}

/// Thrown when a requested resource is not found (404).
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Requested resource was not found.'])
      : super(code: 'NOT_FOUND');
}
