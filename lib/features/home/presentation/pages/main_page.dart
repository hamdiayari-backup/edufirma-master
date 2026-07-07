import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/firebase_notification_service.dart';
import '../../../../providers/notification_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';
import 'home_page.dart';
import '../../../courses/presentation/pages/courses_list_page.dart';
import '../../../courses/presentation/pages/my_courses_page.dart';
import '../../../store/presentation/pages/store_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late AnimationController _animationController;
  /// When set (e.g. after payment success), MyCoursesPage is recreated so it refreshes.
  Key? _myCoursesRefreshKey;
  bool _initialTabApplied = false;

  List<Widget> get _pages => [
    const HomePage(),
    const CoursesListPage(),
    _myCoursesRefreshKey != null
        ? KeyedSubtree(
            key: _myCoursesRefreshKey,
            child: const MyCoursesPage(),
          )
        : const MyCoursesPage(),
    const StorePage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
      FirebaseNotificationService().sendTokenToServerIfLoggedIn();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationProvider>().fetchNotifications();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialTabApplied) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['tab'] != null) {
        _initialTabApplied = true;
        final tab = (args['tab'] as num).toInt();
        if (tab >= 0 && tab < 5) {
          setState(() {
            _currentIndex = tab;
            if (tab == 2) {
              _myCoursesRefreshKey = ValueKey(DateTime.now().millisecondsSinceEpoch);
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true, // Important for floating navbar
      extendBodyBehindAppBar: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: _buildFloatingNavBar(locale),
      ),
    );
  }

  Widget _buildFloatingNavBar(String locale) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Iconsax.home_25, Iconsax.home_1, 'home'.tr(locale)),
              _buildNavItem(1, Iconsax.book5, Iconsax.book_1, 'courses'.tr(locale)),
              _buildCenterButton(locale),  // My Courses (index 2)
              _buildNavItem(3, Iconsax.shop5, Iconsax.shop, 'store'.tr(locale)),
              _buildNavItem(4, Iconsax.user, Iconsax.user, 'profile'.tr(locale)),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animated background
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? AppColors.primary : AppColors.grey400,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            // Label
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(String locale) {
    final isSelected = _currentIndex == 2;
    
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isSelected ? 0.5 : 0.3),
              blurRadius: isSelected ? 20 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isSelected ? Iconsax.book_saved5 : Iconsax.book_saved,
          color: AppColors.white,
          size: 26,
        ),
      ),
    );
  }

}
