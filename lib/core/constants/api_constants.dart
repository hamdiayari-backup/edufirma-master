/// API Constants for EduFirma
/// These are the same endpoints used by the Edufirma backend
class ApiConstants {
  ApiConstants._();
  
  // ============ Base Configuration ============
  static const String domain = 'https://edufirma.com';
  static const String baseUrl = '$domain/api/';
  static const String apiKey = '1234';
  static const String scheme = 'edufirma';
  
  // ============ Authentication Endpoints ============
  static const String login = '${baseUrl}login';
  static const String register = '${baseUrl}register/step/1';
  static const String verifyCode = '${baseUrl}register/step/2';
  static const String registerStep3 = '${baseUrl}register/step/3';
  static const String forgetPassword = '${baseUrl}forget-password';
  static const String googleCallback = '${baseUrl}google/callback';
  static const String facebookCallback = '${baseUrl}facebook/callback';
  
  // ============ Course Endpoints ============
  static const String courses = '${baseUrl}courses';
  static const String featuredCourses = '${baseUrl}featured-courses';
  static const String bundles = '${baseUrl}bundles';
  static String courseDetails(int id) => '${baseUrl}courses/$id';
  static String bundleDetails(int id) => '${baseUrl}bundles/$id';
  static String bundleWebinars(int id) => '${baseUrl}bundles/$id/webinars';
  static String courseContent(int id) => '${baseUrl}courses/$id/content';
  static String courseReport(int id) => '${baseUrl}courses/$id/report';
  static String courseToggle(int id) => '${baseUrl}courses/$id/toggle';
  static const String courseReasons = '${baseUrl}courses/reports/reasons';
  
  // ============ Panel Endpoints (Authenticated) ============
  static String panelCourse(int id) => '${baseUrl}panel/webinars/$id';
  static String panelBundle(int id) => '${baseUrl}panel/bundles/$id';
  static String panelNotices(int id) => '${baseUrl}panel/webinars/$id/noticeboards';
  static const String panelFavoritesToggle = '${baseUrl}panel/favorites/toggle2';
  static const String panelFavorites = '${baseUrl}panel/favorites';
  static const String panelProfile = '${baseUrl}panel/profile';
  static const String panelDashboard = '${baseUrl}panel/dashboard';
  
  // ============ Category & Filter Endpoints ============
  static const String categories = '${baseUrl}categories';
  static const String filterOptions = '${baseUrl}filters';
  
  // ============ Provider Endpoints ============
  static const String providers = '${baseUrl}providers';
  static const String instructors = '${baseUrl}instructors';
  static const String organizations = '${baseUrl}organizations';
  
  // ============ Search Endpoint ============
  static const String search = '${baseUrl}search';
  
  // ============ Cart & Checkout Endpoints ============
  static const String cart = '${baseUrl}cart';
  static const String cartAdd = '${baseUrl}cart/store';
  static const String cartRemove = '${baseUrl}cart';
  static const String checkout = '${baseUrl}cart/checkout';
  static const String applyCoupon = '${baseUrl}cart/coupon/validate';
  
  // ============ Store/Product Endpoints ============
  static const String products = '${baseUrl}products';
  static String productDetails(int id) => '${baseUrl}products/$id';
  
  // ============ User Endpoints ============
  static String userProfile(int id) => '${baseUrl}users/$id';
  
  // ============ Config Endpoints ============
  static const String config = '${baseUrl}config';
  static const String currencies = '${baseUrl}currencies';
  
  // ============ Notification Endpoints ============
  static const String notifications = '${baseUrl}panel/notifications';
  
  // ============ Blog Endpoints ============
  static const String blog = '${baseUrl}blog';
  static String blogDetails(int id) => '${baseUrl}blog/$id';
}






