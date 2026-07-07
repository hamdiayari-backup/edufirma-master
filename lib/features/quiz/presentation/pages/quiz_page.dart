import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/models/quiz_model.dart';
import '../../../../core/services/quiz_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuizService _quizService = locator<QuizService>();
  late ConfettiController _confettiController;

  Quiz? _quizData;
  QuizResultModel? _reviewData;
  QuizResultModel? _resultData;
  int? _quizResultId;
  int? _quizId;

  int _currentQuestionIndex = 0;

  bool _isLoading = false;
  bool _isStarted = false;
  bool _isSubmitting = false;
  bool _isReview = false;
  bool _showResultScreen = false;
  bool _isLoadingResult = false;

  Timer? _timer;
  Duration? _remainingTime;
  double _progressValue = 1.0;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuiz();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _initializeQuiz() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _quizId = args['quiz_id'];
      _isReview = args['is_review'] ?? false;

      if (_isReview && args['quiz_result'] != null) {
        _reviewData = args['quiz_result'] as QuizResultModel;
        _quizData = _reviewData?.quiz;
        _isStarted = true;
        setState(() {});
      } else {
        _startQuiz();
      }
    }
  }

  Future<void> _startQuiz() async {
    if (_quizId == null) return;

    final locale = Localizations.localeOf(context).languageCode;
    setState(() => _isLoading = true);

    final result = await _quizService.startQuiz(_quizId!);

    if (result != null && result['success'] == false) {
      final status = result['status']?.toString() ?? '';
      final isMaxAttempt = status == 'max_attempt';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isMaxAttempt
                  ? 'no_attempts_left_message'.tr(locale)
                  : 'quiz_start_error'.tr(locale),
            ),
            backgroundColor: isMaxAttempt ? AppColors.warning : Colors.red,
          ),
        );
        Navigator.pop(context);
      }
      setState(() => _isLoading = false);
      return;
    }

    if (result != null && result['quiz'] != null) {
      _quizData = result['quiz'] as Quiz;
      _quizResultId = result['quiz_result_id'];
      _isStarted = true;
      _startTimer();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('quiz_start_error'.tr(locale)),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }

    setState(() => _isLoading = false);
  }

  void _startTimer() {
    if (_quizData?.time == null || _quizData!.time! <= 0) return;

    _remainingTime = Duration(minutes: _quizData!.time!);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime!.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime!.inSeconds - 1);
          _progressValue = _remainingTime!.inSeconds / (_quizData!.time! * 60);
        });
      } else {
        timer.cancel();
        _submitQuiz();
      }
    });
  }

  Future<void> _submitQuiz() async {
    if (_quizData == null || _quizResultId == null) return;

    setState(() => _isSubmitting = true);
    _timer?.cancel();

    final success = await _quizService.storeResult(
      _quizData!.id!,
      _quizResultId!,
      _quizData!.questions ?? [],
    );

    if (!success || !mounted) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('quiz_submit_error'
                .tr(Localizations.localeOf(context).languageCode)),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = false;
      _isLoadingResult = true;
    });

    final result = await _quizService.getQuizResult(_quizData!.id!);

    if (mounted) {
      setState(() {
        _resultData = result;
        _showResultScreen = true;
        _isLoadingResult = false;
      });
      if (result?.status == 'passed') {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _confettiController.play();
        });
      }
    }
  }

  void _backToCourse() {
    Navigator.pop(context, true);
  }

  Future<void> _reviewAnswers() async {
    if (_resultData == null) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.quiz,
      arguments: {
        'quiz_id': _quizData?.id,
        'is_review': true,
        'quiz_result': _resultData,
      },
    );
  }

  Future<void> _retryQuiz() async {
    if (_quizData?.id == null) return;
    _resetQuestionState();
    setState(() {
      _showResultScreen = false;
      _resultData = null;
      _currentQuestionIndex = 0;
    });
    await _startQuiz();
  }

  void _resetQuestionState() {
    for (final q in _quizData?.questions ?? []) {
      q.inputController.clear();
      for (final a in q.answers ?? []) {
        a.isSelected = false;
      }
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:
          _showResultScreen ? _buildResultAppBar(locale) : _buildAppBar(locale),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isStarted
              ? const SizedBox()
              : _showResultScreen
                  ? _buildResultScreen(locale)
                  : Column(
                      children: [
                        _buildHeader(locale),
                        Expanded(child: _buildQuestionContent(locale)),
                        _buildBottomNavigation(locale),
                      ],
                    ),
    );
  }

  PreferredSizeWidget _buildResultAppBar(String locale) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: _backToCourse,
      ),
      title: Text(
        _quizData?.title ?? 'quiz'.tr(locale),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildResultScreen(String locale) {
    if (_isLoadingResult) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasResult = _resultData != null;
    final status = _resultData?.status ?? '';
    final isPassed = status == 'passed';
    final isFailed = status == 'failed';
    final isWaiting = status == 'waiting';
    final grade = _resultData?.userGrade ?? 0;
    final total = _quizData?.totalMark ?? 1;
    final canRetry = isFailed && (_resultData?.authCanTryAgain == true);
    final hasQuestions =
        (_resultData?.quiz?.questions != null &&
            _resultData!.quiz!.questions!.isNotEmpty);
    final canReview =
        hasResult && !isWaiting && hasQuestions;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildResultIcon(isPassed, isWaiting, hasResult, locale),
              const SizedBox(height: 24),
              if (hasResult && !isWaiting) _buildScoreCard(grade, total, isPassed, isFailed, locale),
              if (hasResult && !isWaiting) const SizedBox(height: 20),
              Text(
                !hasResult
                    ? 'quiz_submitted'.tr(locale)
                    : isPassed
                        ? 'congratulations_passed'.tr(locale)
                        : isWaiting
                            ? 'waiting_for_review'.tr(locale)
                            : 'try_again_message'.tr(locale),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isPassed) ...[
                const SizedBox(height: 12),
                Text(
                  'quiz_certificate_motivation'.tr(locale),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (isFailed && canReview) ...[
                const SizedBox(height: 12),
                Text(
                  'review_answers_help'.tr(locale),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildResultActions(
                locale,
                canReview: canReview,
                canRetry: canRetry,
                isPassed: isPassed,
              ),
            ],
          ),
        ),
        if (isPassed)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              gravity: 0.15,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResultIcon(
      bool isPassed, bool isWaiting, bool hasResult, String locale) {
    Color color = !hasResult
        ? AppColors.primary
        : isPassed
            ? AppColors.success
            : isWaiting
                ? AppColors.warning
                : AppColors.error;
    IconData icon = !hasResult
        ? Icons.check_circle_outline
        : isPassed
            ? Icons.check_circle
            : isWaiting
                ? Icons.schedule
                : Icons.cancel;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 3),
      ),
      child: Icon(icon, size: 56, color: color),
    );
  }

  Widget _buildScoreCard(
      int grade, int total, bool isPassed, bool isFailed, String locale) {
    final percentage = total > 0 ? ((grade / total) * 100).round() : 0;
    final statusLabel = isPassed
        ? 'quiz_status_passed'.tr(locale)
        : isFailed
            ? 'quiz_status_failed'.tr(locale)
            : 'waiting'.tr(locale);
    final bgColor = isPassed
        ? AppColors.success.withOpacity(0.12)
        : isFailed
            ? AppColors.error.withOpacity(0.12)
            : AppColors.warning.withOpacity(0.12);
    final borderColor = isPassed ? AppColors.success : isFailed ? AppColors.error : AppColors.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'your_grade'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$grade',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: borderColor,
                ),
              ),
              Text(
                ' / $total',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '($percentage %)',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultActions(
    String locale, {
    required bool canReview,
    required bool canRetry,
    required bool isPassed,
  }) {
    return Column(
      children: [
        if (isPassed) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.certificates,
                    arguments: {'initialTab': 1});
              },
              icon: const Icon(Iconsax.medal_star),
              label: Text('view_my_certificate'.tr(locale)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (canReview) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _reviewAnswers,
              icon: const Icon(Iconsax.document_text),
              label: Text('review_answers'.tr(locale)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (canRetry) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _retryQuiz,
              icon: const Icon(Iconsax.refresh),
              label: Text('retry'.tr(locale)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _backToCourse,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'back_to_course'.tr(locale),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(String locale) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => _showExitConfirmation(locale),
      ),
      title: Text(
        _quizData?.title ?? 'quiz'.tr(locale),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  void _showExitConfirmation(String locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('exit_quiz'.tr(locale)),
        content: Text('exit_quiz_confirmation'.tr(locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(locale)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'exit'.tr(locale),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Timer (if not review mode)
          if (!_isReview && _remainingTime != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.timer_1, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_remainingTime!),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progressValue,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _progressValue < 0.2 ? Colors.red : Colors.white,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
          ] else if (_isReview) ...[
            Text(
              'quiz_review'.tr(locale),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Question progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'question'.tr(locale)} ${_currentQuestionIndex + 1}/${_quizData?.questions?.length ?? 0}',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_quizData?.questions?[_currentQuestionIndex].grade ?? 0} ${'points'.tr(locale)}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) /
                  (_quizData?.questions?.length ?? 1),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(String locale) {
    if (_quizData?.questions == null || _quizData!.questions!.isEmpty) {
      return Center(
        child: Text('no_questions'.tr(locale)),
      );
    }

    final question = _quizData!.questions![_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question title
          Text(
            question.title ?? '',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Answer options
          if (question.type == 'descriptive')
            _buildDescriptiveAnswer(question, locale)
          else
            _buildMultipleChoiceAnswers(question, locale),
        ],
      ),
    );
  }

  Widget _buildDescriptiveAnswer(Question question, String locale) {
    // For review mode, show the user's answer
    String? userAnswer;
    if (_isReview && _reviewData?.answerSheet != null) {
      final answerKey = question.id.toString();
      userAnswer =
          _reviewData!.answerSheet!.items[answerKey]?.answer?.toString();
      if (userAnswer != null) {
        question.inputController.text = userAnswer;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: question.inputController,
          focusNode: question.focusNode,
          maxLines: 6,
          readOnly: _isReview,
          decoration: InputDecoration(
            hintText: 'type_your_answer'.tr(locale),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: _isReview ? Colors.grey.shade100 : Colors.white,
          ),
        ),
        if (_isReview && question.descriptiveCorrectAnswer != null) ...[
          const SizedBox(height: 16),
          Text(
            'correct_answer'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              question.descriptiveCorrectAnswer!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMultipleChoiceAnswers(Question question, String locale) {
    // For review mode, mark the user's answer
    int? userAnswerId;
    if (_isReview && _reviewData?.answerSheet != null) {
      final answerKey = question.id.toString();
      final userAnswer = _reviewData!.answerSheet!.items[answerKey]?.answer;
      if (userAnswer != null) {
        userAnswerId = int.tryParse(userAnswer.toString());
      }
    }

    return Column(
      children: List.generate(
        question.answers?.length ?? 0,
        (index) {
          final answer = question.answers![index];
          final isSelected =
              _isReview ? answer.id == userAnswerId : answer.isSelected;
          final isCorrect = answer.correct == 1;

          Color borderColor = AppColors.textSecondary.withOpacity(0.3);
          Color bgColor = Colors.white;

          if (_isReview) {
            if (isCorrect) {
              borderColor = Colors.green;
              bgColor = Colors.green.withOpacity(0.1);
            } else if (isSelected && !isCorrect) {
              borderColor = Colors.red;
              bgColor = Colors.red.withOpacity(0.1);
            }
          } else if (isSelected) {
            borderColor = AppColors.primary;
            bgColor = AppColors.primary.withOpacity(0.1);
          }

          return GestureDetector(
            onTap: _isReview
                ? null
                : () {
                    setState(() {
                      for (var a in question.answers!) {
                        a.isSelected = false;
                      }
                      answer.isSelected = true;
                    });
                  },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? borderColor : Colors.transparent,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: isSelected
                        ? Icon(
                            _isReview
                                ? (isCorrect ? Icons.check : Icons.close)
                                : Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      answer.title ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (_isReview && isCorrect)
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                ],
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: 100 * index))
              .fadeIn()
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildBottomNavigation(String locale) {
    final isLastQuestion =
        _currentQuestionIndex == (_quizData?.questions?.length ?? 1) - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: OutlinedButton(
              onPressed: _currentQuestionIndex > 0
                  ? () => setState(() => _currentQuestionIndex--)
                  : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'previous'.tr(locale),
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Next/Submit button
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (isLastQuestion) {
                        if (_isReview) {
                          Navigator.pop(context);
                        } else {
                          _submitQuiz();
                        }
                      } else {
                        setState(() => _currentQuestionIndex++);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastQuestion && !_isReview
                    ? Colors.green
                    : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isLastQuestion
                          ? (_isReview
                              ? 'close'.tr(locale)
                              : 'submit'.tr(locale))
                          : 'next'.tr(locale),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
