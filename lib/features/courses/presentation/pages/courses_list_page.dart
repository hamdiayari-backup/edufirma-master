import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/duration_utils.dart' show formatCourseDuration;
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/course_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';

class CoursesListPage extends StatefulWidget {
  const CoursesListPage({super.key});

  @override
  State<CoursesListPage> createState() => _CoursesListPageState();
}

class _CoursesListPageState extends State<CoursesListPage> {
  final ScrollController _scrollController = ScrollController();
  int _offset = 0;

  // Filter states
  String? _selectedCategory;
  String? _selectedSort;
  bool _freeOnly = false;
  bool _discountOnly = false;
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourses();
      // Load categories for filter
      context.read<CourseProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    await context.read<CourseProvider>().fetchCourses(
          offset: _offset,
          free: _freeOnly,
          discount: _discountOnly,
          sort: _selectedSort,
          category: _selectedCategory,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final provider = context.read<CourseProvider>();
    if (!provider.isLoadingCourses) {
      _offset += 10;
      provider.fetchCourses(
        offset: _offset,
        free: _freeOnly,
        discount: _discountOnly,
        sort: _selectedSort,
        category: _selectedCategory,
      );
    }
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    await _loadCourses();
  }

  void _applyFilter({
    String? sort,
    bool? free,
    bool? discount,
    String? category,
    String filterName = 'all',
  }) {
    setState(() {
      _offset = 0;
      _selectedSort = sort;
      _freeOnly = free ?? false;
      _discountOnly = discount ?? false;
      _selectedCategory = category;
      _activeFilter = filterName;
    });
    _loadCourses();
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
          'all_courses'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter, color: AppColors.primary),
            onPressed: () {
              _showFilterSheet(locale);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips row
          _buildFilterChipsRow(locale),
          // Courses list
          Expanded(
            child: Consumer<CourseProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingCourses && provider.courses.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (provider.courses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.book, size: 80, color: AppColors.grey300),
                        const SizedBox(height: 16),
                        Text(
                          'no_courses'.tr(locale),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _applyFilter();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: Text('reset_filter'.tr(locale)),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.courses.length + 1,
                    itemBuilder: (context, index) {
                      if (index == provider.courses.length) {
                        return provider.isLoadingCourses
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      final course = provider.courses[index];
                      return _buildCourseItem(course, index, locale);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipsRow(String locale) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickFilterChip('all'.tr(locale), 'all', onTap: () {
            _applyFilter(
              sort: null,
              free: false,
              discount: false,
              category: null,
              filterName: 'all',
            );
          }),
          const SizedBox(width: 8),
          _buildQuickFilterChip('free'.tr(locale), 'free', onTap: () {
            _applyFilter(free: true, filterName: 'free');
          }),
          const SizedBox(width: 8),
          _buildQuickFilterChip('promo'.tr(locale), 'promo', onTap: () {
            _applyFilter(discount: true, filterName: 'promo');
          }),
          const SizedBox(width: 8),
          _buildQuickFilterChip('popular'.tr(locale), 'popular', onTap: () {
            _applyFilter(sort: 'best_rates', filterName: 'popular');
          }),
          const SizedBox(width: 8),
          _buildQuickFilterChip('newest'.tr(locale), 'newest', onTap: () {
            _applyFilter(sort: 'newest', filterName: 'newest');
          }),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, String filterKey,
      {VoidCallback? onTap}) {
    final isActive = _activeFilter == filterKey;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseItem(course, int index, String locale) {
    final isFree = course.isFree;
    final hasDiscount = course.hasDiscount;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.courseDetails,
          arguments: {'id': course.id, 'isBundle': false},
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
            // Thumbnail with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: course.displayThumbnail != null &&
                          course.displayThumbnail!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: course.displayThumbnail!,
                          width: 120,
                          height: 110,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 120,
                            height: 110,
                            color: AppColors.grey100,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 120,
                            height: 110,
                            color: AppColors.grey100,
                            child: const Icon(
                              Iconsax.book,
                              color: AppColors.grey300,
                            ),
                          ),
                        )
                      : Container(
                          width: 120,
                          height: 110,
                          color: AppColors.grey100,
                          child: const Icon(
                            Iconsax.book,
                            color: AppColors.grey300,
                          ),
                        ),
                ),
                // Free badge
                if (isFree)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'free'.tr(locale),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                // Discount badge
                if (hasDiscount && !isFree)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${course.discountPercentDisplay}%',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
                    const SizedBox(height: 6),
                    // Teacher row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.grey100,
                          backgroundImage: course.teacher?.avatar != null
                              ? NetworkImage(course.teacher!.avatar!)
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            course.teacher?.fullName ?? 'instructor'.tr(locale),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Stats row
                    Row(
                      children: [
                        // Rating
                        Row(
                          children: [
                            const Icon(Iconsax.star1,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              course.rate?.toString() ?? '0',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Duration
                        if (course.duration != null &&
                            formatCourseDuration(course.duration).isNotEmpty)
                          Row(
                            children: [
                              const Icon(Iconsax.clock,
                                  size: 14, color: AppColors.grey400),
                              const SizedBox(width: 4),
                              Text(
                                formatCourseDuration(course.duration),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        const Spacer(),
                        // Price
                        if (hasDiscount && !isFree) ...[
                          Text(
                            '${course.originalPriceValue.toStringAsFixed(0)} TND',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.grey400,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          isFree
                              ? 'free'.tr(locale)
                              : '${course.displayPriceValue.toStringAsFixed(0)} TND',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                isFree ? AppColors.success : AppColors.primary,
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
    ).animate().fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 50 * (index % 10)),
        );
  }

  void _showFilterSheet(String locale) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Consumer<CourseProvider>(
                  builder: (context, provider, child) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // Handle bar
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
                            'filter_by'.tr(locale),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Category Section
                          Text(
                            'select_category'.tr(locale),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildFilterOption(
                                'all'.tr(locale),
                                _selectedCategory == null,
                                () {
                                  setModalState(() {
                                    _selectedCategory = null;
                                  });
                                },
                              ),
                              ...provider.categories.map((cat) {
                                return _buildFilterOption(
                                  cat.title ?? '',
                                  _selectedCategory == cat.id.toString(),
                                  () {
                                    setModalState(() {
                                      _selectedCategory = cat.id.toString();
                                    });
                                  },
                                );
                              }),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Sort Section
                          Text(
                            'filter'.tr(locale),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildFilterOption(
                                'newest'.tr(locale),
                                _selectedSort == 'newest',
                                () {
                                  setModalState(() {
                                    _selectedSort = _selectedSort == 'newest'
                                        ? null
                                        : 'newest';
                                  });
                                },
                              ),
                              _buildFilterOption(
                                'popular'.tr(locale),
                                _selectedSort == 'best_rates',
                                () {
                                  setModalState(() {
                                    _selectedSort =
                                        _selectedSort == 'best_rates'
                                            ? null
                                            : 'best_rates';
                                  });
                                },
                              ),
                              _buildFilterOption(
                                'price_low_high'.tr(locale),
                                _selectedSort == 'cheapest',
                                () {
                                  setModalState(() {
                                    _selectedSort = _selectedSort == 'cheapest'
                                        ? null
                                        : 'cheapest';
                                  });
                                },
                              ),
                              _buildFilterOption(
                                'price_high_low'.tr(locale),
                                _selectedSort == 'expensive',
                                () {
                                  setModalState(() {
                                    _selectedSort = _selectedSort == 'expensive'
                                        ? null
                                        : 'expensive';
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Toggles
                          Row(
                            children: [
                              Expanded(
                                child: _buildToggleOption(
                                  'free'.tr(locale),
                                  Iconsax.gift,
                                  _freeOnly,
                                  (val) {
                                    setModalState(() {
                                      _freeOnly = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildToggleOption(
                                  'discount'.tr(locale),
                                  Iconsax.discount_shape,
                                  _discountOnly,
                                  (val) {
                                    setModalState(() {
                                      _discountOnly = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setModalState(() {
                                      _selectedCategory = null;
                                      _selectedSort = null;
                                      _freeOnly = false;
                                      _discountOnly = false;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: const BorderSide(
                                        color: AppColors.primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'reset_filter'.tr(locale),
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _applyFilter(
                                      category: _selectedCategory,
                                      sort: _selectedSort,
                                      free: _freeOnly,
                                      discount: _discountOnly,
                                      filterName: 'custom',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'apply_filter'.tr(locale),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    IconData icon,
    bool isActive,
    Function(bool) onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!isActive),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.primary.withOpacity(0.1) : AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.grey400,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.grey300,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
