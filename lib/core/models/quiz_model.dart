import 'package:flutter/material.dart';

/// Main Quiz Result Model - represents a user's quiz attempt result
class QuizResultModel {
  final int? id;
  final Quiz? quiz;
  final int? userId;
  final int? userGrade;
  final String? status; // 'passed', 'failed', 'waiting'
  final int? createdAt;
  final bool? authCanTryAgain;
  final int? countTryAgain;
  final bool? reviewable;
  final AnswerSheet? answerSheet;
  final List<QuizReview>? quizReview;

  QuizResultModel({
    this.id,
    this.quiz,
    this.userId,
    this.userGrade,
    this.status,
    this.createdAt,
    this.authCanTryAgain,
    this.countTryAgain,
    this.reviewable,
    this.answerSheet,
    this.quizReview,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id'],
      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz']) : null,
      userId: json['user_id'],
      userGrade: json['user_grade'],
      status: json['status'],
      createdAt: json['created_at'],
      authCanTryAgain: json['auth_can_try_again'],
      countTryAgain: json['count_try_again'],
      reviewable: json['reviewable'],
      answerSheet: json['answer_sheet'] != null
          ? AnswerSheet.fromJson(json['answer_sheet'])
          : null,
      quizReview: json['quiz_review'] != null
          ? (json['quiz_review'] as List)
              .map((v) => QuizReview.fromJson(v))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz': quiz?.toJson(),
      'user_id': userId,
      'user_grade': userGrade,
      'status': status,
      'created_at': createdAt,
      'auth_can_try_again': authCanTryAgain,
      'count_try_again': countTryAgain,
      'reviewable': reviewable,
      'answer_sheet': answerSheet?.toJson(),
      'quiz_review': quizReview?.map((v) => v.toJson()).toList(),
    };
  }
}

/// Quiz definition with questions and settings
class Quiz {
  final int? id;
  final String? title;
  final int? time; // Time limit in minutes
  final String? authStatus;
  final int? questionCount;
  final int? totalMark;
  final int? passMark;
  final int? averageGrade;
  final int? studentCount;
  final int? certificatesCount;
  final int? successRate;
  final String? status;
  final int? attempt;
  final int? createdAt;
  final bool? certificate;
  final int? authAttemptCount;
  final String? attemptState;
  final bool? authCanStart;
  final bool? authCanDownloadCertificate;
  final int? participatedCount;
  final List<Question>? questions;
  final int? webinarId;
  final int? bestGrade;
  final Map<String, dynamic>? latestResult;

  Quiz({
    this.id,
    this.title,
    this.time,
    this.authStatus,
    this.questionCount,
    this.totalMark,
    this.passMark,
    this.averageGrade,
    this.studentCount,
    this.certificatesCount,
    this.successRate,
    this.status,
    this.attempt,
    this.createdAt,
    this.certificate,
    this.authAttemptCount,
    this.attemptState,
    this.authCanStart,
    this.authCanDownloadCertificate,
    this.participatedCount,
    this.questions,
    this.webinarId,
    this.bestGrade,
    this.latestResult,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    List<Question>? questions;
    if (json['questions'] != null || json['quiz_questions'] != null) {
      questions = <Question>[];
      try {
        (json['questions'] as List?)?.forEach((v) {
          questions!.add(Question.fromJson(v));
        });
      } catch (_) {}
      try {
        (json['quiz_questions'] as List?)?.forEach((v) {
          questions!.add(Question.fromJson(v));
        });
      } catch (_) {}
    }

    // certificate: bool or int (1/0)
    final certRaw = json['certificate'];
    bool? certificateBool;
    if (certRaw != null) {
      if (certRaw is bool) certificateBool = certRaw;
      else if (certRaw is int) certificateBool = certRaw == 1;
      else certificateBool = certRaw.toString() == '1' || certRaw.toString().toLowerCase() == 'true';
    }
    // best_grade, latest_result (from content API)
    final bestGradeRaw = json['best_grade'] ?? json['bestGrade'];
    final int? bestGrade = bestGradeRaw is int ? bestGradeRaw : int.tryParse(bestGradeRaw?.toString() ?? '');
    final latestResult = json['latest_result'] != null && json['latest_result'] is Map
        ? Map<String, dynamic>.from(json['latest_result'] as Map)
        : null;
    // question_count (API can send question_count)
    final questionCount = json['question_count'] ?? json['questionCount'];
    // attempt, auth_attempt_count (int)
    final attemptRaw = json['attempt'];
    final int? attempt = attemptRaw is int ? attemptRaw : int.tryParse(attemptRaw?.toString() ?? '');
    final authAttemptCountRaw = json['auth_attempt_count'] ?? json['authAttemptCount'];
    final int? authAttemptCount = authAttemptCountRaw is int ? authAttemptCountRaw : int.tryParse(authAttemptCountRaw?.toString() ?? '');

    // total_mark / pass_mark can be int, string, or under different keys
    final totalMarkRaw = json['total_mark'] ?? json['totalMark'] ?? json['total_grade'];
    final passMarkRaw = json['pass_mark'] ?? json['passMark'] ?? json['pass_grade'];
    int? totalMark = totalMarkRaw is int ? totalMarkRaw : int.tryParse(totalMarkRaw?.toString() ?? '');
    int? passMark = passMarkRaw is int ? passMarkRaw : int.tryParse(passMarkRaw?.toString() ?? '');
    // Fallback: sum question grades if we have questions
    if ((totalMark == null || totalMark == 0) && questions != null && questions.isNotEmpty) {
      int sum = 0;
      for (var q in questions) {
        sum += int.tryParse(q.grade?.toString() ?? '0') ?? 0;
      }
      if (sum > 0) totalMark = sum;
    }

    return Quiz(
      id: json['id'],
      title: json['title'],
      time: json['time'],
      authStatus: json['auth_status'] ?? json['authStatus'],
      questionCount: questionCount,
      totalMark: totalMark,
      passMark: passMark,
      averageGrade: json['average_grade'],
      studentCount: json['student_count'],
      certificatesCount: json['certificates_count'],
      successRate: json['success_rate'],
      status: json['status'],
      attempt: attempt,
      createdAt: json['created_at'],
      certificate: certificateBool,
      authAttemptCount: authAttemptCount,
      attemptState: json['attempt_state'],
      authCanStart: json['auth_can_start'],
      authCanDownloadCertificate: json['auth_can_download_certificate'],
      participatedCount: json['participated_count'],
      questions: questions,
      webinarId: json['webinar_id'],
      bestGrade: bestGrade,
      latestResult: latestResult,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'auth_status': authStatus,
      'question_count': questionCount,
      'total_mark': totalMark,
      'pass_mark': passMark,
      'average_grade': averageGrade,
      'student_count': studentCount,
      'certificates_count': certificatesCount,
      'success_rate': successRate,
      'status': status,
      'attempt': attempt,
      'created_at': createdAt,
      'certificate': certificate == true ? 1 : (certificate == false ? 0 : null),
      'auth_attempt_count': authAttemptCount,
      'attempt_state': attemptState,
      'auth_can_start': authCanStart,
      'auth_can_download_certificate': authCanDownloadCertificate,
      'participated_count': participatedCount,
      'questions': questions?.map((v) => v.toJson()).toList(),
      'webinar_id': webinarId,
      'best_grade': bestGrade,
      'latest_result': latestResult,
    };
  }
}

/// Question model
class Question {
  final int? id;
  final String? title;
  final String? type; // 'multiple', 'descriptive'
  final String? descriptiveCorrectAnswer;
  final String? grade;
  final int? createdAt;
  final int? updatedAt;
  List<Answer>? answers;

  // UI state - not from API
  final TextEditingController inputController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  int gradeForUser = 0;

  Question({
    this.id,
    this.title,
    this.type,
    this.descriptiveCorrectAnswer,
    this.grade,
    this.createdAt,
    this.updatedAt,
    this.answers,
  }) {
    gradeForUser = int.tryParse(grade ?? '0') ?? 0;
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    List<Answer>? answers;
    if (json['answers'] != null || json['quizzes_questions_answers'] != null) {
      answers = <Answer>[];
      try {
        (json['answers'] as List?)?.forEach((v) {
          answers!.add(Answer.fromJson(v));
        });
      } catch (_) {}
      try {
        (json['quizzes_questions_answers'] as List?)?.forEach((v) {
          answers!.add(Answer.fromJson(v));
        });
      } catch (_) {}
    }

    return Question(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      descriptiveCorrectAnswer: json['descriptive_correct_answer'],
      grade: json['grade']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      answers: answers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'descriptive_correct_answer': descriptiveCorrectAnswer,
      'grade': grade,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'answers': answers?.map((v) => v.toJson()).toList(),
    };
  }
}

/// Answer option for multiple choice questions
class Answer {
  final int? id;
  final String? title;
  final int? correct;
  final String? image;
  final int? createdAt;
  final int? updatedAt;

  // UI state
  bool isSelected = false;

  Answer({
    this.id,
    this.title,
    this.correct,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      title: json['title'],
      correct: json['correct'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'correct': correct,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// User's answer sheet for a quiz attempt
class AnswerSheet {
  final Map<String, UserAnswer> items;
  final int attemptNumber;

  AnswerSheet({
    required this.items,
    this.attemptNumber = 0,
  });

  factory AnswerSheet.fromJson(Map<String, dynamic> json) {
    Map<String, UserAnswer> items = {};
    int attemptNumber = 0;

    json.forEach((key, value) {
      if (key == 'attempt_number') {
        attemptNumber = int.tryParse(value.toString()) ?? 0;
      } else if (value is Map<String, dynamic>) {
        items[key] = UserAnswer.fromJson(value);
      }
    });

    return AnswerSheet(
      items: items,
      attemptNumber: attemptNumber,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    items.forEach((key, value) {
      data[key] = value.toJson();
    });
    data['attempt_number'] = attemptNumber;
    return data;
  }
}

/// User's answer to a single question
class UserAnswer {
  final String? grade;
  final bool? status;
  final dynamic answer; // Can be int (answer id) or String (descriptive)

  UserAnswer({
    this.grade,
    this.status,
    this.answer,
  });

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      grade: json['grade']?.toString(),
      status: json['status'],
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grade': grade,
      'status': status,
      'answer': answer,
    };
  }
}

/// Quiz review - question with user's answer and correct answer
class QuizReview {
  final int? id;
  final String? title;
  final String? type;
  final String? descriptiveCorrectAnswer;
  final String? grade;
  final int? createdAt;
  final int? updatedAt;
  final List<Answer>? answers;
  final UserAnswer? userAnswer;

  QuizReview({
    this.id,
    this.title,
    this.type,
    this.descriptiveCorrectAnswer,
    this.grade,
    this.createdAt,
    this.updatedAt,
    this.answers,
    this.userAnswer,
  });

  factory QuizReview.fromJson(Map<String, dynamic> json) {
    List<Answer>? answers;
    if (json['answers'] != null) {
      answers =
          (json['answers'] as List).map((v) => Answer.fromJson(v)).toList();
    }

    return QuizReview(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      descriptiveCorrectAnswer: json['descriptive_correct_answer'],
      grade: json['grade']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      answers: answers,
      userAnswer: json['user_answer'] != null
          ? UserAnswer.fromJson(json['user_answer'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'descriptive_correct_answer': descriptiveCorrectAnswer,
      'grade': grade,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'answers': answers?.map((v) => v.toJson()).toList(),
      'user_answer': userAnswer?.toJson(),
    };
  }
}
