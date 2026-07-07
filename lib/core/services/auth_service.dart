import 'dart:convert';
import 'dart:developer';
import '../constants/api_constants.dart';
import '../network/http_client.dart';
import '../storage/local_storage.dart';

class AuthService {
  final HttpClient _httpClient;
  final LocalStorage _storage;

  AuthService(this._httpClient, this._storage);

  /// Login with email/phone and password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      String url = '${ApiConstants.baseUrl}login';

      final res = await _httpClient.httpPost(url, {
        'username': username,
        'password': password,
      });

      log('Login response: ${res.body}');

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success'] == true) {
        await _storage.setAccessToken(jsonResponse['data']['token']);
        await _storage.setUserName('');
        return {'success': true, 'data': jsonResponse['data']};
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      log('Login error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Register step 1 - with email.
  /// Backend infers method from request keys (email vs mobile); it validates against
  /// getGeneralSettings('register_method'). If that is 'mobile', email registration
  /// returns invalid_register_method. Ensure backend register_method matches usage.
  /// [formFields] - Optional form fields from register config (for teacher/organization registration)
  Future<Map<String, dynamic>> registerWithEmail(
    String registerMethod,
    String email,
    String password,
    String repeatPassword, {
    String accountType = 'user',
    Map<String, dynamic>? formFields,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}register/step/1';

      final body = <String, dynamic>{
        'country_code': null,
        'email': email,
        'password': password,
        'password_confirmation': repeatPassword,
        'role_name': accountType,
        'account_type': accountType,
      };

      // Add form fields if provided (important for teacher/organization registration)
      if (formFields != null && formFields.isNotEmpty) {
        body['fields'] = formFields.toString();
      }

      log('=== REGISTER EMAIL ===');
      log('Request body: $body');

      final res = await _httpClient.httpPost(url, body);

      log('Register response: ${res.body}');

      var jsonResponse = jsonDecode(res.body);
      final status = jsonResponse['status']?.toString();
      final ok = _isRegisterSuccess(jsonResponse, status);
      if (ok) {
        return {
          'success': true,
          'user_id': jsonResponse['data']['user_id'],
          'step': status ?? 'stored',
        };
      }
      return {
        'success': false,
        'status': jsonResponse['status']?.toString(),
        'message': jsonResponse['message']?.toString() ?? 'Registration failed',
      };
    } catch (e) {
      log('Register error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Register step 1 - with phone
  /// [formFields] - Optional form fields from register config (for teacher/organization registration)
  Future<Map<String, dynamic>> registerWithPhone(
    String registerMethod,
    String countryCode, // e.g., "+216" or "216" – we'll normalize
    String mobile,
    String password,
    String repeatPassword, {
    String accountType = 'user',
    Map<String, dynamic>? formFields,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}register/step/1';

      // Normalize countryCode: ensure it has + and only digits after
      String cleanDialCode = countryCode.replaceAll(RegExp(r'[^0-9+]'), '');
      if (!cleanDialCode.startsWith('+')) {
        cleanDialCode = '+$cleanDialCode';
      }

      // Remove any leading zero from mobile (common in national formats)
      String cleanMobile = mobile.replaceFirst(RegExp(r'^0+'), '').trim();

      // Build proper E.164 mobile: +country mobile (no duplicate)
      String fullMobile = cleanDialCode + cleanMobile;

      final requestBody = <String, dynamic>{
        'country_code': cleanDialCode,
        'mobile': fullMobile,
        'password': password,
        'password_confirmation': repeatPassword,
        'role_name': accountType,
        'account_type': accountType,
      };

      // Add form fields if provided (important for teacher/organization registration)
      if (formFields != null && formFields.isNotEmpty) {
        requestBody['fields'] = formFields.toString();
      }

      log('=== REGISTER PHONE ===');
      log('Request body: $requestBody');

      final res = await _httpClient.httpPost(url, requestBody);

      log('Register phone response: ${res.body}');

      var jsonResponse = jsonDecode(res.body);
      final status = jsonResponse['status']?.toString();
      final ok = _isRegisterSuccess(jsonResponse, status);
      if (ok) {
        return {
          'success': true,
          'user_id': jsonResponse['data']['user_id'],
          'step': status ?? 'stored',
        };
      }
      return {
        'success': false,
        'status': jsonResponse['status']?.toString(),
        'message': jsonResponse['message']?.toString() ?? 'Registration failed',
      };
    } catch (e) {
      log('Register phone error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Backend success: success==1|'1'|true, or status in go_step_2|go_step_3|stored.
  bool _isRegisterSuccess(Map<String, dynamic> json, String? status) {
    final s = json['success'];
    if (s == true || s == 1 || s == '1') return true;
    return status == 'go_step_2' || status == 'go_step_3' || status == 'stored';
  }

  /// Verify code - step 2
  Future<Map<String, dynamic>> verifyCode(int userId, String code) async {
    try {
      String url = '${ApiConstants.baseUrl}register/step/2';

      log('Verifying code for user_id: $userId, code: "$code", code length: ${code.length}');

      final res = await _httpClient.httpPost(url, {
        "user_id": userId.toString(),
        "code": code,
      });

      log('Verify code response: ${res.body}');

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Verification failed'
        };
      }
    } catch (e) {
      log('Verify code error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Complete registration - step 3
  Future<Map<String, dynamic>> registerStep3(
    int userId,
    String name,
    String referralCode,
  ) async {
    try {
      String url = '${ApiConstants.baseUrl}register/step/3';

      final res = await _httpClient.httpPost(url, {
        "user_id": userId.toString(),
        "full_name": name,
        "referral_code": referralCode,
      });

      log('Register step 3 response: ${res.body}');

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success'] == true) {
        await _storage.setAccessToken(jsonResponse['data']['token']);
        await _storage.setUserName(name);
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      log('Register step 3 error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Forgot password
  Future<Map<String, dynamic>> forgetPassword(
      String? countryCode, String data) async {
    try {
      String url = '${ApiConstants.baseUrl}forget-password';

      Map<String, dynamic> body = {
        'type': countryCode == null ? 'email' : 'mobile',
      };

      if (countryCode == null) {
        body['email'] = data;
      } else {
        body['country_code'] = countryCode;
        body['mobile'] = data;
      }

      final res = await _httpClient.httpPost(url, body);

      log('Forgot password response: ${res.body}');

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Code sent successfully'
        };
      } else {
        // Extraire le message de validation (ex. data.errors.email[0])
        String message = jsonResponse['message'] ?? 'Request failed';
        final errors = jsonResponse['data']?['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstMessages = errors[firstKey];
          if (firstMessages is List && firstMessages.isNotEmpty) {
            final firstMsg = firstMessages.first;
            if (firstMsg != null && firstMsg.toString().trim().isNotEmpty) {
              message = firstMsg.toString();
            }
          }
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      log('Forgot password error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Reset password (mobile: code + new password). Token in URL ignored for mobile.
  Future<Map<String, dynamic>> resetPasswordByMobile(
    String countryCode,
    String mobile,
    String code,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final url = '${ApiConstants.baseUrl}reset-password/0';
      final body = <String, dynamic>{
        'type': 'mobile',
        'mobile': mobile,
        'country_code': countryCode,
        'code': code,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      final res = await _httpClient.httpPost(url, body);
      log('Reset password response: ${res.body}');
      var json = jsonDecode(res.body);
      final ok = json['success'] == true;
      return {
        'success': ok,
        'message':
            json['message']?.toString() ?? (ok ? 'OK' : 'Request failed'),
      };
    } catch (e) {
      log('Reset password error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Logout
  Future<bool> logout() async {
    try {
      String url = '${ApiConstants.baseUrl}logout';

      await _httpClient.httpPostWithToken(url, {});
      await _storage.clearAll();
      return true;
    } catch (e) {
      log('Logout error: $e');
      return false;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
