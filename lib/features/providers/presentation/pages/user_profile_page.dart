import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/guest_service.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with TickerProviderStateMixin {
  int? userId;
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  TabController? _tabController;
  bool _isOrganization = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (userId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        userId = args;
        _loadProfile();
      } else if (args is Map<String, dynamic>) {
        userId = args['id'];
        _loadProfile();
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final guestService = locator<GuestService>();
      final profile = await guestService.getUserProfile(userId!);

      final isOrg = profile?['role_name'] == 'organization';

      // Si organisation et pas de formateurs dans le profil (API Edufirma: organization_teachers), fallback
      if (isOrg && profile != null) {
        final instructors = profile['instructors'] as List?;
        final orgTeachers = profile['organization_teachers'] as List?;
        if ((instructors == null || instructors.isEmpty) &&
            (orgTeachers == null || orgTeachers.isEmpty)) {
          final list = await guestService.getOrganizationInstructors(userId!);
          if (list.isNotEmpty) {
            profile['instructors'] = list;
            profile['organization_teachers'] = list;
          }
        }
      }

      // Dispose old controller if exists
      _tabController?.dispose();

      // 4 tabs for org: À propos, Cours, Badges, Formateurs. 3 for non-org.
      _tabController = TabController(
        length: isOrg ? 4 : 3,
        vsync: this,
      );

      setState(() {
        _profile = profile;
        _isOrganization = isOrg;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _profile == null || _tabController == null
              ? _buildError(locale)
              : _buildContent(locale),
    );
  }

  Widget _buildError(String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.user_remove, size: 60, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            locale == 'ar' ? 'المستخدم غير موجود' : 'Utilisateur non trouvé',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('back'.tr(locale)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String locale) {
    final name = _profile?['full_name'] ?? '';
    final avatar = _profile?['avatar'] ?? '';
    final bio = _profile?['bio'] ?? '';
    final rate = _profile?['rate'] ?? 0;
    final verified =
        _profile?['verified'] == 1 || _profile?['verified'] == true;
    final webinars = _profile?['webinars'] as List? ?? [];
    final badges = _profile?['badges'] as List? ?? [];
    final students = _profile?['students'] as List? ?? [];
    final followersCount =
        _profile?['followers_count'] ?? _profile?['followersCount'] ?? 0;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // App Bar
          SliverAppBar(
            expandedHeight: 300,
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
                child: const Icon(Iconsax.arrow_left,
                    color: AppColors.textPrimary),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.secondary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.white,
                            backgroundImage:
                                avatar.isNotEmpty ? NetworkImage(avatar) : null,
                            child: avatar.isEmpty
                                ? Icon(
                                    _isOrganization
                                        ? Iconsax.building
                                        : Iconsax.user,
                                    size: 40,
                                    color: AppColors.grey300,
                                  )
                                : null,
                          ),
                          if (verified)
                            Positioned(
                              right: 0,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index <
                                      (double.tryParse(rate.toString()) ?? 0)
                                          .round()
                                  ? Iconsax.star1
                                  : Iconsax.star,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            rate.toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            locale == 'ar' ? 'الدورات' : 'Cours',
                            webinars.length.toString(),
                            Iconsax.video_play,
                          ),
                          _buildStatItem(
                            locale == 'ar' ? 'الطلاب' : 'Étudiants',
                            students.length.toString(),
                            Iconsax.people,
                          ),
                          _buildStatItem(
                            locale == 'ar' ? 'المتابعون' : 'Abonnés',
                            followersCount.toString(),
                            Iconsax.heart,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: locale == 'ar' ? 'حول' : 'À propos'),
                  Tab(text: locale == 'ar' ? 'الدورات' : 'Cours'),
                  Tab(text: locale == 'ar' ? 'الشارات' : 'Badges'),
                  if (_isOrganization)
                    Tab(text: locale == 'ar' ? 'المدربون' : 'Formateurs'),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAboutTab(bio, locale),
          _buildCoursesTab(webinars, locale),
          _buildBadgesTab(badges, locale),
          if (_isOrganization) _buildInstructorsTab(locale),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTab(String bio, String locale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale == 'ar' ? 'نبذة' : 'Bio',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: Text(
              bio.isNotEmpty
                  ? bio
                  : (locale == 'ar' ? 'لا توجد معلومات' : 'Aucune information'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildCoursesTab(List webinars, String locale) {
    if (webinars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.book, size: 60, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              locale == 'ar' ? 'لا توجد دورات' : 'Aucun cours',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: webinars.length,
      itemBuilder: (context, index) {
        final course = webinars[index];
        return _buildCourseItem(course, index, locale);
      },
    );
  }

  Widget _buildCourseItem(
      Map<String, dynamic> course, int index, String locale) {
    final title = course['title'] ?? '';
    final thumbnail = course['thumbnail'] ?? course['image'] ?? '';
    final price = course['price'] ?? 0;
    final rate = course['rate'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.courseDetails,
          arguments: {'id': course['id'], 'isBundle': false},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: thumbnail.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: thumbnail,
                      width: 100,
                      height: 90,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 100,
                        height: 90,
                        color: AppColors.grey100,
                        child:
                            const Icon(Iconsax.book, color: AppColors.grey300),
                      ),
                    )
                  : Container(
                      width: 100,
                      height: 90,
                      color: AppColors.grey100,
                      child: const Icon(Iconsax.book, color: AppColors.grey300),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.star1,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              rate.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          price > 0 ? '$price TND' : 'free'.tr(locale),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: price > 0
                                ? AppColors.primary
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(
            duration: 300.ms,
            delay: Duration(milliseconds: 50 * index),
          ),
    );
  }

  Widget _buildBadgesTab(List badges, String locale) {
    if (badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.medal_star, size: 60, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              locale == 'ar' ? 'لا توجد شارات' : 'Aucun badge',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (badge['image'] != null)
                CachedNetworkImage(
                  imageUrl: badge['image'],
                  width: 50,
                  height: 50,
                  errorWidget: (_, __, ___) => const Icon(Iconsax.medal_star,
                      color: AppColors.primary, size: 40),
                )
              else
                const Icon(Iconsax.medal_star,
                    color: AppColors.primary, size: 40),
              const SizedBox(height: 8),
              Text(
                badge['title'] ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Formateurs associés (API Edufirma: organization_teachers dans users/:id/profile)
  Widget _buildInstructorsTab(String locale) {
    final instructors = _profile?['organization_teachers'] as List? ??
        _profile?['instructors'] as List? ??
        [];

    if (instructors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.people, size: 60, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              locale == 'ar' ? 'لا يوجد مدربون' : 'Aucun formateur',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: instructors.length,
      itemBuilder: (context, index) {
        final instructor = instructors[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.grey100,
            backgroundImage: instructor['avatar'] != null
                ? NetworkImage(instructor['avatar'])
                : null,
            child: instructor['avatar'] == null
                ? const Icon(Iconsax.user, color: AppColors.grey300)
                : null,
          ),
          title: Text(
            instructor['full_name'] ?? '',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            instructor['bio'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.textSecondary),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.userProfile,
              arguments: instructor['id'],
            );
          },
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
