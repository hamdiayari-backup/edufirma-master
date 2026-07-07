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
import '../../../../core/models/country_code.dart';
import '../../../../core/utils/auth_message_utils.dart';
import '../widgets/country_picker_dialog.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPhoneMode = false;
  CountryCode _selectedCountry = CountryCode.defaultCountry;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _showCountryPicker() async {
    final result = await showDialog<CountryCode>(
      context: context,
      builder: (context) => const CountryPickerDialog(),
    );
    if (result != null) {
      setState(() => _selectedCountry = result);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final locale = context.read<AppLanguageProvider>().currentLanguage;

    bool success;
    String? dialCode;
    final phone = _phoneController.text.trim();

    if (_isPhoneMode) {
      dialCode =
          '+${(_selectedCountry.dialCode ?? '+216').replaceAll(RegExp(r'[^0-9]'), '')}';
      success = await authProvider.forgotPassword(dialCode, phone);
    } else {
      success = await authProvider.forgotPassword(
        null,
        _emailController.text.trim(),
      );
    }

    if (success && mounted) {
      final msg = _isPhoneMode
          ? 'code_sent_check_sms'.tr(locale)
          : 'code_sent_check_email'.tr(locale);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green),
      );
      if (_isPhoneMode && dialCode != null) {
        Navigator.pushNamed(context, AppRoutes.resetPassword, arguments: {
          'phone': phone,
          'countryCode': dialCode,
        });
      } else {
        Navigator.pop(context);
      }
    } else if (mounted && authProvider.errorMessage != null) {
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
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.lock,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      'forgot_password'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _isPhoneMode
                            ? 'forgot_password_subtitle_phone'.tr(locale)
                            : 'forgot_password_subtitle_email'.tr(locale),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                  const SizedBox(height: 24),
                  // Toggle Phone | Email
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isPhoneMode = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _isPhoneMode
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.call,
                                    size: 18,
                                    color: _isPhoneMode
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'phone'.tr(locale),
                                    style: GoogleFonts.poppins(
                                      color: _isPhoneMode
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isPhoneMode = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: !_isPhoneMode
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.sms,
                                    size: 18,
                                    color: !_isPhoneMode
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'email'.tr(locale),
                                    style: GoogleFonts.poppins(
                                      color: !_isPhoneMode
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 180.ms),
                  const SizedBox(height: 24),
                  if (_isPhoneMode) ...[
                    Text(
                      'phone_number'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _showCountryPicker,
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.grey200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedCountry.flag ?? '🇹🇳',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedCountry.dialCode ?? '+216',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Iconsax.arrow_down_1,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.poppins(
                                color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'enter_phone'.tr(locale),
                              hintStyle: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    BorderSide(color: AppColors.grey200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'required_field'.tr(locale);
                              }
                              if (value.length < 8) {
                                return locale == 'ar'
                                    ? 'رقم الهاتف غير صالح'
                                    : 'Numéro invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'email'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.poppins(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'enter_email'.tr(locale),
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(
                          Iconsax.sms,
                          color: AppColors.primary,
                        ),
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
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'required_field'.tr(locale);
                        }
                        if (!value.contains('@')) {
                          return locale == 'ar'
                              ? 'البريد الإلكتروني غير صالح'
                              : 'Email invalide';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 40),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleSubmit,
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
                                  color: Colors.white)
                              : Text(
                                  'send_code'.tr(locale),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                  const SizedBox(height: 30),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'back_to_login'.tr(locale),
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 350.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
