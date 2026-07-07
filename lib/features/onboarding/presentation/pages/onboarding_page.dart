import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Iconsax.book,
      title: 'Découvrez des cours',
      description:
          'Explorez une large gamme de formations dispensées par des experts dans leur domaine.',
      color: AppColors.primary,
    ),
    OnboardingItem(
      icon: Iconsax.video_play,
      title: 'Apprenez à votre rythme',
      description:
          'Accédez aux vidéos et contenus de cours quand vous voulez, où vous voulez.',
      color: AppColors.secondary,
    ),
    OnboardingItem(
      icon: Iconsax.medal_star,
      title: 'Obtenez des certificats',
      description:
          'Validez vos compétences et boostez votre carrière avec des certifications reconnues.',
      color: AppColors.accent,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final storage = LocalStorage();
    await storage.setFirstLaunch(false);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Passer',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_items[index]);
                },
              ),
            ),

            // Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _items.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primary,
                  dotColor: AppColors.grey300,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 4,
                ),
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage < _items.length - 1 ? 'Suivant' : 'Commencer',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 70,
              color: item.color,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          const SizedBox(height: 50),

          Text(
            item.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 20),

          Text(
            item.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
