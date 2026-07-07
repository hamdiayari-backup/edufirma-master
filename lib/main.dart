import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/firebase_notification_service.dart';
import 'core/di/service_locator.dart';
import 'providers/auth_provider.dart';
import 'core/utils/html_utils.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'core/navigation/route_observer.dart';
import 'providers/app_providers.dart';
import 'providers/app_language_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Block screen capture / recording on Android (FLAG_SECURE)
  if (Platform.isAndroid) {
    try {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } catch (e) {
      debugPrint('Screen secure flag error: $e');
    }
  }

  // Initialize Firebase for push notifications
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FirebaseNotificationService().initialize();
    });
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Setup service locator
  await setupServiceLocator();

  // Restore session from storage so user stays logged in after app restart
  await locator<AuthProvider>().checkLoginStatus();

  // Initialize language
  await locator<AppLanguageProvider>().init();

  runApp(const EduFirmaApp());
}

class EduFirmaApp extends StatefulWidget {
  const EduFirmaApp({super.key});

  @override
  State<EduFirmaApp> createState() => _EduFirmaAppState();
}

class _EduFirmaAppState extends State<EduFirmaApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupNotificationHandlers();
  }

  void _setupNotificationHandlers() {
    final notificationService = FirebaseNotificationService();

    notificationService.onNotificationReceived = (title, body, data) {
      _showInAppNotification(title, body, data);
    };

    notificationService.onNotificationTap = (data) {
      _handleNotificationNavigation(data);
    };
  }

  void _showInAppNotification(
      String title, String body, Map<String, dynamic>? data) {
    final ctx = _navigatorKey.currentContext;
    if (ctx != null) {
      final messenger = ScaffoldMessenger.of(ctx);
      messenger.hideCurrentSnackBar();
      final cleanTitle = HtmlUtils.stripHtml(title);
      final cleanBody = HtmlUtils.stripHtml(body);
      messenger.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cleanTitle.isNotEmpty ? cleanTitle : 'Notification',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(cleanBody),
            ],
          ),
          action: SnackBarAction(
            label: 'Voir',
            onPressed: () {
              messenger.hideCurrentSnackBar();
              _handleNotificationNavigation(data ?? {});
            },
          ),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
        }
      });
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final id = data['id']?.toString();

    switch (type) {
      case 'course':
      case 'webinar':
        if (id != null && id.isNotEmpty) {
          _navigatorKey.currentState?.pushNamed(
            AppRoutes.courseDetails,
            arguments: {'id': int.tryParse(id), 'isBundle': false},
          );
        } else {
          _navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
        }
        break;
      case 'bundle':
        if (id != null && id.isNotEmpty) {
          _navigatorKey.currentState?.pushNamed(
            AppRoutes.courseDetails,
            arguments: {'id': int.tryParse(id), 'isBundle': true},
          );
        } else {
          _navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
        }
        break;
      case 'notification':
      default:
        _navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppProviders.wrapWithProviders(
      Consumer<AppLanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            navigatorObservers: [appRouteObserver],
            title: 'EduFirma',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            locale: languageProvider.currentLocale,
            supportedLocales: const [
              Locale('fr'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            builder: (context, child) {
              return Directionality(
                textDirection: languageProvider.isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
