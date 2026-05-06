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
    return 'http://10.0.2.2:5000';
  }

  // ── Admin credentials ────────────────────────────────────────────────────
  static const String _adminUsername = 'adminlibrary';
  static const String _adminPassword = 'admin123';

  Future<void> _login(String username, String password) async {
    setState(() => _isLoading = true);

    // ✅ Admin shortcut — no API call needed
    if (username == _adminUsername && password == _adminPassword) {
      Session.username = 'Admin';
      Session.studentId = null;
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomePage()),
      );
      return;
    }

    // ── Normal student login via API ─────────────────────────────────────
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) => true,
      ),
    );

    try {
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

        debugPrint('Logged in — studentID: ${Session.studentId}');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        final message = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : 'Invalid username or password';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;

      String errorMessage = 'Connection error. Please try again.';

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timed out. Check your network.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Cannot reach the server.\n'
            'Make sure the server is running and the URL is correct.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );

      debugPrint('DioException: ${e.type} — ${e.message}');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint('Unexpected error: $e');
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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              width: 380,
              decoration: AppStyles.cardBox,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Logo ────────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppStyles.primaryBrown.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppStyles.accentGold,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        size: 48,
                        color: AppStyles.primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("LibraryTracker", style: AppStyles.headline),
                    const SizedBox(height: 4),
                    Text(
                      "Your personal reading companion",
                      style: AppStyles.subText,
                    ),
                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppStyles.accentGold.withOpacity(0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("Sign In", style: AppStyles.subText),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppStyles.accentGold.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Username ────────────────────────────────────────────
                    TextFormField(
                      controller: _usernameController,
                      textCapitalization: TextCapitalization.none,
                      decoration: AppStyles.inputDecoration(
                        "Username",
                        Icons.badge_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Username is required";
                        }
                        if (value.trim().length < 3) {
                          return "Username must be at least 3 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── Password ────────────────────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration:
                          AppStyles.inputDecoration(
                            "Password",
                            Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppStyles.warmGrey,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 8) {
                          return "Password must be at least 8 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── Login Button ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: AppStyles.primaryButton,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.login, size: 18),
                        label: Text(_isLoading ? "SIGNING IN..." : "SIGN IN"),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  await _login(
                                    _usernameController.text.trim(),
                                    _passwordController.text,
                                  );
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Sign Up Link ────────────────────────────────────────
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "New reader? ",
                          style: TextStyle(
                            color: AppStyles.warmGrey,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: "Create an account",
                              style: TextStyle(
                                color: AppStyles.primaryBrown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
