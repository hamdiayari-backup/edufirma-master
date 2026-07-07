import 'package:flutter/material.dart';

/// EduFirma Color Palette
/// Based on the logo: Vibrant Lime Green + Dark Teal
class AppColors {
  AppColors._();
  
  // ============ Primary Colors ============
  /// Primary Green - From logo icon
  static const Color primary = Color(0xFF7CB342);
  static const Color primaryLight = Color(0xFF9CCC65);
  static const Color primaryDark = Color(0xFF558B2F);
  static const Color primarySurface = Color(0xFFE8F5E9);
  
  // ============ Secondary Colors ============
  /// Dark Teal - From logo text
  static const Color secondary = Color(0xFF0D3C45);
  static const Color secondaryLight = Color(0xFF1B5E6B);
  static const Color secondaryDark = Color(0xFF082830);
  
  // ============ Accent Colors ============
  static const Color accent = Color(0xFF00BFA5);
  static const Color accentLight = Color(0xFF5DF2D6);
  static const Color accentDark = Color(0xFF008E76);
  
  // ============ Semantic Colors ============
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // ============ Neutral Colors ============
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Grey Scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // ============ Background Colors ============
  static const Color background = Color(0xFFF8FAF8);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);
  
  // ============ Text Colors ============
  static const Color textPrimary = Color(0xFF0D3C45);
  static const Color textSecondary = Color(0xFF5E6E75);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  
  // ============ Gradients ============
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFF0D3C45),
      Color(0xFF1B5E6B),
      Color(0xFF7CB342),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient overlayGradient = LinearGradient(
    colors: [
      Colors.black.withOpacity(0.7),
      Colors.black.withOpacity(0.0),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  
  // ============ Shadows ============
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}






