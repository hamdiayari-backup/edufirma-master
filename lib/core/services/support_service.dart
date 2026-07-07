import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../models/support_model.dart';
import '../network/http_client.dart';

class SupportService {
  final HttpClient _httpClient;

  SupportService(this._httpClient);

  /// Platform tickets (by department)
  Future<List<SupportModel>> getTickets() async {
    try {
      final url = '${ApiConstants.baseUrl}panel/support/tickets';
      final res = await _httpClient.httpGetWithToken(url);
      final jsonResponse = jsonDecode(res.body) as Map<String, dynamic>;
      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        return (jsonResponse['data'] as List)
            .map((e) => SupportModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('SupportService.getTickets: $e');
      return [];
    }
  }

  /// Course support tickets
  Future<List<SupportModel>> getClassSupport() async {
    try {
      final url = '${ApiConstants.baseUrl}panel/support/class_support';
      final res = await _httpClient.httpGetWithToken(url);
      final jsonResponse = jsonDecode(res.body) as Map<String, dynamic>;
      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        return (jsonResponse['data'] as List)
            .map((e) => SupportModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('SupportService.getClassSupport: $e');
      return [];
    }
  }

  /// Departments for new platform ticket
  /// Accepts: { data: [...] }, { departments: [...] }, { data: { departments: [...] } }, or raw list
  Future<List<Map<String, dynamic>>> getDepartments() async {
    try {
      final url = '${ApiConstants.baseUrl}panel/support/departments';
      final res = await _httpClient.httpGetWithToken(url);
      final body = jsonDecode(res.body);
      if (res.statusCode != 200) return [];

      // Response is a list at top level
      if (body is List) {
        return _normalizeDepartmentList(body);
      }
      final jsonResponse = body as Map<String, dynamic>;
      // data: [ {...}, ... ]
      List? list = jsonResponse['data'] is List ? jsonResponse['data'] as List : null;
      if (list == null && jsonResponse['departments'] is List) {
        list = jsonResponse['departments'] as List;
      }
      if (list == null && jsonResponse['data'] is Map) {
        final data = jsonResponse['data'] as Map<String, dynamic>;
        list = data['departments'] is List ? data['departments'] as List : null;
      }
      if (list != null) {
        return _normalizeDepartmentList(list);
      }
      if (body is Map) {
        debugPrint('SupportService.getDepartments: response keys=${(body as Map).keys.toList()}, expected data or departments (list)');
      }
      return [];
    } catch (e) {
      debugPrint('SupportService.getDepartments: $e');
      return [];
    }
  }

  static List<Map<String, dynamic>> _normalizeDepartmentList(List list) {
    return list.map((e) {
      final m = Map<String, dynamic>.from(e is Map ? e : <String, dynamic>{});
      final rawId = m['id'] ?? m['department_id'];
      final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;
      final title = m['title'] ?? m['name'] ?? m['label'] ?? '';
      return {'id': id, 'title': title.toString().isEmpty ? 'Département $id' : title.toString()};
    }).toList();
  }

  /// Single ticket with conversations
  Future<SupportModel?> getOne(int id) async {
    try {
      final url = '${ApiConstants.baseUrl}panel/support/$id';
      final res = await _httpClient.httpGetWithToken(url);
      final jsonResponse = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 &&
          jsonResponse['success'] == true &&
          jsonResponse['data'] != null) {
        return SupportModel.fromJson(
            Map<String, dynamic>.from(jsonResponse['data'] as Map));
      }
      return null;
    } catch (e) {
      debugPrint('SupportService.getOne: $e');
      return null;
    }
  }

  /// Create new ticket (platform or course)
  /// departmentId: for platform_support; courseId (webinar_id): for course_support
  Future<bool> createMessage(
    String title,
    String desc, {
    int? departmentId,
    int? courseId,
    File? file,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}panel/support';
      final formData = dio.FormData.fromMap({
        'title': title,
        'message': desc,
        'type': departmentId != null ? 'platform_support' : 'course_support',
        if (departmentId != null) 'department_id': departmentId,
        if (courseId != null) 'webinar_id': courseId,
        if (file != null)
          'attach': await dio.MultipartFile.fromFile(
            file.path,
            filename: file.path.split(RegExp(r'[/\\]')).last,
          ),
      });
      final res = await _httpClient.dioPostWithToken(url, formData);
      final data = res.data;
      if (data is Map && data['success'] == true) return true;
      return false;
    } on dio.DioException catch (e) {
      debugPrint('SupportService.createMessage: $e');
      return false;
    }
  }

  /// Reply in a ticket
  Future<bool> sendMessage(String message, int chatId, {File? file}) async {
    try {
      final url = '${ApiConstants.baseUrl}panel/support/$chatId/conversations';
      final formData = dio.FormData.fromMap({
        'message': message,
        if (file != null)
          'attach': await dio.MultipartFile.fromFile(
            file.path,
            filename: file.path.split(RegExp(r'[/\\]')).last,
          ),
      });
      final res = await _httpClient.dioPostWithToken(url, formData);
      final data = res.data;
      if (data is Map && data['success'] == true) return true;
      return false;
    } on dio.DioException catch (e) {
      debugPrint('SupportService.sendMessage: $e');
      return false;
    }
  }
}
