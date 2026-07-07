import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../network/http_client.dart';
import '../../features/courses/data/models/course_model.dart';

class UserService {
  final HttpClient _httpClient;

  UserService(this._httpClient);

  /// Get user profile
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      String url = '${ApiConstants.baseUrl}panel/profile-setting';

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['user'];
      }
      return null;
    } catch (e) {
      log('Error fetching profile: $e');
      return null;
    }
  }

  /// Get dashboard data
  Future<Map<String, dynamic>?> getDashboardData() async {
    try {
      String url = '${ApiConstants.baseUrl}panel/quick-info';

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }
      return null;
    } catch (e) {
      log('Error fetching dashboard: $e');
      return null;
    }
  }

  /// Get purchased courses (includes free registrations)
  Future<List<Map<String, dynamic>>> getPurchasedCourses() async {
    List<Map<String, dynamic>> data = [];
    try {
      String url = '${ApiConstants.baseUrl}panel/webinars/purchases';
      debugPrint('=== Fetching purchased courses from: $url ===');

      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('=== Purchases response status: ${res.statusCode} ===');
      debugPrint('=== Purchases response body: ${res.body} ===');

      var jsonResponse = jsonDecode(res.body);
      debugPrint('=== Purchases success: ${jsonResponse['success']} ===');
      debugPrint(
          '=== Purchases data keys: ${jsonResponse['data']?.keys?.toList()} ===');

      if (jsonResponse['success'] == true) {
        final dataMap = jsonResponse['data'];
        // API returns { data: [ {...}, ... ] }
        if (dataMap is List) {
          for (var json in dataMap) {
            data.add(_toPurchaseMap(json));
          }
        } else if (dataMap is Map) {
          final purchases = dataMap['purchases'];
          if (purchases != null && purchases is List) {
            for (var json in purchases) {
              data.add(_toPurchaseMap(json));
            }
          }
          final webinars = dataMap['webinars'];
          if (webinars != null && webinars is List) {
            for (var json in webinars) {
              data.add(_toPurchaseMap(json));
            }
          }
        }
      }

      debugPrint('=== Total purchased courses: ${data.length} ===');
      return data;
    } catch (e, stack) {
      debugPrint('Error fetching purchases: $e');
      debugPrint('Stack: $stack');
      return data;
    }
  }

  /// Pass through purchase item so bundle_id, bundle, webinar_id, webinar are preserved.
  static Map<String, dynamic> _toPurchaseMap(dynamic json) {
    if (json is Map) return Map<String, dynamic>.from(json);
    return <String, dynamic>{};
  }

  /// Get favorites
  Future<List<Map<String, dynamic>>> getFavorites() async {
    List<Map<String, dynamic>> data = [];
    try {
      String url = '${ApiConstants.baseUrl}panel/favorites';

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        final favorites = jsonResponse['data']?['favorites'];
        if (favorites is List) {
          for (var item in favorites) {
            if (item is Map<String, dynamic>) {
              data.add(item);
            } else if (item is Map) {
              data.add(Map<String, dynamic>.from(item));
            }
          }
        }
      }
      return data;
    } catch (e) {
      log('Error fetching favorites: $e');
      return data;
    }
  }

  /// Delete favorite
  Future<bool> deleteFavorite(int id) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/favorites/$id';

      final res = await _httpClient.httpDeleteWithToken(url, {});
      var jsonResponse = jsonDecode(res.body);

      return jsonResponse['success'] == true;
    } catch (e) {
      log('Error deleting favorite: $e');
      return false;
    }
  }

  /// Get notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    List<Map<String, dynamic>> data = [];
    try {
      String url = '${ApiConstants.baseUrl}panel/notifications';

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        jsonResponse['data']?['notifications']?.forEach((json) {
          data.add(json);
        });
      }
      return data;
    } catch (e) {
      log('Error fetching notifications: $e');
      return data;
    }
  }

  /// Mark notification as read (backend: /seen)
  Future<bool> markNotificationRead(int id) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/notifications/$id/seen';

      final res = await _httpClient.httpPostWithToken(url, {});
      var jsonResponse = jsonDecode(res.body);

      return jsonResponse['success'] == true;
    } catch (e) {
      log('Error marking notification read: $e');
      return false;
    }
  }

  /// Update profile info
  Future<bool> updateInfo({
    required String email,
    required String name,
    required String phone,
    String? timezone,
    bool newsletter = false,
    String? iban,
    String? accountType,
    String? accountId,
    String? address,
    String? bio,
    int? countryId,
    int? provinceId,
    int? cityId,
    int? districtId,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/profile-setting';

      Map<String, dynamic> body = {
        "email": email,
        "full_name": name,
        "mobile": phone,
        "newsletter": newsletter ? 1 : 0,
      };

      if (timezone != null && timezone.isNotEmpty) body["timezone"] = timezone;
      if (accountType != null) body["account_type"] = accountType;
      if (iban != null) body["iban"] = iban;
      if (accountId != null) body["account_id"] = accountId;
      if (address != null && address.isNotEmpty) body["address"] = address;
      if (bio != null && bio.isNotEmpty) body["bio"] = bio;
      if (countryId != null) body["country_id"] = countryId;
      if (provinceId != null) body["province_id"] = provinceId;
      if (cityId != null) body["city_id"] = cityId;
      if (districtId != null) body["district_id"] = districtId;

      final res = await _httpClient.httpPutWithToken(url, body);
      var jsonResponse = jsonDecode(res.body);

      return jsonResponse['success'] == true;
    } catch (e) {
      log('Error updating profile: $e');
      return false;
    }
  }

  /// Update password
  Future<Map<String, dynamic>> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/profile-setting/password';

      final res = await _httpClient.httpPutWithToken(url, {
        "current_password": currentPassword,
        "new_password": newPassword,
      });

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'token': jsonResponse['data']['token'],
        };
      }
      return {
        'success': false,
        'message': jsonResponse['message'] ?? 'Failed to update password'
      };
    } catch (e) {
      log('Error updating password: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Store review
  Future<bool> storeReview({
    required int postId,
    required int contentQuality,
    required int instructorSkills,
    required int purchaseWorth,
    required int supportQuality,
    required String description,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/reviews';

      final res = await _httpClient.httpPostWithToken(url, {
        "webinar_id": postId,
        "content_quality": contentQuality,
        "instructor_skills": instructorSkills,
        "purchase_worth": purchaseWorth,
        "support_quality": supportQuality,
        "description": description,
      });

      var jsonResponse = jsonDecode(res.body);
      return jsonResponse['success'] == true;
    } catch (e) {
      log('Error storing review: $e');
      return false;
    }
  }

  /// Get classes (for teachers)
  Future<Map<String, dynamic>> getClasses() async {
    try {
      String url = '${ApiConstants.baseUrl}panel/classes';

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      List<CourseModel> myClasses = [];
      List<Map<String, dynamic>> purchases = [];
      List<CourseModel> organizations = [];
      List<CourseModel> invitations = [];

      if (jsonResponse['success'] == true) {
        jsonResponse['my_classes']?.forEach((json) {
          myClasses.add(CourseModel.fromJson(json));
        });

        jsonResponse['purchases']?.forEach((json) {
          purchases.add(json);
        });

        jsonResponse['organizations']?.forEach((json) {
          organizations.add(CourseModel.fromJson(json));
        });

        jsonResponse['invitations']?.forEach((json) {
          invitations.add(CourseModel.fromJson(json));
        });
      }

      return {
        'my_classes': myClasses,
        'purchases': purchases,
        'organizations': organizations,
        'invitations': invitations,
      };
    } catch (e) {
      log('Error fetching classes: $e');
      return {
        'my_classes': <CourseModel>[],
        'purchases': <Map<String, dynamic>>[],
        'organizations': <CourseModel>[],
        'invitations': <CourseModel>[],
      };
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    try {
      String url = '${ApiConstants.baseUrl}panel/delete-account-request';

      final res = await _httpClient.httpPostWithToken(url, {});
      var jsonResponse = jsonDecode(res.body);

      return jsonResponse['success'] == true;
    } catch (e) {
      log('Error deleting account: $e');
      return false;
    }
  }

  /// Update profile image
  Future<Map<String, dynamic>> updateImage({
    File? profileImage,
    File? identityImage,
    File? certificateImage,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/profile-setting/images';

      dio.FormData body = dio.FormData.fromMap({
        if (profileImage != null)
          "profile_image": await dio.MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split('/').last,
          ),
        if (identityImage != null)
          "identity_scan": await dio.MultipartFile.fromFile(
            identityImage.path,
            filename: identityImage.path.split('/').last,
          ),
        if (certificateImage != null)
          "certificate": await dio.MultipartFile.fromFile(
            certificateImage.path,
            filename: certificateImage.path.split('/').last,
          ),
      });

      final response = await _httpClient.dioPostWithToken(url, body);

      if (response.data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update image'
        };
      }
    } on dio.DioException catch (e) {
      log('Error updating image: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to upload image'
      };
    } catch (e) {
      log('Error updating image: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Get rewards data (points balance + conversion rate).
  /// Backend: GET panel/rewards. Returns data with available_points, conversion_rate (points_per_unit, unit_per_point), etc.
  Future<Map<String, dynamic>?> getRewards() async {
    try {
      String url = '${ApiConstants.baseUrl}panel/rewards';
      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true || jsonResponse['success'] == 1) {
        return jsonResponse['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(jsonResponse['data'])
            : null;
      }
      return null;
    } catch (e) {
      log('Error fetching rewards: $e');
      return null;
    }
  }

  /// Redeem points for a course or bundle (direct purchase with points, no cart).
  /// Backend: POST panel/rewards/redeem with body { webinar_id } or { bundle_id }.
  Future<Map<String, dynamic>> redeemWithPoints({
    int? webinarId,
    int? bundleId,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/rewards/redeem';
      final Map<String, dynamic> body = {};
      if (webinarId != null) body['webinar_id'] = webinarId;
      if (bundleId != null) body['bundle_id'] = bundleId;
      if (body.isEmpty) {
        return {'success': false, 'message': 'Provide webinar_id or bundle_id'};
      }

      final res = await _httpClient.httpPostWithToken(url, body);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true || jsonResponse['success'] == 1) {
        return {
          'success': true,
          'status': jsonResponse['status'] ?? 'paid',
          'message': jsonResponse['message']?.toString(),
        };
      }
      return {
        'success': false,
        'message': jsonResponse['message']?.toString() ??
            'Impossible d\'échanger les points',
      };
    } catch (e) {
      log('Error redeeming with points: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Send Firebase token for notifications
  Future<bool> sendFirebaseToken(String token) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/users/fcm';

      final res = await _httpClient.httpPutWithToken(url, {"token": token});
      var jsonResponse = jsonDecode(res.body);

      final ok = jsonResponse['success'] == true;
      if (!ok) {
        log('FCM API error: ${res.statusCode} - ${res.body}');
      }
      return ok;
    } catch (e) {
      log('Error sending Firebase token: $e');
      return false;
    }
  }
}
