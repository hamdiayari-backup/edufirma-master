import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/course_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../data/models/purchase_course_model.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PurchaseCourseModel> _purchases = [];

  /// Progress par pack (bundleId -> total, completed) chargé via getBundleProgress
  Map<int, ({int total, int completed})> _bundleProgress = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPurchases();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userService = locator<UserService>();
      final courseService = locator<CourseService>();
      final purchasesData = await userService.getPurchasedCourses();
      final purchases = purchasesData
          .map((json) => PurchaseCourseModel.fromJson(json))
          .toList();

      // Charger la progression des packs (total / terminés) pour afficher le bon %
      final Map<int, ({int total, int completed})> bundleProgress = {};
      for (final p in purchases) {
        if (p.isBundle && p.bundleId != null) {
          final progress = await courseService.getBundleProgress(p.bundleId!);
          if (progress != null) {
            bundleProgress[p.bundleId!] = progress;
          }
        }
      }

      setState(() {
        _purchases = purchases;
        _bundleProgress = bundleProgress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;
    final authProvider = context.watch<AuthProvider>();

    // If not logged in, show login prompt
    if (!authProvider.isLoggedIn) {
      return _buildLoginPrompt(locale);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(locale),
        ],
        body: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: 'in_progress'.tr(locale)),
                  Tab(text: 'completed'.tr(locale)),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCoursesList(inProgress: true, locale: locale),
                  _buildCoursesList(inProgress: false, locale: locale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String locale) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.secondary,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary,
                AppColors.secondary.withOpacity(0.8)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'my_courses'.tr(locale),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 4),
                  Text(
                    '${_purchases.length} ${'courses'.tr(locale).toLowerCase()}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesList({required bool inProgress, required String locale}) {
    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    if (_errorMessage != null) {
      return RefreshIndicator(
        onRefresh: _loadPurchases,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildErrorState(locale),
            ),
          ],
        ),
      );
    }

    // Filter: En cours = progress < 100%, Terminés = progress >= 100%
    final filteredCourses = _purchases.where((p) {
      final percent = p.course?.progressPercent ?? 0;
      return inProgress ? (percent < 100) : (percent >= 100);
    }).toList();

    // Toujours envelopper dans RefreshIndicator pour permettre le refresh même si liste vide
    return RefreshIndicator(
      onRefresh: _loadPurchases,
      color: AppColors.primary,
      child: filteredCourses.isEmpty
          ? CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(inProgress, locale),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final purchase = filteredCourses[index];
                return _buildCourseCard(purchase, index, locale);
              },
            ),
    );
  }

  Widget _buildCourseCard(
      PurchaseCourseModel purchase, int index, String locale) {
    final course = purchase.course;
    final isBundle = purchase.isBundle;
    final courseId = isBundle ? purchase.bundleId : purchase.webinarId;

    // Fallback when course is null but we have an id (e.g. bundle not parsed)
    if (course == null) {
      if (courseId == null) return const SizedBox.shrink();
      return _buildMinimalCard(
        purchase: purchase,
        locale: locale,
        title: isBundle ? 'Pack de cours' : 'Cours',
        subtitle: 'ID: $courseId',
      );
    }

    final rawThumbnail = course.thumbnail ?? course.image ?? '';
    final thumbnail = rawThumbnail.isEmpty
        ? ''
        : (rawThumbnail.startsWith('http')
                ? rawThumbnail
                : 'https://edufirma.com$rawThumbnail')
            .replaceAll(' ', '%20');
    final title = (course.title != null && course.title!.trim().isNotEmpty)
        ? course.title!.trim()
        : (isBundle ? 'Pack de cours' : 'Cours');
    final teacherName = course.teacher?.fullName ?? '';
    // Pour les packs: priorité à _bundleProgress (chargé via API), sinon modèle (API purchases)
    final bundleProgress = isBundle && purchase.bundleId != null
        ? _bundleProgress[purchase.bundleId!]
        : null;
    final int totalCount = bundleProgress?.total ?? course.webinarsCount ?? 0;
    final int completedCount =
        bundleProgress?.completed ?? course.completedWebinarsCount ?? 0;
    final progressPercent = totalCount > 0
        ? ((completedCount / totalCount) * 100).round().clamp(0, 100)
        : (course.effectiveProgressPercent).clamp(0, 100);
    final progress = progressPercent / 100.0;
    final showBundleCounts =
        isBundle && (bundleProgress != null || course.hasBundleProgressCounts);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.courseDetails,
          arguments: {
            'id': purchase.isBundle ? purchase.bundleId : purchase.webinarId,
            'isBundle': purchase.isBundle,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image & Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: thumbnail.isEmpty
                      ? Container(
                          color: AppColors.grey100,
                          child: const Center(
                            child: Icon(Iconsax.book,
                                size: 40, color: AppColors.grey300),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: thumbnail,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.grey100,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.grey100,
                            child: const Center(
                              child: Icon(Iconsax.book,
                                  size: 40, color: AppColors.grey300),
                            ),
                          ),
                        ),
                ),
                // Bundle badge
                if (purchase.isBundle)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Pack',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                // Play button overlay
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Iconsax.play5,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.teacher,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          teacherName,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar (for bundles: % of courses completed vs total)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showBundleCounts) ...[
                        Text(
                          'courses_completed_in_bundle'
                              .tr(locale)
                              .replaceAll('{completed}', '$completedCount')
                              .replaceAll('{total}', '$totalCount'),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'progress'.tr(locale),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.grey200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.courseDetails,
                          arguments: {
                            'id': purchase.isBundle
                                ? purchase.bundleId
                                : purchase.webinarId,
                            'isBundle': purchase.isBundle,
                          },
                        );
                      },
                      icon: const Icon(Iconsax.play, size: 18),
                      label: Text(
                        'continue_learning'.tr(locale),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 100 * index),
        )
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildMinimalCard({
    required PurchaseCourseModel purchase,
    required String locale,
    required String title,
    required String subtitle,
  }) {
    final courseId = purchase.isBundle ? purchase.bundleId : purchase.webinarId;
    if (courseId == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.courseDetails,
          arguments: {
            'id': courseId,
            'isBundle': purchase.isBundle,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Iconsax.book, size: 40, color: AppColors.grey300),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (purchase.isBundle)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Pack',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Iconsax.arrow_right_3,
                  color: AppColors.textSecondary, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool inProgress, String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              inProgress ? Iconsax.book_1 : Iconsax.medal_star,
              size: 50,
              color: AppColors.primary,
            ),
          ).animate().scale(duration: 500.ms),
          const SizedBox(height: 24),
          Text(
            inProgress
                ? 'no_courses'.tr(locale)
                : 'no_completed_courses'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            inProgress
                ? 'explore_courses_to_start'.tr(locale)
                : 'complete_courses_to_see'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          if (inProgress) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.coursesList);
              },
              icon: const Icon(Iconsax.search_normal),
              label: Text(
                'explore_courses'.tr(locale),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 60, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'error'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadPurchases,
            child: Text('retry'.tr(locale)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(String locale) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.book_saved,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ).animate().scale(duration: 500.ms),
                const SizedBox(height: 32),
                Text(
                  'my_courses'.tr(locale),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  'login_to_see_courses'.tr(locale),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    icon: const Icon(Iconsax.login),
                    label: Text(
                      'login'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.grey200,
          highlightColor: AppColors.grey100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}
