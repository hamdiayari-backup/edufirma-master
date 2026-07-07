import 'dart:convert';
import 'dart:developer';
import '../constants/api_constants.dart';
import '../network/http_client.dart';

class GuestService {
  final HttpClient _httpClient;

  GuestService(this._httpClient);

  /// Get currency list
  Future<List<Map<String, dynamic>>> getCurrencyList() async {
    List<Map<String, dynamic>> data = [];
    try {
      String url = '${ApiConstants.baseUrl}currency/list';

      final res = await _httpClient.httpGet(url);
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success'] == true) {
        jsonRes['data']?.forEach((json) {
          data.add(json);
        });
      }
      return data;
    } catch (e) {
      log('Error fetching currencies: $e');
      return data;
    }
  }

  /// Get timezones
  Future<List<String>> getTimeZones() async {
    List<String> data = [];
    try {
      String url = '${ApiConstants.baseUrl}timezones';

      final res = await _httpClient.httpGet(url);
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success'] == true) {
        return List<String>.from(jsonRes['data']);
      }
      return data;
    } catch (e) {
      log('Error fetching timezones: $e');
      return data;
    }
  }

  /// Get app config
  Future<Map<String, dynamic>?> getConfig() async {
    try {
      String url = '${ApiConstants.baseUrl}config';

      final res = await _httpClient.httpGet(url);
      var jsonResponse = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return jsonResponse;
      }
      return null;
    } catch (e) {
      log('Error fetching config: $e');
      return null;
    }
  }

  /// Get register config
  Future<Map<String, dynamic>?> getRegisterConfig(String role) async {
    try {
      String url = '${ApiConstants.baseUrl}config/register/$role';

      final res = await _httpClient.httpGet(url);
      var jsonResponse = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return jsonResponse['data'];
      }
      return null;
    } catch (e) {
      log('Error fetching register config: $e');
      return null;
    }
  }

  /// Get providers (trainers/organizations)
  Future<List<Map<String, dynamic>>> getProviders({
    String? type, // teacher, organization
    int offset = 0,
    int limit = 10,
  }) async {
    List<Map<String, dynamic>> data = [];
    try {
      String url =
          '${ApiConstants.baseUrl}providers?offset=$offset&limit=$limit';
      if (type != null) url += '&type=$type';

      final res = await _httpClient.httpGet(url);
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success'] == true) {
        jsonRes['data']?.forEach((json) {
          data.add(json);
        });
      }
      return data;
    } catch (e) {
      log('Error fetching providers: $e');
      return data;
    }
  }

  /// Get single provider
  Future<Map<String, dynamic>?> getProvider(int id) async {
    try {
      String url = '${ApiConstants.baseUrl}providers/$id';

      final res = await _httpClient.httpGet(url);
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success'] == true) {
        return jsonRes['data'];
      }
      return null;
    } catch (e) {
      log('Error fetching provider: $e');
      return null;
    }
  }

  /// Get user profile (teacher/organization)
  Future<Map<String, dynamic>?> getUserProfile(int id) async {
    try {
      String url = '${ApiConstants.baseUrl}users/$id/profile';
      log('Fetching user profile: $url');

      final res = await _httpClient.httpGetWithToken(url);
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success'] == true) {
        final user = jsonRes['data']?['user'] as Map<String, dynamic>?;
        if (user != null &&
            user['organization_teachers'] != null &&
            user['instructors'] == null) {
          user['instructors'] = user['organization_teachers'];
        }
        return user;
      }
      return null;
    } catch (e) {
      log('Error fetching user profile: $e');
      return null;
    }
  }

  /// Get instructors associated with an organization (fallback if profile has none)
  Future<List<Map<String, dynamic>>> getOrganizationInstructors(
      int organizationUserId) async {
    List<Map<String, dynamic>> list = [];
    try {
      String url =
          '${ApiConstants.baseUrl}users/$organizationUserId/instructors';
      final res = await _httpClient.httpGet(url);
      var jsonRes = jsonDecode(res.body);
      if (jsonRes['success'] == true) {
        final data = jsonRes['data'];
        if (data is List) {
          for (var e in data) list.add(Map<String, dynamic>.from(e as Map));
        } else if (data is Map && data['instructors'] is List) {
          for (var e in data['instructors'])
            list.add(Map<String, dynamic>.from(e as Map));
        }
      }
      return list;
    } catch (e) {
      log('Error fetching organization instructors: $e');
      return list;
    }
  }

  /// Follow/Unfollow user
  Future<bool> followUser(int userId, bool follow) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/users/$userId/follow';

      final res = await _httpClient.httpPostWithToken(url, {
        'status': follow ? '1' : '0',
      });
      var jsonRes = jsonDecode(res.body);

      return jsonRes['success'] == true;
    } catch (e) {
      log('Error following user: $e');
      return false;
    }
  }
}
