import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/models/country_code.dart';

class CountryPickerDialog extends StatefulWidget {
  const CountryPickerDialog({super.key});

  @override
  State<CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryCode> _filteredCountries = CountryCode.commonCountries;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCountries = CountryCode.commonCountries;
      });
    } else {
      setState(() {
        _filteredCountries = CountryCode.commonCountries
            .where((country) =>
                (country.name?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (country.dialCode?.contains(query) ?? false) ||
                (country.code?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sélectionner un pays',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: _filterCountries,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un pays...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Iconsax.search_normal,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.grey200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.grey200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Country List
            Flexible(
              child: _filteredCountries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.global,
                              size: 50,
                              color: AppColors.grey300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun pays trouvé',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        return _buildCountryItem(country);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryItem(CountryCode country) {
    return InkWell(
      onTap: () => Navigator.pop(context, country),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Flag
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  country.flag ?? '🏳️',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Country Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    country.dialCode ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Country Code
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                country.code ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






