import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _codeControllers =
      List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes = List.generate(5, (_) => FocusNode());
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Map<String, dynamic>? _args;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var n in _codeFocusNodes) {
      n.dispose();
    }
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String get _code => _codeControllers.map((c) => c.text).join();

  Future<void> _handleSubmit() async {
    final locale = context.read<AppLanguageProvider>().currentLanguage;
    if (_code.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('complete_code_error'.tr(locale)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final phone = _args?['phone']?.toString() ?? '';
    final countryCode = _args?['countryCode']?.toString() ?? '+216';

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPasswordByMobile(
      countryCode,
      phone,
      _code,
      _passwordController.text,
      _confirmController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('reset_password_success'.tr(locale)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (r) => false,
      );
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
    if (_args == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

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
                  const SizedBox(height: 32),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.lock_1,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'reset_password'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
                  const SizedBox(height: 8),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'reset_password_subtitle'.tr(locale),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                  const SizedBox(height: 28),
                  Text(
                    'verify_code'.tr(locale),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (i) {
                      return SizedBox(
                        width: 50,
                        height: 56,
                        child: TextField(
                          controller: _codeControllers[i],
                          focusNode: _codeFocusNodes[i],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          maxLength: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.grey300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.grey300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (v) {
                            if (v.isNotEmpty && i < 4) {
                              _codeFocusNodes[i + 1].requestFocus();
                            }
                            if (v.isEmpty && i > 0) {
                              _codeFocusNodes[i - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ).animate().fadeIn(duration: 500.ms, delay: 250.ms),
                  const SizedBox(height: 24),
                  _buildPasswordField(
                    locale: locale,
                    label: 'create_password'.tr(locale),
                    hint: 'create_password'.tr(locale),
                    controller: _passwordController,
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'required_field'.tr(locale);
                      }
                      if (v.length < 6) {
                        return locale == 'ar'
                            ? '6 أحرف على الأقل'
                            : 'Au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    locale: locale,
                    label: 'confirm_password'.tr(locale),
                    hint: 'confirm_password_hint'.tr(locale),
                    controller: _confirmController,
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'required_field'.tr(locale);
                      }
                      if (v != _passwordController.text) {
                        return locale == 'ar'
                            ? 'كلمات المرور غير متطابقة'
                            : 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: auth.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'reset_password'.tr(locale),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String locale,
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.poppins(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Iconsax.eye_slash : Iconsax.eye,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: onToggle,
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
              horizontal: 16,
              vertical: 18,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
