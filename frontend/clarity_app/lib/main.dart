import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/main_shell.dart';

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
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
        home: const MainShell(),
      ),
    );
  }
}
