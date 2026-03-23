import 'package:flutter/material.dart';

class AppStyles {
  
  // Classic Library Color Palette
  static const Color primaryBrown = Color(0xFF5C3D2E);
  static const Color accentGold = Color(0xFFD4A853);
  static const Color creamBackground = Color(0xFFF5EFE6);
  static const Color darkWood = Color(0xFF3B2314);
  static const Color softParchment = Color(0xFFFDF6E3);
  static const Color mutedGreen = Color(0xFF4A6741);
  static const Color warmGrey = Color(0xFF8B7D6B);

  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF3B2314), Color(0xFF5C3D2E), Color(0xFF7A5C44)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration cardBox = BoxDecoration(
    color: softParchment,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: accentGold.withOpacity(0.4), width: 1.5),
    boxShadow: const [
      BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6)),
    ],
  );

  static const TextStyle headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: darkWood,
    letterSpacing: 0.5,
  );

  static const TextStyle subText = TextStyle(
    fontSize: 13,
    color: warmGrey,
    letterSpacing: 0.3,
  );

  static const TextStyle bookTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: darkWood,
  );

  static const TextStyle bookAuthor = TextStyle(
    fontSize: 12,
    color: warmGrey,
    fontStyle: FontStyle.italic,
  );

  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: warmGrey),
      prefixIcon: Icon(icon, color: primaryBrown, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentGold.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentGold.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBrown, width: 1.5),
      ),
    );
  }

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primaryBrown,
    foregroundColor: softParchment,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    elevation: 4,
    shadowColor: Colors.black45,
  );

  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: accentGold,
    foregroundColor: darkWood,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
    elevation: 2,
  );
}
