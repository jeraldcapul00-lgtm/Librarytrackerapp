import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import 'signup_screen.dart';
import 'home_page.dart';
import '../data/app_store.dart';

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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    // Logo / Icon
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

                    // Divider with label
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

                    // Username
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

                    // Password
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

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: AppStyles.primaryButton,
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text("SIGN IN"),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            bool isValid = AuthService.validateCredentials(
                              _usernameController.text.trim(),
                              _passwordController.text,
                            );

                            if (isValid) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomePage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Invalid username or password"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign Up
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
