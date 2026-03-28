import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ClarityApp());
}

class ClarityApp extends StatelessWidget {
  const ClarityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Clarity',
            debugShowCheckedModeBanner: false,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: _lightTheme(),
            darkTheme: _darkTheme(),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5B7FBF),
        brightness: Brightness.light,
        surface: const Color(0xFFF8F9FB),
        onSurface: const Color(0xFF1A1C1E),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FB),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: const Color(0xFF1A1C1E),
        displayColor: const Color(0xFF1A1C1E),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFA8886B),
        brightness: Brightness.dark,
        surface: const Color(0xFF1A1915),
        onSurface: const Color(0xFFE8E4DF),
        primary: const Color(0xFFA8886B),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1915),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}
