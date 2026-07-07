import 'package:flutter/foundation.dart';
import '../core/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  bool _isLoading = false;
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  String? _errorMessage;

  NotificationProvider(this._notificationService);

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  String? get errorMessage => _errorMessage;
  bool get hasUnread => _unreadCount > 0;

  /// Fetch all notifications
  Future<void> fetchNotifications({int page = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _notificationService.getNotifications(page: page);
      _notifications = result['notifications'] ?? [];
      _unreadCount = result['unread_count'] ?? 0;
      debugPrint('Loaded ${_notifications.length} notifications, $unreadCount unread');
    } catch (e) {
      _errorMessage = 'Failed to load notifications';
      debugPrint('Error loading notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        final index = _notifications.indexWhere(
          (n) => n['id']?.toString() == notificationId,
        );
        if (index != -1) {
          _notifications[index]['status'] = 'read';
          _notifications[index]['seen'] = true;
          if (_unreadCount > 0) _unreadCount--;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();
      if (success) {
        for (var notification in _notifications) {
          notification['status'] = 'read';
          notification['seen'] = true;
        }
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Delete notification. Removes from list immediately (optimistic) so
  /// Dismissible is removed from tree before next build; API call runs after.
  Future<void> deleteNotification(String notificationId) async {
    if (notificationId.isEmpty) return;
    final index = _notifications.indexWhere(
      (n) => n['id']?.toString() == notificationId,
    );
    if (index == -1) return;

    final wasUnread = _notifications[index]['status'] != 'read' &&
        _notifications[index]['seen'] != true;
    if (wasUnread && _unreadCount > 0) _unreadCount--;
    _notifications.removeWhere((n) => n['id']?.toString() == notificationId);
    notifyListeners(); // Remove widget from tree immediately

    try {
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      // Optionally refetch to restore if API failed
      fetchNotifications();
    }
  }

  /// Clear all notifications locally
  void clearNotifications() {
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }

  /// Delete all notifications (API + local)
  Future<void> deleteAllNotifications() async {
    final ids = _notifications
        .map((n) => n['id']?.toString())
        .where((id) => id != null && id.isNotEmpty)
        .toList();

    for (final id in ids) {
      await _notificationService.deleteNotification(id!);
    }

    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }

  /// Refresh unread count
  Future<void> refreshUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      _unreadCount = count;
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing unread count: $e');
    }
  }
}






