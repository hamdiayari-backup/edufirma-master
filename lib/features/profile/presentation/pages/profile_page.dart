import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn) {
      final profileProvider = context.read<ProfileProvider>();
      await Future.wait([
        profileProvider.fetchProfile(),
        profileProvider.fetchDashboard(),
        profileProvider.fetchRewards(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'my_profile'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Consumer2<AuthProvider, ProfileProvider>(
        builder: (context, authProvider, profileProvider, child) {
          if (!authProvider.isLoggedIn) {
            return _buildNotLoggedIn(locale);
          }

          return RefreshIndicator(
            onRefresh: _loadProfile,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(profileProvider, locale),
                  const SizedBox(height: 20),
                  _buildBadgesAndPointsSection(profileProvider, locale),
                  const SizedBox(height: 30),
                  _buildMenuSection(locale),
                  const SizedBox(height: 20),
                  _buildSettingsSection(locale),
                  const SizedBox(height: 20),
                  _buildLogoutButton(authProvider, locale),
                  const SizedBox(
                      height: 100), // Extra space to avoid bottom navbar
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotLoggedIn(String locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
                Iconsax.user,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'login'.tr(locale),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'login_to_continue'.tr(locale),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'sign_in'.tr(locale),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
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

  Widget _buildProfileHeader(ProfileProvider profileProvider, String locale) {
    final profile = profileProvider.profile;
    final name =
        profile?['full_name'] ?? (locale == 'ar' ? 'مستخدم' : 'Utilisateur');
    final email = profile?['email'] ?? '';
    final avatar = profile?['avatar'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? const Icon(Iconsax.user, size: 35, color: AppColors.primary)
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
            icon: const Icon(Iconsax.edit, color: AppColors.primary),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  /// Currency symbol for points conversion (API or fallback).
  String _currencySymbol(String locale, Map<String, dynamic>? rewardsData) {
    final sign = rewardsData?['currency_sign'] ?? rewardsData?['currency']?['sign'];
    if (sign != null && sign.toString().isNotEmpty) return sign.toString();
    return locale == 'ar' ? 'د.ت' : 'TND';
  }

  Widget _buildBadgesAndPointsSection(
      ProfileProvider profileProvider, String locale) {
    final dashboard = profileProvider.dashboard;
    final rewardsData = profileProvider.rewardsData;
    final hasPoints = dashboard != null &&
        (dashboard['total_points'] != null ||
            dashboard['available_points'] != null ||
            dashboard['spent_points'] != null);
    final badges =
        dashboard != null ? dashboard['badges'] as Map<String, dynamic>? : null;
    final hasBadges = badges != null &&
        (badges['next_badge'] != null ||
            badges['percent'] != null ||
            badges['earned'] != null);

    if (!hasPoints && !hasBadges) return const SizedBox.shrink();

    final totalPoints = dashboard?['total_points'];
    final availablePoints = dashboard?['available_points'] ?? 0;
    final spentPoints = dashboard?['spent_points'] ?? 0;
    final nextBadge = badges?['next_badge']?.toString();
    final percent = badges?['percent'] != null
        ? (double.tryParse(badges!['percent'].toString()) ?? 0)
        : 0.0;
    final earned = badges?['earned']?.toString();

    final conversionRate = rewardsData?['conversion_rate'] as Map<String, dynamic>?;
    final pointsPerUnit = conversionRate?['points_per_unit'];
    final hasConversionRate = pointsPerUnit != null &&
        (pointsPerUnit is int ? pointsPerUnit > 0 : (int.tryParse(pointsPerUnit.toString()) ?? 0) > 0);
    final currencySign = _currencySymbol(locale, rewardsData);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.medal_star,
                    color: Colors.amber, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'reward_points'.tr(locale),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (hasPoints) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProfilePointItem(
                    'available_points'.tr(locale),
                    availablePoints.toString(),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProfilePointItem(
                    'spent_points'.tr(locale),
                    spentPoints.toString(),
                    Colors.red,
                  ),
                ),
                if (totalPoints != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProfilePointItem(
                      locale == 'ar' ? 'المجموع' : 'Total',
                      totalPoints.toString(),
                      AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
            if (hasConversionRate) ...[
              const SizedBox(height: 12),
              Text(
                '${pointsPerUnit} ${'points'.tr(locale)} = 1 $currencySign',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
          if (hasBadges) ...[
            const SizedBox(height: 16),
            if (earned != null && earned.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${locale == 'ar' ? 'الشارة المحققة:' : 'Badge obtenu:'} $earned',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            if (nextBadge != null && nextBadge.isNotEmpty) ...[
              Text(
                '${locale == 'ar' ? 'الشارة التالية:' : 'Prochain badge:'} $nextBadge',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (percent / 100).clamp(0.0, 1.0),
                  backgroundColor: AppColors.grey200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 50.ms)
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildProfilePointItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale == 'ar' ? 'مساحتي' : 'Mon espace',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              _buildMenuItem(Iconsax.chart_2, 'dashboard'.tr(locale), () {
                Navigator.pushNamed(context, AppRoutes.dashboard);
              }),
              _buildDivider(),
              _buildMenuItem(Iconsax.book, 'my_courses'.tr(locale), () {
                Navigator.pushNamed(context, AppRoutes.myCourses);
              }),
              _buildDivider(),
              _buildMenuItem(
                  Iconsax.message_question, 'support_messages'.tr(locale), () {
                Navigator.pushNamed(context, AppRoutes.supportTickets);
              }),
              _buildDivider(),
              _buildMenuItem(Iconsax.heart, 'favorites'.tr(locale), () {
                Navigator.pushNamed(context, AppRoutes.favorites);
              }),
              _buildDivider(),
              _buildMenuItem(Iconsax.medal_star, 'certificates'.tr(locale), () {
                Navigator.pushNamed(context, AppRoutes.certificates);
              }),
              _buildDivider(),
              _buildMenuItem(Iconsax.document_text, 'my_quizzes'.tr(locale),
                  () {
                Navigator.pushNamed(context, AppRoutes.quizResults);
              }),
              _buildDivider(),
              _buildMenuItem(Iconsax.shopping_bag, 'my_orders'.tr(locale), () {
                Navigator.pushNamed(context, AppRoutes.myOrders);
              }),
              _buildDivider(),
              _buildMenuItem(Iconsax.notification, 'notifications'.tr(locale),
                  () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              }),
              _buildDivider(),
              _buildMenuItem(Iconsax.shopping_cart, 'cart'.tr(locale), () {
                Navigator.pushNamed(context, AppRoutes.cart);
              }),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildSettingsSection(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'settings'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              _buildLanguageMenuItem(locale),
              _buildDivider(),
              _buildMenuItem(Iconsax.lock, 'change_password'.tr(locale), () {
                _showChangePasswordSheet(locale);
              }),
              _buildDivider(),
              _buildMenuItem(Iconsax.info_circle, 'about'.tr(locale), () {
                Navigator.pushNamed(context, AppRoutes.about);
              }),
              _buildDivider(),
              _buildMenuItem(Iconsax.trash, 'delete_account'.tr(locale), () {
                _showDeleteAccountConfirmation(locale);
              }, isDanger: true),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildLanguageMenuItem(String locale) {
    return Consumer<AppLanguageProvider>(
      builder: (context, languageProvider, child) {
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Iconsax.language_square, color: AppColors.primary),
          ),
          title: Text(
            'language'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                languageProvider.currentLanguage == 'fr'
                    ? 'Français'
                    : 'العربية',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Iconsax.arrow_right_3,
                  size: 18, color: AppColors.grey400),
            ],
          ),
          onTap: () {
            _showLanguageDialog(locale);
          },
        );
      },
    );
  }

  void _showLanguageDialog(String locale) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            locale == 'ar' ? 'اختر اللغة' : 'Choisir la langue',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('Français', 'fr', locale),
              const SizedBox(height: 8),
              _buildLanguageOption('العربية', 'ar', locale),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
      String title, String langCode, String currentLocale) {
    final isSelected = currentLocale == langCode;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            langCode == 'fr' ? '🇫🇷' : '🇹🇳',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Iconsax.tick_circle, color: AppColors.primary)
          : null,
      onTap: () {
        context.read<AppLanguageProvider>().setLanguage(langCode);
        Navigator.pop(context);
      },
    );
  }

  void _showEditProfileSheet(ProfileProvider profileProvider, String locale) {
    final profile = profileProvider.profile;
    final nameController =
        TextEditingController(text: profile?['full_name'] ?? '');
    final emailController =
        TextEditingController(text: profile?['email'] ?? '');
    final bioController = TextEditingController(text: profile?['bio'] ?? '');
    final mobileController =
        TextEditingController(text: profile?['mobile'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'edit_profile'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.close_circle),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              backgroundImage: profile?['avatar'] != null
                                  ? NetworkImage(profile!['avatar'])
                                  : null,
                              child: profile?['avatar'] == null
                                  ? const Icon(Iconsax.user,
                                      size: 50, color: AppColors.primary)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.camera,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        controller: nameController,
                        label: 'full_name'.tr(locale),
                        icon: Iconsax.user,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: emailController,
                        label: 'email'.tr(locale),
                        icon: Iconsax.sms,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: mobileController,
                        label: 'phone'.tr(locale),
                        icon: Iconsax.call,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: bioController,
                        label: locale == 'ar' ? 'نبذة' : 'Bio',
                        icon: Iconsax.document_text,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await profileProvider.updateProfile({
                        'full_name': nameController.text,
                        'mobile': mobileController.text,
                        'bio': bioController.text,
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? (locale == 'ar'
                                      ? 'تم تحديث الملف'
                                      : 'Profil mis à jour')
                                  : (locale == 'ar'
                                      ? 'حدث خطأ'
                                      : 'Erreur lors de la mise à jour'),
                            ),
                            backgroundColor:
                                success ? AppColors.success : Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'save'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordSheet(String locale) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'change_password'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.close_circle),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: currentPasswordController,
                        label: locale == 'ar'
                            ? 'كلمة المرور الحالية'
                            : 'Mot de passe actuel',
                        icon: Iconsax.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: newPasswordController,
                        label: locale == 'ar'
                            ? 'كلمة المرور الجديدة'
                            : 'Nouveau mot de passe',
                        icon: Iconsax.lock_1,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: confirmPasswordController,
                        label: 'confirm_password'.tr(locale),
                        icon: Iconsax.lock_1,
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(locale == 'ar'
                                ? 'كلمات المرور غير متطابقة'
                                : 'Les mots de passe ne correspondent pas'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final profileProvider = context.read<ProfileProvider>();
                      final success = await profileProvider.updatePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? (locale == 'ar'
                                      ? 'تم تغيير كلمة المرور'
                                      : 'Mot de passe modifié')
                                  : (locale == 'ar'
                                      ? 'حدث خطأ'
                                      : 'Erreur lors du changement'),
                            ),
                            backgroundColor:
                                success ? AppColors.success : Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'save'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grey100),
        ),
        filled: !enabled,
        fillColor: enabled ? null : AppColors.grey100,
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.red : AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: isDanger ? Colors.red : AppColors.textPrimary,
          fontWeight: isDanger ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isDanger
          ? null
          : const Icon(Iconsax.arrow_right_3,
              size: 20, color: AppColors.grey300),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppColors.grey100);
  }

  Future<void> _showDeleteAccountConfirmation(String locale) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'delete_account'.tr(locale),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(
            locale == 'ar'
                ? 'هل أنت متأكد أنك تريد حذف حسابك؟ سيتم حذف جميع بياناتك بشكل دائم.'
                : 'Êtes-vous sûr de vouloir supprimer votre compte ? Toutes vos données seront définitivement supprimées.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                locale == 'ar' ? 'إلغاء' : 'Annuler',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implémenter la suppression du compte
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      locale == 'ar'
                          ? 'سيتم حذف حسابك قريباً'
                          : 'Votre compte sera supprimé sous peu',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text(
                locale == 'ar' ? 'حذف الحساب' : 'Supprimer',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider, String locale) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () async {
          await authProvider.logout();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        },
        icon: const Icon(Iconsax.logout),
        label: Text(
          'logout'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}
