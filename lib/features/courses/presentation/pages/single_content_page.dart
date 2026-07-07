import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/course_service.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../widgets/fullscreen_video_player.dart';

class SingleContentPage extends StatefulWidget {
  const SingleContentPage({super.key});

  @override
  State<SingleContentPage> createState() => _SingleContentPageState();
}

class _SingleContentPageState extends State<SingleContentPage> {
  Map<String, dynamic>? _contentItem;
  Map<String, dynamic>? _contentDetails;
  int? _courseId;
  bool _isLoading = true;
  String? _errorMessage;
  bool _authHasRead = false;

  // Video formats supported
  final List<String> _videoFormats = [
    'mp4',
    'mkv',
    'mov',
    'wmv',
    'avi',
    'webm',
    'video'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_contentItem == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _contentItem = args['item'];
        _courseId = args['courseId'];
        _authHasRead = _contentItem?['auth_has_read'] == true;
        _loadContent();
      }
    }
  }

  Future<void> _loadContent() async {
    if (_contentItem == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courseService = locator<CourseService>();
      final link = _contentItem!['link'] ?? '';

      if (link.isNotEmpty) {
        _contentDetails = await courseService.getSingleContent(link);
      }

      if (_contentDetails == null) {
        _errorMessage = 'Impossible de charger le contenu';
      }
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      debugPrint('Error loading content: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _getFileUrl() {
    final file = _contentDetails?['file'] ?? '';
    if (file.isEmpty) return '';

    // Add base URL if needed
    if (!file.startsWith('http')) {
      return 'https://edufirma.com$file';
    }
    return file;
  }

  bool _isVideoContent() {
    final fileType =
        _contentDetails?['file_type']?.toString().toLowerCase() ?? '';
    final storage = _contentDetails?['storage'] ?? '';

    return _videoFormats.contains(fileType) ||
        storage == 'youtube' ||
        storage == 'vimeo' ||
        (storage == 'upload' && _videoFormats.contains(fileType)) ||
        (storage == 's3' && _videoFormats.contains(fileType)) ||
        (storage == 'external_link' && _videoFormats.contains(fileType));
  }

  Future<void> _toggleReadStatus(bool value) async {
    if (_courseId == null || _contentDetails == null) return;

    final courseService = locator<CourseService>();
    final type = _contentItem?['type'] ?? '';

    // Legacy uses 'text_lesson_id', 'file_id', 'session_id' as item names
    String itemName;
    switch (type) {
      case 'text_lesson':
        itemName = 'text_lesson_id';
        break;
      case 'file':
        itemName = 'file_id';
        break;
      case 'session':
        itemName = 'session_id';
        break;
      case 'assignment':
        itemName = 'assignment_id';
        break;
      case 'quiz':
        itemName = 'quiz_id';
        break;
      default:
        itemName = '${type}_id';
    }

    final success = await courseService.toggleContentRead(
      _courseId!,
      itemName,
      _contentDetails!['id'].toString(),
      value,
    );

    if (success) {
      setState(() {
        _authHasRead = value;
      });
    }
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
          'content'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
              ? _buildErrorState(locale)
              : _buildContent(locale),
    );
  }

  Widget _buildErrorState(String locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 60, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'error'.tr(locale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadContent,
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr(locale)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String locale) {
    final title = _contentDetails?['title'] ?? _contentItem?['title'] ?? '';
    final description = _contentDetails?['description'] ?? '';
    final content = _contentDetails?['content'] ?? ''; // For text lessons
    final storage = _contentDetails?['storage'] ?? '';
    final fileType = _contentDetails?['file_type'] ?? '';
    final volume = _contentDetails?['volume'] ?? '';
    final duration = _contentDetails?['duration'] ?? 0;
    final type = _contentItem?['type'] ?? 'file';

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 16),

              // Video Player (if video content)
              if (_isVideoContent()) ...[
                _buildVideoSection(locale),
                const SizedBox(height: 20),
              ],

              // Content Info
              _buildInfoCards(
                  locale, type, fileType, volume, duration, storage),

              const SizedBox(height: 20),

              // Description or Content
              if (type == 'text_lesson' && content.isNotEmpty) ...[
                Text(
                  locale == 'ar' ? 'المحتوى' : 'Contenu',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Text(
                    _cleanHtml(content),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.8,
                    ),
                  ),
                ),
              ] else if (description.isNotEmpty) ...[
                Text(
                  'description'.tr(locale),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _cleanHtml(description),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Mark as read toggle
              _buildReadToggle(locale),

              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),

        // Bottom action button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomButton(locale),
        ),
      ],
    );
  }

  Widget _buildVideoSection(String locale) {
    final fileUrl = _getFileUrl();
    final storage = _contentDetails?['storage'] ?? '';
    final title = _contentDetails?['title'] ?? '';

    // For YouTube or Vimeo, we need to handle differently
    if (storage == 'youtube' || storage == 'vimeo') {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                storage == 'youtube'
                    ? Icons.play_circle_fill
                    : Iconsax.video_play,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _openExternalVideo(fileUrl),
                icon: const Icon(Icons.open_in_new),
                label: Text(
                  storage == 'youtube'
                      ? 'Ouvrir sur YouTube'
                      : 'Ouvrir sur Vimeo',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: storage == 'youtube'
                      ? Colors.red
                      : const Color(0xFF1AB7EA),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    // For regular video files
    if (fileUrl.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullscreenVideoPlayer(
                videoUrl: fileUrl,
                title: title,
              ),
            ),
          );
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    locale == 'ar' ? 'تشغيل الفيديو' : 'Lire la vidéo',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
          );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoCards(
    String locale,
    String type,
    String fileType,
    String volume,
    int duration,
    String storage,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildInfoCard(
          icon: Iconsax.document,
          label: locale == 'ar' ? 'النوع' : 'Type',
          value: type == 'text_lesson'
              ? (locale == 'ar' ? 'درس نصي' : 'Leçon texte')
              : type == 'session'
                  ? (locale == 'ar' ? 'جلسة' : 'Session')
                  : fileType.toUpperCase(),
        ),
        if (volume.isNotEmpty)
          _buildInfoCard(
            icon: Iconsax.document_download,
            label: locale == 'ar' ? 'الحجم' : 'Taille',
            value: volume,
          ),
        if (duration > 0)
          _buildInfoCard(
            icon: Iconsax.clock,
            label: 'duration'.tr(locale),
            value: '$duration min',
          ),
        if (storage.isNotEmpty)
          _buildInfoCard(
            icon: Iconsax.cloud,
            label: locale == 'ar' ? 'التخزين' : 'Stockage',
            value: storage.replaceAll('_', ' ').toUpperCase(),
          ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadToggle(String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Icon(
            _authHasRead ? Iconsax.tick_circle5 : Iconsax.tick_circle,
            color: _authHasRead ? AppColors.success : AppColors.grey400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              locale == 'ar' ? 'لقد قرأت هذا الدرس' : 'J\'ai lu cette leçon',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: _authHasRead,
            onChanged: _toggleReadStatus,
            activeColor: AppColors.success,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildBottomButton(String locale) {
    final type = _contentItem?['type'] ?? 'file';
    final downloadable = _contentItem?['downloadable'] == 1;
    final fileUrl = _getFileUrl();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (downloadable && fileUrl.isNotEmpty) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadFile(fileUrl),
                  icon: const Icon(Iconsax.document_download),
                  label: Text(
                    locale == 'ar' ? 'تحميل' : 'Télécharger',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
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
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _viewContent(),
                icon:
                    Icon(_isVideoContent() ? Iconsax.video_play : Iconsax.eye),
                label: Text(
                  _isVideoContent()
                      ? (locale == 'ar' ? 'مشاهدة' : 'Regarder')
                      : (locale == 'ar' ? 'عرض' : 'Voir'),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isVideoContent()
                      ? AppColors.success
                      : AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewContent() {
    final fileUrl = _getFileUrl();
    final storage = _contentDetails?['storage'] ?? '';
    final title = _contentDetails?['title'] ?? '';

    if (_isVideoContent()) {
      if (storage == 'youtube' || storage == 'vimeo') {
        _openExternalVideo(fileUrl);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullscreenVideoPlayer(
              videoUrl: fileUrl,
              title: title,
            ),
          ),
        );
      }
    } else {
      // For non-video content, open in browser
      _openExternalVideo(fileUrl);
    }
  }

  Future<void> _openExternalVideo(String url) async {
    if (url.isEmpty) return;

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening URL: $e');
    }
  }

  Future<void> _downloadFile(String url) async {
    // For now, just open in browser for download
    await _openExternalVideo(url);
  }

  String _cleanHtml(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }
}
