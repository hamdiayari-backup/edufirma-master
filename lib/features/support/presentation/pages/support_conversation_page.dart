import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/models/support_model.dart';
import '../../../../core/models/support_conversation_model.dart';
import '../../../../core/services/support_service.dart';
import '../../../../providers/app_language_provider.dart';

class SupportConversationPage extends StatefulWidget {
  const SupportConversationPage({super.key});

  @override
  State<SupportConversationPage> createState() => _SupportConversationPageState();
}

class _SupportConversationPageState extends State<SupportConversationPage> {
  final SupportService _supportService = locator<SupportService>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  int? _ticketId;
  SupportModel? _ticket;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _ticketId = args;
        _load();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_ticketId == null) return;
    setState(() => _loading = true);
    final t = await _supportService.getOne(_ticketId!);
    if (mounted) {
      setState(() {
        _ticket = t;
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatDate(int? ts) {
    if (ts == null || ts == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _ticketId == null) return;
    setState(() => _sending = true);
    final ok = await _supportService.sendMessage(text, _ticketId!);
    if (mounted) {
      setState(() => _sending = false);
      if (ok) {
        _messageController.clear();
        _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<AppLanguageProvider>().currentLanguage == 'ar'
                  ? 'خطأ في الإرسال'
                  : 'Erreur lors de l\'envoi',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
          _ticket?.title ?? 'support_messages'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _ticket == null
              ? Center(
                  child: Text(
                    'support_ticket_not_found'.tr(locale),
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_ticket!.webinar != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.grey200),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Iconsax.video_play, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'support_course_context'.tr(locale),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _ticket!.webinar!['title']?.toString() ?? '',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            ...List.generate(
                              _ticket!.conversations?.length ?? 0,
                              (i) => _buildMessage(_ticket!.conversations![i], locale),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'support_message_hint'.tr(locale),
                                hintStyle: GoogleFonts.poppins(color: AppColors.grey400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.grey200),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _sending ? null : _sendMessage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _sending
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Iconsax.send_1, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildMessage(SupportConversationModel msg, String locale) {
    final isUser = msg.sender != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.message_text_1, color: AppColors.primary, size: 18),
            ),
          if (!isUser) const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.grey200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.message ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isUser ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (msg.filePath != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        // Optional: open file / download
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.document,
                            size: 16,
                            color: isUser ? Colors.white70 : AppColors.grey600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            msg.fileTitle ?? 'Pièce jointe',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isUser ? Colors.white70 : AppColors.grey600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(msg.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isUser ? Colors.white70 : AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
          if (isUser)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.user, color: AppColors.primary, size: 18),
            ),
        ],
      ),
    );
  }
}
