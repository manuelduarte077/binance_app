import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'palette.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get theme => ThemeData.light().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Palette.dark,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Palette.yellow,
          secondary: Palette.darkGray,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Palette.dark,
          unselectedItemColor: Palette.white,
          enableFeedback: false,
        ),
        inputDecorationTheme: _inputDecorationTheme(),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Palette.yellow,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Palette.yellow,
            foregroundColor: Palette.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
        ),
      );

  static OutlineInputBorder _inputBorder({
    Color borderColor = Colors.transparent,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: borderColor),
    );
  }

  static InputDecorationTheme _inputDecorationTheme() {
    return InputDecorationTheme(
      border: _inputBorder(),
      focusedBorder: _inputBorder(),
      enabledBorder: _inputBorder(),
      errorBorder: _inputBorder(borderColor: Palette.red),
      focusedErrorBorder: _inputBorder(borderColor: Palette.red),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      suffixIconColor: Palette.gray,
      prefixIconColor: Palette.gray,
      fillColor: Palette.darkGray,
      filled: true,
      errorStyle: const TextStyle(
        fontSize: 14,
        color: Palette.red,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        color: Palette.gray,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        color: Palette.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
