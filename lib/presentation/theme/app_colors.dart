import 'package:flutter/material.dart';

/// Design tokens for Cancun DashBooth (FlutterConf LATAM 2026).
/// Combines Flutter brand palette with Caribbean Cancun tropical accents.
abstract class AppColors {
  // --- Flutter Brand Colors ---
  static const Color flutterBlue = Color(0xFF02569B);
  static const Color flutterSkyBlue = Color(0xFF04ACF6);
  static const Color dashCyan = Color(0xFF00E5FF);

  // --- Caribbean Cancún Accents ---
  static const Color caribbeanTeal = Color(0xFF00B4D8);
  static const Color sunshineAmber = Color(0xFFFFB703);
  static const Color coralAccent = Color(0xFFFF70A6);

  // --- Dark Surface Theme ---
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceCard = Color(0xFF273549);
  static const Color borderSubtle = Color(0x3300E5FF);
  static const Color borderCard = Color(0x1AFFFFFF);

  // --- Typography & Text ---
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // --- State Colors ---
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
