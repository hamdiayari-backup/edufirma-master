import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/navigation/route_observer.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/course_provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/comment_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/quiz_model.dart';
import '../../data/models/course_model.dart';
import '../widgets/video_demo_player.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({super.key});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage>
    with SingleTickerProviderStateMixin, RouteAware {
  int? courseId;
  bool isBundle = false;
  bool _isInitialized = false;
  bool _showFullDescription = false;
  bool _isRedeemingPoints = false;
  bool _rewardsFetchRequested = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        courseId = args['id'];
        isBundle = args['isBundle'] ?? false;
        _isInitialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadCourse();
        });
      }
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Revenir sur la page pack après avoir quitté un cours du pack : recharger le pack
    if (isBundle == true && courseId != null && mounted) {
      _loadCourse();
    }
  }

  Future<void> _loadCourse() async {
    if (courseId != null) {
      await context
          .read<CourseProvider>()
          .fetchCourseDetails(courseId!, isBundle: isBundle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final course = provider.selectedCourse;
          if (course == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.book, size: 80, color: AppColors.grey300),
                  const SizedBox(height: 16),
                  Text(
                    'course_not_found'.tr(locale),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text('back'.tr(locale)),
                  ),
                ],
              ),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildAppBar(course, locale),
            ],
            body: Column(
              children: [
                _buildTabBar(locale),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(course, locale),
                      _buildContentTab(course, locale),
                      _buildReviewsTab(course, locale),
                      _buildCommentsTab(course, locale),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          final course = provider.selectedCourse;
          if (course == null) return const SizedBox.shrink();
          return _buildBottomBar(course, locale);
        },
      ),
    );
  }

  Widget _buildAppBar(Map<String, dynamic> course, String locale) {
    final thumbnail =
        course['thumbnail'] ?? course['image'] ?? course['image_cover'] ?? '';
    final demoVideo = course['video_demo'] ?? course['demo'] ?? '';
    final videoDemoSource = course['video_demo_source'] ?? '';
    final hasDemoVideo = demoVideo.toString().isNotEmpty;

    return SliverAppBar(
      expandedHeight: hasDemoVideo ? 300 : 250,
      pinned: true,
      backgroundColor: AppColors.secondary,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
        ),
      ),
      actions: [
        // Cart
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.cart);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                final itemCount = cartProvider.itemCount;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Iconsax.shopping_cart,
                        color: AppColors.textPrimary),
                    if (itemCount > 0)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            itemCount > 9 ? '9+' : '$itemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        // Favorite/Wishlist
        GestureDetector(
          onTap: () async {
            if (courseId != null) {
              final result = await context
                  .read<CourseProvider>()
                  .toggleFavorite(courseId!, isBundle: isBundle);

              if (mounted) {
                final success = result['success'] == true;
                final isFavorite = course['is_favorite'] != true;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (isFavorite
                              ? 'Ajouté aux favoris'
                              : 'Retiré des favoris')
                          : (result['message'] ?? 'Erreur'),
                    ),
                    backgroundColor: success ? AppColors.success : Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              course['is_favorite'] == true ? Iconsax.heart5 : Iconsax.heart,
              color: Colors.red,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: hasDemoVideo
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                  child: VideoDemoPlayer(
                    videoUrl: demoVideo,
                    thumbnailUrl: thumbnail,
                    videoSource: videoDemoSource,
                  ),
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  thumbnail.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppColors.grey100),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.secondary,
                            child: const Icon(Iconsax.book,
                                size: 50, color: Colors.white),
                          ),
                        )
                      : Container(
                          color: AppColors.secondary,
                          child: const Icon(Iconsax.book,
                              size: 80, color: Colors.white),
                        ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Badge
                  if (course['label'] != null)
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course['label'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildTabBar(String locale) {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        isScrollable: true,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'overview'.tr(locale)),
          Tab(text: 'content'.tr(locale)),
          Tab(text: 'reviews'.tr(locale)),
          Tab(text: 'comments'.tr(locale)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> course, String locale) {
    final title = course['title'] ?? '';
    final description =
        course['description'] ?? course['seo_description'] ?? '';
    final teacher = course['teacher'];
    final rate = course['rate'] ?? 0;
    final studentsCount = course['students_count'] ?? 0;
    final duration = course['duration'] ?? 0;
    final category = course['category'];
    final accessDays = course['access_days'];
    final webinarCount = course['webinar_count'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          // Stats Row
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildStatChip(Iconsax.star1, rate.toString(), Colors.amber),
              _buildStatChip(
                  Iconsax.people, '$studentsCount', AppColors.primary),
              _buildStatChip(
                  Iconsax.clock,
                  formatCourseDuration(duration).isEmpty
                      ? '-'
                      : formatCourseDuration(duration),
                  AppColors.secondary),
              if (accessDays != null)
                _buildStatChip(
                    Iconsax.calendar,
                    '$accessDays ${locale == 'ar' ? 'يوم' : 'jours'}',
                    Colors.orange),
              if (webinarCount != null)
                _buildStatChip(
                    Iconsax.video_play,
                    '$webinarCount ${locale == 'ar' ? 'دورة' : 'cours'}',
                    Colors.purple),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          // Category
          if (category != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category is String ? category : (category['title'] ?? ''),
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Teacher / Organization
          if (teacher != null) _buildTeacherCard(teacher, locale),

          const SizedBox(height: 24),

          // Description
          Text(
            'description'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            _cleanHtml(description),
            maxLines: _showFullDescription ? null : 5,
            overflow: _showFullDescription ? null : TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

          if (description.length > 200)
            TextButton(
              onPressed: () {
                setState(() {
                  _showFullDescription = !_showFullDescription;
                });
              },
              child: Text(
                _showFullDescription
                    ? 'see_less'.tr(locale)
                    : 'see_more'.tr(locale),
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Prérequis (si l'API renvoie prerequisites)
          if (_hasPrerequisites(course)) ...[
            const SizedBox(height: 24),
            Text(
              'prerequisites'.tr(locale),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildPrerequisitesSection(course['prerequisites'], locale),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  bool _hasPrerequisites(Map<String, dynamic> course) {
    final p = course['prerequisites'];
    return p is List && p.isNotEmpty;
  }

  Widget _buildPrerequisitesSection(dynamic prerequisites, String locale) {
    if (prerequisites is! List || prerequisites.isEmpty)
      return const SizedBox.shrink();
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: prerequisites.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = prerequisites[index];
          final webinar = item is Map ? item['webinar'] : null;
          if (webinar is! Map) return const SizedBox.shrink();
          final id = webinar['id'];
          final title = webinar['title'] ?? 'Cours ${index + 1}';
          final thumbnail = webinar['thumbnail'] ?? webinar['image'] ?? '';
          return Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                if (id != null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.courseDetails,
                    arguments: {'id': id, 'isBundle': false},
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 84,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: thumbnail.toString().isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl:
                                    thumbnail.toString().startsWith('http')
                                        ? thumbnail.toString()
                                        : 'https://edufirma.com$thumbnail',
                                height: 44,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Iconsax.book, size: 20),
                              )
                            : const SizedBox(
                                height: 44,
                                child: Icon(Iconsax.book, size: 20),
                              ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 32,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher, String locale) {
    final name = teacher['full_name'] ?? 'instructor'.tr(locale);
    final avatar = teacher['avatar'] ?? '';
    final bio = teacher['bio'] ?? '';
    final roleName = teacher['role_name'] ?? '';
    final rate = teacher['rate'] ?? 0;
    final teacherId = teacher['id'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          roleName == 'organization'
              ? 'organization'.tr(locale)
              : 'instructor'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            if (teacherId != null) {
              Navigator.pushNamed(
                context,
                AppRoutes.userProfile,
                arguments: teacherId,
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.grey100,
                  backgroundImage:
                      avatar.isNotEmpty ? NetworkImage(avatar) : null,
                  child: avatar.isEmpty
                      ? Icon(
                          roleName == 'organization'
                              ? Iconsax.building
                              : Iconsax.user,
                          color: AppColors.grey300,
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (bio.isNotEmpty)
                        Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Iconsax.star1,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rate.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Iconsax.arrow_right_3, color: AppColors.primary),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildContentTab(Map<String, dynamic> course, String locale) {
    final provider = context.watch<CourseProvider>();
    final contents = provider.courseContent;
    final authHasBought = course['auth_has_bought'] == true;
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;

    // User must be logged in AND have bought/registered for the course
    // Even for free courses, user must register (authHasBought must be true)
    final hasAccess = isLoggedIn && authHasBought;

    // Show loading state
    if (provider.isLoadingContent) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // If user doesn't have access, show purchase prompt
    if (!hasAccess) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                child: const Icon(Iconsax.lock,
                    size: 50, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                locale == 'ar' ? 'المحتوى مغلق' : 'Contenu verrouillé',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                locale == 'ar'
                    ? 'اشترك في هذه الدورة للوصول إلى جميع المحتويات'
                    : 'Inscrivez-vous à ce cours pour accéder à tout le contenu',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // User has access but content is empty - offer to fetch
    if (contents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.tick_circle,
                    size: 50, color: AppColors.success),
              ),
              const SizedBox(height: 24),
              Text(
                locale == 'ar' ? 'أنت مسجل!' : 'Vous êtes inscrit!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                locale == 'ar'
                    ? 'انقر لتحميل محتوى الدورة'
                    : 'Cliquez pour charger le contenu du cours',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Fetch content from API
                  if (courseId != null) {
                    context
                        .read<CourseProvider>()
                        .fetchCourseContent(courseId!, isBundle: isBundle);
                  }
                },
                icon: const Icon(Icons.download),
                label: Text(
                  locale == 'ar' ? 'تحميل المحتوى' : 'Charger le contenu',
                  style: GoogleFonts.poppins(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Check if this is bundle content (webinars)
    final isBundleContent =
        contents.isNotEmpty && contents[0]['type'] == 'bundle_webinars';

    if (isBundleContent) {
      // Display bundle webinars
      final webinars = contents[0]['items'] as List? ?? [];
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: webinars.length,
        itemBuilder: (context, index) {
          final webinar = webinars[index];
          return _buildWebinarCard(webinar, index, locale);
        },
      );
    }

    // Display the content
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        final chapter = contents[index];
        return _buildChapterCard(chapter, index, locale, hasAccess);
      },
    );
  }

  Widget _buildWebinarCard(
      Map<String, dynamic> webinar, int index, String locale) {
    final title = webinar['title'] ?? 'Cours ${index + 1}';
    final thumbnail = webinar['thumbnail'] ?? '';
    final duration = webinar['duration'] ?? 0;
    final webinarId = webinar['id'];
    final isCompleted = webinar['is_completed'] == true ||
        ((webinar['progress_percent'] ?? 0) >= 100);

    return GestureDetector(
      onTap: () {
        if (webinarId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.courseDetails,
            arguments: {'id': webinarId, 'isBundle': false},
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: thumbnail.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: thumbnail,
                      width: 100,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 100,
                        height: 80,
                        color: AppColors.grey100,
                        child: const Icon(Iconsax.video_play,
                            color: AppColors.grey300),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 100,
                        height: 80,
                        color: AppColors.grey100,
                        child: const Icon(Iconsax.video_play,
                            color: AppColors.grey300),
                      ),
                    )
                  : Container(
                      width: 100,
                      height: 80,
                      color: AppColors.grey100,
                      child: const Icon(Iconsax.video_play,
                          color: AppColors.grey300),
                    ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Iconsax.tick_circle5,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'course_completed'.tr(locale),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (duration > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Iconsax.clock,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            formatCourseDuration(duration),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Arrow
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Iconsax.arrow_right_3, color: AppColors.primary),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index));
  }

  Widget _buildChapterCard(
      Map<String, dynamic> chapter, int index, String locale, bool hasAccess) {
    final title = chapter['title'] ??
        '${locale == 'ar' ? 'الفصل' : 'Chapitre'} ${index + 1}';
    final items =
        chapter['items'] ?? chapter['lessons'] ?? chapter['contents'] ?? [];

    // If user doesn't have access, don't show the content items
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: hasAccess
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.grey200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: hasAccess
                ? Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Iconsax.lock, size: 18, color: AppColors.grey400),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: hasAccess ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          '${items is List ? items.length : 0} ${locale == 'ar' ? 'درس' : 'leçons'}',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        // Only show children if user has access
        children: hasAccess && items is List
            ? items
                .map<Widget>(
                    (item) => _buildLessonItem(item, locale, hasAccess))
                .toList()
            : [
                // Show locked message if no access
                if (!hasAccess)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Iconsax.lock,
                            size: 20, color: AppColors.grey400),
                        const SizedBox(width: 8),
                        Text(
                          locale == 'ar'
                              ? 'اشتر الدورة للوصول إلى المحتوى'
                              : 'Achetez le cours pour accéder au contenu',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
      ),
    ).animate().fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: 50 * index),
        );
  }

  Widget _buildLessonItem(
      Map<String, dynamic> item, String locale, bool hasAccess) {
    final title = item['title'] ?? '';
    final type = item['type'] ?? 'file';
    final accessibility = item['accessibility'] ?? 'paid';
    final isFree =
        accessibility == 'free' || item['free'] == true || item['free'] == 1;
    final link = item['link'] ?? '';
    final canAccess = hasAccess || isFree;
    final authHasRead = item['auth_has_read'] == true;

    // Get content-specific details
    final volume = item['volume'] ?? '';
    final questionCount = item['question_count'] ?? item['questionCount'] ?? 0;
    final time = item['time'] ?? 0;
    final downloadable = item['downloadable'] == 1;
    final isVideo = item['is_video'] == true || item['fileType'] == 'video';
    final date = item['date'];
    final summary = item['summary'] ?? '';

    // Determine icon and color based on type
    IconData icon;
    Color iconBgColor;
    String subtitle = '';

    switch (type) {
      case 'quiz':
        icon = Iconsax.shield_tick;
        iconBgColor = const Color(0xFF00BCD4); // Cyan
        final totalMark = item['total_mark'] ?? item['totalMark'];
        final passMark = item['pass_mark'] ?? item['passMark'];
        final attempt = item['attempt'];
        final bestGrade = item['best_grade'] ?? item['bestGrade'];
        final latestResult = item['latest_result'];
        final lastGrade =
            latestResult is Map ? latestResult['user_grade'] : null;
        final lastStatus = latestResult is Map ? latestResult['status'] : null;
        final parts = <String>[];
        parts.add('$questionCount ${locale == 'ar' ? 'سؤال' : 'questions'}');
        if (totalMark != null && totalMark != 0)
          parts.add('${locale == 'ar' ? 'الكل' : 'Note max'}: $totalMark');
        if (passMark != null && passMark != 0)
          parts.add('${locale == 'ar' ? 'النجاح' : 'Passage'}: $passMark');
        if (attempt != null)
          parts.add('${locale == 'ar' ? 'محاولات' : 'Tentatives'}: $attempt');
        if (bestGrade != null)
          parts
              .add('${locale == 'ar' ? 'أفضل' : 'Meilleure note'}: $bestGrade');
        if (lastGrade != null && lastStatus != null)
          parts.add(
              '$lastGrade (${lastStatus == 'passed' ? (locale == 'ar' ? 'ناجح' : 'Réussi') : lastStatus == 'failed' ? (locale == 'ar' ? 'راسب' : 'Échoué') : lastStatus})');
        subtitle = parts.isNotEmpty
            ? parts.join(' • ')
            : '$questionCount ${locale == 'ar' ? 'سؤال' : 'questions'} | ${time ?? 0} ${locale == 'ar' ? 'دقيقة' : 'min'}';
        break;
      case 'text_lesson':
        icon = Iconsax.document_text;
        iconBgColor = const Color(0xFFFFB300); // Amber
        subtitle = summary.isNotEmpty
            ? summary
            : (locale == 'ar' ? 'درس نصي' : 'Leçon texte');
        break;
      case 'file':
        icon = downloadable ? Iconsax.document_download : Iconsax.video_play;
        iconBgColor = downloadable
            ? const Color(0xFF4CAF50)
            : const Color(0xFF4CAF50); // Green
        subtitle =
            volume.isNotEmpty ? volume : (locale == 'ar' ? 'ملف' : 'Fichier');
        break;
      case 'session':
        icon = Iconsax.video;
        iconBgColor = const Color(0xFF2196F3); // Blue
        if (date != null) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(
              (date is int ? date : 0) * 1000);
          subtitle =
              '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
        } else {
          subtitle = locale == 'ar' ? 'جلسة مباشرة' : 'Session live';
        }
        break;
      case 'assignment':
        icon = Iconsax.task;
        iconBgColor = const Color(0xFF9C27B0); // Purple
        subtitle = locale == 'ar' ? 'مهمة' : 'Devoir';
        break;
      default:
        icon = isVideo ? Iconsax.video_play : Iconsax.document;
        iconBgColor = const Color(0xFF4CAF50); // Green
        subtitle = volume.isNotEmpty ? volume : '';
    }

    return InkWell(
      onTap:
          canAccess ? () => _handleContentTap(item, type, link, title) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.grey100, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Icon with colored background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: canAccess
                    ? iconBgColor.withOpacity(0.15)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: canAccess ? iconBgColor : AppColors.grey400,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Content info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: canAccess
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Read indicator
                      if (authHasRead && canAccess)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Status/Action indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFree)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      locale == 'ar' ? 'مجاني' : 'Gratuit',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (!canAccess)
                  const Icon(Iconsax.lock, size: 18, color: AppColors.grey400)
                else
                  Icon(
                    locale == 'ar'
                        ? Iconsax.arrow_left_2
                        : Iconsax.arrow_right_3,
                    size: 18,
                    color: AppColors.grey400,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleContentTap(
      Map<String, dynamic> item, String type, String link, String title) {
    switch (type) {
      case 'quiz':
        // Navigate to quiz info page (pass full item so all API fields are used)
        final quizId = item['id'] ?? item['quiz_id'];
        if (quizId != null) {
          final quiz = Quiz.fromJson(Map<String, dynamic>.from(item));
          final latest = item['latest_result'];
          final userGrade = latest is Map
              ? latest['user_grade']
              : item['latest_result']?['user_grade'];
          final status = latest is Map
              ? latest['status']
              : item['latest_result']?['status'];
          Navigator.pushNamed(
            context,
            AppRoutes.quizInfo,
            arguments: {
              'quiz': quiz,
              if (userGrade != null)
                'user_grade': userGrade is int
                    ? userGrade
                    : int.tryParse(userGrade.toString()),
              if (status != null) 'status': status.toString(),
            },
          );
        }
        break;
      case 'assignment':
        // Navigate to assignment page (if implemented)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Devoir: $title'),
            backgroundColor: AppColors.primary,
          ),
        );
        break;
      case 'text_lesson':
      case 'session':
      case 'file':
      default:
        // Navigate to SingleContentPage which handles fetching the actual file URL
        Navigator.pushNamed(
          context,
          AppRoutes.singleContent,
          arguments: {
            'item': item,
            'courseId': courseId,
          },
        );
        break;
    }
  }

  Future<void> _openExternalLink(String url) async {
    String fullUrl = url;
    if (!url.startsWith('http')) {
      fullUrl = 'https://edufirma.com$url';
    }

    // Try to launch the URL
    try {
      final uri = Uri.parse(fullUrl);
      // ignore: deprecated_member_use
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening URL: $e');
    }
  }

  Widget _buildReviewsTab(Map<String, dynamic> course, String locale) {
    final rate = double.tryParse(course['rate']?.toString() ?? '0') ?? 0;
    final reviewsCount = course['reviews_count'] ?? 0;
    final reviews = course['reviews'] ?? [];
    final isRegistered = course['auth_has_bought'] == true;
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Rating Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          rate.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rate.round()
                                  ? Iconsax.star1
                                  : Iconsax.star,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$reviewsCount ${locale == 'ar' ? 'تقييم' : 'avis'}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Reviews List
              if (reviews.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Iconsax.message, size: 60, color: AppColors.grey300),
                      const SizedBox(height: 16),
                      Text(
                        'no_reviews'.tr(locale),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(
                  reviews is List ? reviews.length : 0,
                  (index) => _buildReviewCard(reviews[index]),
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),

        // Floating action button to write review
        if (isLoggedIn && isRegistered)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              heroTag: 'review_fab',
              onPressed: () => _showReviewDialog(course, locale),
              backgroundColor: AppColors.secondary,
              icon: const Icon(Iconsax.star, color: AppColors.white),
              label: Text(
                'write_review'.tr(locale),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
          ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final user = review['user'] ?? review['creator'] ?? {};
    final rating = review['rate'] ?? review['rating'] ?? 0;
    final content = review['description'] ?? review['content'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.grey100,
                backgroundImage: user['avatar'] != null
                    ? NetworkImage(user['avatar'])
                    : null,
                child: user['avatar'] == null
                    ? const Icon(Iconsax.user,
                        size: 20, color: AppColors.grey300)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['full_name'] ?? 'Utilisateur',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index <
                                  (rating is int
                                      ? rating
                                      : int.tryParse(rating.toString()) ?? 0)
                              ? Iconsax.star1
                              : Iconsax.star,
                          color: Colors.amber,
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  Widget _buildBottomBar(Map<String, dynamic> course, String locale) {
    final price = course['price'] ?? 0;
    final priceWithDiscount = course['price_with_discount'];
    final discountPercent = course['discount_percent'] ?? 0;
    final isFree = price == 0 || price == null;
    final hasDiscount = CourseModel.parseDouble(discountPercent) > 0;
    final originalPrice = CourseModel.parseDouble(price);
    final displayPrice = hasDiscount
        ? CourseModel.effectiveDiscountDisplayPrice(
            price, discountPercent, priceWithDiscount)
        : originalPrice;
    final authHasBought = course['auth_has_bought'] == true;

    // Get the first valid ticket ID from tickets array (NOT the price)
    // Tickets are pricing plans with their own IDs
    int? firstTicketId;
    final tickets = course['tickets'];
    if (tickets != null && tickets is List && tickets.isNotEmpty) {
      final firstTicket = tickets.first;
      if (firstTicket is Map && firstTicket['id'] != null) {
        firstTicketId = firstTicket['id'];
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'price'.tr(locale),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        isFree
                            ? 'free'.tr(locale)
                            : hasDiscount
                                ? '${displayPrice.toStringAsFixed(0)} TND'
                                : '${originalPrice.toStringAsFixed(0)} TND',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isFree ? AppColors.success : AppColors.primary,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${originalPrice.toStringAsFixed(0)} TND',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (hasDiscount)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${CourseModel.parseDouble(discountPercent).toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Action Button
            Expanded(
              child: Consumer3<CartProvider, AuthProvider, ProfileProvider>(
                builder: (context, cartProvider, authProvider, profileProvider, child) {
                  final isLoggedIn = authProvider.isLoggedIn;

                  // If user is logged in AND has bought the course, show continue button
                  if (isLoggedIn && authHasBought) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to course content (first tab is content)
                        _tabController.animateTo(1);
                      },
                      icon: const Icon(Iconsax.play_circle),
                      label: Text(
                        'continue_learning'.tr(locale),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    );
                  }

                  // If user is not logged in, show login button
                  if (!isLoggedIn) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      icon: const Icon(Iconsax.login),
                      label: Text(
                        'login'.tr(locale),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    );
                  }

                  // User is logged in but hasn't bought - show pay with points (if course has points) and/or add to cart
                  final coursePoints = course['points'] != null
                      ? (course['points'] is int
                          ? course['points'] as int
                          : int.tryParse(course['points'].toString()) ?? 0)
                      : 0;
                  final canPayWithPoints = coursePoints > 0 && courseId != null;
                  if (canPayWithPoints && profileProvider.rewardsData == null && !_rewardsFetchRequested) {
                    _rewardsFetchRequested = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      profileProvider.fetchRewards();
                    });
                  }
                  final rewardsData = profileProvider.rewardsData;
                  final conversionRate = rewardsData?['conversion_rate'] as Map<String, dynamic>?;
                  final pointsPerUnit = conversionRate?['points_per_unit'];
                  final hasConversionRate = pointsPerUnit != null &&
                      (pointsPerUnit is int ? pointsPerUnit > 0 : (int.tryParse(pointsPerUnit.toString()) ?? 0) > 0);
                  final currencySign = rewardsData?['currency_sign']?.toString() ?? rewardsData?['currency']?['sign']?.toString() ?? (locale == 'ar' ? 'د.ت' : 'TND');
                  final avPoints = profileProvider.dashboard?['available_points'];
                  final availablePointsNum = avPoints is int ? avPoints : (avPoints != null ? int.tryParse(avPoints.toString()) : null) ?? 0;
                  final hasEnoughPoints = availablePointsNum >= coursePoints;

                  final addToCartButton = ElevatedButton(
                    onPressed: cartProvider.isLoading
                        ? null
                        : () async {
                            if (courseId != null) {
                              // Use smart add to cart which handles both free and paid courses
                              // firstTicketId is the actual ticket ID from course.tickets, null if no tickets
                              debugPrint(
                                  'Adding course: courseId=$courseId, ticketId=$firstTicketId, isFree=$isFree, isBundle=$isBundle');

                              final result = await cartProvider.smartAddToCart(
                                courseId: courseId!,
                                isBundle: isBundle,
                                isFree: isFree,
                                ticketId: firstTicketId,
                                displayPrice: hasDiscount ? displayPrice : null,
                                itemTitle: course['title']?.toString(),
                              );

                              if (mounted) {
                                final status = result['status'];
                                final success = result['success'] == true;

                                String message;
                                if (success) {
                                  if (status == 'free_registered') {
                                    message = locale == 'ar'
                                        ? 'تم التسجيل في الدورة بنجاح!'
                                        : 'Inscrit au cours avec succès!';
                                  } else {
                                    message = 'added_to_cart'.tr(locale);
                                  }
                                } else {
                                  final status = result['status']?.toString();
                                  if (status == 'required_prerequisites') {
                                    message = 'required_prerequisites_message'
                                        .tr(locale);
                                  } else {
                                    message = result['message'] ??
                                        result['error'] ??
                                        'error_adding_cart'.tr(locale);
                                  }
                                }

                                // Message avec fermeture automatique (4 s) pour cours gratuits
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: success
                                        ? AppColors.success
                                        : Colors.red,
                                    duration: const Duration(seconds: 4),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                // Refresh course details after free registration
                                if (success && status == 'free_registered') {
                                  _loadCourse();
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFree ? AppColors.success : AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: cartProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isFree
                                    ? Iconsax.add_circle
                                    : Iconsax.shopping_cart,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'add_to_cart'.tr(locale),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  );

                  if (canPayWithPoints) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasConversionRate)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '$pointsPerUnit ${'points'.tr(locale)} = 1 $currencySign',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${locale == 'ar' ? 'لديك' : 'Vous avez'} $availablePointsNum ${'points'.tr(locale)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hasEnoughPoints
                                    ? (locale == 'ar' ? '• كافٍ' : '• Suffisant')
                                    : (locale == 'ar' ? '• نقاط غير كافية' : '• Points insuffisants'),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: hasEnoughPoints ? AppColors.success : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isRedeemingPoints ? null
                              : () async {
                                  if (courseId == null) return;
                                  setState(() => _isRedeemingPoints = true);
                                  final userService = locator<UserService>();
                                  final result = await userService.redeemWithPoints(
                                    webinarId: isBundle ? null : courseId,
                                    bundleId: isBundle ? courseId : null,
                                  );
                                  if (mounted) {
                                    setState(() => _isRedeemingPoints = false);
                                    final ok = result['success'] == true;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? (result['message']?.toString() ??
                                                  (locale == 'ar'
                                                      ? 'تم الشراء بنقاط الولاء!'
                                                      : 'Achat avec les points réussi!'))
                                              : (result['message']?.toString() ??
                                                  (locale == 'ar'
                                                      ? 'فشل الشراء بالنقاط'
                                                      : 'Échec du paiement en points')),
                                        ),
                                        backgroundColor: ok ? AppColors.success : Colors.red,
                                        duration: const Duration(seconds: 4),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    if (ok) _loadCourse();
                                  }
                                },
                          icon: _isRedeemingPoints
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Iconsax.medal_star, size: 20),
                          label: Text(
                            '${locale == 'ar' ? 'الدفع بالنقاط' : 'Payer avec les points'} ($coursePoints ${'points'.tr(locale)})',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        addToCartButton,
                      ],
                    );
                  }

                  return addToCartButton;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== COMMENTS TAB ==========

  Widget _buildCommentsTab(Map<String, dynamic> course, String locale) {
    final comments = course['comments'] ?? [];
    final isRegistered = course['auth_has_bought'] == true;
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Comments List
              if (comments.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(Iconsax.message_text,
                          size: 60, color: AppColors.grey300),
                      const SizedBox(height: 16),
                      Text(
                        'no_comments'.tr(locale),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'be_first_to_comment'.tr(locale),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(
                  comments is List ? comments.length : 0,
                  (index) => _buildCommentCard(comments[index], locale),
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),

        // Floating action button to add comment
        if (isLoggedIn && isRegistered)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              heroTag: 'comment_fab',
              onPressed: () => _showCommentDialog(course, locale),
              backgroundColor: AppColors.primary,
              icon: const Icon(Iconsax.message_add, color: AppColors.white),
              label: Text(
                'leave_comment'.tr(locale),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
          ),
      ],
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment, String locale) {
    final user = comment['user'] ?? {};
    final content = comment['comment'] ?? '';
    final createdAt = comment['create_at'] ?? comment['created_at'];
    final replies = comment['replies'] ?? [];
    final status = comment['status'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.grey100,
                backgroundImage: user['avatar'] != null &&
                        user['avatar'].toString().isNotEmpty
                    ? NetworkImage(user['avatar'].toString().startsWith('http')
                        ? user['avatar']
                        : 'https://edufirma.com${user['avatar']}')
                    : null,
                child:
                    user['avatar'] == null || user['avatar'].toString().isEmpty
                        ? const Icon(Iconsax.user,
                            size: 20, color: AppColors.grey300)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['full_name'] ?? 'Utilisateur',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        _formatDate(createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // Status badge
              if (status == 'pending')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'pending'.tr(locale),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Comment content
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          // Replies
          if (replies is List && replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...List.generate(
              replies.length,
              (index) => _buildReplyCard(replies[index]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyCard(Map<String, dynamic> reply) {
    final user = reply['user'] ?? {};
    final content = reply['reply'] ?? reply['comment'] ?? '';

    return Container(
      margin: const EdgeInsets.only(left: 20, top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: AppColors.primary.withOpacity(0.5),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.grey200,
                backgroundImage: user['avatar'] != null
                    ? NetworkImage(user['avatar'].toString().startsWith('http')
                        ? user['avatar']
                        : 'https://edufirma.com${user['avatar']}')
                    : null,
                child: user['avatar'] == null
                    ? const Icon(Iconsax.user,
                        size: 14, color: AppColors.grey400)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                user['full_name'] ?? 'Instructor',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Instructor',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      int ts = timestamp is int
          ? timestamp
          : int.tryParse(timestamp.toString()) ?? 0;
      if (ts < 10000000000) ts *= 1000; // Convert seconds to milliseconds
      final date = DateTime.fromMillisecondsSinceEpoch(ts);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  // ========== COMMENT DIALOG ==========

  void _showCommentDialog(Map<String, dynamic> course, String locale) {
    final commentController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'leave_comment'.tr(locale),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'share_your_thoughts'.tr(locale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Comment input
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'write_comment'.tr(locale),
                  hintStyle: GoogleFonts.poppins(color: AppColors.grey400),
                  filled: true,
                  fillColor: AppColors.grey50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (commentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('please_enter_comment'.tr(locale))),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          final commentService = locator<CommentService>();
                          final result = await commentService.submitComment(
                            itemId: courseId!,
                            itemName: isBundle ? 'bundle' : 'webinar',
                            comment: commentController.text.trim(),
                          );

                          setState(() => isLoading = false);

                          if (result['success'] == true) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ??
                                    'comment_submitted'.tr(locale)),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Reload course to get updated comments
                            _loadCourse();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    result['message'] ?? 'error'.tr(locale)),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'submit_comment'.tr(locale),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ========== REVIEW DIALOG ==========

  void _showReviewDialog(Map<String, dynamic> course, String locale) {
    final descriptionController = TextEditingController();
    int contentQuality = 4;
    int instructorSkills = 4;
    int purchaseWorth = 4;
    int supportQuality = 4;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'write_review'.tr(locale),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'rate_course'.tr(locale),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Rating fields
                _buildRatingRow(
                  'content_quality'.tr(locale),
                  contentQuality,
                  (rating) => setState(() => contentQuality = rating.toInt()),
                ),
                const SizedBox(height: 16),
                _buildRatingRow(
                  'instructor_skills'.tr(locale),
                  instructorSkills,
                  (rating) => setState(() => instructorSkills = rating.toInt()),
                ),
                const SizedBox(height: 16),
                _buildRatingRow(
                  'purchase_worth'.tr(locale),
                  purchaseWorth,
                  (rating) => setState(() => purchaseWorth = rating.toInt()),
                ),
                const SizedBox(height: 16),
                _buildRatingRow(
                  'support_quality'.tr(locale),
                  supportQuality,
                  (rating) => setState(() => supportQuality = rating.toInt()),
                ),
                const SizedBox(height: 24),

                // Description input
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'review_description'.tr(locale),
                    hintStyle: GoogleFonts.poppins(color: AppColors.grey400),
                    filled: true,
                    fillColor: AppColors.grey50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (descriptionController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('please_enter_review'.tr(locale))),
                              );
                              return;
                            }

                            setState(() => isLoading = true);

                            final commentService = locator<CommentService>();
                            final result = await commentService.submitReview(
                              webinarId: courseId!,
                              contentQuality: contentQuality,
                              instructorSkills: instructorSkills,
                              purchaseWorth: purchaseWorth,
                              supportQuality: supportQuality,
                              description: descriptionController.text.trim(),
                            );

                            setState(() => isLoading = false);

                            if (result['success'] == true) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] ??
                                      'review_submitted'.tr(locale)),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Reload course to get updated reviews
                              _loadCourse();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      result['message'] ?? 'error'.tr(locale)),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'submit_review'.tr(locale),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingRow(
      String label, int currentRating, Function(double) onRatingUpdate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        RatingBar.builder(
          initialRating: currentRating.toDouble(),
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemSize: 24,
          itemPadding: const EdgeInsets.symmetric(horizontal: 2),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: onRatingUpdate,
        ),
      ],
    );
  }
}
