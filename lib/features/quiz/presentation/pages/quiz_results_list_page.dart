import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/quiz_model.dart';
import '../../../../core/services/quiz_service.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../providers/app_language_provider.dart';

/// Page "Quizz" du profil : liste des quiz passés avec résultats complets.
class QuizResultsListPage extends StatefulWidget {
  const QuizResultsListPage({super.key});

  @override
  State<QuizResultsListPage> createState() => _QuizResultsListPageState();
}

class _QuizResultsListPageState extends State<QuizResultsListPage> {
  final QuizService _quizService = locator<QuizService>();
  List<QuizResultModel> _results = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _quizService.getMyResults();
      setState(() {
        _results = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openResultDetail(QuizResultModel result) async {
    // Charger le détail complet si nécessaire (quiz_review pour la révision)
    QuizResultModel? full = result;
    if (result.reviewable == true && (result.quizReview == null || result.quizReview!.isEmpty)) {
      final detailed = await _quizService.reviewQuiz(result.id!);
      if (detailed != null) full = detailed;
    }
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.quizInfo,
      arguments: {
        'quiz': full.quiz,
        'quiz_result': full,
      },
    );
  }

  String _formatDate(int? timestamp, String locale) {
    if (timestamp == null) return '—';
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'my_quizzes'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.warning_2, size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          'error'.tr(locale),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: _loadResults,
                          icon: const Icon(Iconsax.refresh),
                          label: Text('retry'.tr(locale)),
                        ),
                      ],
                    ),
                  ),
                )
              : _results.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.document_text,
                              size: 64,
                              color: AppColors.grey300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'no_quiz_results'.tr(locale),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadResults,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final r = _results[index];
                          return _buildResultCard(r, locale, index);
                        },
                      ),
                    ),
    );
  }

  Widget _buildResultCard(QuizResultModel r, String locale, int index) {
    final title = r.quiz?.title ?? 'quiz'.tr(locale);
    final totalMark = r.quiz?.totalMark ?? 0;
    final userGrade = r.userGrade ?? 0;
    final passed = (r.status ?? '').toLowerCase() == 'passed';
    final dateStr = _formatDate(r.createdAt, locale);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: AppColors.white,
      child: InkWell(
        onTap: () => _openResultDetail(r),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: passed
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      passed
                          ? 'quiz_status_passed'.tr(locale)
                          : 'quiz_status_failed'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: passed ? AppColors.primary : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Iconsax.medal_star, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '$userGrade / ${totalMark > 0 ? totalMark : "?"} ${'points'.tr(locale)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Iconsax.calendar_1, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'view_result'.tr(locale),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0, delay: (50 * index).ms);
  }
}
