import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Onaylanan HTML önizlemesindeki renk/tipografi tokenlarının
/// birebir Flutter karşılığı.
class AppColors {
  static const void_ = Color(0xFF0A0A0B);
  static const surface = Color(0xFF151517);
  static const elevated = Color(0xFF1D1D21);
  static const stroke = Color(0xFF28282D);
  static const violet = Color(0xFFFFFFFF);
  static const violetDim = Color(0xFF2A2A2E);
  static const violetGlow = Color(0x55FFFFFF);
  static const textPrimary = Color(0xFFEDEDF0);
  static const textSecondary = Color(0xFF8B8B94);
  static const textTertiary = Color(0xFF5C5C63);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.void_,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.violet,
        secondary: AppColors.violetDim,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.sora(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 12.5,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.void_,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.violet),
        ),
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13.5),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.stroke),
        ),
      ),
    );
  }
}
