import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Centralized local key-value storage backed by [SharedPreferences].
class LocalStorageService {
  final SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryFallback = {};
  final bool isInMemory;

  LocalStorageService({SharedPreferences? prefs, this.isInMemory = false}) : _prefs = prefs;

  Future<SharedPreferences?> _getPrefs() async {
    if (isInMemory) return null;
    return _prefs ?? await SharedPreferences.getInstance();
  }

  // Onboarding
  Future<bool> isOnboardingCompleted() async {
    if (isInMemory) return _memoryFallback[AppConstants.onboardingKey] as bool? ?? false;
    final prefs = await _getPrefs();
    return prefs?.getBool(AppConstants.onboardingKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    if (isInMemory) {
      _memoryFallback[AppConstants.onboardingKey] = completed;
      return;
    }
    final prefs = await _getPrefs();
    await prefs?.setBool(AppConstants.onboardingKey, completed);
  }

  // Cached User Profile
  Future<Map<String, dynamic>?> getCachedUser() async {
    if (isInMemory) {
      final userJson = _memoryFallback[AppConstants.userKey] as String?;
      if (userJson == null) return null;
      try {
        return jsonDecode(userJson) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    final prefs = await _getPrefs();
    final userJson = prefs?.getString(AppConstants.userKey);
    if (userJson == null) return null;
    try {
      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCachedUser(Map<String, dynamic> userMap) async {
    if (isInMemory) {
      _memoryFallback[AppConstants.userKey] = jsonEncode(userMap);
      return;
    }
    final prefs = await _getPrefs();
    await prefs?.setString(AppConstants.userKey, jsonEncode(userMap));
  }

  Future<void> clearCachedUser() async {
    if (isInMemory) {
      _memoryFallback.remove(AppConstants.userKey);
      return;
    }
    final prefs = await _getPrefs();
    await prefs?.remove(AppConstants.userKey);
  }

  // Configurable API Base URL
  Future<String> getBaseUrl() async {
    if (isInMemory) {
      return _memoryFallback[AppConstants.baseUrlKey] as String? ?? AppConstants.defaultBaseUrl;
    }
    final prefs = await _getPrefs();
    return prefs?.getString(AppConstants.baseUrlKey) ?? AppConstants.defaultBaseUrl;
  }

  Future<void> setBaseUrl(String url) async {
    if (isInMemory) {
      _memoryFallback[AppConstants.baseUrlKey] = url;
      return;
    }
    final prefs = await _getPrefs();
    await prefs?.setString(AppConstants.baseUrlKey, url);
  }

  // Language Preferences
  Future<String> getLanguageCode() async {
    if (isInMemory) {
      return _memoryFallback[AppConstants.languageKey] as String? ?? AppConstants.defaultLanguage;
    }
    final prefs = await _getPrefs();
    return prefs?.getString(AppConstants.languageKey) ?? AppConstants.defaultLanguage;
  }

  Future<void> setLanguageCode(String code) async {
    if (isInMemory) {
      _memoryFallback[AppConstants.languageKey] = code;
      return;
    }
    final prefs = await _getPrefs();
    await prefs?.setString(AppConstants.languageKey, code);
  }

  // Clear all non-secure data
  Future<void> clearAll() async {
    if (isInMemory) {
      _memoryFallback.clear();
      return;
    }
    final prefs = await _getPrefs();
    await prefs?.clear();
  }
}
