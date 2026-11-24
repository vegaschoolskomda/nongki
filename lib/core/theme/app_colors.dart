import 'package:flutter/material.dart';

/// NONGKI Brand Colors: sesuai prd-design.md
class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF5B3023); // Cokelat tua
  static const Color primaryDark = Color(0xFF3D211A); // Cokelat pekat
  static const Color secondary = Color(0xFF986747); // Cokelat sedang
  static const Color accent = Color(0xFFF2E5D5); // Krem hangat

  // Background & Surface
  static const Color background = Color(0xFFFFFCF8); // Putih hangat
  static const Color surface = Color(0xFFFFFFFF); // Putih
  static const Color surfaceVariant = Color(0xFFF7EFE9); // Krem halus

  // Text
  static const Color textPrimary = Color(0xFF2B211D);
  static const Color textSecondary = Color(0xFF766A63);

  // Border
  static const Color border = Color(0xFFE5D8CD);

  // Status colors
  static const Color success = Color(0xFF2E8B57);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFC8872B);
  static const Color error = Color(0xFFB83B32);
  static const Color errorLight = Color(0xFFFFEBEE);

  // Additional
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color cardShadow = Color(0x14000000);
  static const Color overlay = Color(0x66000000);

  // Nav bar
  static const Color navActive = primary;
  static const Color navInactive = Color(0xFFB0A099);
  static const Color navBackground = surface;

  // Star rating
  static const Color starActive = Color(0xFFE8A020);
  static const Color starInactive = Color(0xFFE5D8CD);
}

