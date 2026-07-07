import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/course_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../courses/data/models/category_model.dart';

class CategoriesListPage extends StatefulWidget {
  const CategoriesListPage({super.key});

  @override
  State<CategoriesListPage> createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends State<CategoriesListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    await context.read<CourseProvider>().fetchCategories();
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
          'categories'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingCategories) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final categories = provider.categories;

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.category,
                    size: 80,
                    color: AppColors.grey300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    locale == 'ar' ? 'لا توجد فئات' : 'Aucune catégorie',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadCategories,
            color: AppColors.primary,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(
                  context,
                  category,
                  index,
                  locale,
                )
                    .animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: 50 * index),
                    )
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                    );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    CategoryModel category,
    int index,
    String locale,
  ) {
    final title = category.title ?? '';
    final imageUrl = category.imageUrl;
    final coursesCount = category.webinarsCount ?? category.coursesCount ?? 0;
    final color = _getCategoryColor(index);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.categoryCourses,
          arguments: {
            'categoryId': category.id ?? 0,
            'categoryTitle': title,
            'category': category,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
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
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color, color.withOpacity(0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Iconsax.category,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Iconsax.category,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
              ),
            ),
            // Title and count
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Iconsax.video_play,
                          size: 14,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$coursesCount ${locale == 'ar' ? 'دورة' : 'cours'}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
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

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF7CB342), // Green
      const Color(0xFF42A5F5), // Blue
      const Color(0xFFFF7043), // Orange
      const Color(0xFFAB47BC), // Purple
      const Color(0xFF26A69A), // Teal
      const Color(0xFFEC407A), // Pink
      const Color(0xFF5C6BC0), // Indigo
      const Color(0xFFFFCA28), // Amber
      const Color(0xFF66BB6A), // Light Green
      const Color(0xFFEF5350), // Red
      const Color(0xFF29B6F6), // Light Blue
      const Color(0xFF8D6E63), // Brown
    ];
    return colors[index % colors.length];
  }
}
