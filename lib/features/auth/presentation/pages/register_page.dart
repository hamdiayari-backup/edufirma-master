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
import '../../../../core/models/register_config_model.dart';
import '../../../../core/services/guest_service.dart';
import '../../../../core/di/service_locator.dart';
import '../widgets/country_picker_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isPhoneMode = true; // Default to phone mode for Tunisia
  CountryCode _selectedCountry = CountryCode.defaultCountry;

  // Account type selection
  String _accountType = 'user'; // user, teacher, organization
  bool _isLoadingConfig = false;
  RegisterConfigModel? _registerConfig;
  List<String> _availableRoles = ['user']; // Roles available from API

  /// True when backend allows both email and mobile (register_method "both" / "email_or_mobile" or showOtherRegisterMethod).
  bool get _showMethodToggle {
    final rm = _registerConfig?.registerMethod?.toString().toLowerCase();
    if (rm == 'both' || rm == 'email_or_mobile') return true;
    return _registerConfig?.showOtherRegisterMethodBool == true;
  }

  @override
  void initState() {
    super.initState();
    _loadRegisterConfig();
  }

  Future<void> _loadRegisterConfig() async {
    setState(() => _isLoadingConfig = true);

    try {
      final guestService = locator<GuestService>();
      final configData = await guestService.getRegisterConfig(_accountType);

      if (configData != null) {
        _registerConfig = RegisterConfigModel.fromJson(configData);

        // Update available roles
        if (_registerConfig!.selectRolesDuringRegistration.isNotEmpty) {
          _availableRoles = [
            'user',
            ..._registerConfig!.selectRolesDuringRegistration
          ];
        }

        // Default mode from config: email-only → email; mobile/both → phone.
        final rm = _registerConfig?.registerMethod?.toString().toLowerCase();
        if (rm == 'email' || rm == 'mail') {
          _isPhoneMode = false;
        }
      }
    } catch (e) {
      debugPrint('Error loading register config: $e');
    }

    if (mounted) {
      setState(() => _isLoadingConfig = false);
    }
  }

  Future<void> _onAccountTypeChanged(String newType) async {
    if (newType == _accountType) return;

    setState(() {
      _accountType = newType;
      _isLoadingConfig = true;
    });

    try {
      final guestService = locator<GuestService>();
      final configData = await guestService.getRegisterConfig(newType);

      if (configData != null) {
        _registerConfig = RegisterConfigModel.fromJson(configData);
      }
    } catch (e) {
      debugPrint('Error loading register config: $e');
    }

    if (mounted) {
      setState(() => _isLoadingConfig = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final locale = context.read<AppLanguageProvider>().currentLanguage;

    bool success;
    if (_isPhoneMode) {
      // Force the correct format: extract numbers and add + at the beginning
      final originalDialCode = _selectedCountry.dialCode ?? '+216';
      debugPrint('Original dialCode: "$originalDialCode"');

      // Extract only numbers and add + at beginning
      final dialCode = '+${originalDialCode.replaceAll(RegExp(r'[^0-9]'), '')}';
      debugPrint('Final dialCode: "$dialCode"');

      // Send the dialCode with + and mobile separately
      success = await authProvider.registerWithPhone(
        dialCode, // This will be +216
        _phoneController.text.trim(),
        _passwordController.text,
        _confirmPasswordController.text,
        accountType: _accountType,
        registerMethod: _registerConfig?.registerMethod,
      );
    } else {
      success = await authProvider.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _confirmPasswordController.text,
        accountType: _accountType,
        registerMethod: _registerConfig?.registerMethod,
      );
    }

    if (success && mounted) {
      // Check if verification is disabled
      if (_registerConfig?.disableRegistrationVerification == true) {
        // Go directly to home
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.main,
          (route) => false,
        );
      } else {
        // Navigate to verify code page
        Navigator.pushNamed(context, AppRoutes.verifyCode, arguments: {
          'user_id': authProvider.userId,
          'method': _isPhoneMode ? 'phone' : 'email',
          'email': _isPhoneMode ? null : _emailController.text.trim(),
          'phone': _isPhoneMode ? _phoneController.text.trim() : null,
          'countryCode': _isPhoneMode ? _selectedCountry.dialCode : null,
          'password': _passwordController.text,
          'retypePassword': _confirmPasswordController.text,
          'registerMethod': _registerConfig?.registerMethod,
        });
      }
    } else if (mounted && authProvider.errorMessage != null) {
      final key = AuthMessageUtils.normalizeToKey(
        authProvider.errorMessage,
        authProvider.registrationErrorStatus,
      );
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
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 30),

                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                      ),

                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: Text(
                      'create_account'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                  Center(
                    child: Text(
                      'create_account_desc'.tr(locale),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                  const SizedBox(height: 24),

                  // Account Type Selection (if multiple roles available)
                  if (_availableRoles.length > 1) ...[
                    _buildAccountTypeSelector(locale),
                    const SizedBox(height: 20),
                  ],

                  // Registration Method Toggle (only when backend allows both)
                  if (_showMethodToggle) ...[
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
                  ],
                  const SizedBox(height: 24),

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
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    label: 'password'.tr(locale),
                    hint: 'create_password'.tr(locale),
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
                      if (value.length < 6) {
                        return locale == 'ar'
                            ? 'الحد الأدنى 6 أحرف'
                            : 'Minimum 6 caractères';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 250.ms),

                  const SizedBox(height: 20),

                  // Confirm Password Field
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'confirm_password'.tr(locale),
                    hint: 'confirm_password_hint'.tr(locale),
                    icon: Iconsax.lock,
                    obscureText: _obscureConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Iconsax.eye_slash : Iconsax.eye,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'required_field'.tr(locale);
                      }
                      if (value != _passwordController.text) {
                        return 'password_mismatch'.tr(locale);
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: 35),

                  // Register Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleRegister,
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
                                  'signup'.tr(locale),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 350.ms),

                  const SizedBox(height: 25),

                  // Terms
                  Center(
                    child: Text(
                      locale == 'ar'
                          ? 'بالتسجيل، أنت توافق على شروط الاستخدام'
                          : 'En vous inscrivant, vous acceptez nos conditions',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 380.ms),

                  const SizedBox(height: 30),

                  // Login Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'have_account'.tr(locale),
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.login);
                          },
                          child: Text(
                            'login'.tr(locale),
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
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

  Widget _buildAccountTypeSelector(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'account_type'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              // Student
              _buildAccountTypeOption(
                label: 'student'.tr(locale),
                value: 'user',
                icon: Iconsax.user,
                locale: locale,
              ),
              // Instructor (if available)
              if (_availableRoles.contains('teacher'))
                _buildAccountTypeOption(
                  label: 'instructor'.tr(locale),
                  value: 'teacher',
                  icon: Iconsax.teacher,
                  locale: locale,
                ),
              // Organization (if available)
              if (_availableRoles.contains('organization'))
                _buildAccountTypeOption(
                  label: 'organization'.tr(locale),
                  value: 'organization',
                  icon: Iconsax.building,
                  locale: locale,
                ),
            ],
          ),
        ),
        if (_isLoadingConfig)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  locale == 'ar' ? 'جاري التحميل...' : 'Chargement...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 180.ms);
  }

  Widget _buildAccountTypeOption({
    required String label,
    required String value,
    required IconData icon,
    required String locale,
  }) {
    final isSelected = _accountType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onAccountTypeChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
