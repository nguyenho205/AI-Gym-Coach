import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Abstract interface for secure key-value storage.
abstract class ISecureStorageService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> clearAll();
}

/// Production implementation of [ISecureStorageService] using [FlutterSecureStorage].
/// Falls back to an internal memory cache if native secure storage throws (e.g. in unit tests).
class SecureStorageService implements ISecureStorageService {
  final FlutterSecureStorage? _storage;
  final Map<String, String> _memoryFallback = {};
  final bool isInMemory;

  SecureStorageService({FlutterSecureStorage? storage, this.isInMemory = false})
      : _storage = isInMemory ? null : (storage ?? const FlutterSecureStorage());

  @override
  Future<void> saveToken(String token) async {
    if (isInMemory || _storage == null) {
      _memoryFallback[AppConstants.tokenKey] = token;
      return;
    }
    try {
      await _storage.write(key: AppConstants.tokenKey, value: token);
    } catch (_) {
      _memoryFallback[AppConstants.tokenKey] = token;
    }
  }

  @override
  Future<String?> getToken() async {
    if (isInMemory || _storage == null) {
      return _memoryFallback[AppConstants.tokenKey];
    }
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token != null) return token;
    } catch (_) {}
    return _memoryFallback[AppConstants.tokenKey];
  }

  @override
  Future<void> deleteToken() async {
    if (isInMemory || _storage == null) {
      _memoryFallback.remove(AppConstants.tokenKey);
      return;
    }
    try {
      await _storage.delete(key: AppConstants.tokenKey);
    } catch (_) {}
    _memoryFallback.remove(AppConstants.tokenKey);
  }

  @override
  Future<void> clearAll() async {
    if (isInMemory || _storage == null) {
      _memoryFallback.clear();
      return;
    }
    try {
      await _storage.deleteAll();
    } catch (_) {}
    _memoryFallback.clear();
  }
}
