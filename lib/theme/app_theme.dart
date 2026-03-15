import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary     = Color(0xFF1B5E20);
  static const Color primaryLight= Color(0xFF2E7D32);
  static const Color accent      = Color(0xFFF9A825);
  static const Color surface     = Color(0xFFF8FDF8);
  static const Color cardBg      = Color(0xFFFFFFFF);
  static const Color textDark    = Color(0xFF1A1A1A);
  static const Color textMuted   = Color(0xFF6B7280);
  static const Color danger      = Color(0xFFDC2626);
  static const Color success     = Color(0xFF16A34A);
  static const Color warning     = Color(0xFFD97706);
  static const Color border      = Color(0xFFE5E7EB);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(),
    scaffoldBackgroundColor: surface,
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.dmSans(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 14),
    ),
  );
}