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

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(
    5, // Changed from 6 to 5
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  // Data received from registration page
  Map<String, dynamic>? _arguments;
  bool get _isPhoneMode =>
      _arguments?['method'] == 'phone' || _arguments?['phone'] != null;
  String get _contactInfo => _isPhoneMode
      ? '${_arguments?['countryCode'] ?? '+216'} ${_arguments?['phone'] ?? ''}'
      : _arguments?['email'] ?? '';

  @override
  void initState() {
    super.initState();
    // Get arguments after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _arguments = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    if (_code.length != 5) {
      // Changed from 6 to 5
      final locale = context.read<AppLanguageProvider>().currentLanguage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('complete_code_error'.tr(locale)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyCode(_code);

    if (success && mounted) {
      // Navigate to complete profile page (Step 3)
      Navigator.pushReplacementNamed(context, AppRoutes.completeProfile);
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
                        Iconsax.shield_tick,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                  const SizedBox(height: 30),

                  // Title
                  Center(
                    child: Text(
                      'verification'.tr(locale),
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
                        _isPhoneMode
                            ? 'verification_phone_desc'.tr(locale)
                            : 'verification_email_desc'.tr(locale),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                  const SizedBox(height: 20),

                  // Display contact info
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _contactInfo,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 250.ms),

                  const SizedBox(height: 40),

                  // Code Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      // Changed from 6 to 5
                      return SizedBox(
                        width: 50,
                        height: 60,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15),
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
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 4) {
                              // Changed from 5 to 4
                              _focusNodes[index + 1].requestFocus();
                            }
                            if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty && index < 4) {
                              // Changed from 5 to 4
                              _focusNodes[index + 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ).animate().fadeIn(duration: 500.ms, delay: 250.ms),

                  const SizedBox(height: 20),

                  // Code preview
                  Center(
                    child: Text(
                      'Code: ${_code.replaceAll(RegExp(r'.'), '•')}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        letterSpacing: 4,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: 20),

                  // Verify Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleVerify,
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
                                  'verify'.tr(locale),
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

                  // Resend Code
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Center(
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.primary)
                            : TextButton(
                                onPressed: () async {
                                  if (_arguments == null) return;

                                  bool success;
                                  if (_isPhoneMode) {
                                    success =
                                        await authProvider.registerWithPhone(
                                      _arguments!['countryCode']
                                              ?.replaceAll('+', '') ??
                                          '216',
                                      _arguments!['phone'],
                                      _arguments!['password'],
                                      _arguments!['retypePassword'],
                                      registerMethod:
                                          _arguments!['registerMethod'],
                                    );
                                  } else {
                                    success =
                                        await authProvider.registerWithEmail(
                                      _arguments!['email'],
                                      _arguments!['password'],
                                      _arguments!['retypePassword'],
                                      registerMethod:
                                          _arguments!['registerMethod'],
                                    );
                                  }

                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('code_resent'.tr(locale)),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    // Clear the code inputs
                                    for (var controller in _controllers) {
                                      controller.clear();
                                    }
                                  }
                                },
                                child: Text(
                                  'resend_code'.tr(locale),
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      );
                    },
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
