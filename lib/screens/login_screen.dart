import 'package:flutter/material.dart';
import '../widgets/social_button.dart';
import '../theme/app_styles.dart';
import 'signup_screen.dart';
import 'home_page.dart';
import '../data/user_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                  Text("Welcome Back! Log In with", style: AppStyles.headline),
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

                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: AppStyles.primaryButton,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        bool isValid = UserStore.validateUser(
                          _emailController.text,
                          _passwordController.text,
                        );

                        if (isValid) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomePage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Invalid email or password"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text("LOG IN"),
                  ),

                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: const Text("Don't have an account? Create Account"),
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
