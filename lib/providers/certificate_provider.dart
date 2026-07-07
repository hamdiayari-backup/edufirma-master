import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../core/services/certificate_service.dart';

class CertificateProvider with ChangeNotifier {
  final CertificateService _certificateService;

  CertificateProvider(this._certificateService);

  List<Map<String, dynamic>> _courseCertificates = [];
  List<Map<String, dynamic>> _quizCertificates = [];
  List<Map<String, dynamic>> _bundleCertificates = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get courseCertificates => _courseCertificates;
  List<Map<String, dynamic>> get quizCertificates => _quizCertificates;
  List<Map<String, dynamic>> get bundleCertificates => _bundleCertificates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalCertificates =>
      _courseCertificates.length + _quizCertificates.length + _bundleCertificates.length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Fetch all certificates (course, quiz, pack)
  Future<void> fetchCertificates() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final results = await Future.wait([
        _certificateService.getCourseCertificates(),
        _certificateService.getQuizCertificates(),
        _certificateService.getBundleCertificates(),
      ]);

      _courseCertificates = results[0];
      _quizCertificates = results[1];
      _bundleCertificates = results[2];

      debugPrint('Loaded ${_courseCertificates.length} course certificates');
      debugPrint('Loaded ${_quizCertificates.length} quiz certificates');
      debugPrint('Loaded ${_bundleCertificates.length} bundle certificates');
    } catch (e) {
      _errorMessage = 'Failed to load certificates';
      debugPrint('Error in fetchCertificates: $e');
    }

    _setLoading(false);
  }

  /// Get certificate download URL
  String getCertificateUrl(int certificateId,
      {bool isQuiz = false, bool isBundle = false}) {
    return _certificateService.getCertificateDownloadUrl(certificateId,
        isQuiz: isQuiz, isBundle: isBundle);
  }

  /// Download certificate as bytes (authenticated). Use for in-app download/open.
  Future<Uint8List?> downloadCertificateBytes(int certificateId,
      {bool isQuiz = false, bool isBundle = false}) async {
    return _certificateService.downloadCertificateBytes(certificateId,
        isQuiz: isQuiz, isBundle: isBundle);
  }
}
