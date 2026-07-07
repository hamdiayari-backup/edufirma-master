import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _userNameKey = 'user_name';
  static const String _currencyKey = 'currency';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _languageKey = 'language';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Access Token
  Future<void> setAccessToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_accessTokenKey, token);
  }

  Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_accessTokenKey);
  }

  Future<void> removeAccessToken() async {
    final prefs = await _prefs;
    await prefs.remove(_accessTokenKey);
  }

  // User Name
  Future<void> setUserName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_userNameKey, name);
  }

  Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_userNameKey);
  }

  // Currency
  Future<void> setCurrency(String currency) async {
    final prefs = await _prefs;
    await prefs.setString(_currencyKey, currency);
  }

  Future<String?> getCurrency() async {
    final prefs = await _prefs;
    return prefs.getString(_currencyKey);
  }

  // First Launch
  Future<void> setFirstLaunch(bool isFirst) async {
    final prefs = await _prefs;
    await prefs.setBool(_isFirstLaunchKey, isFirst);
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await _prefs;
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  // Language
  Future<void> setLanguage(String language) async {
    final prefs = await _prefs;
    await prefs.setString(_languageKey, language);
  }

  Future<String?> getLanguage() async {
    final prefs = await _prefs;
    return prefs.getString(_languageKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_userNameKey);
  }
}
