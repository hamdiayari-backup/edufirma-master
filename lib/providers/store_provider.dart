import 'package:flutter/foundation.dart';
import '../core/services/store_service.dart';

class StoreProvider extends ChangeNotifier {
  final StoreService _storeService;

  // Expose service for direct access when needed (parallel loading)
  StoreService get storeService => _storeService;

  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic>? _cart;
  Map<String, dynamic>? _selectedProduct;
  String? _errorMessage;
  int _cartItemCount = 0;

  StoreProvider(this._storeService);

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get products => _products;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get orders => _orders;
  Map<String, dynamic>? get cart => _cart;
  Map<String, dynamic>? get selectedProduct => _selectedProduct;
  String? get errorMessage => _errorMessage;
  int get cartItemCount => _cartItemCount;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Fetch products
  Future<void> fetchProducts({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    bool keepExisting = false, // Nouvelle option
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final newProducts = await _storeService.getProducts(
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: page,
      );

      if (keepExisting) {
        // Ajouter les nouveaux produits aux existants
        _products.addAll(newProducts);
      } else {
        // Remplacer tous les produits (comportement par défaut)
        _products = newProducts;
      }
    } catch (e) {
      _errorMessage = 'Failed to load products';
      debugPrint('=== fetchProducts error: $e ===');
    }

    _setLoading(false);
  }

  /// Fetch categories
  Future<void> fetchCategories() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _categories = await _storeService.getCategories();
    } catch (e) {
      _errorMessage = 'Failed to load categories';
    }

    _setLoading(false);
  }

  /// Fetch product details
  Future<void> fetchProductDetails(String productId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _selectedProduct = await _storeService.getProductDetails(productId);
    } catch (e) {
      _errorMessage = 'Failed to load product details';
    }

    _setLoading(false);
  }

  /// Fetch cart
  Future<void> fetchCart() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _cart = await _storeService.getCart();
      _updateCartItemCount();
    } catch (e) {
      _errorMessage = 'Failed to load cart';
    }

    _setLoading(false);
  }

  void _updateCartItemCount() {
    if (_cart != null && _cart!['items'] != null) {
      _cartItemCount = (_cart!['items'] as List).length;
    } else {
      _cartItemCount = 0;
    }
  }

  /// Add to cart
  Future<Map<String, dynamic>> addToCart(String productId,
      {int quantity = 1, Map<String, dynamic>? specifications}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _storeService.addToCart(
        productId: productId,
        quantity: quantity,
        specifications: specifications,
      );

      if (result['success'] == true) {
        await fetchCart();
        return {'success': true};
      }

      _errorMessage = result['message'] ?? 'Failed to add to cart';
      _setLoading(false);
      return result;
    } catch (e) {
      _errorMessage = 'Failed to add to cart: $e';
      _setLoading(false);
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }

  /// Remove from cart
  Future<bool> removeFromCart(String itemId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _storeService.removeFromCart(itemId);
      if (success) {
        await fetchCart();
        return true;
      }
      _errorMessage = 'Failed to remove from cart';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Failed to remove from cart';
      _setLoading(false);
      return false;
    }
  }

  /// Get checkout link
  Future<String?> getCheckoutLink({int? discountId}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final link =
          await _storeService.getWebCheckoutLink(discountId: discountId);
      _setLoading(false);
      return link;
    } catch (e) {
      _errorMessage = 'Failed to get checkout link';
      _setLoading(false);
      return null;
    }
  }

  /// Create order with payment (for store products)
  /// This processes the current cart and returns payment URL
  Future<String?> createOrderWithPayment({
    Map<String, dynamic>? shippingAddress,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Check if cart has items
      if (_cart == null ||
          _cart!['items'] == null ||
          (_cart!['items'] as List).isEmpty) {
        _errorMessage = 'Cart is empty';
        _setLoading(false);
        return null;
      }

      // Call checkout endpoint (it reads from cart directly)
      final result = await _storeService.createOrder(
        shippingAddress: shippingAddress,
      );

      if (result != null && result['payment_url'] != null) {
        _setLoading(false);
        return result['payment_url'];
      }

      _errorMessage = result?['message'] ?? 'Failed to create order';
      _setLoading(false);
      return null;
    } catch (e) {
      _errorMessage = 'Failed to create order: $e';
      _setLoading(false);
      return null;
    }
  }

  /// Fetch orders
  Future<void> fetchOrders({int page = 1}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _orders = await _storeService.getOrders(page: page);
    } catch (e) {
      _errorMessage = 'Failed to load orders';
    }

    _setLoading(false);
  }

  /// Load initial store data
  Future<void> loadInitialData() async {
    await Future.wait([
      fetchProducts(),
      fetchCategories(),
    ]);
  }

  /// Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }
}
