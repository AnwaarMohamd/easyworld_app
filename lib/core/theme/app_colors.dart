import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF00B5CC);
  static const Color secondary = Color(0xFF00D4A7);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Neutral
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Light Theme
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;

  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  static const Color lightBorder = Color(0xFFE5E7EB);

  // Dark Theme
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);

  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  static const Color darkBorder = Color(0xFF374151);

  // Character Status
  static const Color alive = Color(0xFF22C55E);
  static const Color dead = Color(0xFFEF4444);
  static const Color unknown = Color(0xFF9CA3AF);
}