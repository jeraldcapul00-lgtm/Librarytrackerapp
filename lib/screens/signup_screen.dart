import 'package:flutter/material.dart';
import '../widgets/social_button.dart';
import '../theme/app_styles.dart';
import 'login_screen.dart';
import '../data/user_store.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppStyles.backgroundGradient,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 350,
            decoration: AppStyles.cardBox,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FlutterLogo(size: 60),
                  const SizedBox(height: 20),
                  Text("Create Account with", style: AppStyles.headline),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SocialButton(icon: Icons.facebook, color: Colors.blue),
                      SizedBox(width: 10),
                      SocialButton(icon: Icons.g_mobiledata, color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text("or"),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Your Email"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!value.contains("@")) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "New Password",
                    ),
                    obscureText: true,
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
                  TextFormField(
                    controller: _confirmController,
                    decoration: const InputDecoration(
                      labelText: "Re-type Password",
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: AppStyles.primaryButton,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Save user to UserStore
                        UserStore.addUser(
                          _emailController.text,
                          _passwordController.text,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Account created successfully!"),
                          ),
                        );

                        // Redirect back to Login
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    child: const Text("CREATE"),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Already have an account? Log in"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
