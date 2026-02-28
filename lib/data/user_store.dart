class UserStore {
  static final List<Map<String, String>> _users = [];

  static void addUser(String email, String password) {
    _users.add({"email": email, "password": password});
  }

  static bool validateUser(String email, String password) {
    for (var user in _users) {
      if (user["email"] == email && user["password"] == password) {
        return true;
      }
    }
    return false;
  }
}
