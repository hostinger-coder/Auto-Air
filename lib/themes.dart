import 'package:flutter/material.dart';
import 'themes/custom_colors.dart';

class AppThemes {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    extensions: const <ThemeExtension<dynamic>>[
      CustomColors(
        primaryAction: Colors.deepPurple,
        secondaryButton: Color(0xFF1A1A1A),
        success: Color(0xFF22C55E),
        successTrack: Color(0x7322C55E),
        successBorder: Color(0x5922C55E),
      ),
    ],

    scaffoldBackgroundColor: Colors.black,
    primaryColor: const Color(0xFF531DAB),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF531DAB),
      secondary: Color(0xFF1A1A1A),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      surface: Colors.black,
    ),

    fontFamily: 'Roboto',

    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
    ),

    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.black,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFF2A2F3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
      ),
      prefixIconColor: Colors.grey.shade600,
      suffixIconColor: Colors.grey.shade600,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF531DAB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        textStyle: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide.none,
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        textStyle: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Colors.white70,
      thickness: 2,
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    extensions: const <ThemeExtension<dynamic>>[
      CustomColors(
        primaryAction: Colors.deepPurple,
        secondaryButton: Color(0xFFE0E0E0),
        success: Color(0xFF16A34A),
        successTrack: Color(0x6616A34A),
        successBorder: Color(0x4D16A34A),
      ),
    ],

    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    primaryColor: const Color(0xFF531DAB),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF531DAB),
      secondary: Color(0xFFE0E0E0),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      surface: Colors.white,
    ),

    fontFamily: 'Roboto',

    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
    ),

    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
      ),
      prefixIconColor: Colors.grey.shade600,
      suffixIconColor: Colors.grey.shade600,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF531DAB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        textStyle: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide.none,
        backgroundColor: const Color(0xFFE0E0E0),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        textStyle: const TextStyle(fontSize: 18, color: Colors.black),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Colors.black54,
      thickness: 2,
    ),
  );
}
