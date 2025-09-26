import 'package:depanvite/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:depanvite/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner : false,
      home: const SplashScreen(),
    );
  }
}