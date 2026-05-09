// lib/screens/login_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:librarytrackerapp/theme/app_styles.dart';
import '../data/user_session.dart';
import 'signup_screen.dart';
import 'home_page.dart';
import 'admin_home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    return 'http://192.168.137.1:5000';
  }

  // 🔐 HARDCODED ADMIN TRIGGER
  static const String _adminUsername = 'adminlibrary';
  static const String _adminPassword = 'admin123';

  Future<void> _login(String username, String password) async {
    setState(() => _isLoading = true);

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) => true,
      ),
    );

    try {
      // ─────────────────────────────────────────────
      // 👮 ADMIN LOGIN (SAFE HYBRID)
      // ─────────────────────────────────────────────
      if (username == _adminUsername && password == _adminPassword) {
        try {
          final adminResponse = await dio.post(
            '$_baseUrl/Admin/login',
            data: {"username": username, "password": password},
          );

          final adminData = adminResponse.data;

          if (adminData is Map && adminData['status'] == 200) {
            final data = adminData['data'];

            Session.username = data['username'];
            Session.token = data['token'];
            Session.studentId = null;
            Session.isAdmin = true;
          } else {
            Session.username = 'Admin';
            Session.token = 'local_admin_token';
            Session.studentId = null;
            Session.isAdmin = true;
          }
        } catch (e) {
          debugPrint("Admin API failed: $e");

          Session.username = 'Admin';
          Session.token = 'local_admin_token';
          Session.studentId = null;
          Session.isAdmin = true;
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomePage()),
        );
        return;
      }

      // ─────────────────────────────────────────────
      // 👤 USER LOGIN
      // ─────────────────────────────────────────────
      final response = await dio.post(
        '$_baseUrl/Login/UserLogin',
        data: {"username": username, "password": password},
      );

      if (!mounted) return;

      final data = response.data;
      debugPrint('Login response: $data');

      if (data is Map && data['status'] == 200) {
        final userData = data['data'];

        Session.studentId = userData['studentId'];
        Session.username = username;
        Session.token = null;
        Session.isAdmin = false;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Invalid credentials'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppStyles.backgroundGradient,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 380,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              decoration: AppStyles.cardBox,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_stories,
                      size: 60,
                      color: AppStyles.primaryBrown,
                    ),
                    const SizedBox(height: 16),

                    Text("LibraryTracker", style: AppStyles.headline),
                    const SizedBox(height: 4),
                    Text(
                      "Your personal reading companion",
                      style: AppStyles.subText,
                    ),

                    const SizedBox(height: 30),

                    // Username
                    TextFormField(
                      controller: _usernameController,
                      decoration: AppStyles.inputDecoration(
                        "Username",
                        Icons.person,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Enter username"
                          : null,
                    ),

                    const SizedBox(height: 15),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration:
                          AppStyles.inputDecoration(
                            "Password",
                            Icons.lock,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Enter password"
                          : null,
                    ),

                    const SizedBox(height: 25),

                    // LOGIN BUTTON (BROWN)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  await _login(
                                    _usernameController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("LOGIN"),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text("Create Account"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
