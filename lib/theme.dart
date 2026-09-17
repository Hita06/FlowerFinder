import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const green = Color(0xFF5CC49A);
  static const darkGreen = Color(0xFF2F6B4F);
  static const cream = Color(0xFFFFF9F0);
  static const pink = Color(0xFFF4A6B8);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.cream,

    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),

    textTheme: TextTheme(
      // Leckerli One for large/display text
      displayLarge: GoogleFonts.leckerliOne(
        fontSize: 36,
        color: AppColors.darkGreen,
      ),

      headlineLarge: GoogleFonts.leckerliOne(
        fontSize: 30,
        color: AppColors.darkGreen,
      ),

      headlineMedium: GoogleFonts.leckerliOne(
        fontSize: 26,
        color: AppColors.darkGreen,
      ),

      // Normal app text
      bodyLarge: GoogleFonts.leagueSpartan(fontSize: 16),

      bodyMedium: GoogleFonts.leagueSpartan(fontSize: 14),

      labelLarge: GoogleFonts.leagueSpartan(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.green,
      foregroundColor: Colors.white,
      elevation: 0,

      titleTextStyle: GoogleFonts.leckerliOne(
        fontSize: 24,
        color: Colors.white,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        elevation: 0,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
