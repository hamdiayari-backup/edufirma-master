import 'package:flutter/foundation.dart';
import '../core/services/user_service.dart';
import '../core/storage/local_storage.dart';

class ProfileProvider extends ChangeNotifier {
  final UserService _userService;
  final LocalStorage _storage;

  bool _isLoading = false;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _dashboard;
  Map<String, dynamic>? _rewardsData;
  List<Map<String, dynamic>> _purchases = [];
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> _notifications = [];
  String? _errorMessage;

  ProfileProvider(this._userService, this._storage);

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get profile => _profile;
  Map<String, dynamic>? get dashboard => _dashboard;
  Map<String, dynamic>? get rewardsData => _rewardsData;
  List<Map<String, dynamic>> get purchases => _purchases;
  List<Map<String, dynamic>> get favorites => _favorites;
  List<Map<String, dynamic>> get notifications => _notifications;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Fetch profile
  Future<void> fetchProfile() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _profile = await _userService.getProfile();
    } catch (e) {
      _errorMessage = 'Failed to load profile';
    }

    _setLoading(false);
  }

  /// Fetch dashboard
  Future<void> fetchDashboard() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _dashboard = await _userService.getDashboardData();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard';
    }

    _setLoading(false);
  }

  /// Fetch rewards (points balance + conversion rate). GET panel/rewards.
  Future<void> fetchRewards() async {
    try {
      _rewardsData = await _userService.getRewards();
      notifyListeners();
    } catch (e) {
      _rewardsData = null;
    }
  }

  /// Fetch purchased courses
  Future<void> fetchPurchases() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _purchases = await _userService.getPurchasedCourses();
    } catch (e) {
      _errorMessage = 'Failed to load purchases';
    }

    _setLoading(false);
  }

  /// Fetch favorites
  Future<void> fetchFavorites() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _favorites = await _userService.getFavorites();
    } catch (e) {
      _errorMessage = 'Failed to load favorites';
    }

    _setLoading(false);
  }

  /// Delete favorite
  Future<bool> deleteFavorite(int id) async {
    try {
      final success = await _userService.deleteFavorite(id);
      if (success) {
        _favorites.removeWhere((f) => f['id'] == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Fetch notifications
  Future<void> fetchNotifications() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _notifications = await _userService.getNotifications();
    } catch (e) {
      _errorMessage = 'Failed to load notifications';
    }

    _setLoading(false);
  }

  /// Mark notification as read
  Future<bool> markNotificationRead(int id) async {
    try {
      final success = await _userService.markNotificationRead(id);
      if (success) {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['read'] = true;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Update profile info with named parameters
  Future<bool> updateProfileInfo({
    required String email,
    required String name,
    required String phone,
    String? timezone,
    bool newsletter = false,
    String? address,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _userService.updateInfo(
        email: email,
        name: name,
        phone: phone,
        timezone: timezone,
        newsletter: newsletter,
        address: address,
      );
      if (success) {
        await fetchProfile();
        return true;
      }
      _errorMessage = 'Failed to update profile';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      _setLoading(false);
      return false;
    }
  }

  /// Update profile with Map data (simpler API)
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _userService.updateInfo(
        email: data['email'] ?? _profile?['email'] ?? '',
        name: data['full_name'] ?? data['name'] ?? _profile?['full_name'] ?? '',
        phone: data['mobile'] ?? data['phone'] ?? _profile?['mobile'] ?? '',
        timezone: data['timezone'],
        newsletter: data['newsletter'] ?? false,
        address: data['address'],
        bio: data['bio'],
      );
      if (success) {
        // Update local profile with new data
        if (_profile != null) {
          _profile = {..._profile!, ...data};
        }
        notifyListeners();
        return true;
      }
      _errorMessage = 'Failed to update profile';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      _setLoading(false);
      return false;
    }
  }

  /// Update password
  Future<bool> updatePassword(
      String currentPassword, String newPassword) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result =
          await _userService.updatePassword(currentPassword, newPassword);
      if (result['success'] == true) {
        if (result['token'] != null) {
          await _storage.setAccessToken(result['token']);
        }
        _setLoading(false);
        return true;
      }
      _errorMessage = result['message'] ?? 'Failed to update password';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update password';
      _setLoading(false);
      return false;
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
    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _userService.storeReview(
        postId: postId,
        contentQuality: contentQuality,
        instructorSkills: instructorSkills,
        purchaseWorth: purchaseWorth,
        supportQuality: supportQuality,
        description: description,
      );
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = 'Failed to submit review';
      _setLoading(false);
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _userService.deleteAccount();
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete account';
      _setLoading(false);
      return false;
    }
  }

  /// Load all user data
  Future<void> loadUserData() async {
    await Future.wait([
      fetchProfile(),
      fetchDashboard(),
      fetchRewards(),
      fetchPurchases(),
      fetchFavorites(),
      fetchNotifications(),
    ]);
  }

  /// Clear user data
  void clearUserData() {
    _profile = null;
    _dashboard = null;
    _rewardsData = null;
    _purchases = [];
    _favorites = [];
    _notifications = [];
    notifyListeners();
  }
}

