import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/storage/local_storage.dart';

class AppLanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('fr');
  String _currentLanguage = 'fr';

  Locale get currentLocale => _currentLocale;
  String get currentLanguage => _currentLanguage;

  bool get isRTL => _currentLanguage == 'ar';

  /// Initialize language from storage
  Future<void> init() async {
    final storage = LocalStorage();
    final savedLang = await storage.getLanguage();
    if (savedLang != null) {
      _currentLanguage = savedLang;
      _currentLocale = Locale(savedLang);
      notifyListeners();
    }
  }

  /// Change language
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      _currentLocale = Locale(languageCode);
      
      final storage = LocalStorage();
      await storage.setLanguage(languageCode);
      
      notifyListeners();
    }
  }

  /// Toggle between French and Arabic
  Future<void> toggleLanguage() async {
    final newLang = _currentLanguage == 'fr' ? 'ar' : 'fr';
    await setLanguage(newLang);
  }
}






