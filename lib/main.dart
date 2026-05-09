import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const LibraryTrackerApp());
}

class LibraryTrackerApp extends StatelessWidget {
  const LibraryTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LibraryTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C3D2E),
          brightness: Brightness.light,
        ),
        fontFamily: 'Georgia',
        scaffoldBackgroundColor: const Color(0xFFF5EFE6),
      ),
      home: const LoginScreen(),
    );
  }
}
