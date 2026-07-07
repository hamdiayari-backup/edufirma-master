import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../models/quiz_model.dart';
import '../network/http_client.dart';

/// Service for quiz-related API operations
class QuizService {
  final HttpClient _httpClient;

  QuizService(this._httpClient);

  /// Start a quiz and get questions
  /// Returns quiz data and quiz_result_id for submitting answers.
  /// On failure: {success: false, status: 'max_attempt'|'error', message: '...'}.
  Future<Map<String, dynamic>?> startQuiz(int quizId) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/quizzes/$quizId/start';
      debugPrint('=== Starting quiz: $url ===');

      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('=== Start quiz response: ${res.statusCode} ===');

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return {
          'quiz': Quiz.fromJson(jsonResponse['data']['quiz']),
          'quiz_result_id': jsonResponse['data']['quiz_result_id'],
        };
      } else {
        debugPrint('Start quiz error: ${jsonResponse['message']}');
        return {
          'success': false,
          'status': jsonResponse['status']?.toString() ?? 'error',
          'message': jsonResponse['message']?.toString() ?? '',
        };
      }
    } catch (e) {
      debugPrint('Error starting quiz: $e');
      return null;
    }
  }

  /// Submit quiz answers
  Future<bool> storeResult(
      int quizId, int quizResultId, List<Question> questions) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/quizzes/$quizId/store-result';
      debugPrint('=== Storing quiz result: $url ===');

      List<Map<String, dynamic>> answerSheet = [];

      for (var question in questions) {
        if (question.type == 'descriptive') {
          answerSheet.add({
            'question_id': question.id,
            'answer': question.inputController.text.trim(),
          });
        } else {
          // Multiple choice
          final selectedAnswer = question.answers?.firstWhere(
            (a) => a.isSelected,
            orElse: () => Answer(),
          );
          if (selectedAnswer?.id != null) {
            answerSheet.add({
              'question_id': question.id,
              'answer': selectedAnswer!.id,
            });
          }
        }
      }

      // Remove null answers
      answerSheet.removeWhere((element) => element['answer'] == null);

      final body = {
        'quiz_result_id': quizResultId,
        'answer_sheet': answerSheet,
      };

      debugPrint('=== Quiz submit body: $body ===');

      final res = await _httpClient.httpPostWithToken(url, body);
      debugPrint('=== Store result response: ${res.statusCode} ===');

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return true;
      } else {
        debugPrint('Store result error: ${jsonResponse['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Error storing result: $e');
      return false;
    }
  }

  /// Get quiz results for review
  Future<QuizResultModel?> getQuizResult(int quizId) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/quizzes/$quizId/result';
      debugPrint('=== Getting quiz result: $url ===');

      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('=== Quiz result response: ${res.statusCode} ===');

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return QuizResultModel.fromJson(jsonResponse['data']);
      } else {
        debugPrint('Get result error: ${jsonResponse['message']}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting result: $e');
      return null;
    }
  }

  /// Get my quiz results (student)
  Future<List<QuizResultModel>> getMyResults() async {
    List<QuizResultModel> data = [];
    try {
      String url = '${ApiConstants.baseUrl}panel/quizzes/results/my-results';
      debugPrint('=== Getting my results: $url ===');

      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('=== My results response: ${res.statusCode} ===');

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        final results = jsonResponse['data']['results'] as List?;
        if (results != null) {
          for (var json in results) {
            data.add(QuizResultModel.fromJson(json));
          }
        }
      }
      return data;
    } catch (e) {
      debugPrint('Error getting my results: $e');
      return data;
    }
  }

  /// Get quizzes not yet participated
  Future<List<Quiz>> getNotParticipated() async {
    List<Quiz> data = [];
    try {
      String url = '${ApiConstants.baseUrl}panel/quizzes/not_participated';
      debugPrint('=== Getting not participated: $url ===');

      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('=== Not participated response: ${res.statusCode} ===');

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        final quizzes = jsonResponse['data']['quizzes'] as List?;
        if (quizzes != null) {
          for (var json in quizzes) {
            data.add(Quiz.fromJson(json));
          }
        }
      }
      return data;
    } catch (e) {
      debugPrint('Error getting not participated: $e');
      return data;
    }
  }

  /// Review quiz result details
  Future<QuizResultModel?> reviewQuiz(int resultId) async {
    try {
      String url = '${ApiConstants.baseUrl}panel/quizzes/results/$resultId';
      debugPrint('=== Reviewing quiz: $url ===');

      final res = await _httpClient.httpGetWithToken(url);
      debugPrint('=== Review response: ${res.statusCode} ===');

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success'] == true) {
        return QuizResultModel.fromJson(
            jsonResponse['data']['quizResultDetails']);
      } else {
        debugPrint('Review error: ${jsonResponse['message']}');
        return null;
      }
    } catch (e) {
      debugPrint('Error reviewing quiz: $e');
      return null;
    }
  }
}
