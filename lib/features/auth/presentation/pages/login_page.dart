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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isPhoneMode = true; // Default to phone mode for Tunisia
  CountryCode _selectedCountry = CountryCode.defaultCountry;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    String identifier;
    if (_isPhoneMode) {
      // Remove the + from dial code and prepend to phone number
      final dialCode = _selectedCountry.dialCode?.replaceAll('+', '') ?? '216';
      identifier = '$dialCode${_phoneController.text.trim()}';
    } else {
      identifier = _emailController.text.trim();
    }

    final success = await authProvider.login(
      identifier,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (route) => false,
      );
    } else if (mounted && authProvider.errorMessage != null) {
      final key = AuthMessageUtils.normalizeToKey(authProvider.errorMessage, null);
      final locale = context.read<AppLanguageProvider>().currentLanguage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(key.tr(locale)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showCountryPicker() async {
    final result = await showDialog<CountryCode>(
      context: context,
      builder: (context) => const CountryPickerDialog(),
    );

    if (result != null) {
      setState(() {
        _selectedCountry = result;
      });
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
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 30),

                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppColors.cardShadow,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/edandroid.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms).scale(
                      begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

                  const SizedBox(height: 30),

                  // Title
                  Center(
                    child: Text(
                      'login'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                  Center(
                    child: Text(
                      'welcome_back_desc'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                  const SizedBox(height: 30),

                  // Login Method Toggle
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

                  const SizedBox(height: 25),

                  // Phone or Email Field
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
                        // Country Code Picker
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
                        // Phone Number Input
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                            ),
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
                                    color: AppColors.primary, width: 2),
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
                                return 'invalid_phone'.tr(locale);
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _buildTextField(
                      controller: _emailController,
                      label: 'email'.tr(locale),
                      hint: 'enter_email'.tr(locale),
                      icon: Iconsax.sms,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'required_field'.tr(locale);
                        }
                        if (!value.contains('@')) {
                          return 'invalid_email'.tr(locale);
                        }
                        return null;
                      },
                      locale: locale,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    label: 'password'.tr(locale),
                    hint: 'enter_password'.tr(locale),
                    icon: Iconsax.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'required_field'.tr(locale);
                      }
                      return null;
                    },
                    locale: locale,
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 250.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 15),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.forgotPassword);
                      },
                      child: Text(
                        'forgot_password'.tr(locale),
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: 25),

                  // Login Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleLogin,
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
                                  'login'.tr(locale),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 350.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 40),

                  // Register Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'no_account'.tr(locale),
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: Text(
                            'signup'.tr(locale),
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
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
    required String locale,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
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
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textSecondary,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: suffixIcon,
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
