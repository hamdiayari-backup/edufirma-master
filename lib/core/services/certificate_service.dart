import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../network/http_client.dart';

class CertificateService {
  final HttpClient _httpClient;

  CertificateService(this._httpClient);

  /// Get course/webinar completion certificates
  /// API: panel/webinars/certificates
  Future<List<Map<String, dynamic>>> getCourseCertificates() async {
    List<Map<String, dynamic>> data = [];
    try {
      // FIXED: Added 'panel/' prefix for authenticated endpoint
      String url = '${ApiConstants.baseUrl}panel/webinars/certificates';
      debugPrint('=== CertificateService.getCourseCertificates URL: $url ===');

      // FIXED: Use httpGetWithToken for authenticated requests
      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('Course certificates status: ${res.statusCode}');

      var jsonResponse = jsonDecode(res.body);
      debugPrint('Course certificates success: ${jsonResponse['success']}');

      // FIXED: Check 'success' for both boolean true and integer 1
      if (jsonResponse['success'] == true || jsonResponse['success'] == 1) {
        final certificates = jsonResponse['data']?['certificates'] ?? [];
        debugPrint(
            'Found ${certificates is List ? certificates.length : 0} course certificates');
        if (certificates is List) {
          for (var cert in certificates) {
            data.add(cert as Map<String, dynamic>);
          }
        }
      } else {
        debugPrint('Course certificates API returned success=${jsonResponse['success']}');
      }
      return data;
    } catch (e, stack) {
      debugPrint('Error fetching course certificates: $e');
      debugPrint('Stack: $stack');
      return data;
    }
  }

  /// Get quiz certificates (achievements)
  /// API: panel/certificates/achievements
  Future<List<Map<String, dynamic>>> getQuizCertificates() async {
    List<Map<String, dynamic>> data = [];
    try {
      // FIXED: Added 'panel/' prefix for authenticated endpoint
      String url = '${ApiConstants.baseUrl}panel/certificates/achievements';
      debugPrint('=== CertificateService.getQuizCertificates URL: $url ===');

      // FIXED: Use httpGetWithToken for authenticated requests
      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('Quiz certificates status: ${res.statusCode}');

      var jsonResponse = jsonDecode(res.body);
      debugPrint('Quiz certificates success: ${jsonResponse['success']}');

      // FIXED: Check 'success' for both boolean true and integer 1
      if (jsonResponse['success'] == true || jsonResponse['success'] == 1) {
        // Quiz achievements data is directly in 'data' array
        final certificates = jsonResponse['data'] ?? [];
        debugPrint(
            'Found ${certificates is List ? certificates.length : 0} quiz certificates');
        if (certificates is List) {
          for (var cert in certificates) {
            data.add(cert as Map<String, dynamic>);
          }
        }
      } else {
        debugPrint('Quiz certificates API returned success=${jsonResponse['success']}');
      }
      return data;
    } catch (e, stack) {
      debugPrint('Error fetching quiz certificates: $e');
      debugPrint('Stack: $stack');
      return data;
    }
  }

  /// Get certificates created by instructor (for teachers/organizations)
  /// API: panel/certificates/created
  Future<List<Map<String, dynamic>>> getCreatedCertificates() async {
    List<Map<String, dynamic>> data = [];
    try {
      String url = '${ApiConstants.baseUrl}panel/certificates/created';
      debugPrint('=== CertificateService.getCreatedCertificates URL: $url ===');

      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('Created certificates status: ${res.statusCode}');

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true || jsonResponse['success'] == 1) {
        final certificates = jsonResponse['data']?['certificates'] ?? [];
        debugPrint(
            'Found ${certificates is List ? certificates.length : 0} created certificates');
        if (certificates is List) {
          for (var cert in certificates) {
            data.add(cert as Map<String, dynamic>);
          }
        }
      } else {
        debugPrint('Created certificates API returned success=${jsonResponse['success']}');
      }
      return data;
    } catch (e, stack) {
      debugPrint('Error fetching created certificates: $e');
      debugPrint('Stack: $stack');
      return data;
    }
  }

  /// Get bundle (pack) certificates - Certificat officiel de pack de formation
  /// API: panel/certificates/bundles
  Future<List<Map<String, dynamic>>> getBundleCertificates() async {
    List<Map<String, dynamic>> data = [];
    try {
      String url = '${ApiConstants.baseUrl}panel/certificates/bundles';
      debugPrint('=== CertificateService.getBundleCertificates URL: $url ===');

      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('Bundle certificates status: ${res.statusCode}');

      var jsonResponse = jsonDecode(res.body);
      debugPrint('Bundle certificates success: ${jsonResponse['success']}');

      if (jsonResponse['success'] == true || jsonResponse['success'] == 1) {
        final certificates = jsonResponse['data']?['certificates'] ?? jsonResponse['data'] ?? [];
        debugPrint('Found ${certificates is List ? certificates.length : 0} bundle certificates');
        if (certificates is List) {
          for (var cert in certificates) {
            data.add(cert as Map<String, dynamic>);
          }
        }
      } else {
        debugPrint('Bundle certificates API returned success=${jsonResponse['success']}');
      }
      return data;
    } catch (e, stack) {
      debugPrint('Error fetching bundle certificates: $e');
      debugPrint('Stack: $stack');
      return data;
    }
  }

  /// Get certificate download/view URL
  /// The certificate 'link' field from API response contains the direct URL
  /// For quiz achievements: certificate.link field
  /// For course completion: link field (GET /api/panel/webinars/certificates/{id})
  String getCertificateDownloadUrl(int certificateId,
      {bool isQuiz = false, bool isBundle = false}) {
    if (isBundle) {
      return '${ApiConstants.baseUrl}panel/certificates/bundles/$certificateId';
    }
    if (isQuiz) {
      return '${ApiConstants.baseUrl}panel/certificates/$certificateId/download';
    }
    // Course certificates: GET /api/panel/webinars/certificates/{id} (pas de /download)
    return '${ApiConstants.baseUrl}panel/webinars/certificates/$certificateId';
  }

  /// Get authorization headers for loading certificate images
  /// Certificate images require authentication
  Future<Map<String, String>> getCertificateHeaders() async {
    return _httpClient.getAuthHeaders();
  }

  /// Download certificate file with auth (Bearer token).
  /// Returns raw bytes (e.g. PDF) or null on failure.
  Future<Uint8List?> downloadCertificateBytes(int certificateId,
      {bool isQuiz = false, bool isBundle = false}) async {
    try {
      final url = getCertificateDownloadUrl(certificateId,
          isQuiz: isQuiz, isBundle: isBundle);
      debugPrint('=== CertificateService.downloadCertificateBytes: $url ===');
      final bytes = await _httpClient.httpGetBytesWithToken(url);
      if (bytes != null) {
        debugPrint('Downloaded ${bytes.length} bytes for certificate $certificateId');
      }
      return bytes;
    } catch (e, stack) {
      debugPrint('Error downloading certificate $certificateId: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }
}
