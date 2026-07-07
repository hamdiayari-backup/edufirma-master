import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  
  File? _selectedImage;
  bool _isLoading = false;
  bool _isImageUploading = false;
  String? _avatarUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;
    
    if (profile != null) {
      _nameController.text = profile['full_name'] ?? '';
      _emailController.text = profile['email'] ?? '';
      _phoneController.text = profile['mobile'] ?? '';
      _bioController.text = profile['bio'] ?? '';
      setState(() {
        _avatarUrl = profile['avatar'];
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    final locale = context.read<AppLanguageProvider>().currentLanguage;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              locale == 'ar' ? 'تغيير الصورة' : 'Changer la photo',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Iconsax.camera,
                  label: locale == 'ar' ? 'الكاميرا' : 'Caméra',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildImageOption(
                  icon: Iconsax.gallery,
                  label: locale == 'ar' ? 'المعرض' : 'Galerie',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImage != null || _avatarUrl != null)
                  _buildImageOption(
                    icon: Iconsax.trash,
                    label: locale == 'ar' ? 'حذف' : 'Supprimer',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isImageUploading = true;
    });

    try {
      final userService = locator<UserService>();
      final result = await userService.updateImage(
        profileImage: _selectedImage,
      );

      if (result['success'] == true) {
        // Refresh profile to get new avatar URL
        if (mounted) {
          await context.read<ProfileProvider>().fetchProfile();
          _loadProfile();
          setState(() {
            _selectedImage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo mise à jour avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Erreur lors de la mise à jour'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImageUploading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image first if selected
      if (_selectedImage != null) {
        await _uploadImage();
      }

      // Update profile info
      final profileProvider = context.read<ProfileProvider>();
      final success = await profileProvider.updateProfile({
        'full_name': _nameController.text.trim(),
        'mobile': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la mise à jour'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
          'edit_profile'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                )
                              : _avatarUrl != null
                                  ? Image.network(
                                      _avatarUrl!,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                      loadingBuilder: (_, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: AppColors.grey100,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.primary,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.primary.withOpacity(0.1),
                                        child: const Icon(
                                          Iconsax.user,
                                          size: 50,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.primary.withOpacity(0.1),
                                      child: const Icon(
                                        Iconsax.user,
                                        size: 50,
                                        color: AppColors.primary,
                                      ),
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: _isImageUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Iconsax.camera,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),

              const SizedBox(height: 12),
              
              Text(
                locale == 'ar' ? 'انقر لتغيير الصورة' : 'Appuyez pour changer la photo',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              // Form Fields
              _buildFormField(
                controller: _nameController,
                label: 'full_name'.tr(locale),
                icon: Iconsax.user,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return locale == 'ar' ? 'هذا الحقل مطلوب' : 'Ce champ est requis';
                  }
                  return null;
                },
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1),

              const SizedBox(height: 16),

              _buildFormField(
                controller: _emailController,
                label: 'email'.tr(locale),
                icon: Iconsax.sms,
                enabled: false,
                keyboardType: TextInputType.emailAddress,
              ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideX(begin: -0.1),

              const SizedBox(height: 16),

              _buildFormField(
                controller: _phoneController,
                label: 'phone'.tr(locale),
                icon: Iconsax.call,
                keyboardType: TextInputType.phone,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.1),

              const SizedBox(height: 16),

              _buildFormField(
                controller: _bioController,
                label: locale == 'ar' ? 'نبذة عنك' : 'À propos de vous',
                icon: Iconsax.document_text,
                maxLines: 4,
              ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideX(begin: -0.1),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'save'.tr(locale),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled ? AppColors.white : AppColors.grey100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}






