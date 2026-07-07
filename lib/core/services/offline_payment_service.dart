import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import '../constants/api_constants.dart';
import '../network/http_client.dart';
import '../storage/local_storage.dart';

/// Offline Payment Service - handles offline payment requests
/// Based on Edufirma Offline Payment API Documentation
class OfflinePaymentService {
  final HttpClient _httpClient;
  final LocalStorage _storage;

  OfflinePaymentService(this._httpClient, this._storage);

  /// Get available bank information from backend
  /// Endpoint: GET /cart/offline-bank-info
  Future<Map<String, dynamic>?> getBankAccountInfo() async {
    try {
      // Try the documented endpoint first
      String url = '${ApiConstants.baseUrl}panel/cart/offline-bank-info';
      print('=== Fetching bank info from: $url ===');

      var res = await _httpClient.httpGetWithToken(url);
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      var jsonResponse = jsonDecode(res.body);

      // Check for successful response
      if ((jsonResponse['status'] == 1 || jsonResponse['success'] == true) &&
          jsonResponse['data'] != null) {
        print('Bank data found: ${jsonResponse['data']}');
        return jsonResponse['data'];
      }

      // Fallback to old endpoint if the new one doesn't work
      url = '${ApiConstants.baseUrl}panel/offline-payments/info';
      print('=== Trying fallback endpoint: $url ===');
      res = await _httpClient.httpGetWithToken(url);
      print('Fallback response: ${res.body}');
      jsonResponse = jsonDecode(res.body);

      if ((jsonResponse['status'] == 1 || jsonResponse['success'] == true) &&
          jsonResponse['data'] != null) {
        return jsonResponse['data'];
      }

      return null;
    } catch (e) {
      print('=== Error fetching bank info: $e ===');
      // Try fallback endpoint on error
      try {
        String url = '${ApiConstants.baseUrl}panel/offline-payments/info';
        final res = await _httpClient.httpGetWithToken(url);
        var jsonResponse = jsonDecode(res.body);

        if ((jsonResponse['status'] == 1 || jsonResponse['success'] == true) &&
            jsonResponse['data'] != null) {
          return jsonResponse['data'];
        }
      } catch (_) {}
      return null;
    }
  }

  /// Get user's offline payments
  /// Endpoint: GET /financial/offline-payments
  Future<List<Map<String, dynamic>>> getOfflinePayments() async {
    try {
      String url = '${ApiConstants.baseUrl}panel/financial/offline-payments';

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['status'] == 1 && jsonResponse['data'] != null) {
        // Handle both array and object with payments key
        if (jsonResponse['data'] is List) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else if (jsonResponse['data']['payments'] != null) {
          return List<Map<String, dynamic>>.from(
              jsonResponse['data']['payments']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Submit offline payment request
  /// Endpoint: POST /cart/offline-payment-request
  ///
  /// Parameters:
  /// - orderId: The order ID to link the payment to
  /// - bankId: The bank ID from the bank list
  /// - referenceNumber: Bank transfer reference/transaction number
  /// - payDate: Date of the payment (YYYY-MM-DD)
  /// - amount: Amount transferred
  /// - attachment: Payment receipt/proof image (optional)
  Future<Map<String, dynamic>> createOfflinePaymentWithOrder({
    required int orderId,
    required int bankId,
    required String referenceNumber,
    required String payDate,
    required double amount,
    File? attachment,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/cart/offline-payment-request';

      Map<String, dynamic> formData = {
        "order_id": orderId.toString(),
        "bank_id": bankId.toString(),
        "reference_number": referenceNumber,
        "pay_date": payDate,
        "amount": amount.toString(),
      };

      // Add file attachment if provided
      if (attachment != null) {
        String fileName = attachment.path.split('/').last;
        formData['attachment'] = await dio.MultipartFile.fromFile(
          attachment.path,
          filename: fileName,
        );
      }

      // Use Dio for file upload
      final dioInstance = dio.Dio();
      String token = await _storage.getAccessToken() ?? '';

      final response = await dioInstance.post(
        url,
        data: dio.FormData.fromMap(formData),
        options: dio.Options(
          headers: {
            "Authorization": "Bearer $token",
            'Accept': 'application/json',
            'x-api-key': ApiConstants.apiKey,
            'x-locale': 'fr',
          },
        ),
      );

      var jsonResponse = response.data;
      final ok = jsonResponse['status'] == 1 ||
          jsonResponse['status'] == true ||
          jsonResponse['success'] == true ||
          jsonResponse['success'] == 1;

      if (ok) {
        return {
          'success': true,
          'message': jsonResponse['message'] ??
              'Demande de paiement hors ligne soumise avec succès',
          'data': jsonResponse['data'],
        };
      } else {
        String errorMessage = jsonResponse['message'] ??
            'Échec de la soumission de la demande de paiement';

        // Handle validation errors
        if (jsonResponse['errors'] != null) {
          final errors = jsonResponse['errors'] as Map<String, dynamic>;
          final errorList = errors.values.expand((e) => e is List ? e : [e]).toList();
          if (errorList.isNotEmpty) {
            errorMessage = errorList.first.toString();
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': jsonResponse['errors'] ?? {},
        };
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Erreur de connexion';
      if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map) {
          errorMessage = responseData['message'] ?? errorMessage;
          if (responseData['errors'] != null) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            final errorList = errors.values.expand((err) => err is List ? err : [err]).toList();
            if (errorList.isNotEmpty) {
              errorMessage = errorList.first.toString();
            }
          }
        }
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur est survenue: ${e.toString()}',
      };
    }
  }

  /// Update offline payment request
  /// Endpoint: PUT /financial/offline-payments/{id}
  ///
  /// Parameters:
  /// - paymentId: Offline payment ID
  /// - amount: Payment amount
  /// - account: Bank account name (must match available banks)
  /// - referralCode: Transaction reference number
  /// - date: Payment date (YYYY-MM-DD)
  /// - attachment: Payment receipt image (optional)
  Future<Map<String, dynamic>> updateOfflinePayment({
    required int paymentId,
    required int amount,
    required String account,
    required String referralCode,
    required String date,
    File? attachment,
  }) async {
    try {
      String url =
          '${ApiConstants.baseUrl}panel/financial/offline-payments/$paymentId';

      Map<String, dynamic> formData = {
        "amount": amount.toString(),
        "account": account,
        "referral_code": referralCode,
        "date": date,
      };

      // Add file attachment if provided
      if (attachment != null) {
        String fileName = attachment.path.split('/').last;
        formData['attachment'] = await dio.MultipartFile.fromFile(
          attachment.path,
          filename: fileName,
        );
      }

      // Use Dio for file upload with PUT method
      final dioInstance = dio.Dio();
      String token = await _storage.getAccessToken() ?? '';

      final response = await dioInstance.put(
        url,
        data: dio.FormData.fromMap(formData),
        options: dio.Options(
          headers: {
            "Authorization": "Bearer $token",
            'Accept': 'application/json',
            'x-api-key': ApiConstants.apiKey,
            'x-locale': 'fr',
          },
        ),
      );

      var jsonResponse = response.data;

      if (jsonResponse['status'] == 1) {
        return {
          'success': true,
          'message':
              jsonResponse['message'] ?? 'Paiement mis à jour avec succès',
        };
      } else {
        return {
          'success': false,
          'message':
              jsonResponse['message'] ?? 'Échec de la mise à jour du paiement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur est survenue: ${e.toString()}',
      };
    }
  }

  /// Delete offline payment request
  /// Endpoint: DELETE /financial/offline-payments/{id}
  Future<Map<String, dynamic>> deleteOfflinePayment(int paymentId) async {
    try {
      String url =
          '${ApiConstants.baseUrl}panel/financial/offline-payments/$paymentId';

      final res = await _httpClient.httpDeleteWithToken(url, {});
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['status'] == 1) {
        return {
          'success': true,
          'message':
              jsonResponse['message'] ?? 'Paiement supprimé avec succès',
        };
      } else {
        return {
          'success': false,
          'message':
              jsonResponse['message'] ?? 'Échec de la suppression du paiement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur est survenue: ${e.toString()}',
      };
    }
  }
}
