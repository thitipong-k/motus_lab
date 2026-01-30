import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motus_lab/core/theme/app_style.dart';

/// **AppTheme (ระบบจัดการธีม)**
/// คลาสนี้ทำหน้าที่สร้าง ThemeData สำหรับ 5 สไตล์หลักของแอป:
/// 1. Cyberpunk Neon (ค่าเริ่มต้น) - มืด/นีออน
/// 2. Clean Professional - สว่าง/น้ำเงิน
/// 3. Modern Glassmorphism - โปร่งใส/เบลอ
/// 4. Dark Tactical - ดุดัน/ทหาร
/// 5. Minimalist Eco - ขาว/เขียว
class AppTheme {
  static ThemeData getTheme(AppStyle style) {
    switch (style) {
      case AppStyle.cyberpunk:
        return _cyberpunkTheme;
      case AppStyle.professional:
        return _professionalTheme;
      case AppStyle.glass:
        return _glassTheme;
      case AppStyle.tactical:
        return _tacticalTheme;
      case AppStyle.eco:
        return _ecoTheme;
    }
  }

  // Option 1: Cyberpunk Neon (Enhanced)
  static ThemeData get _cyberpunkTheme {
    const primary = Color(0xFF00FFC2); // Neon Turquoise (Brighter)
    const secondary = Color(0xFFFF00FF); // Neon Magenta
    const background = Color(0xFF050510); // Deep Space Blue/Black
    const surface = Color(0xFF151525);

    // Base Text Style with Google Font
    final baseText = GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      textTheme: baseText.apply(
        bodyColor: Colors.white,
        displayColor: primary,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        error: Color(0xFFFF3040),
      ),
      cardTheme: CardThemeData(
        color: surface.withOpacity(0.9),
        elevation: 10,
        shadowColor: primary.withOpacity(0.4),
        shape: BeveledRectangleBorder(
            // Cut corners (Iconic Cyberpunk shape)
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: primary.withOpacity(0.5), width: 1.5)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background.withOpacity(0.8),
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primary,
          letterSpacing: 2.0,
          shadows: [
            Shadow(color: primary.withOpacity(0.8), blurRadius: 10), // Glow
          ],
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(8)), // Angular buttons
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: const TextStyle(color: primary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary.withOpacity(0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }

  // Option 2: Clean Professional
  static ThemeData get _professionalTheme {
    const primary = Color(0xFF1565C0);
    const background = Color(0xFFF5F7FA);
    const surface = Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: Color(0xFF546E7A),
        surface: surface,
        background: background,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  // Option 3: Modern Glassmorphism
  static ThemeData get _glassTheme {
    const primary = Colors.white;
    const background = Color(0xFF1A1A2E); // Deep Purple/Blue base
    // Note: Glass effect requires backdrop filter in UI, here we set base colors

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF00BFA5),
        surface: Color(0xFF16213E),
        background: background,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.1), // Translucent
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: const StadiumBorder(), // Pill shape
        ),
      ),
    );
  }

  // Option 4: Dark Tactical
  static ThemeData get _tacticalTheme {
    const primary = Color(0xFFFF3D00); // Safety Orange
    const background = Color(0xFF212121);
    const surface = Color(0xFF303030);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: Colors.grey,
        surface: surface,
        background: background,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 8,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Square
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        foregroundColor: primary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 20,
            color: primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Option 5: Minimalist Eco
  static ThemeData get _ecoTheme {
    const primary = Color(0xFF00BFA5); // Teal
    const background = Colors.white;
    const surface = Color(0xFFF9F9F9);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: Color(0xFF64DD17),
        surface: surface,
        background: background,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0, // Flat
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Softer
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }
}
