import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../network/http_client.dart';

class NotificationService {
  final HttpClient _httpClient;

  NotificationService(this._httpClient);

  /// Get notifications
  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/notifications?page=$page';

      debugPrint('=== NotificationService.getNotifications URL: $url ===');
      
      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('Notifications status: ${res.statusCode}');
      
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        final data = jsonResponse['data'];
        List<Map<String, dynamic>> notifications = [];
        
        if (data['notifications'] != null && data['notifications'] is List) {
          for (var n in data['notifications']) {
            notifications.add(Map<String, dynamic>.from(n));
          }
        } else if (data is List) {
          for (var n in data) {
            notifications.add(Map<String, dynamic>.from(n));
          }
        }
        
        return {
          'notifications': notifications,
          'unread_count': data['unread_notifications_count'] ?? 
                          data['unread_count'] ?? 
                          notifications.where((n) => n['status'] != 'read' && n['seen'] != true).length,
        };
      }
      
      return {'notifications': [], 'unread_count': 0};
    } catch (e, stack) {
      debugPrint('Error fetching notifications: $e');
      debugPrint('Stack: $stack');
      return {'notifications': [], 'unread_count': 0};
    }
  }

  /// Mark notification as read (backend: /seen)
  Future<bool> markAsRead(String notificationId) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/notifications/$notificationId/seen';

      final res = await _httpClient.httpPostWithToken(url, {});
      var jsonResponse = jsonDecode(res.body);

      return jsonResponse['success'] == true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read (backend: /seen-all)
  Future<bool> markAllAsRead() async {
    try {
      String url = '${ApiConstants.baseUrl}panel/notifications/seen-all';

      final res = await _httpClient.httpPostWithToken(url, {});
      var jsonResponse = jsonDecode(res.body);

      return jsonResponse['success'] == true;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/notifications/$notificationId';

      final res = await _httpClient.httpDeleteWithToken(url, {});
      // 204 No Content = success with empty body (common for DELETE)
      if (res.statusCode == 204 || res.body.isEmpty) {
        return true;
      }
      try {
        var jsonResponse = jsonDecode(res.body);
        return jsonResponse['success'] == true;
      } catch (_) {
        return res.statusCode >= 200 && res.statusCode < 300;
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      String url = '${ApiConstants.baseUrl}panel/notifications/count';

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return jsonResponse['data']?['count'] ?? 
               jsonResponse['data']?['unread_count'] ?? 
               0;
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }
}






