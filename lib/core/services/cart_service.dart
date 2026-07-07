import 'dart:convert';
import '../constants/api_constants.dart';
import '../network/http_client.dart';
import '../../features/cart/data/models/cart_model.dart';
import '../../features/cart/data/models/checkout_model.dart';
import 'konnect_service.dart';

/// Cart Service - handles cart operations and payment
class CartService {
  final HttpClient _httpClient;

  CartService(this._httpClient);

  /// Get cart data
  Future<CartModel?> getCart() async {
    try {
      String url = '${ApiConstants.baseUrl}panel/cart/list';

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return CartModel.fromJson(jsonResponse['data']?['cart'] ?? {});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Add course to cart
  /// Note: ticketId should be an actual ticket ID from the course's tickets array,
  /// not the price. If no tickets exist for the course, don't pass ticketId.
  Future<Map<String, dynamic>> addCourseToCart(int courseId,
      {int? ticketId}) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/cart/store';

      final Map<String, String> body = {
        "webinar_id": courseId.toString(),
      };

      // Only include ticket_id if it's a valid ticket ID (not 0 or null)
      // ticketId should be an actual ticket ID from course.tickets, not the price
      if (ticketId != null && ticketId > 0) {
        body["ticket_id"] = ticketId.toString();
      }

      final res = await _httpClient.httpPostWithToken(url, body);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {'success': true};
      } else {
        final status = jsonResponse['status']?.toString();
        final message =
            jsonResponse['message'] ?? 'Erreur lors de l\'ajout au panier';
        return {
          'success': false,
          'message': message,
          if (status != null && status.isNotEmpty) 'status': status,
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Add bundle (pack) to cart.
  /// Backend must accept either webinar_id (course) OR bundle_id (pack) on panel/cart/store.
  /// Pass ticketId when the bundle has tickets (pricing plans); backend should use it to apply
  /// the same discounted price as for webinars (otherwise pack may be added at original price).
  Future<Map<String, dynamic>> addBundleToCart(int bundleId, {int? ticketId}) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/cart/store';

      final body = <String, String>{"bundle_id": bundleId.toString()};
      if (ticketId != null && ticketId > 0) {
        body["ticket_id"] = ticketId.toString();
      }
      final res = await _httpClient.httpPostWithToken(url, body);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {'success': true};
      } else {
        final status = jsonResponse['status']?.toString();
        String message =
            jsonResponse['message'] ?? 'Erreur lors de l\'ajout au panier';
        final data = jsonResponse['data'];
        if (data is Map && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final first = errors.values.isNotEmpty
              ? (errors.values.first is List
                  ? (errors.values.first as List).first?.toString()
                  : errors.values.first?.toString())
              : null;
          if (first != null) message = first;
        }
        return {
          'success': false,
          'message': message,
          if (status != null && status.isNotEmpty) 'status': status,
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Add product (store item) to cart
  Future<Map<String, dynamic>> addProductToCart(
    String itemId,
    String itemName, {
    String? specifications,
    int quantity = 1,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/cart';

      final res = await _httpClient.httpPostWithToken(url, {
        "item_id": itemId,
        "item_name": itemName,
        "specifications": specifications,
        "quantity": quantity.toString(),
      });
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message':
              jsonResponse['message'] ?? 'Erreur lors de l\'ajout au panier',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Remove item from cart
  Future<bool> removeFromCart(int itemId) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/cart/$itemId';

      final res = await _httpClient.httpDeleteWithToken(url, {});
      var jsonResponse = jsonDecode(res.body);

      return jsonResponse['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Validate coupon code
  Future<Map<String, dynamic>?> validateCoupon(String coupon) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/cart/coupon/validate';

      final res = await _httpClient.httpPostWithToken(url, {"coupon": coupon});
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {
          'amounts': CartAmounts.fromJson(jsonResponse['data']['amounts']),
          'discount_id': jsonResponse['data']['discount']['id'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Proceed to checkout
  /// Optionally pass paymentMethod ('bank_transfer' or 'cash_on_delivery') for offline payment
  Future<CheckoutModel?> checkout({String? paymentMethod}) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/cart/checkout';

      final Map<String, dynamic> body = {};
      if (paymentMethod != null) {
        body['payment_method'] = paymentMethod;
      }

      final res = await _httpClient.httpPostWithToken(url, body);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true || jsonResponse['status'] == 1) {
        return CheckoutModel.fromJson(jsonResponse['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pay order with loyalty points. Backend: POST panel/payments/pay-with-points.
  Future<Map<String, dynamic>> payWithPoints(int orderId) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/payments/pay-with-points';
      final res = await _httpClient.httpPostWithToken(url, {'order_id': orderId});
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true || jsonResponse['success'] == 1) {
        return {'success': true, 'message': jsonResponse['message']?.toString()};
      }
      return {
        'success': false,
        'message': jsonResponse['message']?.toString() ?? 'Paiement en points impossible',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Pay with account credit/balance
  Future<bool> payWithCredit(int orderId) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/payments/credit';

      final res = await _httpClient.httpPostWithToken(url, {
        "order_id": orderId.toString(),
      });
      var jsonResponse = jsonDecode(res.body);

      return jsonResponse['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Check order status before payment
  Future<Map<String, dynamic>?> checkOrderStatus(int orderId) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/orders/$orderId';

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return jsonResponse['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Request payment (for gateway payment).
  /// Le backend doit utiliser le montant de la commande (order total), pas un montant client.
  /// Ne pas envoyer [amount] : source de vérité = order créé au checkout.
  Future<dynamic> paymentRequest(int gatewayId, int orderId, {double? amount}) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/payments/request';

      if (orderId <= 0) return null;

      final requestBody = <String, String>{
        "gateway_id": gatewayId.toString(),
        "order_id": orderId.toString(),
      };
      // N'envoie pas amount au backend : le backend utilise order.total (comme kingco legacy).

      final res = await _httpClient.httpPostWithToken(url, requestBody);

      // Check if response is HTML (error page) instead of JSON
      if (res.body.startsWith('<!DOCTYPE') || res.body.contains('<html')) {
        return null;
      }

      try {
        var jsonResponse = jsonDecode(res.body);

        if (jsonResponse['success'] == true) {
          return res.body;
        }
        return null;
      } catch (e) {
        // If can't parse JSON, return raw body (might be redirect URL)
        return res.body;
      }
    } catch (e) {
      return null;
    }
  }

  /// Process Konnect payment
  Future<String?> processKonnectPayment(
      List<Map<String, dynamic>> items) async {
    try {
      final konnectService = KonnectService();
      return await konnectService.processPayment(items);
    } catch (e) {
      return null;
    }
  }

  /// Web checkout (get payment URL)
  Future<String?> webCheckout({List<Map<String, dynamic>>? items}) async {
    try {
      // If no items provided, get from cart
      if (items == null || items.isEmpty) {
        final cart = await getCart();
        if (cart?.items == null || cart!.items!.isEmpty) {
          return null;
        }

        // Map cart items to payment format
        items = cart.items!.map((item) {
          return {
            'product_id': item.id,
            'quantity': item.quantity ?? 1,
            'price': item.finalPrice,
            'name': item.title ?? 'Product ${item.id}',
          };
        }).toList();
      }

      // Process payment with Konnect
      return await processKonnectPayment(items);
    } catch (e) {
      return null;
    }
  }

  /// Apply subscription to course (for subscribed users)
  Future<bool> applySubscription(int courseId) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/subscribe/apply';

      final res = await _httpClient.httpPostWithToken(url, {
        "webinar_id": courseId.toString(),
      });
      var jsonResponse = jsonDecode(res.body);

      return jsonResponse['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Enroll in free course
  Future<Map<String, dynamic>> enrollFreeCourse(int courseId,
      {bool isBundle = false}) async {
    try {
      String url =
          '${ApiConstants.baseUrl}panel/${isBundle ? 'bundles' : 'webinars'}/$courseId/free';

      final res = await _httpClient.httpPostWithToken(url, {});
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// List user orders (courses, bundles, offline payments).
  /// Backend: GET panel/orders. Used in "Mes commandes" alongside store orders.
  Future<List<Map<String, dynamic>>> getPanelOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    List<Map<String, dynamic>> data = [];
    try {
      String url =
          '${ApiConstants.baseUrl}panel/orders?page=$page&per_page=$perPage';
      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success'] == true || jsonResponse['status'] == 'success') {
        final orders = jsonResponse['data']?['orders'] ??
            jsonResponse['data'] ??
            jsonResponse['orders'] ??
            [];
        if (orders is List) {
          for (var order in orders) {
            if (order is Map<String, dynamic>) {
              data.add(Map<String, dynamic>.from(order));
            }
          }
        }
      }
      return data;
    } catch (e) {
      return data;
    }
  }
}
