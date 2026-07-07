import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/models/support_model.dart';
import '../../../../core/services/support_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../providers/app_language_provider.dart';

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupportService _supportService = locator<SupportService>();
  final UserService _userService = locator<UserService>();

  bool _loadingTickets = true;
  bool _loadingCourse = true;
  List<SupportModel> _tickets = [];
  List<SupportModel> _courseSupport = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loadingTickets = true;
      _loadingCourse = true;
    });
    final tickets = await _supportService.getTickets();
    final course = await _supportService.getClassSupport();
    if (mounted) {
      setState(() {
        _tickets = tickets;
        _courseSupport = course;
        _loadingTickets = false;
        _loadingCourse = false;
      });
    }
  }

  String _formatDate(int? ts) {
    if (ts == null || ts == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _statusChip(String? status) {
    Color bg;
    String label;
    if (status == 'close' || status == 'closed') {
      bg = AppColors.grey300;
      label = 'support_status_closed'.tr(context.read<AppLanguageProvider>().currentLanguage);
    } else if (status == 'replied') {
      bg = AppColors.primary.withValues(alpha: 0.2);
      label = 'support_status_replied'.tr(context.read<AppLanguageProvider>().currentLanguage);
    } else {
      bg = AppColors.warning.withValues(alpha: 0.2);
      label = 'support_status_waiting'.tr(context.read<AppLanguageProvider>().currentLanguage);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTicketItem(SupportModel t, VoidCallback onTap) {
    final locale = context.read<AppLanguageProvider>().currentLanguage;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Iconsax.message_text_1, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title ?? (locale == 'ar' ? 'بدون عنوان' : 'Sans titre'),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(t.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      _statusChip(t.status),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 20, color: AppColors.grey400),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildEmpty(String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.message_question, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'support_no_tickets'.tr(locale),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'support_no_tickets_desc'.tr(locale),
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool loading, List<SupportModel> list, bool isTicketsTab) {
    final locale = context.read<AppLanguageProvider>().currentLanguage;
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (list.isEmpty) return _buildEmpty(locale);
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildTicketItem(list[i], () {
          Navigator.pushNamed(context, AppRoutes.supportConversation,
              arguments: list[i].id);
        }),
      ),
    );
  }

  Future<void> _openNewTicketSheet(bool isPlatform) async {
    final locale = context.read<AppLanguageProvider>().currentLanguage;
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NewTicketSheet(
        locale: locale,
        isPlatform: isPlatform,
        supportService: _supportService,
        userService: _userService,
      ),
    );
    if (success == true && mounted) _load();
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
          'support_messages'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'support_tickets'.tr(locale)),
            Tab(text: 'support_course'.tr(locale)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_loadingTickets, _tickets, true),
          _buildList(_loadingCourse, _courseSupport, false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNewTicketSheet(_tabController.index == 0),
        backgroundColor: AppColors.primary,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }
}

class _NewTicketSheet extends StatefulWidget {
  final String locale;
  final bool isPlatform;
  final SupportService supportService;
  final UserService userService;

  const _NewTicketSheet({
    required this.locale,
    required this.isPlatform,
    required this.supportService,
    required this.userService,
  });

  @override
  State<_NewTicketSheet> createState() => _NewTicketSheetState();
}

class _NewTicketSheetState extends State<_NewTicketSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int? _departmentId;
  int? _courseId;
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _purchases = [];
  bool _loadingDepts = true;
  bool _loadingCourses = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.isPlatform) {
      widget.supportService.getDepartments().then((list) {
        if (mounted) {
          setState(() {
            _departments = list;
            _loadingDepts = false;
            if (list.isNotEmpty && _departmentId == null) {
              _departmentId = list.first['id'] is int
                  ? list.first['id'] as int
                  : int.tryParse(list.first['id']?.toString() ?? '0');
            }
          });
        }
      });
    } else {
      widget.userService.getPurchasedCourses().then((list) {
        if (mounted) {
          setState(() {
            _purchases = list;
            _loadingCourses = false;
            if (list.isNotEmpty && _courseId == null) {
              final w = list.first['webinar'] ?? list.first;
              final id = list.first['webinar_id'] ?? w['id'];
              _courseId = id is int ? id : int.tryParse(id?.toString() ?? '0');
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.locale == 'ar' ? 'أدخل العنوان والوصف' : 'Veuillez remplir le titre et la description'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    if (widget.isPlatform && _departmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.locale == 'ar' ? 'اختر القسم' : 'Veuillez sélectionner un département'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    if (!widget.isPlatform && _courseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.locale == 'ar' ? 'اختر الدورة' : 'Veuillez sélectionner un cours'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    setState(() => _sending = true);
    final ok = await widget.supportService.createMessage(
      title,
      desc,
      departmentId: widget.isPlatform ? _departmentId : null,
      courseId: widget.isPlatform ? null : _courseId,
      file: null,
    );
    setState(() => _sending = false);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.locale == 'ar' ? 'تم إرسال التذكرة' : 'Ticket envoyé'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.locale == 'ar' ? 'خطأ في الإرسال' : 'Erreur lors de l\'envoi'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'support_new_ticket'.tr(locale),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'support_title'.tr(locale),
                        prefixIcon: const Icon(Iconsax.text, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.grey200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.isPlatform) ...[
                      if (_loadingDepts)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        )
                      else if (_departments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            locale == 'ar' ? 'لا توجد أقسام متاحة' : 'Aucun département disponible.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          value: _departmentId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'support_select_department'.tr(locale),
                            prefixIcon: const Icon(Iconsax.building_4, color: AppColors.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.grey200),
                            ),
                          ),
                          items: _departments.map((d) {
                            final id = d['id'] is int ? d['id'] as int : int.tryParse(d['id']?.toString() ?? '0');
                            final title = d['title']?.toString() ?? '';
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(title, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _departmentId = v),
                        ),
                      const SizedBox(height: 16),
                    ] else ...[
                      if (_loadingCourses)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        )
                      else if (_purchases.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'support_no_purchased_courses'.tr(locale),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'support_no_purchased_courses_desc'.tr(locale),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          value: _courseId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'support_select_course'.tr(locale),
                            prefixIcon: const Icon(Iconsax.book, color: AppColors.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.grey200),
                            ),
                          ),
                          items: _purchases.map((p) {
                            final w = p['webinar'] ?? p;
                            final id = p['webinar_id'] ?? w['id'];
                            final vid = id is int ? id : int.tryParse(id?.toString() ?? '0');
                            final title = w['title']?.toString() ?? (p['title']?.toString() ?? '');
                            return DropdownMenuItem<int>(
                              value: vid,
                              child: Text(title.isEmpty ? 'Cours #$vid' : title, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _courseId = v),
                        ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'support_description'.tr(locale),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.grey200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _sending ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _sending
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text('send'.tr(locale), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
