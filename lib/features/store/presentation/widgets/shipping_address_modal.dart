import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class ShippingAddressModal extends StatefulWidget {
  const ShippingAddressModal({super.key});

  @override
  State<ShippingAddressModal> createState() => _ShippingAddressModalState();
}

class _ShippingAddressModalState extends State<ShippingAddressModal> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'Tunisia');
  final _zipCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitAddress() {
    if (_formKey.currentState!.validate()) {
      final address = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'zip_code': _zipCodeController.text.trim(),
        'phone': _phoneController.text.trim(),
      };
      Navigator.pop(context, address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.location,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc?.shippingAddress ?? 'Adresse de livraison',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        loc?.pleaseEnterAddress ?? 'Veuillez renseigner votre adresse',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // First Name & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _firstNameController,
                            label: loc?.firstName ?? 'Prénom',
                            icon: Iconsax.user,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return loc?.required ?? 'Requis';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _lastNameController,
                            label: loc?.lastName ?? 'Nom',
                            icon: Iconsax.user,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return loc?.required ?? 'Requis';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Address
                    _buildTextField(
                      controller: _addressController,
                      label: loc?.fullAddress ?? 'Adresse complète',
                      icon: Iconsax.location,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc?.addressRequired ?? 'L\'adresse est requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // City & Zip Code
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _cityController,
                            label: loc?.city ?? 'Ville',
                            icon: Iconsax.building,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return loc?.required ?? 'Requis';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _zipCodeController,
                            label: loc?.zipCode ?? 'Code postal',
                            icon: Iconsax.code,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return loc?.required ?? 'Requis';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Country
                    _buildTextField(
                      controller: _countryController,
                      label: loc?.country ?? 'Pays',
                      icon: Iconsax.global,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc?.countryRequired ?? 'Le pays est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: loc?.phone ?? 'Téléphone',
                      icon: Iconsax.call,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc?.phoneRequired ?? 'Le téléphone est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.tick_circle, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              loc?.confirmAddress ?? 'Confirmer l\'adresse',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: AppColors.grey50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        errorStyle: GoogleFonts.poppins(fontSize: 11),
      ),
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
