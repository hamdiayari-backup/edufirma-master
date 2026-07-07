import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';

/// Page Favoris – alignée sur le legacy kingco (GET panel/favorites, DELETE panel/favorites/:id).
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFavorites());
  }

  Future<void> _loadFavorites() async {
    await context.read<ProfileProvider>().fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;

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
          'favorites'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.favorites.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final list = provider.favorites;
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.heart, size: 72, color: AppColors.grey300),
                  const SizedBox(height: 20),
                  Text(
                    locale == 'ar' ? 'لا توجد مفضلات' : 'Aucun favori',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      locale == 'ar'
                          ? 'أضف دورات أو باقات إلى المفضلة من صفحة التفاصيل'
                          : 'Ajoutez des cours ou des packs aux favoris depuis la page détail',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _loadFavorites,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final favorite = list[index];
                return _buildFavoriteCard(
                  favorite,
                  locale,
                  index,
                  onDelete: () => _deleteFavorite(provider, favorite['id']),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteFavorite(ProfileProvider provider, dynamic id) async {
    if (id == null) return;
    final locale = context.read<AppLanguageProvider>().currentLanguage;
    final ok = await provider.deleteFavorite(id is int ? id : int.tryParse(id.toString()) ?? 0);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (locale == 'ar' ? 'تمت إزالته من المفضلة' : 'Retiré des favoris')
              : (locale == 'ar' ? 'فشل الحذف' : 'Échec de la suppression'),
        ),
        backgroundColor: ok ? AppColors.success : Colors.red,
      ),
    );
  }

  Widget _buildFavoriteCard(
    Map<String, dynamic> favorite,
    String locale,
    int index, {
    required VoidCallback onDelete,
  }) {
    final webinar = favorite['webinar'] as Map<String, dynamic>?;
    final favoriteId = favorite['id'];
    if (webinar == null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Iconsax.book, color: AppColors.grey300),
          title: Text(
            'Cours / Pack',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          trailing: IconButton(
            icon: const Icon(Iconsax.trash, color: Colors.red),
            onPressed: onDelete,
          ),
        ),
      );
    }
    final id = webinar['id'];
    final title = webinar['title'] ?? webinar['label'] ?? '';
    final thumbnail = webinar['thumbnail'] ?? webinar['image'] ?? webinar['image_cover'] ?? '';
    final price = webinar['price'] ?? webinar['price_with_discount'] ?? 0;
    final rate = webinar['rate'] ?? 0;
    final isBundle = webinar['type'] == 'bundle' ||
        webinar['is_bundle'] == true ||
        favorite['item_type'] == 'bundle';

    final thumbUrl = thumbnail.toString().trim().isEmpty
        ? ''
        : thumbnail.toString().startsWith('http')
            ? thumbnail.toString()
            : 'https://edufirma.com${thumbnail.toString().startsWith('/') ? '' : '/'}${thumbnail.toString()}';

    return Dismissible(
      key: ValueKey(favoriteId ?? index),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Iconsax.trash, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: () {
          if (id != null) {
            Navigator.pushNamed(
              context,
              AppRoutes.courseDetails,
              arguments: {
                'id': id is int ? id : int.tryParse(id.toString()),
                'isBundle': isBundle,
              },
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: thumbUrl.isEmpty
                    ? Container(
                        width: 110,
                        height: 100,
                        color: AppColors.grey100,
                        child: const Icon(Iconsax.book, color: AppColors.grey300, size: 36),
                      )
                    : CachedNetworkImage(
                        imageUrl: thumbUrl,
                        width: 110,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.grey100,
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 110,
                          height: 100,
                          color: AppColors.grey100,
                          child: const Icon(Iconsax.book, color: AppColors.grey300),
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBundle)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Pack',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
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
                        children: [
                          const Icon(Iconsax.star1, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rate.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            price > 0 ? '$price TND' : 'free'.tr(locale),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: price > 0 ? AppColors.primary : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Iconsax.trash, size: 16, color: Colors.red),
                            label: Text(
                              locale == 'ar' ? 'حذف' : 'Retirer',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
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
        ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index)),
      ),
    );
  }
}
