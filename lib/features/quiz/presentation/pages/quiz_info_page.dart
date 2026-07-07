import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/quiz_model.dart';
import '../../../../core/services/quiz_service.dart';
import '../../../../core/localization/app_translations.dart';

class QuizInfoPage extends StatefulWidget {
  const QuizInfoPage({super.key});

  @override
  State<QuizInfoPage> createState() => _QuizInfoPageState();
}

class _QuizInfoPageState extends State<QuizInfoPage> {
  final QuizService _quizService = locator<QuizService>();
  late ConfettiController _confettiController;

  Quiz? _quizData;
  QuizResultModel? _quizResult;
  int? _userGrade;
  String _status = '';
  bool _isLoading = false;
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuizInfo();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _initializeQuizInfo() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      if (args['quiz'] != null) {
        _quizData = args['quiz'] as Quiz;
        // From content API: use latest_result or best_grade for display
        final latest = _quizData?.latestResult;
        if (latest != null) {
          final m = latest;
          if (m['user_grade'] != null || m['status'] != null) {
            _userGrade = m['user_grade'] is int ? m['user_grade'] as int : int.tryParse(m['user_grade']?.toString() ?? '');
            _status = m['status']?.toString() ?? '';
            _hasResult = true;
          }
        }
        if (!_hasResult && _quizData?.bestGrade != null) {
          _userGrade = _quizData!.bestGrade;
          _hasResult = true;
        }
      }
      if (args['quiz_result'] != null) {
        _quizResult = args['quiz_result'] as QuizResultModel;
        _quizData = _quizResult?.quiz ?? _quizData;
        _userGrade = _quizResult?.userGrade ?? _userGrade;
        _status = _quizResult?.status ?? _status;
        _hasResult = true;
      }
      if (args['status'] != null) {
        _status = args['status'];
      }
      if (args['user_grade'] != null) {
        _userGrade = args['user_grade'] is int ? args['user_grade'] as int : int.tryParse(args['user_grade']?.toString() ?? '');
        _hasResult = true;
      }

      setState(() {});

      // Play confetti if passed
      if (_status == 'passed') {
        Future.delayed(const Duration(milliseconds: 500), () {
          _confettiController.play();
        });
      }
    }
  }

  Future<void> _startQuiz() async {
    if (_quizData?.id == null) return;

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.quiz,
      arguments: {
        'quiz_id': _quizData!.id,
        'is_review': false,
      },
    );

    if (result == true) {
      // Quiz completed, go back to course
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _reviewQuiz() async {
    if (_quizResult == null) return;

    Navigator.pushNamed(
      context,
      AppRoutes.quiz,
      arguments: {
        'quiz_id': _quizData?.id,
        'is_review': true,
        'quiz_result': _quizResult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'quiz_info'.tr(locale),
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuizTitle(locale),
                      const SizedBox(height: 30),
                      if (_hasResult)
                        _buildResultCard(locale)
                      else
                        _buildStartCard(locale),
                      const SizedBox(height: 24),
                      _buildInfoGrid(locale),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                _buildActionButton(locale),
                // Confetti
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    gravity: 0.2,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple,
                      Colors.yellow,
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuizTitle(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _quizData?.title ?? '',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn().slideX(begin: -0.1, end: 0),
      ],
    );
  }

  Widget _buildStartCard(String locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Iconsax.document_text, size: 60, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'ready_to_start'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_quizData?.questionCount ?? 0} ${'questions'.tr(locale)} • ${_quizData?.time ?? 0} ${'minutes'.tr(locale)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn()
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildResultCard(String locale) {
    final isPassed = _status == 'passed';
    final isWaiting = _status == 'waiting';
    final isFailed = _status == 'failed';

    Color statusColor = Colors.orange;
    IconData statusIcon = Iconsax.timer_1;
    String statusText = 'waiting'.tr(locale);

    if (isPassed) {
      statusColor = Colors.green;
      statusIcon = Iconsax.tick_circle;
      statusText = 'passed'.tr(locale);
    } else if (isFailed) {
      statusColor = Colors.red;
      statusIcon = Iconsax.close_circle;
      statusText = 'failed'.tr(locale);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // Grade circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 8),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _userGrade?.toString() ?? '-',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'your_grade'.tr(locale),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 500.ms),

          const SizedBox(height: 20),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Message
          Text(
            isPassed
                ? 'congratulations_passed'.tr(locale)
                : isFailed
                    ? 'try_again_message'.tr(locale)
                    : 'waiting_for_review'.tr(locale),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  String _formatMark(int? value, String locale) {
    if (value == null) return '-';
    return '${value.toString()} ${'points'.tr(locale)}';
  }

  Widget _buildInfoGrid(String locale) {
    final totalMark = _quizData?.totalMark;
    final passMark = _quizData?.passMark;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildInfoItem(
          icon: Iconsax.star,
          label: 'total_mark'.tr(locale),
          value: totalMark != null ? _formatMark(totalMark, locale) : '-',
          color: Colors.amber,
        ),
        _buildInfoItem(
          icon: Iconsax.tick_square,
          label: 'pass_mark'.tr(locale),
          value: passMark != null ? _formatMark(passMark, locale) : '-',
          color: Colors.green,
        ),
        _buildInfoItem(
          icon: Iconsax.message_question,
          label: 'questions'.tr(locale),
          value: _quizData?.questionCount?.toString() ?? '-',
          color: Colors.blue,
        ),
        _buildInfoItem(
          icon: Iconsax.timer_1,
          label: 'time'.tr(locale),
          value: '${_quizData?.time ?? 0} min',
          color: Colors.purple,
        ),
        if (_quizData?.attempt != null)
          _buildInfoItem(
            icon: Iconsax.repeat,
            label: 'attempts'.tr(locale),
            value: _quizData!.attempt.toString(),
            color: Colors.orange,
          ),
        if (_quizData?.authAttemptCount != null)
          _buildInfoItem(
            icon: Iconsax.user_tick,
            label: locale == 'ar' ? 'محاولاتك' : 'Vos tentatives',
            value: _quizData!.authAttemptCount.toString(),
            color: Colors.indigo,
          ),
        if (_quizData?.bestGrade != null)
          _buildInfoItem(
            icon: Iconsax.medal_star,
            label: locale == 'ar' ? 'أفضل درجة' : 'Meilleure note',
            value: _formatMark(_quizData!.bestGrade, locale),
            color: Colors.amber,
          ),
        if (_quizData?.certificate == true)
          _buildInfoItem(
            icon: Iconsax.award,
            label: locale == 'ar' ? 'شهادة' : 'Certificat',
            value: locale == 'ar' ? 'نعم' : 'Oui',
            color: Colors.teal,
          ),
        if (_hasResult && _quizResult?.countTryAgain != null)
          _buildInfoItem(
            icon: Iconsax.refresh,
            label: 'tries_left'.tr(locale),
            value: _quizResult!.countTryAgain.toString(),
            color: Colors.teal,
          ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionButton(String locale) {
    final noAttemptsLeft = _quizData?.authCanStart == false ||
        (_hasResult && _quizResult?.authCanTryAgain != true);
    final canStart = !noAttemptsLeft;
    final canReview = _hasResult && _status == 'passed';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (noAttemptsLeft) ...[
              Text(
                'no_attempts_left_message'.tr(locale),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                if (canReview) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reviewQuiz,
                      icon: const Icon(Iconsax.eye),
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
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: canReview ? 1 : 2,
                  child: ElevatedButton.icon(
                    onPressed: canStart ? _startQuiz : null,
                    icon: Icon(_hasResult ? Iconsax.refresh : Iconsax.play),
                    label: Text(
                      canStart
                          ? (_hasResult
                              ? 'retry'.tr(locale)
                              : 'start_quiz'.tr(locale))
                          : 'no_attempts_left'.tr(locale),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
