import 'package:flutter/foundation.dart';
import '../core/services/auth_service.dart';
import '../core/services/firebase_notification_service.dart';
import '../core/storage/local_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final LocalStorage _storage;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  String? _registrationErrorStatus;
  int? _userId;
  String? _currentStep;

  AuthProvider(this._authService, this._storage);

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  String? get registrationErrorStatus => _registrationErrorStatus;
  int? get userId => _userId;
  String? get currentStep => _currentStep;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _registrationErrorStatus = null;
    notifyListeners();
  }

  /// Check login status
  Future<void> checkLoginStatus() async {
    final token = await _storage.getAccessToken();
    _isLoggedIn = token != null && token.isNotEmpty;
    notifyListeners();
  }

  /// Login
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.login(username, password);

    _setLoading(false);

    if (result['success'] == true) {
      _isLoggedIn = true;
      FirebaseNotificationService().sendTokenToServerIfLoggedIn();
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Register with email - Step 1
  /// [registerMethod] unused: backend infers method from email/mobile keys; kept for API compatibility.
  Future<bool> registerWithEmail(
    String email,
    String password,
    String repeatPassword, {
    String accountType = 'user',
    String? registerMethod,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _registrationErrorStatus = null;

    final result = await _authService.registerWithEmail(
      'email',
      email,
      password,
      repeatPassword,
      accountType: accountType,
    );

    _setLoading(false);

    if (result['success'] == true) {
      _userId = result['user_id'];
      _currentStep = result['step'];
      _registrationErrorStatus = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] as String?;
      _registrationErrorStatus = result['status'] as String?;
      notifyListeners();
      return false;
    }
  }

  /// Register with phone - Step 1
  /// [registerMethod] unused: backend infers method from email/mobile keys; kept for API compatibility.
  Future<bool> registerWithPhone(
    String countryCode,
    String mobile,
    String password,
    String repeatPassword, {
    String accountType = 'user',
    String? registerMethod,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _registrationErrorStatus = null;

    final result = await _authService.registerWithPhone(
      'mobile',
      countryCode,
      mobile,
      password,
      repeatPassword,
      accountType: accountType,
    );

    _setLoading(false);

    if (result['success'] == true) {
      _userId = result['user_id'];
      _currentStep = result['step'];
      _registrationErrorStatus = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] as String?;
      _registrationErrorStatus = result['status'] as String?;
      notifyListeners();
      return false;
    }
  }

  /// Verify code - Step 2
  Future<bool> verifyCode(String code) async {
    if (_userId == null) {
      _errorMessage = 'User ID not found';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.verifyCode(_userId!, code);

    _setLoading(false);

    if (result['success'] == true) {
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Complete registration - Step 3
  Future<bool> completeRegistration(String name, String referralCode) async {
    if (_userId == null) {
      _errorMessage = 'User ID not found';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    final result =
        await _authService.registerStep3(_userId!, name, referralCode);

    _setLoading(false);

    if (result['success'] == true) {
      _isLoggedIn = true;
      FirebaseNotificationService().sendTokenToServerIfLoggedIn();
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Forgot password
  Future<bool> forgotPassword(String? countryCode, String data) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.forgetPassword(countryCode, data);

    _setLoading(false);

    if (result['success'] == true) {
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Reset password (mobile: code + new password)
  Future<bool> resetPasswordByMobile(
    String countryCode,
    String mobile,
    String code,
    String password,
    String passwordConfirmation,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.resetPasswordByMobile(
      countryCode,
      mobile,
      code,
      password,
      passwordConfirmation,
    );

    _setLoading(false);

    if (result['success'] == true) {
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _setLoading(true);

    await _authService.logout();

    _isLoggedIn = false;
    _userId = null;
    _currentStep = null;
    _setLoading(false);
  }
}
