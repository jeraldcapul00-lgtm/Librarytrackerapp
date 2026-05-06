// lib/data/session.dart
// Holds the logged-in user's info for the entire app session.

class Session {
  static int? studentId;
  static String? username;

  static void clear() {
    studentId = null;
    username = null;
  }
}
