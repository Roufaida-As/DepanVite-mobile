import 'package:flutter/material.dart';

class AppTheme {
  static const Color black = Color(0xFF11141A);
  static const Color yellow = Color(0xFFFFC120);
  static const Color beige = Color(0xFFFFF4D2);
  static const Color grey = Color(0xFFF6F6F6);
  static const Color red = Color(0xFFD53235);
  static const Color grey2 = Color(0xFFE8E8E8); 
  static const Color background = Color(0xFFFEFEFE); 


  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppTheme.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: black,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      fontFamily: 'Poppins',
    );
  }
}