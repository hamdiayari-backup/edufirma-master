import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../network/http_client.dart';

/// Service for handling course comments and reviews
class CommentService {
  final HttpClient _httpClient;

  CommentService(this._httpClient);

  /// Submit a new comment on a course
  /// [itemId] - Course/webinar ID
  /// [itemName] - Type of item ('webinar' for courses, 'bundle' for bundles, 'blog' for blog posts)
  /// [comment] - The comment text
  /// [replyId] - Optional ID of comment to reply to
  Future<Map<String, dynamic>> submitComment({
    required int itemId,
    required String itemName,
    required String comment,
    int? replyId,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/comments';
      debugPrint('=== Submitting comment to: $url ===');

      final body = {
        'item_id': itemId,
        'item_name': itemName,
        'comment': comment,
        if (replyId != null) 'reply_id': replyId,
      };

      debugPrint('=== Comment body: $body ===');

      final res = await _httpClient.httpPostWithToken(url, body);
      debugPrint('=== Comment response status: ${res.statusCode} ===');
      debugPrint('=== Comment response: ${res.body} ===');

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message':
              jsonResponse['message'] ?? 'Comment submitted successfully',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to submit comment',
        };
      }
    } catch (e) {
      debugPrint('Error submitting comment: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get all comments by the current user
  Future<Map<String, dynamic>> getMyComments() async {
    try {
      String url = '${ApiConstants.baseUrl}panel/comments';
      debugPrint('=== Fetching comments from: $url ===');

      final res = await _httpClient.httpGetWithToken(url);
      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        final data = jsonResponse['data'] ?? {};
        return {
          'success': true,
          'webinar_comments': data['my_comment']?['webinar'] ?? [],
          'class_comments': data['class_comment'] ?? [],
        };
      } else {
        return {
          'success': false,
          'webinar_comments': [],
          'class_comments': [],
        };
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      return {
        'success': false,
        'webinar_comments': [],
        'class_comments': [],
      };
    }
  }

  /// Update an existing comment
  Future<Map<String, dynamic>> updateComment(
      int commentId, String comment) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/comments/$commentId';

      final res = await _httpClient.httpPutWithToken(url, {
        'comment': comment,
      });

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Comment updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to update comment',
        };
      }
    } catch (e) {
      debugPrint('Error updating comment: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Delete a comment
  Future<Map<String, dynamic>> deleteComment(int commentId) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/comments/$commentId';

      final res = await _httpClient.httpDeleteWithToken(url, {});

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Comment deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to delete comment',
        };
      }
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Report a comment
  Future<Map<String, dynamic>> reportComment(
      int commentId, String message) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/comments/$commentId/report';

      final res = await _httpClient.httpPostWithToken(url, {
        'message': message,
      });

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Comment reported successfully',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to report comment',
        };
      }
    } catch (e) {
      debugPrint('Error reporting comment: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Reply to a comment (as instructor)
  Future<Map<String, dynamic>> replyToComment(
      int commentId, String reply) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/comments/$commentId/reply';

      final res = await _httpClient.httpPostWithToken(url, {
        'reply': reply,
      });

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Reply sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to send reply',
        };
      }
    } catch (e) {
      debugPrint('Error replying to comment: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Submit a review for a course
  Future<Map<String, dynamic>> submitReview({
    required int webinarId,
    required int contentQuality,
    required int instructorSkills,
    required int purchaseWorth,
    required int supportQuality,
    required String description,
  }) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/reviews';
      debugPrint('=== Submitting review to: $url ===');

      final body = {
        'webinar_id': webinarId,
        'content_quality': contentQuality,
        'instructor_skills': instructorSkills,
        'purchase_worth': purchaseWorth,
        'support_quality': supportQuality,
        'description': description,
      };

      debugPrint('=== Review body: $body ===');

      final res = await _httpClient.httpPostWithToken(url, body);
      debugPrint('=== Review response status: ${res.statusCode} ===');
      debugPrint('=== Review response: ${res.body} ===');

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Review submitted successfully',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to submit review',
        };
      }
    } catch (e) {
      debugPrint('Error submitting review: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
