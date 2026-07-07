import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../courses/data/models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final bool isBundle;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.isBundle = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: course.displayThumbnail != null &&
                          course.displayThumbnail!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: course.displayThumbnail!,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 130,
                            color: AppColors.grey100,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 130,
                            color: AppColors.grey100,
                            child: const Icon(
                              Iconsax.image,
                              color: AppColors.grey300,
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          height: 130,
                          color: AppColors.grey100,
                          child: const Icon(
                            Iconsax.book,
                            color: AppColors.grey300,
                            size: 40,
                          ),
                        ),
                ),
                // Bundle Badge
                if (isBundle)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
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
                  ),
                // Price Badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course.isFree ? 'Gratuit' : course.displayPrice,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // Teacher & Rating
                    Row(
                      children: [
                        // Teacher Avatar
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.grey100,
                          backgroundImage: course.teacher?.avatar != null
                              ? NetworkImage(course.teacher!.avatar!)
                              : null,
                          child: course.teacher?.avatar == null
                              ? const Icon(
                                  Iconsax.user,
                                  size: 14,
                                  color: AppColors.grey300,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            course.teacher?.fullName ?? 'Formateur',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        // Rating
                        Icon(
                          Iconsax.star1,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.rate?.toString() ?? '0',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
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
      ),
    );
  }
}
