import 'package:flutter/material.dart';

class AppStyles {
  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF4CAF50), Color(0xFF4caf70)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration cardBox = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
    ],
  );

  static const TextStyle headline = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle subText = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}
