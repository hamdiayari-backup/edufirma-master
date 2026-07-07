/// App Constants
class AppConstants {
  AppConstants._();
  
  // ============ App Info ============
  static const String appName = 'EduFirma';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Apprenez. Évoluez. Réussissez.';
  
  // ============ Shared Preferences Keys ============
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserId = 'user_id';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyLanguage = 'language';
  static const String keyCurrency = 'currency';
  static const String keyThemeMode = 'theme_mode';
  
  // ============ User Roles ============
  static const String roleUser = 'user';
  static const String roleTeacher = 'teacher';
  static const String roleOrganization = 'organization';
  
  // ============ Course Types ============
  static const String typeCourse = 'course';
  static const String typeLive = 'webinar';
  static const String typeText = 'text_lesson';
  
  // ============ Pagination ============
  static const int pageSize = 10;
  static const int initialPage = 0;
  
  // ============ Animation Durations ============
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 3);
  
  // ============ Timeouts ============
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // ============ Image Paths ============
  static const String logoPath = 'assets/images/logo.png';
  static const String logoWhitePath = 'assets/images/logo_white.png';
  static const String placeholderPath = 'assets/images/placeholder.png';
  static const String onboarding1 = 'assets/images/onboarding_1.png';
  static const String onboarding2 = 'assets/images/onboarding_2.png';
  static const String onboarding3 = 'assets/images/onboarding_3.png';
  
  // ============ Animation Paths ============
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String errorAnimation = 'assets/animations/error.json';
  static const String emptyAnimation = 'assets/animations/empty.json';
  
  // ============ Supported Languages ============
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'fr', 'name': 'Français', 'flag': '🇹🇳'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇹🇳'},
  ];
}






