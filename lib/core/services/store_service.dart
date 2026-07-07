import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../network/http_client.dart';

class StoreService {
  final HttpClient _httpClient;

  StoreService(this._httpClient);

  /// Get store categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    List<Map<String, dynamic>> data = [];
    try {
      String url = '${ApiConstants.baseUrl}store/categories';

      final res = await _httpClient.httpGet(url);

      // Check if response is HTML (error page) instead of JSON
      if (res.body.startsWith('<!DOCTYPE') || res.body.contains('<html')) {
        debugPrint(
            '=== Received HTML instead of JSON - API endpoint not found ===');
        debugPrint('Response body preview: ${res.body.substring(0, 200)}...');
        return data;
      }

      var jsonResponse = jsonDecode(res.body);

      // Handle both response formats from backend
      if (jsonResponse['status'] == 'success' ||
          jsonResponse['success'] == true) {
        final categories = jsonResponse['data']?['categories'] ??
            jsonResponse['categories'] ??
            jsonResponse['data'] ??
            [];
        debugPrint('Found ${categories.length} store categories');
        if (categories is List) {
          for (var cat in categories) {
            data.add(cat);
          }
        }
      } else {
        debugPrint(
            '=== API returned error: ${jsonResponse['message'] ?? 'Unknown error'} ===');
      }
      return data;
    } catch (e, stack) {
      debugPrint('Error fetching store categories: $e');
      debugPrint('Stack: $stack');
      return data;
    }
  }

  /// Get products
  Future<List<Map<String, dynamic>>> getProducts({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int perPage = 20,
  }) async {
    List<Map<String, dynamic>> data = [];
    try {
      String url;

      // Use different endpoint for category-specific products
      if (categoryId != null) {
        url =
            '${ApiConstants.baseUrl}store/categories/$categoryId/products?page=$page&per_page=$perPage';
      } else {
        url =
            '${ApiConstants.baseUrl}store/products?page=$page&per_page=$perPage';
      }

      if (minPrice != null) url += '&min_price=$minPrice';
      if (maxPrice != null) url += '&max_price=$maxPrice';

      final res = await _httpClient.httpGet(url);

      // Check if response is HTML (error page) instead of JSON
      if (res.body.startsWith('<!DOCTYPE') || res.body.contains('<html')) {
        debugPrint(
            '=== Received HTML instead of JSON - API endpoint not found ===');
        debugPrint('Response body preview: ${res.body.substring(0, 200)}...');
        return data; // Return empty list instead of crashing
      }

      var jsonResponse = jsonDecode(res.body);

      // Handle both response formats from backend
      if (jsonResponse['status'] == 'success' ||
          jsonResponse['success'] == true) {
        final products = jsonResponse['data']?['products'] ??
            jsonResponse['products'] ??
            jsonResponse['data'] ??
            [];
        if (products is List) {
          for (var product in products) {
            data.add(product);
          }
        }
      } else {
        debugPrint(
            '=== API returned error: ${jsonResponse['message'] ?? 'Unknown error'} ===');
      }
      return data;
    } catch (e, stack) {
      debugPrint('Error fetching products: $e');
      debugPrint('Stack: $stack');
      return data;
    }
  }

  /// Get product details
  Future<Map<String, dynamic>?> getProductDetails(String productId) async {
    try {
      String url = '${ApiConstants.baseUrl}store/products/$productId';

      final res = await _httpClient.httpGet(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['status'] == 'success' ||
          jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      return null;
    }
  }

  /// Get store cart
  Future<Map<String, dynamic>?> getCart() async {
    try {
      String url = '${ApiConstants.baseUrl}store/cart';

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['status'] == 'success' ||
          jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching store cart: $e');
      return null;
    }
  }

  /// Add to store cart
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    int quantity = 1,
    Map<String, dynamic>? specifications,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}store/cart/add';

      // Build request body - only include specifications if not null
      final Map<String, dynamic> body = {
        'product_id': productId,
        'quantity': quantity,
      };

      if (specifications != null && specifications.isNotEmpty) {
        body['specifications'] = specifications;
      }

      debugPrint('=== Adding to cart: $body ===');

      final res = await _httpClient.httpPostWithToken(url, body);
      var jsonResponse = jsonDecode(res.body);

      debugPrint('=== Add to cart response: $jsonResponse ===');

      if (jsonResponse['status'] == 'success' ||
          jsonResponse['success'] == true) {
        return {'success': true};
      } else {
        // Return the actual error message from API
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to add to cart',
          'error_code': jsonResponse['message'],
        };
      }
    } catch (e) {
      debugPrint('Error adding to store cart: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  /// Remove from store cart
  Future<bool> removeFromCart(String itemId) async {
    try {
      String url = '${ApiConstants.baseUrl}store/cart/$itemId';

      final res = await _httpClient.httpDeleteWithToken(url, {});
      var jsonResponse = jsonDecode(res.body);

      return jsonResponse['status'] == 'success' ||
          jsonResponse['success'] == true;
    } catch (e) {
      debugPrint('Error removing from store cart: $e');
      return false;
    }
  }

  /// Get web checkout link
  Future<String?> getWebCheckoutLink({int? discountId}) async {
    try {
      String url =
          '${ApiConstants.baseUrl}store/checkout/web-checkout-generator';

      Map<String, dynamic> body = {};
      if (discountId != null) body['discount_id'] = discountId;

      final res = await _httpClient.httpPostWithToken(url, body);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['status'] == 'success' ||
          jsonResponse['success'] == true) {
        return jsonResponse['data']?['url'] ?? jsonResponse['url'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting checkout link: $e');
      return null;
    }
  }

  /// Create order with Konnect payment (for store products)
  /// This processes the current cart and returns payment URL
  Future<Map<String, dynamic>?> createOrder({
    Map<String, dynamic>? shippingAddress,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}store/checkout';

      final Map<String, dynamic> body = {
        'payment_method': 'konnect',
      };

      // Add shipping address if provided
      if (shippingAddress != null) {
        body['shipping_address'] = shippingAddress;
      }

      debugPrint('=== Creating order from cart ===');
      debugPrint('=== Shipping address: $shippingAddress ===');

      final res = await _httpClient.httpPostWithToken(url, body);
      var jsonResponse = jsonDecode(res.body);

      debugPrint('=== Checkout response: $jsonResponse ===');

      if (jsonResponse['status'] == 'success' ||
          jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }

      return null;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  /// Get orders
  Future<List<Map<String, dynamic>>> getOrders({
    int page = 1,
    int perPage = 10,
  }) async {
    List<Map<String, dynamic>> data = [];
    try {
      String url =
          '${ApiConstants.baseUrl}store/checkout/orders?page=$page&per_page=$perPage';

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['status'] == 'success' ||
          jsonResponse['success'] == true) {
        final orders =
            jsonResponse['data']?['orders'] ?? jsonResponse['data'] ?? [];
        if (orders is List) {
          for (var order in orders) {
            data.add(order);
          }
        }
      }
      return data;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return data;
    }
  }

  /// Helper: Get product title from translations or fallback
  static String getProductTitle(Map<String, dynamic> product) {
    try {
      final translations = product['translations'];
      if (translations != null &&
          translations is List &&
          translations.isNotEmpty &&
          translations[0] != null) {
        return translations[0]['title']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('Error getting product title: $e');
    }
    return product['title']?.toString() ?? '';
  }

  /// Helper: Get product image from media
  static String getProductImage(Map<String, dynamic> product) {
    try {
      // First try thumbnail field (most common in API)
      final thumbnail = product['thumbnail']?.toString();
      if (thumbnail != null && thumbnail.isNotEmpty) {
        if (!thumbnail.startsWith('http')) {
          return 'https://edufirma.com$thumbnail';
        }
        return thumbnail;
      }

      // Fallback to media array
      final media = product['media'];
      if (media != null &&
          media is List &&
          media.isNotEmpty &&
          media[0] != null) {
        final path = media[0]['path']?.toString() ?? '';
        if (path.isNotEmpty) {
          if (!path.startsWith('http')) {
            return 'https://edufirma.com$path';
          }
          return path;
        }
      }
    } catch (e) {
      debugPrint('Error getting product image: $e');
    }
    return '';
  }

  /// Helper: Get product price
  static double getProductPrice(Map<String, dynamic> product) {
    try {
      final price = product['price'];
      if (price is num) {
        return price.toDouble();
      }
      if (price is String) {
        return double.tryParse(price) ?? 0.0;
      }
    } catch (e) {
      debugPrint('Error getting product price: $e');
    }
    return 0.0;
  }

  /// Helper: Get category title from translations or fallback
  static String getCategoryTitle(Map<String, dynamic> category) {
    try {
      final translations = category['translations'];
      if (translations != null &&
          translations is List &&
          translations.isNotEmpty) {
        // Try to find French translation first
        for (var translation in translations) {
          if (translation != null && translation['locale'] == 'fr') {
            final title = translation['title']?.toString();
            if (title != null && title.isNotEmpty) {
              return title;
            }
          }
        }
        // Fallback to first translation if no French found
        if (translations[0] != null) {
          return translations[0]['title']?.toString() ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error getting category title: $e');
    }
    return category['title']?.toString() ?? category['name']?.toString() ?? '';
  }
}
