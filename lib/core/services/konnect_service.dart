import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../storage/local_storage.dart';
import '../di/service_locator.dart';

/// Konnect Payment Service for Tunisia
class KonnectService {
  static const String _baseUrl = 'https://edufirma.com/api/flutter';
  final int maxRetries = 3;
  final Duration timeout = const Duration(seconds: 30);

  KonnectService();

  /// Creates a new order with Konnect payment
  Future<Map<String, dynamic>> createOrder(List<Map<String, dynamic>> items) async {
    try {
      final storage = locator<LocalStorage>();
      final token = await storage.getAccessToken();
      
      if (token == null || token.isEmpty) {
        throw UnauthorizedException('Authentication required');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: _getHeaders(token),
        body: jsonEncode({
          'items': items,
          'payment_method': 'konnect',
        }),
      ).timeout(timeout);

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint('Konnect createOrder response: $responseData');

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw _handleApiError(response, responseData);
      }
    } catch (e) {
      debugPrint('Konnect createOrder error: $e');
      rethrow;
    }
  }

  /// Process Konnect payment and get payment URL
  Future<String?> processPayment(List<Map<String, dynamic>> items) async {
    try {
      final orderResponse = await createOrder(items);

      debugPrint('Konnect payment response: $orderResponse');

      // Check for payment URL in different response structures
      if (orderResponse['status'] == 'success' &&
          orderResponse['data'] != null &&
          orderResponse['data']['payment_url'] != null) {
        return orderResponse['data']['payment_url'];
      } else if (orderResponse['success'] == true &&
          orderResponse['payment_url'] != null) {
        return orderResponse['payment_url'];
      } else {
        final errorMessage = orderResponse['data']?['message'] ??
            orderResponse['message'] ??
            'Failed to process payment';
        throw ApiException(errorMessage);
      }
    } catch (e) {
      debugPrint('Konnect processPayment error: $e');
      rethrow;
    }
  }

  /// Fetches user's orders with pagination
  Future<Map<String, dynamic>> getOrders({int page = 1, int perPage = 10}) async {
    try {
      final storage = locator<LocalStorage>();
      final token = await storage.getAccessToken();
      
      if (token == null || token.isEmpty) {
        throw UnauthorizedException('Authentication required');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/orders?page=$page&per_page=$perPage'),
        headers: _getHeaders(token),
      ).timeout(timeout);

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw _handleApiError(response, responseData);
      }
    } catch (e) {
      debugPrint('Konnect getOrders error: $e');
      rethrow;
    }
  }

  /// Launches the payment URL in browser
  Future<bool> launchPayment(String paymentUrl) async {
    try {
      debugPrint('Launching payment URL: $paymentUrl');

      final uri = Uri.parse(paymentUrl);

      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          // Fallback to in-app browser
          return await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );
        }
        return true;
      } else {
        debugPrint('Could not launch URL: $paymentUrl');
        throw ApiException('Could not launch payment URL');
      }
    } catch (e) {
      debugPrint('Error launching payment URL: $e');
      rethrow;
    }
  }

  /// Helper method to get headers with auth token
  Map<String, String> _getHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Accept-Language': 'fr',
    };
  }

  /// Handles API error responses
  Exception _handleApiError(http.Response response, dynamic responseData) {
    final statusCode = response.statusCode;
    final message = responseData['message'] ?? 'An error occurred';

    switch (statusCode) {
      case 400:
        return BadRequestException(message, responseData['errors']);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 422:
        return ValidationException(message, responseData['errors']);
      case 429:
        return RateLimitExceededException(message);
      case 500:
      case 502:
      case 503:
        return ServerException(message);
      default:
        return ApiException('HTTP $statusCode: $message');
    }
  }
}

// Custom exception classes
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  final dynamic errors;
  BadRequestException(super.message, this.errors);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ValidationException extends ApiException {
  final dynamic errors;
  ValidationException(super.message, this.errors);
}

class RateLimitExceededException extends ApiException {
  RateLimitExceededException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}
