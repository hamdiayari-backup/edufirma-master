import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../network/http_client.dart';
import '../../features/courses/data/models/course_model.dart';

class CourseService {
  final HttpClient _httpClient;

  CourseService(this._httpClient);

  /// Get all courses with filters
  Future<List<CourseModel>> getAll({
    required int offset,
    bool upcoming = false,
    bool free = false,
    bool discount = false,
    bool downloadable = false,
    String? sort,
    String? type,
    String? cat,
    bool reward = false,
    bool bundle = false,
    List<int>? filterOption,
  }) async {
    List<CourseModel> data = [];
    try {
      String url =
          '${ApiConstants.baseUrl}${bundle ? 'bundles' : 'courses'}?offset=$offset&limit=10';

      if (upcoming) url += '&upcoming=1';
      if (free) url += '&free=1';
      if (discount) url += '&discount=1';
      if (downloadable) url += '&downloadable=1';
      if (reward) url += '&reward=1';
      if (sort != null) url += '&sort=$sort';
      if (cat != null) url += '&cat=$cat';

      if (filterOption != null && filterOption.isNotEmpty) {
        for (int i = 0; i < filterOption.length; i++) {
          url += '&filter_option=${filterOption[i]}';
        }
      }

      debugPrint('=== CourseService.getAll URL: $url ===');

      final res = await _httpClient.httpGet(url);
      debugPrint('Status: ${res.statusCode}, Body length: ${res.body.length}');

      var jsonRes = jsonDecode(res.body);
      debugPrint(
          'API success: ${jsonRes['success']}, data type: ${jsonRes['data'].runtimeType}');

      // Log full response structure for debugging when filtering by category
      if (cat != null) {
        debugPrint('=== FULL RESPONSE FOR CATEGORY $cat ===');
        debugPrint('Response keys: ${jsonRes.keys}');
        if (jsonRes['data'] is Map) {
          debugPrint('Data keys: ${(jsonRes['data'] as Map).keys}');
          debugPrint('Data content: ${jsonRes['data']}');
        } else if (jsonRes['data'] is List) {
          debugPrint(
              'Data is List with ${(jsonRes['data'] as List).length} items');
        }
        // Log full response body for category filter
        debugPrint('Full response body: ${res.body}');
      }

      if (jsonRes['success'] == true) {
        if (bundle) {
          // Bundles: data.bundles is the array
          final bundles = jsonRes['data']['bundles'];
          debugPrint('Bundles count from API: ${bundles?.length ?? 0}');
          if (bundles != null) {
            for (var json in bundles) {
              data.add(CourseModel.fromJson(json));
            }
          }
        } else {
          // Courses: data might be directly the array OR in data.webinars
          final responseData = jsonRes['data'];
          debugPrint('Courses data type: ${responseData.runtimeType}');

          if (responseData is Map) {
            // Check if courses are in 'webinars' key
            if (responseData['webinars'] != null &&
                responseData['webinars'] is List) {
              final webinars = responseData['webinars'] as List;
              debugPrint('Found webinars in data.webinars: ${webinars.length}');
              for (var json in webinars) {
                data.add(CourseModel.fromJson(json as Map<String, dynamic>));
              }
            }
            // Check if courses are in 'courses' key
            else if (responseData['courses'] != null &&
                responseData['courses'] is List) {
              final courses = responseData['courses'] as List;
              debugPrint('Found courses in data.courses: ${courses.length}');
              for (var json in courses) {
                data.add(CourseModel.fromJson(json as Map<String, dynamic>));
              }
            }
          } else if (responseData is List) {
            debugPrint('Courses count from API: ${responseData.length}');
            for (var json in responseData) {
              data.add(CourseModel.fromJson(json as Map<String, dynamic>));
            }
          }
        }
      }

      debugPrint('Parsed ${data.length} ${bundle ? "bundles" : "courses"}');
      return data;
    } catch (e, stack) {
      debugPrint('ERROR in getAll: $e');
      debugPrint('Stack: $stack');
      return data;
    }
  }

  /// Get featured courses
  Future<List<CourseModel>> featuredCourses({String? cat}) async {
    List<CourseModel> data = [];
    try {
      String url = '${ApiConstants.baseUrl}featured-courses';
      if (cat != null) url += '?cat=$cat';

      debugPrint('=== CourseService.featuredCourses ===');
      debugPrint('URL: $url');

      final res = await _httpClient.httpGet(url);
      debugPrint('Response status: ${res.statusCode}');

      var jsonRes = jsonDecode(res.body);
      debugPrint('Success: ${jsonRes['success']}');

      if (jsonRes['success'] == true) {
        // Featured courses: data is directly the array
        final courses = jsonRes['data'];
        debugPrint('Featured data type: ${courses.runtimeType}');
        if (courses is List) {
          debugPrint('Featured count from API: ${courses.length}');
          for (var json in courses) {
            data.add(CourseModel.fromJson(json));
          }
        }
      }

      debugPrint('Parsed ${data.length} featured courses');
      return data;
    } catch (e, stack) {
      debugPrint('ERROR in featuredCourses: $e');
      debugPrint('Stack: $stack');
      return data;
    }
  }

  /// Get single course details
  Future<Map<String, dynamic>?> getSingleCourse(int id,
      {bool isBundle = false, bool isPrivate = false}) async {
    try {
      String url =
          '${ApiConstants.baseUrl}${isPrivate ? 'panel/webinars' : isBundle ? 'bundles' : 'courses'}/$id';

      final res = await _httpClient.httpGet(url, isSendToken: true);
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success'] == true) {
        final data = jsonRes['data'];
        if (isBundle && data is Map) {
          final bundle = data['bundle'];
          return bundle is Map
              ? Map<String, dynamic>.from(bundle)
              : Map<String, dynamic>.from(data);
        }
        return data is Map ? Map<String, dynamic>.from(data) : null;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching single course: $e');
      return null;
    }
  }

  /// Get bundle webinars (API public: GET /api/bundles/{id}/webinars).
  /// Accepts response with webinars in data.webinars or at root (webinars).
  /// Courses are already sorted by order (NULL last, then ASC) from API.
  Future<List<CourseModel>> getBundleWebinars(int bundleId) async {
    List<CourseModel> data = [];
    try {
      String url = '${ApiConstants.baseUrl}bundles/$bundleId/webinars';

      final res = await _httpClient.httpGet(url);
      var jsonRes = jsonDecode(res.body);

      List? list;
      if (jsonRes['success'] == true && jsonRes['data'] != null) {
        list = jsonRes['data']['webinars'] as List?;
      }
      if (list == null || list.isEmpty) {
        list = jsonRes['webinars'] as List?;
      }
      if (list != null) {
        for (var json in list) {
          if (json is Map)
            data.add(CourseModel.fromJson(Map<String, dynamic>.from(json)));
        }
      }
      return data;
    } catch (e) {
      debugPrint('Error fetching bundle webinars: $e');
      return data;
    }
  }

  /// Get full bundle with webinars and progress (for content tab and progress).
  /// GET panel/bundles/{id}. Returns data.bundle with webinars[].progress_percent, is_completed.
  Future<Map<String, dynamic>?> getBundleWithProgress(int bundleId) async {
    try {
      String url = ApiConstants.panelBundle(bundleId);
      final res = await _httpClient.httpGetWithToken(url);
      if (res.statusCode != 200) return null;
      var jsonRes = jsonDecode(res.body);
      final ok = jsonRes['status'] == 1 ||
          jsonRes['code'] == 'retrieved' ||
          jsonRes['success'] == true;
      if (!ok) return null;
      final data = jsonRes['data'];
      final bundle = data is Map ? (data['bundle'] ?? data) : null;
      return bundle is Map ? Map<String, dynamic>.from(bundle) : null;
    } catch (e) {
      debugPrint('Error fetching bundle with progress: $e');
      return null;
    }
  }

  /// Get bundle progress: total courses and completed count (for "Mes cours").
  /// Calls GET panel/bundles/{id}. API returns status/code and bundle with total_webinars, completed_webinars, and webinars[].progress_percent / is_completed.
  Future<({int total, int completed})?> getBundleProgress(int bundleId) async {
    try {
      String url = ApiConstants.panelBundle(bundleId);
      final res = await _httpClient.httpGetWithToken(url);
      if (res.statusCode != 200) return null;

      var jsonRes = jsonDecode(res.body);
      // API uses status: 1, code: "retrieved" (or success: true for legacy)
      final ok = jsonRes['status'] == 1 ||
          jsonRes['code'] == 'retrieved' ||
          jsonRes['success'] == true;
      if (!ok) return null;

      final data = jsonRes['data'];
      final bundle = data is Map ? (data['bundle'] ?? data) : null;
      if (bundle == null || bundle is! Map) return null;

      // Prefer bundle-level fields from the new API
      final totalFromApi = _intFrom(bundle['total_webinars']);
      final completedFromApi = _intFrom(bundle['completed_webinars']);
      if (totalFromApi != null &&
          totalFromApi > 0 &&
          completedFromApi != null) {
        debugPrint(
            'Bundle $bundleId progress: $completedFromApi/$totalFromApi (from total_webinars/completed_webinars)');
        return (total: totalFromApi, completed: completedFromApi);
      }

      // Fallback: count from webinars array (progress_percent >= 100 or is_completed == true)
      final webinars = bundle['webinars'] as List?;
      if (webinars != null && webinars.isNotEmpty) {
        final total = webinars.length;
        int completed = 0;
        for (var w in webinars) {
          if (_isWebinarCompleted(w)) completed++;
        }
        debugPrint(
            'Bundle $bundleId progress: $completed/$total (from webinars)');
        return (total: total, completed: completed);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching bundle progress: $e');
      return null;
    }
  }

  static int? _intFrom(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// True if webinar is completed: is_completed == true or progress_percent >= 100.
  static bool _isWebinarCompleted(dynamic w) {
    if (w == null || w is! Map) return false;
    if (w['is_completed'] == true) return true;
    final percent = _progressPercentFromWebinar(w);
    return percent >= 100;
  }

  /// Extrait le pourcentage de progression d'un objet webinar (progress_percent, progress, pivot, etc.).
  static int _progressPercentFromWebinar(dynamic w) {
    if (w == null || w is! Map) return 0;
    final p = w['progress_percent'] ?? w['progress'];
    if (p != null) return (double.tryParse(p.toString()) ?? 0).round();
    final pivot = w['pivot'];
    if (pivot is Map) {
      final pp = pivot['progress_percent'] ?? pivot['progress'];
      if (pp != null) return (double.tryParse(pp.toString()) ?? 0).round();
    }
    return 0;
  }

  /// Search courses, users, organizations
  Future<Map<String, dynamic>> search(String text) async {
    List<CourseModel> courseData = [];
    List<Map<String, dynamic>> usersData = [];
    List<Map<String, dynamic>> organizationsData = [];

    try {
      String url = '${ApiConstants.baseUrl}search?search=$text';

      final res = await _httpClient.httpGet(url);
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success'] == true) {
        final data = jsonRes['data'];
        if (data is Map) {
          // Courses: accept data.webinars (list), data.webinars.webinars, data.courses
          List? webinars;
          final webinarsNode = data['webinars'];
          if (webinarsNode is List)
            webinars = webinarsNode;
          else if (webinarsNode is Map && webinarsNode['webinars'] is List) {
            webinars = webinarsNode['webinars'] as List;
          }
          if (webinars == null && data['courses'] is List) {
            webinars = data['courses'] as List;
          }
          if (webinars != null) {
            for (var json in webinars) {
              if (json is Map) {
                courseData
                    .add(CourseModel.fromJson(Map<String, dynamic>.from(json)));
              }
            }
          }
          // Users
          final usersNode = data['users'];
          if (usersNode is List) {
            for (var json in usersNode) {
              if (json is Map) usersData.add(Map<String, dynamic>.from(json));
            }
          } else if (usersNode is Map && usersNode['users'] is List) {
            for (var json in usersNode['users'] as List) {
              if (json is Map) usersData.add(Map<String, dynamic>.from(json));
            }
          }
          // Organizations
          final orgsNode = data['organizations'];
          if (orgsNode is List) {
            for (var json in orgsNode) {
              if (json is Map)
                organizationsData.add(Map<String, dynamic>.from(json));
            }
          } else if (orgsNode is Map && orgsNode['organizations'] is List) {
            for (var json in (orgsNode['organizations'] as List)) {
              if (json is Map)
                organizationsData.add(Map<String, dynamic>.from(json));
            }
          }
        }
      }

      return {
        'courses': courseData,
        'users': usersData,
        'organizations': organizationsData,
      };
    } catch (e) {
      debugPrint('Error searching: $e');
      return {
        'courses': courseData,
        'users': usersData,
        'organizations': organizationsData,
      };
    }
  }

  /// Get course content
  Future<List<Map<String, dynamic>>> getContent(int courseId) async {
    List<Map<String, dynamic>> data = [];
    try {
      String url = '${ApiConstants.baseUrl}courses/$courseId/content';

      debugPrint('=== Fetching course content from: $url ===');
      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('=== Content response status: ${res.statusCode} ===');
      debugPrint('=== Content response body: ${res.body} ===');

      var jsonResponse = jsonDecode(res.body);
      debugPrint('=== Content success: ${jsonResponse['success']} ===');
      debugPrint(
          '=== Content data type: ${jsonResponse['data']?.runtimeType} ===');
      debugPrint('=== Content data: ${jsonResponse['data']} ===');

      if (jsonResponse['success'] == true) {
        final contentData = jsonResponse['data'];
        if (contentData is List) {
          for (var json in contentData) {
            data.add(json as Map<String, dynamic>);
          }
        } else if (contentData is Map) {
          // Maybe the data is in a nested key like 'chapters' or 'sections'
          debugPrint('=== Data is a Map, checking for nested content ===');
          debugPrint('=== Map keys: ${contentData.keys} ===');

          // Try common nested keys
          final chapters = contentData['chapters'] ??
              contentData['sections'] ??
              contentData['content'];
          if (chapters is List) {
            for (var json in chapters) {
              data.add(json as Map<String, dynamic>);
            }
          }
        }
      } else {
        debugPrint(
            '=== Content API returned error: ${jsonResponse['message']} ===');
      }
      return data;
    } catch (e, stack) {
      debugPrint('Error fetching content: $e');
      debugPrint('Stack: $stack');
      return data;
    }
  }

  /// Add to favorites
  Future<bool> addFavorite(int courseId, bool isBundle) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/favorites/toggle2';

      final res = await _httpClient.httpPostWithToken(url, {
        "item": isBundle ? 'bundle' : 'webinar',
        "id": courseId,
      });

      var jsonResponse = jsonDecode(res.body);
      return jsonResponse['success'] == true;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    }
  }

  /// Report course
  Future<bool> reportCourse(String reason, int courseId, String message) async {
    try {
      String url = '${ApiConstants.baseUrl}courses/$courseId/report';

      final res = await _httpClient.httpPostWithToken(url, {
        "reason": reason,
        "message": message,
      });

      var jsonResponse = jsonDecode(res.body);
      return jsonResponse['success'] == true;
    } catch (e) {
      debugPrint('Error reporting course: $e');
      return false;
    }
  }

  /// Get single content details (file, session, text_lesson)
  /// This fetches the actual file URL from an API link like /api/panel/files/113
  Future<Map<String, dynamic>?> getSingleContent(String link) async {
    try {
      // Build full URL if link is relative
      String url = link;
      if (!link.startsWith('http')) {
        url = 'https://edufirma.com$link';
      }

      debugPrint('=== Fetching single content from: $url ===');

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      debugPrint('Single content response success: ${jsonResponse['success']}');

      if (jsonResponse['success'] == true) {
        final data = jsonResponse['data'];
        debugPrint('Content file: ${data['file']}');
        debugPrint('Content storage: ${data['storage']}');
        debugPrint('Content file_type: ${data['file_type']}');
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching single content: $e');
      return null;
    }
  }

  /// Toggle content read status
  /// itemName should be 'text_lesson_id', 'file_id', 'session_id', 'assignment_id', 'quiz_id'
  Future<bool> toggleContentRead(
    int courseId,
    String itemName,
    String itemId,
    bool status,
  ) async {
    try {
      String url = '${ApiConstants.baseUrl}courses/$courseId/toggle';

      final body = {
        "item": itemName,
        "item_id": itemId,
        "status": status,
      };

      debugPrint('=== Toggle content read ===');
      debugPrint('URL: $url');
      debugPrint('Body: $body');

      final res = await _httpClient.httpPostWithToken(url, body);

      debugPrint('Toggle response: ${res.body}');
      var jsonResponse = jsonDecode(res.body);
      return jsonResponse['success'] == true;
    } catch (e) {
      debugPrint('Error toggling content: $e');
      return false;
    }
  }

  /// Toggle favorite/wishlist for a course or bundle
  Future<Map<String, dynamic>> toggleFavorite(int courseId,
      {bool isBundle = false}) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/favorites/toggle2';

      final res = await _httpClient.httpPostWithToken(url, {
        "item": isBundle ? 'bundle' : 'webinar',
        "id": courseId,
      });

      var jsonResponse = jsonDecode(res.body);
      debugPrint('Toggle favorite response: $jsonResponse');

      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Favori mis à jour',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Erreur',
        };
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
