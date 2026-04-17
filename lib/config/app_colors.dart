import 'package:flutter/material.dart';

/// CourseVault Color Palette
/// Modern, professional academic theme with blue and purple accents
class AppColors {
  // Primary Colors - Academic Blue
  static const Color primary = Color(0xFF1F6FEB); // Vibrant academic blue
  static const Color primaryLight = Color(0xFF5B9FFF); // Light blue
  static const Color primaryDark = Color(0xFF0D4AB3); // Dark blue

  // Secondary Colors - Purple Accent
  static const Color secondary = Color(0xFF7C5FD4); // Modern purple
  static const Color secondaryLight = Color(0xFFB29FE8); // Light purple
  static const Color secondaryDark = Color(0xFF5A3FA0); // Dark purple

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF212121);
  static const Color mediumGrey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color extraLightGrey = Color(0xFFF5F5F5);
  static const Color backgroundColor =
      Color(0xFFF4F8FC); // Light blue-ish white

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF9C4);
  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textLight = Color(0xFFFAFAFA);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);
  static const Color focusBorder = Color(0xFF1F6FEB);

  // Gradient Colors for backgrounds
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF1F6FEB), Color(0xFF7C5FD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
