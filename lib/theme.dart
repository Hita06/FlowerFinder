// This file defines the application's theme, including custom colours and text styles.

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
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
    ),

    // Application-wide typography
    textTheme: TextTheme(
      // Display text
      displayLarge: GoogleFonts.leckerliOne(
        fontSize: 36,
        color: AppColors.darkGreen,
      ),
      displayMedium: GoogleFonts.leckerliOne(
        fontSize: 32,
        color: AppColors.darkGreen,
      ),
      displaySmall: GoogleFonts.leckerliOne(
        fontSize: 28,
        color: AppColors.darkGreen,
      ),

      // Headings
      headlineLarge: GoogleFonts.leckerliOne(
        fontSize: 30,
        color: AppColors.darkGreen,
      ),
      headlineMedium: GoogleFonts.leckerliOne(
        fontSize: 26,
        color: AppColors.darkGreen,
      ),
      headlineSmall: GoogleFonts.leckerliOne(
        fontSize: 22,
        color: AppColors.darkGreen,
      ),

      // Titles
      titleLarge: GoogleFonts.leagueSpartan(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGreen,
      ),
      titleMedium: GoogleFonts.leagueSpartan(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGreen,
      ),
      titleSmall: GoogleFonts.leagueSpartan(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGreen,
      ),

      // Body text
      bodyLarge: GoogleFonts.leagueSpartan(
        fontSize: 16,
        color: AppColors.darkGreen,
      ),
      bodyMedium: GoogleFonts.leagueSpartan(
        fontSize: 14,
        color: AppColors.darkGreen,
      ),
      bodySmall: GoogleFonts.leagueSpartan(
        fontSize: 12,
        color: AppColors.darkGreen,
      ),

      // Labels and buttons
      labelLarge: GoogleFonts.leagueSpartan(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGreen,
      ),
      labelMedium: GoogleFonts.leagueSpartan(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGreen,
      ),
      labelSmall: GoogleFonts.leagueSpartan(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGreen,
      ),
    ),

    // App bar styling
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.green,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.leckerliOne(
        fontSize: 24,
        color: Colors.white,
      ),
    ),

    // Elevated button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.leagueSpartan(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
