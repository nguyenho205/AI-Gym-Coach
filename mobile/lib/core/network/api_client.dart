import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage_service.dart';

/// Centralized REST API client supporting standard HTTP verbs and multipart video upload.
class ApiClient {
  final http.Client _httpClient;
  final ISecureStorageService _secureStorage;
  String _baseUrl;

  ApiClient({
    http.Client? httpClient,
    required ISecureStorageService secureStorage,
    String baseUrl = AppConstants.defaultBaseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _secureStorage = secureStorage,
        _baseUrl = baseUrl;

  String get baseUrl => _baseUrl;
  void updateBaseUrl(String newUrl) {
    _baseUrl = newUrl;
  }

  /// Builds standardized headers with optional bearer token.
  Future<Map<String, String>> _buildHeaders({bool requiresAuth = true, String? contentType}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    if (requiresAuth) {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanBase = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final urlString = '$cleanBase$cleanEndpoint';
    final uri = Uri.parse(urlString);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())),
      );
    }
    return uri;
  }

  /// Executes GET request.
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      return await _httpClient.get(uri, headers: headers).timeout(AppConstants.requestTimeout);
    });
  }

  /// Executes POST request with JSON payload.
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint);
      final headers = await _buildHeaders(
        requiresAuth: requiresAuth,
        contentType: 'application/json',
      );
      final encodedBody = body != null ? jsonEncode(body) : null;
      return await _httpClient
          .post(uri, headers: headers, body: encodedBody)
          .timeout(AppConstants.requestTimeout);
    });
  }

  /// Executes PUT request with JSON payload.
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint);
      final headers = await _buildHeaders(
        requiresAuth: requiresAuth,
        contentType: 'application/json',
      );
      final encodedBody = body != null ? jsonEncode(body) : null;
      return await _httpClient
          .put(uri, headers: headers, body: encodedBody)
          .timeout(AppConstants.requestTimeout);
    });
  }

  /// Executes DELETE request.
  Future<dynamic> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    return _sendRequest(() async {
      final uri = _buildUri(endpoint);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      return await _httpClient.delete(uri, headers: headers).timeout(AppConstants.requestTimeout);
    });
  }

  /// Uploads video file via Multipart form-data matching API specs.
  /// Request fields:
  /// - `video`: video file
  /// - `exercise_type`: exercise identifier
  Future<dynamic> uploadMultipartVideo({
    required String endpoint,
    required String filePath,
    required String exerciseType,
    Map<String, String>? additionalFields,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest('POST', uri);

      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      request.fields['exercise_type'] = exerciseType;
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      // Check file exists
      final file = File(filePath);
      if (!await file.exists()) {
        throw const VideoUploadException('Video file not found at the selected path.');
      }

      final ext = filePath.split('.').last.toLowerCase();
      final mediaType = ext == 'mov' ? MediaType('video', 'quicktime') : MediaType('video', 'mp4');

      final multipartFile = await http.MultipartFile.fromPath(
        'video',
        filePath,
        contentType: mediaType,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(AppConstants.uploadTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('Upload timed out. Please check your network speed.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw VideoUploadException('Upload failed: ${e.toString()}');
    }
  }

  Future<dynamic> _sendRequest(Future<http.Response> Function() requestFn) async {
    try {
      final response = await requestFn();
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('Request timed out. Please try again.');
    } on http.ClientException {
      throw const NetworkException('Network connection error.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Unexpected error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic responseBody;

    if (response.body.isNotEmpty) {
      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {
        responseBody = response.body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    }

    String errorMessage = 'Request failed with status $statusCode';
    List<String> errorList = [];

    if (responseBody is Map<String, dynamic>) {
      if (responseBody['message'] is String) {
        errorMessage = responseBody['message'];
      } else if (responseBody['detail'] is String) {
        errorMessage = responseBody['detail'];
      }
      if (responseBody['errors'] is List) {
        errorList = (responseBody['errors'] as List).map((e) => e.toString()).toList();
      }
    }

    switch (statusCode) {
      case 400:
        throw ValidationException(errorMessage, errors: errorList);
      case 401:
        throw AuthenticationException(errorMessage.isNotEmpty ? errorMessage : 'Your session has expired.');
      case 403:
        throw const AppException('Access denied. You do not have permission for this action.');
      case 404:
        throw NotFoundException(errorMessage.isNotEmpty ? errorMessage : 'Resource not found.');
      case 422:
        throw ValidationException(errorMessage, errors: errorList);
      case 500:
      case 502:
      case 503:
        throw ServerException('Something went wrong on the server ($statusCode).', statusCode);
      default:
        throw AppException(errorMessage, code: 'HTTP_$statusCode');
    }
  }
}
