import 'dart:convert';
import 'dart:developer';
import '../constants/api_constants.dart';
import '../network/http_client.dart';
import '../../features/courses/data/models/category_model.dart';
import '../../features/courses/data/models/course_model.dart';

class CategoryService {
  final HttpClient _httpClient;

  CategoryService(this._httpClient);

  /// Get trending categories
  Future<List<CategoryModel>> getTrendCategories() async {
    List<CategoryModel> data = [];
    try {
      String url = '${ApiConstants.baseUrl}trend-categories';

      final res = await _httpClient.httpGet(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        jsonResponse['data']['categories']?.forEach((json) {
          data.add(CategoryModel.fromJson(json));
        });
      }
      return data;
    } catch (e) {
      log('Error fetching trend categories: $e');
      return data;
    }
  }

  /// Get all categories
  Future<List<CategoryModel>> getCategories() async {
    List<CategoryModel> data = [];
    try {
      String url = '${ApiConstants.baseUrl}categories';

      final res = await _httpClient.httpGet(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        jsonResponse['data']['categories']?.forEach((json) {
          data.add(CategoryModel.fromJson(json));
        });
      }
      return data;
    } catch (e) {
      log('Error fetching categories: $e');
      return data;
    }
  }

  /// Get filters for a category
  Future<List<Map<String, dynamic>>> getFilters(int categoryId) async {
    List<Map<String, dynamic>> data = [];
    try {
      String url = '${ApiConstants.baseUrl}categories/$categoryId/webinars';

      final res = await _httpClient.httpGet(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        jsonResponse['data']['filters']?.forEach((json) {
          data.add(json);
        });
      }
      return data;
    } catch (e) {
      log('Error fetching filters: $e');
      return data;
    }
  }

  /// Get courses/webinars for a specific category
  Future<List<CourseModel>> getCategoryCourses(int categoryId,
      {int offset = 0, int limit = 10}) async {
    List<CourseModel> data = [];
    try {
      String url =
          '${ApiConstants.baseUrl}categories/$categoryId/webinars?offset=$offset&limit=$limit';

      log('Fetching category courses from: $url');
      final res = await _httpClient.httpGet(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        // The API might return courses in different formats
        // Try to find the courses array
        final responseData = jsonResponse['data'];

        if (responseData is Map) {
          // Check if courses are in 'webinars' key
          if (responseData['webinars'] != null &&
              responseData['webinars'] is List) {
            for (var json in (responseData['webinars'] as List)) {
              data.add(CourseModel.fromJson(json as Map<String, dynamic>));
            }
          }
          // Check if courses are in 'courses' key
          else if (responseData['courses'] != null &&
              responseData['courses'] is List) {
            for (var json in (responseData['courses'] as List)) {
              data.add(CourseModel.fromJson(json as Map<String, dynamic>));
            }
          }
        } else if (responseData is List) {
          for (var item in responseData) {
            if (item is Map) {
              data.add(CourseModel.fromJson(item as Map<String, dynamic>));
            }
          }
        }
      }

      log('Loaded ${data.length} courses for category $categoryId');
      return data;
    } catch (e) {
      log('Error fetching category courses: $e');
      return data;
    }
  }
}
