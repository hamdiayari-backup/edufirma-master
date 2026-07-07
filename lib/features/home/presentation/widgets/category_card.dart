import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? imageUrl;
  final VoidCallback? onTap;
  final double? iconSize;
  final double? iconContainerSize;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.imageUrl,
    this.onTap,
    this.iconSize,
    this.iconContainerSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconContainerSize ?? 32,
              height: iconContainerSize ?? 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: color.withOpacity(0.1),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: color,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          icon,
                          color: color,
                          size: iconSize ?? 16,
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: color,
                      size: iconSize ?? 16,
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
