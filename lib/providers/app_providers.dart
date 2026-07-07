import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/di/service_locator.dart';
import 'auth_provider.dart';
import 'course_provider.dart';
import 'cart_provider.dart';
import 'store_provider.dart';
import 'profile_provider.dart';
import 'certificate_provider.dart';
import 'app_language_provider.dart';
import 'notification_provider.dart';

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
        ChangeNotifierProvider<AppLanguageProvider>(
          create: (_) => locator<AppLanguageProvider>(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => locator<AuthProvider>(),
        ),
        ChangeNotifierProvider<CourseProvider>(
          create: (_) => locator<CourseProvider>(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => locator<CartProvider>(),
        ),
        ChangeNotifierProvider<StoreProvider>(
          create: (_) => locator<StoreProvider>(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => locator<ProfileProvider>(),
        ),
        ChangeNotifierProvider<CertificateProvider>(
          create: (_) => locator<CertificateProvider>(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => locator<NotificationProvider>(),
        ),
      ];

  static Widget wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: providers,
      child: child,
    );
  }
}
