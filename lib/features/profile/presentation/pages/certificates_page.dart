import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../providers/certificate_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCertificates();
      _applyInitialTab();
    });
  }

  void _applyInitialTab() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final initialTab = args['initialTab'] as int?;
      if (initialTab != null &&
          initialTab >= 0 &&
          initialTab < (_tabController?.length ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tabController?.animateTo(initialTab);
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates() async {
    await context.read<CertificateProvider>().fetchCertificates();
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
          'certificates'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: _tabController == null
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: locale == 'ar' ? 'الدورات' : 'Cours'),
                  Tab(text: locale == 'ar' ? 'الاختبارات' : 'Quiz'),
                  Tab(text: locale == 'ar' ? 'الباقات' : 'Pack'),
                ],
              ),
      ),
      body: Consumer<CertificateProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Toujours afficher le TabBarView pour que la navigation Cours/Quiz/Pack fonctionne.
          // Chaque onglet affiche sa liste ou son message vide.
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCertificatesList(provider.courseCertificates, false, false, locale),
              _buildCertificatesList(provider.quizCertificates, true, false, locale),
              _buildCertificatesList(provider.bundleCertificates, false, true, locale),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.medal_star,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              locale == 'ar' ? 'لا توجد شهادات بعد' : 'Aucun certificat pour le moment',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              locale == 'ar'
                  ? 'أكمل الدورات والاختبارات للحصول على الشهادات'
                  : 'Complétez des cours et quiz pour obtenir des certificats',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesList(
      List<Map<String, dynamic>> certificates, bool isQuiz, bool isBundle, String locale) {
    if (certificates.isEmpty) {
      String emptyMsg;
      if (isBundle) {
        emptyMsg = locale == 'ar' ? 'لا يوجد شهادة pack' : 'Aucun certificat de pack';
      } else if (isQuiz) {
        emptyMsg = locale == 'ar' ? 'لا توجد شهادات اختبارات' : 'Aucun certificat de quiz';
      } else {
        emptyMsg = locale == 'ar' ? 'لا توجد شهادات دورات' : 'Aucun certificat de cours';
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBundle ? Iconsax.box : (isQuiz ? Iconsax.document_text : Iconsax.book),
                size: 60,
                color: AppColors.grey300,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMsg,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCertificates,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          final certificate = certificates[index];
          return _buildCertificateCard(certificate, isQuiz, isBundle, locale, index);
        },
      ),
    );
  }

  Widget _buildCertificateCard(
      Map<String, dynamic> certificate, bool isQuiz, bool isBundle, String locale, int index) {
    final certificateId = certificate['id'];
    final createdAt = certificate['created_at'];
    final date = createdAt != null
        ? (createdAt is int
            ? DateTime.fromMillisecondsSinceEpoch(createdAt * 1000)
            : DateTime.tryParse(createdAt.toString()) ?? DateTime.now())
        : DateTime.now();

    String title = '';
    if (isBundle) {
      final bundle = certificate['bundle'];
      title = (bundle is Map ? bundle['title'] : null) ??
          (locale == 'ar' ? 'شهادة pack' : 'Certificat de pack');
    } else if (isQuiz) {
      title = certificate['quiz']?['title'] ?? (locale == 'ar' ? 'شهادة اختبار' : 'Certificat de quiz');
    } else {
      title = certificate['webinar']?['title'] ?? (locale == 'ar' ? 'شهادة دورة' : 'Certificat de cours');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _downloadCertificate(certificateId, isQuiz, isBundle, locale),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Certificate Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isBundle ? Iconsax.box : (isQuiz ? Iconsax.document_text : Iconsax.award),
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Certificate Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Iconsax.calendar,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Download Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Iconsax.document_download,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
  }

  Future<void> _downloadCertificate(
      int certificateId, bool isQuiz, bool isBundle, String locale) async {
    if (!mounted) return;
    final provider = context.read<CertificateProvider>();
    final isAr = locale == 'ar';

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr ? 'جاري التحميل...' : 'Téléchargement en cours...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final bytes = await provider.downloadCertificateBytes(certificateId,
          isQuiz: isQuiz, isBundle: isBundle);

      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr
                ? 'تعذر تحميل الشهادة'
                : 'Impossible de télécharger le certificat'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final dir = await getTemporaryDirectory();
      final ext = 'pdf';
      final file = File('${dir.path}/certificate_$certificateId.$ext');
      await file.writeAsBytes(bytes);

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr
                ? 'تم التحميل: ${file.path}'
                : 'Téléchargé: ${file.path}'),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr ? 'تم فتح الشهادة' : 'Certificat ouvert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr
                ? 'حدث خطأ أثناء تحميل الشهادة'
                : 'Erreur lors du téléchargement du certificat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
