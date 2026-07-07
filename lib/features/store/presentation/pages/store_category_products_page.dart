import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../providers/store_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/services/store_service.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../../../home/presentation/widgets/category_card.dart';

class StoreCategoryProductsPage extends StatefulWidget {
  final int? categoryId;
  final String categoryTitle;
  final Map<String, dynamic>? category;

  const StoreCategoryProductsPage({
    super.key,
    this.categoryId,
    required this.categoryTitle,
    this.category,
  });

  @override
  State<StoreCategoryProductsPage> createState() =>
      _StoreCategoryProductsPageState();
}

class _StoreCategoryProductsPageState extends State<StoreCategoryProductsPage> {
  int? _selectedSubCategoryId;
  Map<String, dynamic>? _fullCategory;
  List<Map<String, dynamic>> _allProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCategory();
    });
  }

  Future<void> _initializeCategory() async {
    final storeProvider = context.read<StoreProvider>();

    // Fetch categories if not loaded
    if (storeProvider.categories.isEmpty) {
      await storeProvider.fetchCategories();
    }

    // Find the full category with subcategories
    if (widget.categoryId != null) {
      _fullCategory = storeProvider.categories.firstWhere(
        (cat) => cat['id'] == widget.categoryId,
        orElse: () => widget.category ?? {},
      );
    }

    await _loadData();
  }

  Future<void> _loadData({int? subCategoryId}) async {
    setState(() => _isLoading = true);

    final storeProvider = context.read<StoreProvider>();

    try {
      if (subCategoryId != null) {
        // Load specific subcategory products
        await storeProvider.fetchProducts(categoryId: subCategoryId.toString());
        _allProducts = List.from(storeProvider.products);
      } else if (widget.categoryId != null) {
        // Load parent category - get products from all subcategories
        final subCategories = _fullCategory?['sub_categories'] as List? ?? [];

        if (subCategories.isNotEmpty) {
          // Fetch products from all subcategories IN PARALLEL
          _allProducts = [];
          final futures = <Future<List<Map<String, dynamic>>>>[];

          for (var subCat in subCategories) {
            final subCatId = subCat['id'];
            futures.add(storeProvider.storeService
                .getProducts(categoryId: subCatId.toString()));
          }

          // Wait for all requests to complete
          final results = await Future.wait(futures);
          final seenIds = <dynamic>{};
          for (var productList in results) {
            for (var map in productList) {
              final id = map['id'];
              if (id == null || !seenIds.contains(id)) {
                if (id != null) seenIds.add(id);
                _allProducts.add(map);
              }
            }
          }
        } else {
          // No subcategories, fetch directly from this category
          await storeProvider.fetchProducts(
              categoryId: widget.categoryId.toString());
          _allProducts = List.from(storeProvider.products);
        }
      } else {
        // Load all products (when categoryId is null - "Tous")
        await storeProvider.fetchProducts();
        _allProducts = List.from(storeProvider.products);
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

  Future<void> _onRefresh() async {
    await _loadData(subCategoryId: _selectedSubCategoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.categoryTitle,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: _isLoading && _allProducts.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // Subcategories navigation
                  SliverToBoxAdapter(
                    child: _buildSubCategories(),
                  ),

                  // Loading indicator
                  if (_isLoading && _allProducts.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      ),
                    ),

                  // Products Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: _allProducts.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 50),
                                  Icon(
                                    Iconsax.box,
                                    size: 80,
                                    color: AppColors.grey300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun produit disponible',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = _allProducts[index];
                                return _buildProductCard(product, index);
                              },
                              childCount: _allProducts.length,
                            ),
                          ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSubCategories() {
    // Don't show subcategories for "Tous les produits"
    if (widget.categoryId == null) {
      return const SizedBox.shrink();
    }

    final subCategories = _fullCategory?['sub_categories'] as List? ?? [];

    if (subCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        SectionHeader(
          title: 'Sous-catégories',
          onSeeAll: null,
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: subCategories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // "Tous" card - shows all products from parent category
                return CategoryCard(
                  title: 'Tous',
                  icon: Iconsax.category,
                  color: _selectedSubCategoryId == null
                      ? AppColors.primary
                      : AppColors.grey400,
                  imageUrl: null,
                  onTap: () => _onSubCategorySelected(null),
                );
              }
              final subCategory = subCategories[index - 1];
              final subCategoryId = subCategory['id'];
              final title = StoreService.getCategoryTitle(subCategory);
              final imageUrl = _getCategoryImage(subCategory);
              final isSelected = _selectedSubCategoryId == subCategoryId;

              return CategoryCard(
                title:
                    title.isNotEmpty ? title : 'Sous-catégorie $subCategoryId',
                icon: _getCategoryIcon(index - 1),
                color: isSelected
                    ? AppColors.primary
                    : _getCategoryColor(index - 1),
                imageUrl: imageUrl,
                onTap: () => _onSubCategorySelected(subCategoryId),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  String? _getCategoryImage(Map<String, dynamic> category) {
    try {
      final icon = category['icon']?.toString();
      final image = category['image']?.toString();
      final thumbnail = category['thumbnail']?.toString();

      String? imageUrl = icon ?? image ?? thumbnail;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        if (!imageUrl.startsWith('http')) {
          return 'https://edufirma.com$imageUrl';
        }
        return imageUrl;
      }
    } catch (e) {
      debugPrint('Error getting category image: $e');
    }
    return null;
  }

  IconData _getCategoryIcon(int index) {
    final icons = [
      Iconsax.shop,
      Iconsax.box,
      Iconsax.bag,
      Iconsax.tag,
      Iconsax.category,
      Iconsax.grid_1,
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
    ];
    return colors[index % colors.length];
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    final title = StoreService.getProductTitle(product);
    final imageUrl = StoreService.getProductImage(product);
    final price = StoreService.getProductPrice(product);
    final seller = product['seller'];
    final sellerName = seller?['full_name']?.toString() ?? '';
    final sellerAvatar = seller?['avatar']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        _showProductDetails(product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppColors.grey100,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.grey100,
                          child: const Icon(
                            Iconsax.image,
                            color: AppColors.grey300,
                            size: 40,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.grey100,
                        child: const Icon(
                          Iconsax.box,
                          color: AppColors.grey300,
                          size: 40,
                        ),
                      ),
              ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.isNotEmpty ? title : 'Produit',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // Seller info with avatar
                    if (sellerName.isNotEmpty)
                      Row(
                        children: [
                          // Seller avatar
                          if (sellerAvatar.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: sellerAvatar.startsWith('http')
                                      ? sellerAvatar
                                      : 'https://edufirma.com$sellerAvatar',
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 18,
                                    height: 18,
                                    color: AppColors.grey200,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Iconsax.user,
                                      size: 10,
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Seller name
                          Expanded(
                            child: Text(
                              sellerName,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${price.toStringAsFixed(2)} TND',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final authProvider = context.read<AuthProvider>();
                            final storeProvider = context.read<StoreProvider>();

                            if (!authProvider.isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Veuillez vous connecter'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final result = await storeProvider.addToCart(
                              product['id']?.toString() ?? '',
                            );

                            if (mounted) {
                              final success = result['success'] == true;
                              String message = success
                                  ? 'Ajouté au panier'
                                  : result['message'] ??
                                      'Erreur lors de l\'ajout';

                              if (message.contains('insufficient stock')) {
                                message = 'Stock insuffisant';
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor:
                                      success ? AppColors.success : Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Iconsax.shopping_cart,
                              size: 18,
                              color: AppColors.primary,
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
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
  }

  void _showProductDetails(Map<String, dynamic> product) {
    final title = StoreService.getProductTitle(product);
    final imageUrl = StoreService.getProductImage(product);
    final price = StoreService.getProductPrice(product);
    final description = product['description']?.toString() ?? '';
    final seller = product['seller'];
    final sellerName = seller?['full_name']?.toString() ?? '';
    final sellerAvatar = seller?['avatar']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
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
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      if (imageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${price.toStringAsFixed(2)} TND',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),

                            // Seller info
                            if (sellerName.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: sellerAvatar.isNotEmpty
                                        ? NetworkImage(sellerAvatar)
                                        : null,
                                    child: sellerAvatar.isEmpty
                                        ? const Icon(Iconsax.user)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vendu par',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        sellerName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],

                            // Description
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 12),
                              Text(
                                'Description',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _cleanHtml(description),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ],

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom action
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final authProvider = context.read<AuthProvider>();
                        final storeProvider = context.read<StoreProvider>();

                        if (!authProvider.isLoggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez vous connecter'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final result = await storeProvider.addToCart(
                          product['id']?.toString() ?? '',
                        );

                        if (context.mounted) {
                          Navigator.pop(context);

                          final success = result['success'] == true;
                          String message = success
                              ? 'Ajouté au panier'
                              : result['message'] ?? 'Erreur lors de l\'ajout';

                          if (message.contains('insufficient_stock')) {
                            message = 'Stock insuffisant pour ce produit';
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor:
                                  success ? AppColors.primary : Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Iconsax.shopping_cart),
                      label: const Text('Ajouter au panier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }
}
