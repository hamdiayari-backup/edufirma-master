import 'package:flutter/foundation.dart';
import '../core/services/cart_service.dart';
import '../core/services/konnect_service.dart';
import '../features/cart/data/models/cart_model.dart';
import '../features/cart/data/models/checkout_model.dart';

/// Cart Provider - manages cart state
class CartProvider extends ChangeNotifier {
  final CartService _cartService;

  CartModel? _cart;
  CheckoutModel? _checkoutData;
  bool _isLoading = false;
  String? _errorMessage;
  int? _discountId;
  List<Map<String, dynamic>> _panelOrders = [];
  bool _isLoadingPanelOrders = false;
  /// Prix après réduction transmis depuis la page cours (clé = titre de l'article)
  final Map<String, double> _displayPriceOverrides = {};

  CartProvider(this._cartService);

  /// Prix à afficher pour un article : priorité au montant après réduction de la page cours si l’API n’envoie pas de remise.
  double getDisplayPriceForItem(CartItem item) {
    if (item.discount != null && item.discount! > 0) {
      return (item.finalPrice).toDouble();
    }
    final title = item.title?.trim();
    if (title != null && title.isNotEmpty && _displayPriceOverrides.containsKey(title)) {
      return _displayPriceOverrides[title]!;
    }
    return (item.finalPrice).toDouble();
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return double.tryParse(v.toString()) ?? 0.0;
  }

  /// Montants à afficher : recalculés à partir des prix après réduction (page cours) quand l’API envoie remise 0.
  CartAmounts? getDisplayAmounts(CartModel? cart) {
    final amounts = cart?.amounts;
    final items = cart?.items;
    if (amounts == null || items == null || items.isEmpty) return amounts;

    double subTotalFromItems = 0;
    double sumAfterDiscount = 0;
    for (final item in items) {
      final qty = (item.quantity ?? 1).toDouble();
      subTotalFromItems += _toDouble(item.price) * qty;
      sumAfterDiscount += getDisplayPriceForItem(item) * qty;
    }
    final computedDiscount = subTotalFromItems - sumAfterDiscount;
    final apiDiscount = _toDouble(amounts.totalDiscount);
    final deliveryFee = _toDouble(amounts.productDeliveryFee);

    if (computedDiscount > 0 && apiDiscount <= 0) {
      final taxRate = _toDouble(amounts.tax);
      final taxPriceOnDiscount = taxRate > 0 ? sumAfterDiscount * taxRate / 100 : 0.0;
      final displayTotal = sumAfterDiscount + taxPriceOnDiscount + deliveryFee;
      return CartAmounts(
        subTotal: subTotalFromItems,
        totalDiscount: computedDiscount,
        tax: amounts.tax,
        taxPrice: taxPriceOnDiscount,
        commission: amounts.commission,
        commissionPrice: amounts.commissionPrice,
        total: displayTotal,
        productDeliveryFee: amounts.productDeliveryFee,
        taxIsDifferent: amounts.taxIsDifferent,
      );
    }
    return amounts;
  }

  // Getters
  CartModel? get cart => _cart;
  CheckoutModel? get checkoutData => _checkoutData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get discountId => _discountId;

  bool get isEmpty => _cart?.isEmpty ?? true;
  int get itemCount => _cart?.itemCount ?? 0;
  int get total => _cart?.amounts?.totalInt ?? 0;
  List<Map<String, dynamic>> get panelOrders => _panelOrders;
  bool get isLoadingPanelOrders => _isLoadingPanelOrders;

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Fetch cart data
  Future<void> fetchCart() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _cart = await _cartService.getCart();
      debugPrint('Cart fetched: ${_cart?.itemCount} items');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching cart: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch panel orders (courses, bundles, offline payments) for "Mes commandes".
  Future<void> fetchPanelOrders({int page = 1}) async {
    _isLoadingPanelOrders = true;
    notifyListeners();
    try {
      _panelOrders = await _cartService.getPanelOrders(page: page, perPage: 50);
    } catch (e) {
      debugPrint('Error fetching panel orders: $e');
      _panelOrders = [];
    } finally {
      _isLoadingPanelOrders = false;
      notifyListeners();
    }
  }

  /// Add course to cart
  Future<Map<String, dynamic>> addCourseToCart(int courseId, {int? ticketId}) async {
    _setLoading(true);

    try {
      final result = await _cartService.addCourseToCart(courseId, ticketId: ticketId);

      if (result['success'] == true) {
        await fetchCart(); // Refresh cart
      }

      return result;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Add bundle to cart (optionally with ticketId for discounted price, like webinars).
  Future<Map<String, dynamic>> addBundleToCart(int bundleId, {int? ticketId}) async {
    _setLoading(true);

    try {
      final result = await _cartService.addBundleToCart(bundleId, ticketId: ticketId);

      if (result['success'] == true) {
        await fetchCart(); // Refresh cart
      }

      return result;
    } catch (e) {
      debugPrint('Error adding bundle to cart: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Add product to cart
  Future<Map<String, dynamic>> addProductToCart(
    String itemId,
    String itemName, {
    String? specifications,
    int quantity = 1,
  }) async {
    _setLoading(true);

    try {
      final result = await _cartService.addProductToCart(
        itemId,
        itemName,
        specifications: specifications,
        quantity: quantity,
      );

      if (result['success'] == true) {
        await fetchCart(); // Refresh cart
      }

      return result;
    } catch (e) {
      debugPrint('Error adding product to cart: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Remove item from cart
  Future<bool> removeFromCart(int itemId) async {
    _setLoading(true);

    try {
      final success = await _cartService.removeFromCart(itemId);

      if (success) {
        final removedItem = _cart?.items?.firstWhere((i) => i.id == itemId, orElse: () => CartItem(title: null));
        final removedTitle = removedItem?.title?.trim();
        if (removedTitle != null) _displayPriceOverrides.remove(removedTitle);
        // Remove from local cart immediately
        _cart?.items?.removeWhere((item) => item.id == itemId);
        notifyListeners();
        
        // Refresh cart to get updated amounts
        await fetchCart();
      }

      return success;
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Validate coupon
  Future<bool> validateCoupon(String coupon) async {
    _setLoading(true);

    try {
      final result = await _cartService.validateCoupon(coupon);

      if (result != null) {
        // Update cart amounts with coupon discount
        if (result['amounts'] != null) {
          _cart?.amounts = result['amounts'];
        }
        _discountId = result['discount_id'];
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error validating coupon: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Proceed to checkout
  Future<CheckoutModel?> checkout() async {
    _setLoading(true);

    try {
      _checkoutData = await _cartService.checkout();
      notifyListeners();
      return _checkoutData;
    } catch (e) {
      debugPrint('Error during checkout: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Pay with account credit
  Future<bool> payWithCredit(int orderId) async {
    _setLoading(true);

    try {
      final success = await _cartService.payWithCredit(orderId);

      if (success) {
        // Clear cart after successful payment
        _cart = null;
        _checkoutData = null;
        _discountId = null;
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint('Error paying with credit: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Pay order with loyalty points. Returns map with success and optional message.
  Future<Map<String, dynamic>> payWithPoints(int orderId) async {
    _setLoading(true);

    try {
      final result = await _cartService.payWithPoints(orderId);

      if (result['success'] == true) {
        _cart = null;
        _checkoutData = null;
        _discountId = null;
        notifyListeners();
      }

      return result;
    } catch (e) {
      debugPrint('Error paying with points: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Request Konnect payment (for store products)
  Future<String?> requestKonnectPayment(List<Map<String, dynamic>> items) async {
    _setLoading(true);

    try {
      return await _cartService.processKonnectPayment(items);
    } catch (e) {
      debugPrint('Error requesting Konnect payment: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Request payment via gateway (for courses).
  /// [amount] : montant après remise à envoyer au gateway (optionnel).
  Future<dynamic> requestPayment(int gatewayId, int orderId, {double? amount}) async {
    _setLoading(true);

    try {
      return await _cartService.paymentRequest(gatewayId, orderId, amount: amount);
    } catch (e) {
      debugPrint('Error requesting payment: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get web checkout URL
  Future<String?> webCheckout({List<Map<String, dynamic>>? items}) async {
    _setLoading(true);

    try {
      return await _cartService.webCheckout(items: items);
    } catch (e) {
      debugPrint('Error in web checkout: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Apply subscription to course
  Future<bool> applySubscription(int courseId) async {
    _setLoading(true);

    try {
      return await _cartService.applySubscription(courseId);
    } catch (e) {
      debugPrint('Error applying subscription: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Enroll in free course
  Future<Map<String, dynamic>> enrollFreeCourse(int courseId, {bool isBundle = false}) async {
    _setLoading(true);

    try {
      return await _cartService.enrollFreeCourse(courseId, isBundle: isBundle);
    } catch (e) {
      debugPrint('Error enrolling in free course: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Smart add to cart - handles both free courses (enrollment) and paid courses.
  /// [displayPrice] et [itemTitle] : montant après réduction vu sur la page cours, pour l’affichage dans le panier.
  Future<Map<String, dynamic>> smartAddToCart({
    required int courseId,
    required bool isBundle,
    required bool isFree,
    int? ticketId,
    double? displayPrice,
    String? itemTitle,
  }) async {
    _setLoading(true);

    try {
      if (isFree) {
        // For free courses, enroll directly
        final result = await _cartService.enrollFreeCourse(courseId, isBundle: isBundle);
        if (result['success'] == true) {
          return {'success': true, 'status': 'free_registered'};
        }
        return result;
      } else {
        // Enregistrer le montant après réduction (page cours) pour l’affichage dans le panier
        if (displayPrice != null && itemTitle != null && itemTitle.trim().isNotEmpty) {
          _displayPriceOverrides[itemTitle.trim()] = displayPrice;
        }
        // For paid courses, add to cart
        Map<String, dynamic> result;
        
        if (isBundle) {
          result = await _cartService.addBundleToCart(courseId, ticketId: ticketId);
        } else {
          result = await _cartService.addCourseToCart(courseId, ticketId: ticketId);
        }
        
        if (result['success'] == true) {
          await fetchCart(); // Refresh cart
          return {'success': true, 'status': 'added_to_cart'};
        }
        return result;
      }
    } catch (e) {
      debugPrint('Error in smartAddToCart: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// Clear cart
  void clearCart() {
    _cart = null;
    _checkoutData = null;
    _discountId = null;
    _errorMessage = null;
    _displayPriceOverrides.clear();
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
