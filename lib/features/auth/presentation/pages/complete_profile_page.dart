import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/auth_message_utils.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _referralCodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.completeRegistration(
      _nameController.text.trim(),
      _referralCodeController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (route) => false,
      );
    } else if (mounted && authProvider.errorMessage != null) {
      final locale = context.read<AppLanguageProvider>().currentLanguage;
      final key = AuthMessageUtils.normalizeToKey(authProvider.errorMessage, null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(key.tr(locale)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: const Icon(
                        Iconsax.arrow_left,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 40),

                  // Icon
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.user_edit,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                  const SizedBox(height: 30),

                  // Title
                  Center(
                    child: Text(
                      'complete_profile'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'complete_profile_desc'.tr(locale),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                  const SizedBox(height: 40),

                  // Full Name Field
                  _buildTextField(
                    controller: _nameController,
                    label: 'full_name'.tr(locale),
                    hint: 'enter_full_name'.tr(locale),
                    icon: Iconsax.user,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'required_field'.tr(locale);
                      }
                      if (value.length < 2) {
                        return locale == 'ar'
                            ? 'الاسم قصير جداً'
                            : 'Nom trop court';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 250.ms),

                  const SizedBox(height: 20),

                  // Referral Code Field (optional)
                  _buildTextField(
                    controller: _referralCodeController,
                    label: 'referral_code'.tr(locale),
                    hint: 'enter_referral_code'.tr(locale),
                    icon: Iconsax.ticket_discount,
                    isOptional: true,
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: 40),

                  // Complete Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleComplete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: authProvider.isLoading
                              ? const CircularProgressIndicator(
                                  color: AppColors.white)
                              : Text(
                                  'complete'.tr(locale),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 350.ms),

                  const SizedBox(height: 20),

                  // Skip for now (optional)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Allow skip with empty referral code but require name
                        if (_nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('name_required'.tr(locale)),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        _handleComplete();
                      },
                      child: Text(
                        'skip_referral'.tr(locale),
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 8),
              Text(
                '(${context.read<AppLanguageProvider>().currentLanguage == 'ar' ? 'اختياري' : 'Optionnel'})',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: GoogleFonts.poppins(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }
}
