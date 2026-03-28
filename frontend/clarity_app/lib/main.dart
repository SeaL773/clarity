import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ClarityApp());
}

class ClarityApp extends StatelessWidget {
  const ClarityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        title: 'Clarity',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
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
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B7FBF),
            brightness: Brightness.dark,
            surface: const Color(0xFF111315),
            onSurface: const Color(0xFFE3E3E3),
          ),
          scaffoldBackgroundColor: const Color(0xFF111315),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFF1C1E21),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
