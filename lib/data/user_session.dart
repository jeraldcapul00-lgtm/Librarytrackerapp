// lib/data/session.dart

class Session {
  static int? studentId;
  static String? username;

  // 🔐 ADD THESE (required for admin + routing)
  static String? token;
  static bool isAdmin = false;

  static void clear() {
    studentId = null;
    username = null;
    token = null;
    isAdmin = false;
  }
}
