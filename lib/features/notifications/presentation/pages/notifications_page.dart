import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/html_utils.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../providers/notification_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.notifications.isEmpty)
                return const SizedBox.shrink();
              final locale = context.read<AppLanguageProvider>().currentLanguage;
              return PopupMenuButton<String>(
                icon: const Icon(Iconsax.more, color: AppColors.primary),
                onSelected: (value) async {
                  if (value == 'read_all') {
                    await provider.markAllAsRead();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(locale == 'ar'
                              ? 'تم تحديد الكل كمقروء'
                              : 'Tout marqué comme lu'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'read_all',
                    child: Row(
                      children: [
                        const Icon(Iconsax.tick_circle, size: 20),
                        const SizedBox(width: 8),
                        Text('read_all'.tr(locale)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.notification,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aucune notification',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous n\'avez pas encore de notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _buildNotificationCard(notification, index, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    int index,
    NotificationProvider provider,
  ) {
    final rawTitle = notification['title'] ?? '';
    final title = HtmlUtils.stripHtml(rawTitle.toString());
    final rawMessage = notification['message'] ?? notification['body'] ?? '';
    final message = HtmlUtils.stripHtml(rawMessage.toString());
    final createdAt = notification['created_at'];
    final isRead =
        notification['status'] == 'read' || notification['seen'] == true;
    final type = notification['type'] ?? 'general';

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'course':
      case 'webinar':
        icon = Iconsax.book;
        iconColor = AppColors.primary;
        break;
      case 'purchase':
      case 'payment':
        icon = Iconsax.card;
        iconColor = AppColors.success;
        break;
      case 'message':
        icon = Iconsax.message;
        iconColor = Colors.blue;
        break;
      case 'promotion':
      case 'offer':
        icon = Iconsax.discount_shape;
        iconColor = Colors.orange;
        break;
      case 'certificate':
        icon = Iconsax.medal;
        iconColor = Colors.amber;
        break;
      default:
        icon = Iconsax.notification;
        iconColor = AppColors.secondary;
    }

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          provider.markAsRead(notification['id']?.toString() ?? '');
        }
        _handleNotificationTap(notification);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? AppColors.white
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: isRead
              ? null
              : Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
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
                            fontSize: 15,
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.grey400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: 50 * index),
        );
  }

  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return '';

    try {
      int timestamp;
      if (createdAt is int) {
        timestamp = createdAt;
      } else {
        timestamp = int.tryParse(createdAt.toString()) ?? 0;
      }

      if (timestamp == 0) return '';

      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'À l\'instant';
      } else if (difference.inHours < 1) {
        return 'Il y a ${difference.inMinutes} min';
      } else if (difference.inDays < 1) {
        return 'Il y a ${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type']?.toString();
    final data = notification['data'] ?? notification['sender'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : null;

    switch (type) {
      case 'course':
      case 'webinar':
        final courseId = dataMap?['id'] ?? dataMap?['webinar_id'];
        if (courseId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.courseDetails,
            arguments: {'id': courseId, 'isBundle': false},
          );
        } else {
          _showNotificationDetail(notification);
        }
        break;
      case 'bundle':
        final bundleId = dataMap?['id'] ?? dataMap?['bundle_id'];
        if (bundleId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.courseDetails,
            arguments: {'id': bundleId, 'isBundle': true},
          );
        } else {
          _showNotificationDetail(notification);
        }
        break;
      default:
        _showNotificationDetail(notification);
        break;
    }
  }

  void _showNotificationDetail(Map<String, dynamic> notification) {
    final rawTitle = notification['title'] ?? '';
    final title = HtmlUtils.stripHtml(rawTitle.toString());
    final rawMessage = notification['message'] ?? notification['body'] ?? '';
    final message = HtmlUtils.stripHtml(rawMessage.toString());
    final createdAt = notification['created_at'];
    final dateStr = _formatDate(createdAt);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Iconsax.notification,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isNotEmpty ? title : 'Notification',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (dateStr.isNotEmpty)
                          Text(
                            dateStr,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (message.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
}
