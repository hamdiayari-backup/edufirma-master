import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/store_service.dart';
import '../../../../providers/store_provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  /// Cache des noms de produits (product_id -> titre) pour afficher les noms dans les commandes.
  Map<String, String> _productNames = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    final storeProvider = context.read<StoreProvider>();
    final cartProvider = context.read<CartProvider>();
    await Future.wait([
      storeProvider.fetchOrders(page: 1),
      cartProvider.fetchPanelOrders(page: 1),
    ]);
    if (!mounted) return;

    final orders = storeProvider.orders;
    final productIds = <String>{};
    for (final order in orders) {
      final id = order['product_id']?.toString();
      if (id != null && id.isNotEmpty) productIds.add(id);
    }

    if (productIds.isNotEmpty) {
      final storeService = storeProvider.storeService;
      final names = <String, String>{};
      for (final id in productIds) {
        if (!mounted) break;
        final product = await storeService.getProductDetails(id);
        if (product != null) {
          final title = StoreService.getProductTitle(product);
          if (title.isNotEmpty) names[id] = title;
        }
      }
      if (mounted) setState(() => _productNames = names);
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
        title: Text(
          'my_orders'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Consumer2<StoreProvider, CartProvider>(
        builder: (context, storeProvider, cartProvider, child) {
          final storeLoading = storeProvider.isLoading && storeProvider.orders.isEmpty;
          final panelLoading = cartProvider.isLoadingPanelOrders && cartProvider.panelOrders.isEmpty;
          if (storeLoading && panelLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final hasStoreOrders = storeProvider.orders.isNotEmpty;
          final hasPanelOrders = cartProvider.panelOrders.isNotEmpty;
          if (!hasStoreOrders && !hasPanelOrders) {
            return _buildEmptyState(locale);
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (hasPanelOrders) ...[
                  _sectionTitle(locale, locale == 'ar' ? 'طلبات الدورات وال packs' : 'Commandes cours & packs'),
                  ...List.generate(cartProvider.panelOrders.length, (index) {
                    return _buildPanelOrderCard(
                        cartProvider.panelOrders[index], locale, index);
                  }),
                  const SizedBox(height: 24),
                ],
                if (hasStoreOrders) ...[
                  _sectionTitle(locale, locale == 'ar' ? 'طلبات المتجر' : 'Commandes boutique'),
                  ...List.generate(storeProvider.orders.length, (index) {
                    return _buildOrderCard(
                        storeProvider.orders[index], locale, index, _productNames);
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String locale, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// Resolve effective status for panel order (cours/pack). Backend may use status, payment_status, sale.status or 0/1.
  dynamic _panelOrderStatusValue(Map<String, dynamic> order) {
    dynamic v = order['status'] ?? order['payment_status'] ?? order['order_status'];
    if (v != null) return v;
    final sale = order['sale'];
    if (sale is Map<String, dynamic>) {
      return sale['status'] ?? sale['payment_status'];
    }
    return null;
  }

  /// Build card for panel order (course/bundle/offline). Uses same status/date/total helpers.
  Widget _buildPanelOrderCard(Map<String, dynamic> order, String locale, int index) {
    final orderId = order['id'] ?? order['order_id'] ?? '#—';
    final statusVal = _panelOrderStatusValue(order);
    final status = _orderStatus(statusVal);
    final statusLabel = _orderStatusLabel(statusVal, locale);
    final total = _orderTotal(order);
    final dateStr = _orderDate(order, locale);
    final productLines = _panelOrderProductLines(order, locale);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale == 'ar' ? 'طلب' : 'Commande',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: status.color.withOpacity(0.5), width: 1),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: status.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '#${orderId.toString()}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      total,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Iconsax.calendar_1,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (productLines.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: AppColors.grey200),
                  const SizedBox(height: 10),
                  Text(
                    'order_products'.tr(locale),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...productLines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Iconsax.book_1, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              line,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
  }

  /// Extract title from a course/webinar or bundle map (handles translations list).
  static String? _itemTitle(Map<String, dynamic>? m) {
    if (m == null) return null;
    final t = m['title']?.toString();
    if (t != null && t.isNotEmpty) return t;
    final tr = m['translations'];
    if (tr is List && tr.isNotEmpty && tr[0] is Map) {
      final first = (tr[0] as Map).cast<String, dynamic>();
      final tt = first['title']?.toString();
      if (tt != null && tt.isNotEmpty) return tt;
    }
    return null;
  }

  /// Product lines for panel order (courses, bundles). Items may have webinar, bundle, title, webinar_title, bundle_title.
  List<String> _panelOrderProductLines(Map<String, dynamic> order, String locale) {
    final List<String> lines = [];
    final items = order['items'] ?? order['order_items'] ?? order['products'];
    if (items != null && items is List && items.isNotEmpty) {
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        final itemMap = item;
        String? title = itemMap['title']?.toString() ??
            itemMap['webinar_title']?.toString() ??
            itemMap['bundle_title']?.toString() ??
            _itemTitle(itemMap['webinar'] is Map ? Map<String, dynamic>.from(itemMap['webinar'] as Map) : null) ??
            _itemTitle(itemMap['bundle'] is Map ? Map<String, dynamic>.from(itemMap['bundle'] as Map) : null);
        if (title == null || title.isEmpty) {
          final web = itemMap['webinar'];
          final bnd = itemMap['bundle'];
          if (web is Map) title = _itemTitle(Map<String, dynamic>.from(web));
          if ((title == null || title.isEmpty) && bnd is Map) title = _itemTitle(Map<String, dynamic>.from(bnd));
        }
        final qty = itemMap['quantity'] ?? itemMap['qty'] ?? 1;
        final webinarId = itemMap['webinar_id'];
        final bundleId = itemMap['bundle_id'];
        if (title != null && title.isNotEmpty) {
          lines.add('${qty} × $title');
        } else {
          final ref = webinarId != null
              ? (locale == 'ar' ? 'دورة' : 'Cours') + ' #$webinarId'
              : bundleId != null
                  ? (locale == 'ar' ? 'Pack' : 'Pack') + ' #$bundleId'
                  : 'order_product_ref'.tr(locale) + ' #${webinarId ?? bundleId ?? '?'}';
          lines.add('$qty × $ref');
        }
      }
    }
    // Single webinar/bundle at order level (offline or legacy)
    if (lines.isEmpty) {
      final webinar = order['webinar'];
      final bundle = order['bundle'];
      String? title = _itemTitle(webinar is Map ? Map<String, dynamic>.from(webinar) : null)
          ?? _itemTitle(bundle is Map ? Map<String, dynamic>.from(bundle) : null);
      if (title != null && title.isNotEmpty) {
        lines.add('1 × $title');
      } else {
        final wid = order['webinar_id'];
        final bid = order['bundle_id'];
        if (wid != null) lines.add('1 × ${locale == 'ar' ? 'دورة' : 'Cours'} #$wid');
        else if (bid != null) lines.add('1 × Pack #$bid');
      }
    }
    return lines;
  }

  Widget _buildEmptyState(String locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
                Iconsax.shopping_bag,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              locale == 'ar' ? 'لا توجد طلبات' : 'Aucune commande',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              locale == 'ar'
                  ? 'ستظهر طلباتك (دورات، packs ومتجر) هنا'
                  : 'Vos commandes (cours, packs et boutique) apparaîtront ici',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String locale, int index,
      Map<String, String> productNames) {
    final orderId = order['id'] ?? order['order_id'] ?? '#—';
    final status = _orderStatus(order['status']);
    final statusLabel = _orderStatusLabel(order['status'], locale);
    final total = _orderTotal(order);
    final dateStr = _orderDate(order, locale);
    final productLines =
        _orderProductLines(order, locale, productNames: productNames);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale == 'ar' ? 'طلب' : 'Commande',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: status.color.withOpacity(0.5), width: 1),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: status.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '#${orderId.toString()}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      total,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Iconsax.calendar_1,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (productLines.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: AppColors.grey200),
                  const SizedBox(height: 10),
                  Text(
                    'order_products'.tr(locale),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...productLines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Iconsax.box_1,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              line,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
  }

  /// Build product summary lines from order (items or product_id + quantity).
  /// Uses [productNames] cache when API doesn't return product title in order.
  /// Backend may send items as 'items' or 'order_items' (Laravel snake_case).
  List<String> _orderProductLines(Map<String, dynamic> order, String locale,
      {Map<String, String>? productNames}) {
    productNames ??= {};
    final List<String> lines = [];
    final items =
        order['items'] ?? order['order_items']; // Laravel: order_items
    if (items != null && items is List && items.isNotEmpty) {
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        final title = item['title'] ??
            item['product_title'] ??
            item['product']?['title'] ??
            item['product']?['translations']?[0]?['title'];
        final qty = item['quantity'] ?? item['qty'] ?? 1;
        final ref = item['product_id'] ?? item['id'];
        final displayTitle = (title != null && title.toString().isNotEmpty)
            ? title.toString()
            : productNames[ref?.toString()];
        if (displayTitle != null && displayTitle.isNotEmpty) {
          lines.add('${qty} × $displayTitle');
        } else {
          lines.add(
            '${qty} × ${'order_product_ref'.tr(locale)} #${ref ?? '?'}',
          );
        }
      }
    } else {
      final productId = order['product_id']?.toString();
      final quantity = order['quantity'] ?? 1;
      if (productId != null) {
        final displayTitle = productNames[productId];
        if (displayTitle != null && displayTitle.isNotEmpty) {
          lines.add('$quantity × $displayTitle');
        } else {
          lines.add(
            '$quantity × ${'order_product_ref'.tr(locale)} #$productId',
          );
        }
      }
    }
    return lines;
  }

  _OrderStatus _orderStatus(dynamic status) {
    if (status == null) return _OrderStatus.pending;
    // Backend may send 1/0 or "1"/"0" for paid/pending
    if (status == 1 || status == '1') return _OrderStatus.completed;
    if (status == 0 || status == '0') return _OrderStatus.pending;
    final s = status.toString().toLowerCase();
    if (s == 'paid' || s == 'completed' || s == 'delivered' || s == 'success') {
      return _OrderStatus.completed;
    }
    if (s == 'cancelled' || s == 'failed' || s == 'refunded') {
      return _OrderStatus.cancelled;
    }
    if (s == 'processing' ||
        s == 'shipped' ||
        s == 'waiting_delivery') {
      return _OrderStatus.processing;
    }
    return _OrderStatus.pending;
  }

  String _orderStatusLabel(dynamic status, String locale) {
    if (status == null) return 'order_status_pending'.tr(locale);
    if (status == 1 || status == '1') return 'order_status_completed'.tr(locale);
    if (status == 0 || status == '0') return 'order_status_pending'.tr(locale);
    final s = status.toString().toLowerCase();
    if (s == 'paid') return 'order_status_paid'.tr(locale);
    if (s == 'completed' || s == 'delivered' || s == 'success') {
      return 'order_status_completed'.tr(locale);
    }
    if (s == 'cancelled' || s == 'failed') {
      return 'order_status_cancelled'.tr(locale);
    }
    if (s == 'processing') return 'order_status_processing'.tr(locale);
    if (s == 'shipped') return 'order_status_shipped'.tr(locale);
    if (s == 'waiting_delivery') {
      return 'order_status_waiting_delivery'.tr(locale);
    }
    if (s == 'pending') return 'order_status_pending'.tr(locale);
    return status.toString();
  }

  String _orderTotal(Map<String, dynamic> order) {
    // API: total from sale when present (e.g. sale.total_amount "22.00")
    final sale = order['sale'];
    dynamic total;
    String? currency;
    if (sale != null && sale is Map<String, dynamic>) {
      total = sale['total_amount'] ?? sale['amount'];
      currency = sale['currency']?.toString();
    }
    total ??= order['total'] ??
        order['total_amount'] ??
        order['amount'] ??
        order['order_amount'];
    if (total == null) return '—';
    num? value;
    if (total is num) {
      value = total;
    } else {
      value = num.tryParse(total.toString().replaceFirst(',', '.'));
    }
    if (value == null) return '—';
    final currencyStr = currency ?? order['currency']?.toString() ?? 'TND';
    return '$value $currencyStr';
  }

  String _orderDate(Map<String, dynamic> order, String locale) {
    final createdAt = order['created_at'] ?? order['order_date'];
    if (createdAt == null) return '—';
    DateTime? dt;
    if (createdAt is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
    } else if (createdAt is String) {
      dt = DateTime.tryParse(createdAt);
    }
    if (dt == null) return createdAt.toString();
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

enum _OrderStatus {
  pending,
  processing,
  completed,
  cancelled,
}

extension on _OrderStatus {
  Color get color {
    switch (this) {
      case _OrderStatus.completed:
        return AppColors.success;
      case _OrderStatus.cancelled:
        return AppColors.error;
      case _OrderStatus.processing:
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }
}
