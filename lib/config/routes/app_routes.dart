import 'package:flutter/material.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/home/presentation/pages/main_page.dart';
import '../../features/courses/presentation/pages/courses_list_page.dart';
import '../../features/courses/presentation/pages/my_courses_page.dart';
import '../../features/courses/presentation/pages/course_details_page.dart';
import '../../features/courses/presentation/pages/search_page.dart';
import '../../features/courses/presentation/pages/single_content_page.dart';
import '../../features/categories/presentation/pages/categories_list_page.dart';
import '../../features/categories/presentation/pages/category_courses_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/checkout_page.dart';
import '../../features/cart/presentation/pages/payment_status_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/about_page.dart';
import '../../features/profile/presentation/pages/certificates_page.dart';
import '../../features/profile/presentation/pages/favorites_page.dart';
import '../../features/profile/presentation/pages/my_orders_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/providers/presentation/pages/user_profile_page.dart';
import '../../features/store/presentation/pages/store_page.dart';
import '../../features/store/presentation/pages/store_category_products_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/quiz/presentation/pages/quiz_page.dart';
import '../../features/quiz/presentation/pages/quiz_info_page.dart';
import '../../features/quiz/presentation/pages/quiz_results_list_page.dart';
import '../../features/support/presentation/pages/support_tickets_page.dart';
import '../../features/support/presentation/pages/support_conversation_page.dart';

/// App Routes configuration
class AppRoutes {
  AppRoutes._();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyCode = '/verify-code';
  static const String completeProfile = '/complete-profile';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String main = '/main';
  static const String search = '/search';
  static const String coursesList = '/courses';
  static const String courseDetails = '/course-details';
  static const String singleContent = '/single-content';
  static const String bundles = '/bundles';
  static const String store = '/store';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String favorites = '/favorites';
  static const String myCourses = '/my-courses';
  static const String notifications = '/notifications';
  static const String userProfile = '/user-profile';
  static const String editProfile = '/edit-profile';
  static const String about = '/about';
  static const String certificates = '/certificates';
  static const String myOrders = '/my-orders';
  static const String categoriesList = '/categories';
  static const String categoryCourses = '/category-courses';
  static const String paymentStatus = '/payment-status';
  static const String storeCategoryProducts = '/store-category-products';
  static const String dashboard = '/dashboard';
  static const String quiz = '/quiz';
  static const String quizInfo = '/quiz-info';
  static const String quizResults = '/quiz-results';
  static const String supportTickets = '/support-tickets';
  static const String supportConversation = '/support-conversation';

  // Routes map
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashPage(),
        onboarding: (context) => const OnboardingPage(),
        login: (context) => const LoginPage(),
        register: (context) => const RegisterPage(),
        verifyCode: (context) => const VerifyCodePage(),
        completeProfile: (context) => const CompleteProfilePage(),
        forgotPassword: (context) => const ForgotPasswordPage(),
        resetPassword: (context) => const ResetPasswordPage(),
        main: (context) => const MainPage(),
        search: (context) => const SearchPage(),
        coursesList: (context) => const CoursesListPage(),
        myCourses: (context) => const MyCoursesPage(),
        courseDetails: (context) => const CourseDetailsPage(),
        singleContent: (context) => const SingleContentPage(),
        categoriesList: (context) => const CategoriesListPage(),
        categoryCourses: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return CategoryCoursesPage(
            categoryId: args?['categoryId'] ?? 0,
            categoryTitle: args?['categoryTitle'] ?? '',
            category: args?['category'],
          );
        },
        cart: (context) => const CartPage(),
        checkout: (context) => const CheckoutPage(),
        profile: (context) => const ProfilePage(),
        editProfile: (context) => const EditProfilePage(),
        about: (context) => const AboutPage(),
        certificates: (context) => const CertificatesPage(),
        favorites: (context) => const FavoritesPage(),
        myOrders: (context) => const MyOrdersPage(),
        notifications: (context) => const NotificationsPage(),
        userProfile: (context) => const UserProfilePage(),
        paymentStatus: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String? ??
              'pending';
          return PaymentStatusPage(status: args);
        },
        store: (context) => const StorePage(),
        storeCategoryProducts: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return StoreCategoryProductsPage(
            categoryId: args?['categoryId'], // Peut être null
            categoryTitle: args?['categoryTitle'] ?? '',
            category: args?['category'],
          );
        },
        dashboard: (context) => const DashboardPage(),
        quiz: (context) => const QuizPage(),
        quizInfo: (context) => const QuizInfoPage(),
        quizResults: (context) => const QuizResultsListPage(),
        '/support-tickets': (context) => const SupportTicketsPage(),
        '/support-conversation': (context) => const SupportConversationPage(),
      };
}
