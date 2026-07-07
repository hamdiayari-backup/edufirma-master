import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';

class HttpClient {
  final LocalStorage _storage;
  final dio.Dio _dio;
  String _currentLanguage = 'fr';

  HttpClient(this._storage, this._dio);

  void setLanguage(String language) {
    _currentLanguage = language.toLowerCase();
  }

  Map<String, String> _getHeaders({bool withToken = false, String? token}) {
    return {
      if (withToken && token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      'Accept': 'application/json',
      'x-api-key': ApiConstants.apiKey,
      'x-locale': _currentLanguage,
    };
  }

  // GET request without token
  Future<http.Response> httpGet(String url, {bool isSendToken = false}) async {
    String token = '';
    if (isSendToken) {
      token = await _storage.getAccessToken() ?? '';
    }

    final headers = _getHeaders(withToken: isSendToken, token: token);

    var request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    return http.Response(
      await response.stream.bytesToString(),
      response.statusCode,
    );
  }

  // GET request with token
  Future<http.Response> httpGetWithToken(String url) async {
    String token = await _storage.getAccessToken() ?? '';

    final headers = _getHeaders(withToken: true, token: token);

    var request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    return http.Response(
      await response.stream.bytesToString(),
      response.statusCode,
    );
  }

  /// GET with token, returns response body as bytes (e.g. for PDF download).
  /// Returns null if status is not 200.
  Future<Uint8List?> httpGetBytesWithToken(String url) async {
    String token = await _storage.getAccessToken() ?? '';
    final headers = _getHeaders(withToken: true, token: token);

    var request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode != 200) return null;
    final chunks = await response.stream.toList();
    return Uint8List.fromList(chunks.expand((x) => x).toList());
  }

  // POST request without token
  Future<http.Response> httpPost(String url, dynamic body) async {
    final headers = _getHeaders();
    var myBody = json.encode(body);

    var request = http.Request('POST', Uri.parse(url));
    request.body = myBody;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    return http.Response(
      await response.stream.bytesToString(),
      response.statusCode,
    );
  }

  // POST request with token
  Future<http.Response> httpPostWithToken(String url, dynamic body) async {
    String token = await _storage.getAccessToken() ?? '';

    final headers = _getHeaders(withToken: true, token: token);
    var myBody = json.encode(body);

    var request = http.Request('POST', Uri.parse(url));
    request.body = myBody;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    return http.Response(
      await response.stream.bytesToString(),
      response.statusCode,
    );
  }

  // PUT request with token
  Future<http.Response> httpPutWithToken(String url, dynamic body) async {
    String token = await _storage.getAccessToken() ?? '';

    final headers = _getHeaders(withToken: true, token: token);
    var myBody = json.encode(body);

    var request = http.Request('PUT', Uri.parse(url));
    request.body = myBody;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    return http.Response(
      await response.stream.bytesToString(),
      response.statusCode,
    );
  }

  // DELETE request with token
  Future<http.Response> httpDeleteWithToken(String url, dynamic body) async {
    String token = await _storage.getAccessToken() ?? '';

    final headers = _getHeaders(withToken: true, token: token);
    var myBody = json.encode(body);

    var request = http.Request('DELETE', Uri.parse(url));
    request.body = myBody;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    return http.Response(
      await response.stream.bytesToString(),
      response.statusCode,
    );
  }

  // Dio POST with token (for file uploads)
  Future<dio.Response> dioPostWithToken(String url, dynamic body) async {
    String token = await _storage.getAccessToken() ?? '';

    return _dio
        .post(
          url,
          data: body,
          options: dio.Options(
            headers: _getHeaders(withToken: true, token: token),
          ),
        )
        .timeout(const Duration(seconds: 30));
  }

  /// Get authorization headers for external use (e.g., loading images with auth)
  Future<Map<String, String>> getAuthHeaders() async {
    String token = await _storage.getAccessToken() ?? '';
    return _getHeaders(withToken: true, token: token);
  }
}
