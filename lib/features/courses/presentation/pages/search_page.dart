import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/course_provider.dart';
import '../../data/models/course_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<CourseModel> _searchResults = [];
  List<Map<String, dynamic>> _usersResults = [];
  List<Map<String, dynamic>> _organizationsResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  // Filters
  String? _selectedSort;
  String? _selectedCategory;
  bool _freeOnly = false;
  bool _discountOnly = false;

  final List<Map<String, String>> _sortOptions = [
    {'value': 'newest', 'label': 'Plus récent'},
    {'value': 'oldest', 'label': 'Plus ancien'},
    {'value': 'expensive', 'label': 'Prix décroissant'},
    {'value': 'cheap', 'label': 'Prix croissant'},
    {'value': 'best_sellers', 'label': 'Meilleures ventes'},
    {'value': 'best_rates', 'label': 'Mieux notés'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final result = await context.read<CourseProvider>().search(query);

      setState(() {
        _searchResults = result['courses'] ?? [];
        _usersResults = List<Map<String, dynamic>>.from(result['users'] ?? []);
        _organizationsResults =
            List<Map<String, dynamic>>.from(result['organizations'] ?? []);
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showFilterSheet() {
    final categories = context.read<CourseProvider>().categories;

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
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtres',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedSort = null;
                          _selectedCategory = null;
                          _freeOnly = false;
                          _discountOnly = false;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Réinitialiser',
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sort
                      Text(
                        'Trier par',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _sortOptions.map((option) {
                          final isSelected = _selectedSort == option['value'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSort =
                                    isSelected ? null : option['value'];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.grey100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                option['label']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Categories
                      Text(
                        'Catégorie',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((cat) {
                          final isSelected =
                              _selectedCategory == cat.id?.toString();
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory =
                                    isSelected ? null : cat.id?.toString();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.grey100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cat.title ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Toggles
                      SwitchListTile(
                        title: Text(
                          'Cours gratuits uniquement',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        value: _freeOnly,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _freeOnly = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: Text(
                          'En promotion uniquement',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        value: _discountOnly,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _discountOnly = value;
                          });
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Apply Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Appliquer les filtres',
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

  Future<void> _applyFilters() async {
    setState(() => _isSearching = true);

    try {
      final query = _searchController.text.trim();
      // If user has search results, filter them client-side so we don't lose the search.
      if (query.isNotEmpty && _searchResults.isNotEmpty) {
        List<CourseModel> filtered = _searchResults.where((c) {
          if (_selectedCategory != null &&
              c.categoryId?.toString() != _selectedCategory) return false;
          if (_freeOnly && !c.isFree) return false;
          if (_discountOnly && !c.hasDiscount) return false;
          return true;
        }).toList();
        _sortCourseList(filtered);
        setState(() {
          _searchResults = filtered;
          _hasSearched = true;
          _isSearching = false;
        });
        return;
      }
      // No search query or empty results: load filtered catalog from API.
      await context.read<CourseProvider>().fetchCourses(
            sort: _selectedSort,
            category: _selectedCategory,
            free: _freeOnly,
            discount: _discountOnly,
          );

      final courses = context.read<CourseProvider>().courses;
      setState(() {
        _searchResults = courses;
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _sortCourseList(List<CourseModel> list) {
    if (_selectedSort == null) return;
    switch (_selectedSort!) {
      case 'newest':
        list.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
        break;
      case 'oldest':
        list.sort((a, b) => (a.createdAt ?? 0).compareTo(b.createdAt ?? 0));
        break;
      case 'expensive':
        list.sort((a, b) =>
            b.displayPriceValue.compareTo(a.displayPriceValue));
        break;
      case 'cheap':
      case 'cheapest':
        list.sort((a, b) =>
            a.displayPriceValue.compareTo(b.displayPriceValue));
        break;
      case 'best_rates':
        list.sort((a, b) {
          final ra = double.tryParse(a.rate ?? '0') ?? 0;
          final rb = double.tryParse(b.rate ?? '0') ?? 0;
          return rb.compareTo(ra);
        });
        break;
      case 'best_sellers':
        list.sort((a, b) =>
            (b.studentsCount ?? 0).compareTo(a.studentsCount ?? 0));
        break;
    }
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
          'Rechercher',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Rechercher des cours, formateurs...',
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Iconsax.search_normal,
                          color: AppColors.primary,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Iconsax.close_circle,
                                    color: AppColors.grey400),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults = [];
                                    _hasSearched = false;
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      onSubmitted: _performSearch,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Iconsax.filter, color: Colors.white),
                        if (_selectedSort != null ||
                            _selectedCategory != null ||
                            _freeOnly ||
                            _discountOnly)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active Filters
          if (_selectedSort != null ||
              _selectedCategory != null ||
              _freeOnly ||
              _discountOnly)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (_selectedSort != null)
                    _buildFilterChip(
                      _sortOptions.firstWhere(
                        (o) => o['value'] == _selectedSort,
                        orElse: () => {'label': ''},
                      )['label']!,
                      () => setState(() => _selectedSort = null),
                    ),
                  if (_selectedCategory != null)
                    _buildFilterChip(
                      'Catégorie',
                      () => setState(() => _selectedCategory = null),
                    ),
                  if (_freeOnly)
                    _buildFilterChip(
                      'Gratuit',
                      () => setState(() => _freeOnly = false),
                    ),
                  if (_discountOnly)
                    _buildFilterChip(
                      'En promo',
                      () => setState(() => _discountOnly = false),
                    ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : !_hasSearched
                    ? _buildInitialState()
                    : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Iconsax.close_circle,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.search_normal, size: 80, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            'Recherchez des cours',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tapez pour trouver des cours, formateurs\net organisations',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_searchResults.isEmpty &&
        _usersResults.isEmpty &&
        _organizationsResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.search_status, size: 80, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez avec d\'autres mots-clés',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.grey400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Courses Section
        if (_searchResults.isNotEmpty) ...[
          Text(
            'Cours (${_searchResults.length})',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _searchResults.length,
            (index) => _buildCourseCard(_searchResults[index], index),
          ),
          const SizedBox(height: 24),
        ],

        // Users Section
        if (_usersResults.isNotEmpty) ...[
          Text(
            'Formateurs (${_usersResults.length})',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _usersResults.length,
            (index) => _buildUserCard(_usersResults[index], index),
          ),
          const SizedBox(height: 24),
        ],

        // Organizations Section
        if (_organizationsResults.isNotEmpty) ...[
          Text(
            'Organisations (${_organizationsResults.length})',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _organizationsResults.length,
            (index) => _buildUserCard(_organizationsResults[index], index,
                isOrg: true),
          ),
        ],

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildCourseCard(CourseModel course, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.courseDetails,
          arguments: {'id': course.id, 'isBundle': course.type == 'bundle'},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: course.displayThumbnail ?? '',
                width: 100,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.grey100),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.grey100,
                  child: const Icon(Iconsax.book),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Iconsax.star1, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        course.rate ?? '0',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        course.teacher?.fullName ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.displayPrice,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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

  Widget _buildUserCard(Map<String, dynamic> user, int index,
      {bool isOrg = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.grey100,
            backgroundImage:
                user['avatar'] != null ? NetworkImage(user['avatar']) : null,
            child: user['avatar'] == null
                ? Icon(
                    isOrg ? Iconsax.building : Iconsax.user,
                    color: AppColors.grey300,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['full_name'] ?? 'Utilisateur',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (user['bio'] != null)
                  Text(
                    user['bio'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                Row(
                  children: [
                    const Icon(Iconsax.star1, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      user['rate']?.toString() ?? '0',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.arrow_right_3, color: AppColors.primary),
            onPressed: () {
              // Navigate to user profile
            },
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: 50 * index),
        );
  }
}
