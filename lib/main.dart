import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'instruction_screen.dart';
import 'splash_screen.dart';

void main() {
  runApp(const RakthChitraApp());
}

class RakthChitraApp extends StatelessWidget {
  const RakthChitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFD84315),
        secondary: Color(0xFFFF7043),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF3E0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFD84315),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD84315),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 16, height: 1.5),
      ),
    );

    return MaterialApp(
      title: 'Rakth-Chitra',
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        InstructionScreen.routeName: (_) => const InstructionScreen(),
        CameraScreen.routeName: (_) => const CameraScreen(),
      },
    );
  }
}
