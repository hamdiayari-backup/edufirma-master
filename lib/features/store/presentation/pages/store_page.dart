import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/store_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/services/store_service.dart';
import '../../../cart/presentation/pages/payment_webview_page.dart';
import '../../../home/presentation/widgets/category_card.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../widgets/shipping_address_modal.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final storeProvider = context.read<StoreProvider>();
    // Load initial data: all products and categories
    await storeProvider.loadInitialData();
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Modern gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.background,
                  AppColors.primarySurface.withOpacity(0.2),
                  AppColors.background,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withOpacity(0.12),
                    AppColors.primary.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primarySurface.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryLight.withOpacity(0.1),
                      AppColors.primarySurface.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 500,
            left: 50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primarySurface.withOpacity(0.2),
                    AppColors.primaryLight.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Boutique',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              bottom: _tabController == null
                  ? null
                  : TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      labelStyle:
                          GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      tabs: const [
                        Tab(text: 'Produits'),
                        Tab(text: 'Panier'),
                      ],
                    ),
              actions: [
                Consumer<StoreProvider>(
                  builder: (context, provider, child) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Iconsax.shopping_cart,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            _tabController?.animateTo(1);
                          },
                        ),
                        if (provider.cartItemCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${provider.cartItemCount}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            body: _tabController == null
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductsTab(),
                      _buildCartTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: Consumer<StoreProvider>(
        builder: (context, provider, child) {
          // Show loading only on initial load
          if (provider.isLoading &&
              provider.products.isEmpty &&
              provider.categories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Categories section
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildCategories(provider),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Loading indicator for products refresh
              if (provider.isLoading && provider.products.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                ),

              // Products Grid
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: provider.products.isEmpty
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
                            final product = provider.products[index];
                            return _buildProductCard(product, index);
                          },
                          childCount: provider.products.length,
                        ),
                      ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartTab() {
    return Consumer<StoreProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final cart = provider.cart;
        final items = cart?['items'] as List? ?? [];

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.shopping_cart,
                  size: 80,
                  color: AppColors.grey300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Votre panier est vide',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajoutez des produits pour commencer',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.grey400,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _tabController?.animateTo(0),
                  icon: const Icon(Iconsax.shopping_bag),
                  label: const Text('Voir les produits'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildCartItem(item, provider);
                },
              ),
            ),
            _buildCartSummary(provider),
          ],
        );
      },
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, StoreProvider provider) {
    final title = item['title']?.toString() ?? 'Produit';
    final image = item['image']?.toString() ?? '';
    double price = 0.0;
    int quantity = 1;

    if (item['type'] == 'product' &&
        item['item_data']?['product_order'] != null) {
      var productOrder = item['item_data']['product_order'];
      if (productOrder['product'] != null) {
        price = (productOrder['product']['price'] ?? 0).toDouble();
        quantity = productOrder['quantity'] ?? 1;
      }
    } else {
      price = (item['price'] ?? 0).toDouble();
      quantity = item['quantity'] ?? 1;
    }

    final imageUrl =
        image.startsWith('http') ? image : 'https://edufirma.com$image';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.grey100,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.grey100,
                child: const Icon(Iconsax.image, color: AppColors.grey300),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantité: $quantity',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(price * quantity).toStringAsFixed(2)} TND',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, color: Colors.red),
            onPressed: () async {
              final success =
                  await provider.removeFromCart(item['id'].toString());
              if (mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la suppression'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildCartSummary(StoreProvider provider) {
    final cart = provider.cart;
    final items = cart?['items'] as List? ?? [];

    double total = 0.0;
    for (var item in items) {
      double price = 0.0;
      int quantity = 1;

      if (item['type'] == 'product' &&
          item['item_data']?['product_order'] != null) {
        var productOrder = item['item_data']['product_order'];
        if (productOrder['product'] != null) {
          price = (productOrder['product']['price'] ?? 0).toDouble();
          quantity = productOrder['quantity'] ?? 1;
        }
      } else {
        price = (item['price'] ?? 0).toDouble();
        quantity = item['quantity'] ?? 1;
      }
      total += price * quantity;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} TND',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final hasPhysicalItem =
                      provider.cart?['has_physical_item'] == true;
                  Map<String, dynamic>? shippingAddress;

                  if (hasPhysicalItem) {
                    shippingAddress =
                        await showModalBottomSheet<Map<String, dynamic>>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: const ShippingAddressModal(),
                      ),
                    );

                    if (shippingAddress == null) {
                      return;
                    }
                  }

                  final paymentUrl = await provider.createOrderWithPayment(
                    shippingAddress: shippingAddress,
                  );

                  if (paymentUrl != null && mounted) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentWebViewPage(
                          url: paymentUrl,
                          title: 'Paiement',
                        ),
                      ),
                    );

                    if (result == true && mounted) {
                      await provider.fetchCart();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Paiement effectué avec succès!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage ??
                            'Erreur lors de la création de la commande'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Passer la commande',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(StoreProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        SectionHeader(
          title: 'Catégories',
          onSeeAll: null,
        ),
        const SizedBox(height: 15),
        provider.isLoading && provider.categories.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            : Padding(
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
                  itemCount: provider.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // "Tous" card - shows ALL products
                      return CategoryCard(
                        title: 'Tous',
                        icon: Iconsax.category,
                        color: AppColors.primary,
                        imageUrl: null,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.storeCategoryProducts,
                            arguments: {
                              'categoryId': null, // null = all products
                              'categoryTitle': 'Tous les produits',
                              'category': null,
                            },
                          );
                        },
                      );
                    }

                    final category = provider.categories[index - 1];
                    final categoryId = category['id'];
                    final title = StoreService.getCategoryTitle(category);
                    final imageUrl = _getCategoryImage(category);

                    return CategoryCard(
                      title: title.isNotEmpty ? title : 'Catégorie $categoryId',
                      icon: _getCategoryIcon(index - 1),
                      color: _getCategoryColor(index - 1),
                      imageUrl: imageUrl,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.storeCategoryProducts,
                          arguments: {
                            'categoryId': categoryId,
                            'categoryTitle': title,
                            'category': category,
                          },
                        );
                      },
                    );
                  },
                ),
              ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
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
                    if (sellerName.isNotEmpty)
                      Row(
                        children: [
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
