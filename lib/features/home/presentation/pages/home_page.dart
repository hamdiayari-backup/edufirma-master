import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../providers/course_provider.dart';
import '../../../../providers/notification_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/localization/app_translations.dart';
import '../widgets/course_card.dart';
import '../widgets/category_card.dart';
import '../widgets/section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final courseProvider = context.read<CourseProvider>();
    await courseProvider.loadInitialData();
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;

    return Scaffold(
      body: Stack(
        children: [
          // Modern gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.background,
                  AppColors.primarySurface.withOpacity(0.2),
                  AppColors.background,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Large decorative circle (top right)
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withOpacity(0.12),
                    AppColors.primary.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Medium decorative circle (top left)
          Positioned(
            top: 100,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primarySurface.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Small decorative circle (middle right)
          Positioned(
            top: 300,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Light green blob shape (bottom left)
          Positioned(
            bottom: -100,
            left: -100,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryLight.withOpacity(0.1),
                      AppColors.primarySurface.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Small light green shape (middle)
          Positioned(
            top: 500,
            left: 50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primarySurface.withOpacity(0.2),
                    AppColors.primaryLight.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(locale)),
                  SliverToBoxAdapter(child: _buildSearchBar(locale)),
                  SliverToBoxAdapter(child: _buildCategories(locale)),
                  SliverToBoxAdapter(child: _buildFeaturedCourses(locale)),
                  SliverToBoxAdapter(child: _buildAllCourses(locale)),
                  SliverToBoxAdapter(child: _buildBundles(locale)),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String locale) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: AppColors.cardShadow,
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/images/edandroid.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 15),

          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome'.tr(locale),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'EduFirma',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Notification Icon
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Iconsax.notification,
                          color: AppColors.primary),
                      if (notificationProvider.hasUnread)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSearchBar(String locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.search);
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(
                Iconsax.search_normal,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'search_courses'.tr(locale),
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
              const Icon(Iconsax.filter, color: AppColors.secondary),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildCategories(String locale) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;

        return Column(
          children: [
            const SizedBox(height: 25),
            SectionHeader(
              title: 'popular_categories'.tr(locale),
              onSeeAll: () {
                Navigator.pushNamed(context, AppRoutes.categoriesList);
              },
            ),
            const SizedBox(height: 15),
            provider.isLoadingCategories || categories.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: categories.length > 6 ? 6 : categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return CategoryCard(
                          title: category.title ?? '',
                          icon: _getCategoryIcon(index),
                          color: _getCategoryColor(index),
                          imageUrl: category.imageUrl,
                          iconSize: 48,
                          iconContainerSize: 48,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.categoryCourses,
                              arguments: {
                                'categoryId': category.id ?? 0,
                                'categoryTitle': category.title ?? '',
                                'category': category,
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
      },
    );
  }

  Widget _buildFeaturedCourses(String locale) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final courses = provider.featuredCourses;

        return Column(
          children: [
            const SizedBox(height: 25),
            SectionHeader(
              title: 'featured_courses'.tr(locale),
              onSeeAll: () {
                Navigator.pushNamed(context, AppRoutes.coursesList);
              },
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 280,
              child: provider.isLoadingFeatured
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : courses.isEmpty
                      ? Center(
                          child: Text(
                            'no_courses'.tr(locale),
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return CourseCard(
                              course: course,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.courseDetails,
                                  arguments: {
                                    'id': course.id,
                                    'isBundle': false
                                  },
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
      },
    );
  }

  Widget _buildAllCourses(String locale) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final courses = provider.courses;

        return Column(
          children: [
            const SizedBox(height: 25),
            SectionHeader(
              title: 'all_courses'.tr(locale),
              onSeeAll: () {
                Navigator.pushNamed(context, AppRoutes.coursesList);
              },
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 280,
              child: provider.isLoadingCourses
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : courses.isEmpty
                      ? Center(
                          child: Text(
                            'no_courses'.tr(locale),
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return CourseCard(
                              course: course,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.courseDetails,
                                  arguments: {
                                    'id': course.id,
                                    'isBundle': false
                                  },
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
      },
    );
  }

  Widget _buildBundles(String locale) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final bundles = provider.bundles;

        return Column(
          children: [
            const SizedBox(height: 25),
            SectionHeader(
              title: 'bundles'.tr(locale),
              onSeeAll: () {
                Navigator.pushNamed(context, AppRoutes.coursesList);
              },
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 280,
              child: provider.isLoadingBundles
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : bundles.isEmpty
                      ? Center(
                          child: Text(
                            'no_data'.tr(locale),
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: bundles.length,
                          itemBuilder: (context, index) {
                            final bundle = bundles[index];
                            return CourseCard(
                              course: bundle,
                              isBundle: true,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.courseDetails,
                                  arguments: {
                                    'id': bundle.id,
                                    'isBundle': true
                                  },
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
      },
    );
  }

  IconData _getCategoryIcon(int index) {
    final icons = [
      Iconsax.code,
      Iconsax.paintbucket,
      Iconsax.chart,
      Iconsax.language_square,
      Iconsax.music,
      Iconsax.camera,
    ];
    return icons[index % icons.length];
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}
