import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../data/models/cart_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _couponController = TextEditingController();
  bool _isApplyingCoupon = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    if (_couponController.text.trim().isEmpty) return;

    setState(() => _isApplyingCoupon = true);

    final success = await context.read<CartProvider>().validateCoupon(
      _couponController.text.trim(),
    );

    setState(() => _isApplyingCoupon = false);

    if (mounted) {
      final locale = context.read<AppLanguageProvider>().currentLanguage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'coupon_applied'.tr(locale)
              : 'coupon_invalid'.tr(locale)),
          backgroundColor: success ? AppColors.success : Colors.red,
        ),
      );
    }
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
        title: Consumer<CartProvider>(
          builder: (context, provider, child) {
            final itemCount = provider.cart?.itemCount ?? 0;
            return Text(
              itemCount > 0
                  ? '${'cart'.tr(locale)} ($itemCount)'
                  : 'cart'.tr(locale),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.cart == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final cart = provider.cart;

          if (cart == null || cart.isEmpty) {
            return _buildEmptyCart(locale);
          }

          return Stack(
            children: [
              // Cart Items List
              RefreshIndicator(
                onRefresh: () => provider.fetchCart(),
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 280),
                  children: [
                    // Cart Items
                    ...cart.items!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildCartItem(item, index, locale, provider)
                          .animate()
                          .fadeIn(
                            duration: 400.ms,
                            delay: Duration(milliseconds: 50 * index),
                          )
                          .slideX(begin: 0.1, end: 0);
                    }),

                    // User Group Discount
                    if (cart.userGroup != null) ...[
                      const SizedBox(height: 16),
                      _buildDiscountBanner(
                        icon: Iconsax.discount_shape,
                        title: '${cart.userGroup!.discount}% remise groupe',
                        subtitle: cart.userGroup!.name ?? '',
                      ),
                    ],

                    // Cashback
                    if (cart.totalCashbackAmount != null) ...[
                      const SizedBox(height: 16),
                      _buildDiscountBanner(
                        icon: Iconsax.wallet_2,
                        title: 'Cashback',
                        subtitle: 'Finalisez et recevez ${cart.totalCashbackAmount} TND',
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom Panel (Amounts & Checkout)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomPanel(cart, locale, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.shopping_cart,
              size: 60,
              color: AppColors.primary,
            ),
          ).animate().scale(duration: 500.ms),
          const SizedBox(height: 24),
          Text(
            'empty_cart'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'add_courses_to_start'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.coursesList);
            },
            icon: const Icon(Iconsax.book_1),
            label: Text(
              'explore_courses'.tr(locale),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index, String locale, CartProvider provider) {
    final itemId = item.id ?? index;
    
    return Dismissible(
      key: ValueKey('cart_item_$itemId'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Iconsax.trash, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('remove'.tr(locale), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text('Voulez-vous supprimer cet article?', style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('cancel'.tr(locale), style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('remove'.tr(locale), style: GoogleFonts.poppins(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        if (item.id != null) {
          provider.removeFromCart(item.id!);
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
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: item.image ?? '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: AppColors.grey100,
                  child: const Icon(Iconsax.book, color: AppColors.grey300),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.teacherName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.teacherName!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final displayPrice = provider.getDisplayPriceForItem(item);
                        final originalPrice = (item.price ?? 0).toDouble();
                        final hasDiscount = displayPrice < originalPrice && originalPrice > 0;
                        return Row(
                          children: [
                            Text(
                              '${displayPrice.toStringAsFixed(0)} TND',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${item.price} TND',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Delete Button
            IconButton(
              onPressed: () async {
                if (item.id == null) return;
                
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('remove'.tr(locale), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    content: Text('Voulez-vous supprimer cet article?', style: GoogleFonts.poppins()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('cancel'.tr(locale), style: GoogleFonts.poppins()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('remove'.tr(locale), style: GoogleFonts.poppins(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  provider.removeFromCart(item.id!);
                }
              },
              icon: const Icon(Iconsax.trash, color: Colors.red, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountBanner({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (color ?? AppColors.primary).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color ?? AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
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
    );
  }

  Widget _buildBottomPanel(CartModel cart, String locale, CartProvider provider) {
    final amounts = provider.getDisplayAmounts(cart) ?? cart.amounts;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coupon Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'coupon'.tr(locale),
                      hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Iconsax.ticket_discount, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isApplyingCoupon ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isApplyingCoupon
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'apply_coupon'.tr(locale),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Amount Summary
            _buildAmountRow('Sous-total', '${amounts?.subTotal ?? 0} TND'),
            _buildAmountRow('Remise', '-${amounts?.totalDiscount ?? 0} TND', isDiscount: true),
            if (amounts?.taxPrice != null && amounts!.taxPrice != 0)
              _buildAmountRow('Taxe (${amounts.tax ?? 0}%)', '${amounts.taxPrice} TND'),
            const Divider(height: 20),
            _buildAmountRow(
              'total'.tr(locale),
              '${amounts != null ? amounts!.totalDouble.toStringAsFixed(2) : '0.00'} TND',
              isTotal: true,
            ),

            const SizedBox(height: 16),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(context, AppRoutes.checkout);
                      },
                icon: const Icon(Iconsax.card),
                label: Text(
                  'checkout'.tr(locale),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isDiscount
                  ? AppColors.success
                  : isTotal
                      ? AppColors.primary
                      : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
