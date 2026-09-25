import 'package:flutter/widgets.dart';
import '../storage/local_storage_service.dart';
import 'app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  Locale _locale = const Locale('en');

  LocaleProvider({required LocalStorageService storage}) : _storage = storage {
    _loadSavedLanguage();
  }

  Locale get locale => _locale;
  AppLanguage get currentLanguage => AppLanguage.fromCode(_locale.languageCode);

  Future<void> _loadSavedLanguage() async {
    try {
      final code = await _storage.getLanguageCode();
      _locale = Locale(code);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_locale.languageCode == language.code) return;
    _locale = Locale(language.code);
    await _storage.setLanguageCode(language.code);
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    await _storage.setLanguageCode(newLocale.languageCode);
    notifyListeners();
  }
}
