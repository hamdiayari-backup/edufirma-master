/// Script to test backend notifications & FCM API
/// Run: dart run scripts/test_backend_notifications.dart
/// Or: fvm dart run scripts/test_backend_notifications.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  // === CONFIG: Replace with your values ===
  const baseUrl = 'https://edufirma.com/api/';
  const apiKey = '1234';
  const jwt = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2tpbmdjb3EuY29tL2FwaS9sb2dpbiIsImlhdCI6MTc2OTc4OTMyNywibmJmIjoxNzY5Nzg5MzI3LCJqdGkiOiJKNGtjbnppVWYyT0puekRjIiwic3ViIjoiMTA5MiIsInBydiI6IjQwYTk3ZmNhMmQ0MjRlNzc4YTA3YTBhMmYxMmRjNTE3YTg1Y2JkYzEifQ.jz6xHxV-C_d4WXtc2V4i8tos2yP4Rs2NvrowX60ifCE';

  print('=== Test Backend Notifications ===\n');

  // 1. Test GET notifications
  print('1. GET /panel/notifications?page=1');
  try {
    final req = await HttpClient()
        .getUrl(Uri.parse('${baseUrl}panel/notifications?page=1'));
    req.headers.set('Authorization', 'Bearer $jwt');
    req.headers.set('x-api-key', apiKey);
    req.headers.set('x-locale', 'fr');
    req.headers.set('Content-Type', 'application/json');

    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();

    print('   Status: ${res.statusCode}');
    final json = jsonDecode(body) as Map<String, dynamic>;
    print('   Success: ${json['success']}');
    if (json['data'] != null) {
      final data = json['data'] as Map<String, dynamic>?;
      final list = data?['notifications'] as List?;
      print('   Notifications count: ${list?.length ?? 0}');
    }
    print('   Response: ${body.length > 200 ? body.substring(0, 200) + "..." : body}\n');
  } catch (e) {
    print('   ERROR: $e\n');
  }

  // 2. Test PUT FCM token
  print('2. PUT /panel/users/fcm');
  try {
    final req = await HttpClient()
        .putUrl(Uri.parse('${baseUrl}panel/users/fcm'));
    req.headers.set('Authorization', 'Bearer $jwt');
    req.headers.set('x-api-key', apiKey);
    req.headers.set('Content-Type', 'application/json');
    req.write(jsonEncode({'token': 'test_fcm_token_${DateTime.now().millisecondsSinceEpoch}'}));

    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();

    print('   Status: ${res.statusCode}');
    final json = jsonDecode(body) as Map<String, dynamic>;
    print('   Success: ${json['success']}');
    print('   Message: ${json['message'] ?? json['status']}');
    print('   Full: $body\n');
  } catch (e) {
    print('   ERROR: $e\n');
  }

  print('=== Done ===');
}
