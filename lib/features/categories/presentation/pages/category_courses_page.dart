import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/course_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../home/presentation/widgets/course_card.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../../../courses/data/models/category_model.dart';

class CategoryCoursesPage extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;
  final CategoryModel? category;

  const CategoryCoursesPage({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    this.category,
  });

  @override
  State<CategoryCoursesPage> createState() => _CategoryCoursesPageState();
}

class _CategoryCoursesPageState extends State<CategoryCoursesPage> {
  int? _selectedSubCategoryId;

  CategoryModel? _fullCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCategory();
    });
  }

  Future<void> _initializeCategory() async {
    // If category doesn't have subcategories loaded, fetch the full category
    if (widget.category?.subCategories == null) {
      final courseProvider = context.read<CourseProvider>();
      await courseProvider.fetchCategories();

      // Find the category with subcategories
      final categories = courseProvider.categories;
      _fullCategory = categories.firstWhere(
        (cat) => cat.id == widget.categoryId,
        orElse: () =>
            widget.category ??
            CategoryModel(id: widget.categoryId, title: widget.categoryTitle),
      );
    } else {
      _fullCategory = widget.category;
    }

    await _loadData();
  }

  Future<void> _loadData({int? subCategoryId}) async {
    final courseProvider = context.read<CourseProvider>();

    // If a subcategory is selected, filter by it
    if (subCategoryId != null) {
      debugPrint('=== Loading courses for subcategory $subCategoryId ===');
      await Future.wait([
        courseProvider.fetchCourses(category: subCategoryId.toString()),
        courseProvider.fetchBundles(category: subCategoryId.toString()),
      ]);
    } else {
      debugPrint('=== Loading courses for category ${widget.categoryId} ===');
      debugPrint('Category Title: ${widget.categoryTitle}');

      // Get all courses from all subcategories
      final subCategories =
          _fullCategory?.subCategories ?? widget.category?.subCategories;
      if (subCategories != null && subCategories.isNotEmpty) {
        debugPrint('Found ${subCategories.length} subcategories');

        // Collect all subcategory IDs
        List<int> subCategoryIds = subCategories
            .where((subCat) => subCat.id != null)
            .map((subCat) => subCat.id!)
            .toList();

        // Also include parent category ID
        subCategoryIds.insert(0, widget.categoryId);

        // Fetch courses from all subcategories and merge them
        await Future.wait([
          courseProvider.fetchCoursesFromMultipleCategories(subCategoryIds),
          courseProvider.fetchBundles(category: widget.categoryId.toString()),
        ]);
      } else {
        // No subcategories, try direct category
        await Future.wait([
          courseProvider.fetchCourses(category: widget.categoryId.toString()),
          courseProvider.fetchBundles(category: widget.categoryId.toString()),
        ]);
      }
    }
  }

  void _onSubCategorySelected(int? subCategoryId) {
    setState(() {
      _selectedSubCategoryId =
          subCategoryId == _selectedSubCategoryId ? null : subCategoryId;
    });
    _loadData(subCategoryId: _selectedSubCategoryId);
  }

  Widget _buildSubCategories(String locale) {
    final subCategories =
        _fullCategory?.subCategories ?? widget.category?.subCategories ?? [];

    if (subCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        SectionHeader(
          title: 'subcategories'.tr(locale),
          onSeeAll: null,
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: subCategories.length + 1, // +1 for "All" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All" option
                final isSelected = _selectedSubCategoryId == null;
                return GestureDetector(
                  onTap: () => _onSubCategorySelected(null),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.grey300,
                        width: isSelected ? 0 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? AppColors.buttonShadow
                          : AppColors.cardShadow,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.white.withOpacity(0.2)
                                : AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Iconsax.category,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tous',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final subCategory = subCategories[index - 1];
              final isSelected = _selectedSubCategoryId == subCategory.id;

              return GestureDetector(
                onTap: () => _onSubCategorySelected(subCategory.id),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.grey300,
                      width: isSelected ? 0 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? AppColors.buttonShadow
                        : AppColors.cardShadow,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.white.withOpacity(0.2)
                              : _getCategoryColor(index - 1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: subCategory.imageUrl != null &&
                                subCategory.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: subCategory.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: _getCategoryColor(index - 1)
                                        .withOpacity(0.1),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _getCategoryColor(index - 1),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    _getCategoryIcon(index - 1),
                                    color: isSelected
                                        ? AppColors.white
                                        : _getCategoryColor(index - 1),
                                    size: 24,
                                  ),
                                ),
                              )
                            : Icon(
                                _getCategoryIcon(index - 1),
                                color: isSelected
                                    ? AppColors.white
                                    : _getCategoryColor(index - 1),
                                size: 24,
                              ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subCategory.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(int index) {
    final icons = [
      Iconsax.code,
      Iconsax.paintbucket,
      Iconsax.chart,
      Iconsax.language_square,
      Iconsax.music,
      Iconsax.camera,
      Iconsax.book,
      Iconsax.video_play,
    ];
    return icons[index % icons.length];
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.blue,
    ];
    return colors[index % colors.length];
  }

  Future<void> _onRefresh() async {
    await _loadData();
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
          widget.categoryTitle,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Category Header with Image
            if (_fullCategory != null || widget.category != null)
              SliverToBoxAdapter(
                child: _buildCategoryHeader(
                    _fullCategory ?? widget.category!, locale),
              ),
            // Subcategories Cards (if they exist)
            if ((_fullCategory?.subCategories != null &&
                    _fullCategory!.subCategories!.isNotEmpty) ||
                (widget.category?.subCategories != null &&
                    widget.category!.subCategories!.isNotEmpty))
              SliverToBoxAdapter(
                child: _buildSubCategories(locale),
              ),
            // All Courses
            SliverToBoxAdapter(
              child: _buildAllCourses(locale),
            ),
            // Bundles
            SliverToBoxAdapter(
              child: _buildBundles(locale),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(CategoryModel category, String locale) {
    final imageUrl = category.imageUrl;
    final coursesCount = category.webinarsCount ?? category.coursesCount ?? 0;
    final bundlesCount = category.bundlesCount ?? 0;
    final totalCount = coursesCount + bundlesCount;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Category Image (small)
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.grey100,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.category,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Iconsax.category,
                size: 30,
                color: AppColors.primary,
              ),
            ),
          const SizedBox(width: 16),
          // Category Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Iconsax.video_play,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$totalCount ${locale == 'ar' ? 'دورة' : totalCount > 1 ? 'cours' : 'cours'}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildAllCourses(String locale) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final courses = provider.courses;

        return Column(
          children: [
            const SizedBox(height: 25),
            SectionHeader(
              title: 'all_courses'.tr(locale),
              onSeeAll: null,
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 280,
              child: provider.isLoadingCourses
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : courses.isEmpty
                      ? Center(
                          child: Text(
                            'no_courses'.tr(locale),
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return CourseCard(
                              course: course,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.courseDetails,
                                  arguments: {
                                    'id': course.id,
                                    'isBundle': false
                                  },
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
      },
    );
  }

  Widget _buildBundles(String locale) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final bundles = provider.bundles;

        return Column(
          children: [
            const SizedBox(height: 25),
            SectionHeader(
              title: 'bundles'.tr(locale),
              onSeeAll: null,
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 280,
              child: provider.isLoadingBundles
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : bundles.isEmpty
                      ? Center(
                          child: Text(
                            'no_data'.tr(locale),
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: bundles.length,
                          itemBuilder: (context, index) {
                            final bundle = bundles[index];
                            return CourseCard(
                              course: bundle,
                              isBundle: true,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.courseDetails,
                                  arguments: {
                                    'id': bundle.id,
                                    'isBundle': true
                                  },
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
      },
    );
  }
}



