import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VertigoTheme {
  // 🎨 Couleurs Light
  static const Color primaryGreen = Color(0xFF2D5A27);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color salmonRed = Color(0xFFE8635A);
  static const Color creamBg = Color(0xFFF5EDD6);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF888888);
  static const Color accentYellow = Color(0xFFFFD93D);
  static const Color priceGreen = Color(0xFF2D5A27);

  // 🌙 Couleurs Dark
  static const Color darkBg = Color(0xFF1A2E1A);
  static const Color darkSurface = Color(0xFF2A3D2A);
  static const Color darkCard = Color(0xFF2E4A2E);
  static const Color darkBrown = Color(0xFF3D2E1A);
  static const Color darkText = Color(0xFFF5EDD6);
  static const Color darkTextGrey = Color(0xFFAAAAAA);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          secondary: salmonRed,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: creamBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: textDark),
        ),
        cardColor: Colors.white,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: primaryGreen.withOpacity(0.15),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: lightGreen,
          secondary: salmonRed,
          brightness: Brightness.dark,
          surface: darkSurface,
          background: darkBg,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        scaffoldBackgroundColor: darkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkSurface,
          elevation: 0,
          iconTheme: IconThemeData(color: darkText),
        ),
        cardColor: darkCard,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: darkSurface,
          indicatorColor: lightGreen.withOpacity(0.2),
        ),
      );
}