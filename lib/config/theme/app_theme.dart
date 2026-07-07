import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();
  
  // ============ Light Theme ============
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      
      // Text Theme
      textTheme: _textTheme,
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textHint,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySurface,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey500,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicator: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.primary, width: 3),
          ),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.secondary,
        contentTextStyle: GoogleFonts.poppins(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // ============ Dark Theme ============
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.accent,
        secondaryContainer: AppColors.accentDark,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onBackground: AppColors.white,
        onError: AppColors.white,
      ),
      
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      
      textTheme: _textThemeDark,
      
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  
  // ============ Text Theme Light ============
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
      ),
    );
  }
  
  // ============ Text Theme Dark ============
  static TextTheme get _textThemeDark {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.grey300,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.grey400,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.grey300,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.grey400,
      ),
    );
  }
}






