import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/http_client.dart';
import '../storage/local_storage.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import '../services/category_service.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';
import '../services/store_service.dart';
import '../services/guest_service.dart';
import '../services/notification_service.dart';
import '../services/certificate_service.dart';
import '../services/konnect_service.dart';
import '../services/comment_service.dart';
import '../services/quiz_service.dart';
import '../services/support_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/notification_provider.dart';

final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core - Dio
  locator.registerLazySingleton<Dio>(() => Dio());

  // Storage
  locator.registerLazySingleton<LocalStorage>(() => LocalStorage());

  // HTTP Client
  locator.registerLazySingleton<HttpClient>(
    () => HttpClient(locator<LocalStorage>(), locator<Dio>()),
  );

  // Services
  locator.registerLazySingleton<AuthService>(
    () => AuthService(locator<HttpClient>(), locator<LocalStorage>()),
  );

  locator.registerLazySingleton<CourseService>(
    () => CourseService(locator<HttpClient>()),
  );

  locator.registerLazySingleton<CategoryService>(
    () => CategoryService(locator<HttpClient>()),
  );

  locator.registerLazySingleton<CartService>(
    () => CartService(locator<HttpClient>()),
  );

  locator.registerLazySingleton<UserService>(
    () => UserService(locator<HttpClient>()),
  );

  locator.registerLazySingleton<StoreService>(
    () => StoreService(locator<HttpClient>()),
  );

  locator.registerLazySingleton<GuestService>(
    () => GuestService(locator<HttpClient>()),
  );

  locator.registerLazySingleton<NotificationService>(
    () => NotificationService(locator<HttpClient>()),
  );

  locator.registerLazySingleton<CertificateService>(
    () => CertificateService(locator<HttpClient>()),
  );

  locator.registerLazySingleton<KonnectService>(
    () => KonnectService(),
  );

  locator.registerLazySingleton<CommentService>(
    () => CommentService(locator<HttpClient>()),
  );

  locator.registerLazySingleton<QuizService>(
    () => QuizService(locator<HttpClient>()),
  );

  locator.registerLazySingleton<SupportService>(
    () => SupportService(locator<HttpClient>()),
  );

  // Providers
  locator.registerLazySingleton<AppLanguageProvider>(
    () => AppLanguageProvider(),
  );

  locator.registerLazySingleton<AuthProvider>(
    () => AuthProvider(locator<AuthService>(), locator<LocalStorage>()),
  );

  locator.registerLazySingleton<CourseProvider>(
    () => CourseProvider(locator<CourseService>(), locator<CategoryService>()),
  );

  locator.registerLazySingleton<CartProvider>(
    () => CartProvider(locator<CartService>()),
  );

  locator.registerLazySingleton<StoreProvider>(
    () => StoreProvider(locator<StoreService>()),
  );

  locator.registerLazySingleton<ProfileProvider>(
    () => ProfileProvider(locator<UserService>(), locator<LocalStorage>()),
  );

  locator.registerLazySingleton<CertificateProvider>(
    () => CertificateProvider(locator<CertificateService>()),
  );

  locator.registerLazySingleton<NotificationProvider>(
    () => NotificationProvider(locator<NotificationService>()),
  );
}
