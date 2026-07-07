import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/models/dashboard_model.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/di/service_locator.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardModel? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final userService = locator<UserService>();
      final data = await userService.getDashboardData();

      if (data != null && mounted) {
        setState(() {
          _dashboardData = DashboardModel.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;
    final profile = context.watch<ProfileProvider>().profile;
    final isInstructor = profile?['role_name'] == 'teacher' ||
        profile?['role_name'] == 'organization';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  _buildAppBar(locale, profile),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Welcome Card
                        _buildWelcomeCard(locale, profile),
                        const SizedBox(height: 20),

                        // Stats Grid
                        _buildStatsGrid(locale, isInstructor),
                        const SizedBox(height: 20),

                        // Balance Card (for instructors)
                        if (isInstructor) ...[
                          _buildBalanceCard(locale),
                          const SizedBox(height: 20),
                        ],

                        // Monthly Chart (for instructors)
                        if (isInstructor &&
                            _dashboardData?.monthlyChart != null) ...[
                          _buildMonthlyChart(locale),
                          const SizedBox(height: 20),
                        ],

                        // Points Card
                        if (_dashboardData?.totalPoints != null)
                          _buildPointsCard(locale),

                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAppBar(String locale, Map<String, dynamic>? profile) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 60, right: 20, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'dashboard'.tr(locale),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    profile?['role_name'] == 'organization'
                        ? 'organization'.tr(locale)
                        : profile?['role_name'] == 'teacher'
                            ? 'instructor'.tr(locale)
                            : 'student'.tr(locale),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String locale, Map<String, dynamic>? profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${locale == 'ar' ? 'مرحباً' : 'Bonjour'} 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?['full_name'] ?? _dashboardData?.fullName ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${locale == 'ar' ? 'لديك' : 'Vous avez'} ${_dashboardData?.unreadNotifications?.count ?? 0} ${locale == 'ar' ? 'إشعارات جديدة' : 'nouvelles notifications'}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: profile?['avatar'] != null
                ? NetworkImage(profile!['avatar'].toString().startsWith('http')
                    ? profile['avatar']
                    : 'https://edufirma.com${profile['avatar']}')
                : null,
            child: profile?['avatar'] == null
                ? const Icon(Iconsax.user, size: 30, color: Colors.white)
                : null,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatsGrid(String locale, bool isInstructor) {
    final stats = isInstructor
        ? [
            _StatItem(
              icon: Iconsax.video,
              value: _dashboardData?.pendingAppointments?.toString() ?? '0',
              label: 'pending_meetings'.tr(locale),
              color: Colors.blue,
            ),
            _StatItem(
              icon: Iconsax.chart,
              value: _dashboardData?.monthlySalesCount?.toString() ?? '0',
              label: 'monthly_sales'.tr(locale),
              color: Colors.green,
            ),
            _StatItem(
              icon: Iconsax.message,
              value: _dashboardData?.supportsCount?.toString() ?? '0',
              label: 'support_messages'.tr(locale),
              color: Colors.orange,
            ),
            _StatItem(
              icon: Iconsax.message_text,
              value: _dashboardData?.commentsCount?.toString() ?? '0',
              label: 'my_comments'.tr(locale),
              color: Colors.purple,
            ),
          ]
        : [
            _StatItem(
              icon: Iconsax.book,
              value: _dashboardData?.webinarsCount?.toString() ?? '0',
              label: 'my_courses'.tr(locale),
              color: Colors.blue,
            ),
            _StatItem(
              icon: Iconsax.video,
              value: _dashboardData?.reserveMeetingsCount?.toString() ?? '0',
              label: locale == 'ar' ? 'الاجتماعات' : 'Réunions',
              color: Colors.green,
            ),
            _StatItem(
              icon: Iconsax.message,
              value: _dashboardData?.supportsCount?.toString() ?? '0',
              label: 'support_messages'.tr(locale),
              color: Colors.orange,
            ),
            _StatItem(
              icon: Iconsax.message_text,
              value: _dashboardData?.commentsCount?.toString() ?? '0',
              label: 'my_comments'.tr(locale),
              color: Colors.purple,
            ),
          ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3, // Reduced from 1.5 to give more height
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(12), // Reduced from 16
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Added to minimize height
            children: [
              Container(
                width: 36, // Reduced from 40
                height: 36, // Reduced from 40
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat.icon,
                    color: stat.color, size: 18), // Reduced from 20
              ),
              const SizedBox(height: 8), // Reduced from 12
              Text(
                stat.value,
                style: GoogleFonts.poppins(
                  fontSize: 20, // Reduced from 22
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Flexible(
                child: Text(
                  stat.label,
                  style: GoogleFonts.poppins(
                    fontSize: 10, // Reduced from 11
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(
              begin: index.isEven ? -0.1 : 0.1,
              end: 0,
            );
      },
    );
  }

  Widget _buildBalanceCard(String locale) {
    final balance = _dashboardData?.balance ?? 0;
    final canWithdraw = _dashboardData?.canDrawable ?? false;

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
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.wallet_2, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'balance'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${balance.toStringAsFixed(2)} TND',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (canWithdraw)
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement withdraw
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            locale == 'ar' ? 'قريباً' : 'Bientôt disponible'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('withdraw'.tr(locale)),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMonthlyChart(String locale) {
    final chartData = _dashboardData?.monthlyChart;
    if (chartData == null || chartData.data.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = chartData.data.reduce((a, b) => a > b ? a : b).toDouble();

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
          Text(
            'monthly_sales'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < chartData.months.length) {
                          return Text(
                            chartData.months[index].substring(0, 3),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      chartData.data.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        chartData.data[index].toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: maxValue * 1.2,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPointsCard(String locale) {
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
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.medal_star, color: Colors.amber),
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPointItem(
                  'available_points'.tr(locale),
                  _dashboardData?.availablePoints?.toString() ?? '0',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPointItem(
                  'spent_points'.tr(locale),
                  _dashboardData?.spentPoints?.toString() ?? '0',
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress to next badge
          if (_dashboardData?.badges != null) ...[
            const SizedBox(height: 8),
            Text(
              '${locale == 'ar' ? 'الشارة التالية:' : 'Prochain badge:'} ${_dashboardData?.badges?.nextBadge ?? '-'}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_dashboardData?.badges?.percent ?? 0) / 100,
                backgroundColor: AppColors.grey200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPointItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}
