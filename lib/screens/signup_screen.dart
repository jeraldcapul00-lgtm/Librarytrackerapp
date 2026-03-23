import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import 'login_screen.dart';
import '../data/app_store.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final List<String> _courseOptions = ['BSBA', 'BSA', 'BSCS', 'BSHM', 'BSIT'];

  String? _selectedCourse;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
                        Icons.library_add,
                        size: 48,
                        color: AppStyles.primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Join LibraryTracker", style: AppStyles.headline),
                    const SizedBox(height: 4),
                    Text(
                      "Start tracking your reading journey",
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
                          child: Text(
                            "Create Account",
                            style: AppStyles.subText,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppStyles.accentGold.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: AppStyles.inputDecoration(
                              "First Name",
                              Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "First name is required";
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: AppStyles.inputDecoration(
                              "Last Name",
                              Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return "Last name is required";
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _usernameController,
                      decoration: AppStyles.inputDecoration(
                        "Username",
                        Icons.badge_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return "Username is required";
                        if (value.trim().length < 3)
                          return "Username must be at least 3 characters";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

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
                        if (value == null || value.isEmpty)
                          return "Password is required";
                        if (value.length < 8)
                          return "Must be at least 8 characters";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      decoration:
                          AppStyles.inputDecoration(
                            "Confirm Password",
                            Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppStyles.warmGrey,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                      validator: (value) {
                        if (value != _passwordController.text)
                          return "Passwords do not match";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: _selectedCourse,
                      decoration: AppStyles.inputDecoration(
                        "Course",
                        Icons.school_outlined,
                      ),
                      hint: const Text("Select Course"),
                      items: _courseOptions
                          .map(
                            (course) => DropdownMenuItem(
                              value: course,
                              child: Text(course),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCourse = value),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Course is required";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: AppStyles.inputDecoration(
                        "Email Address",
                        Icons.mail_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Email is required";
                        if (!value.contains("@")) return "Enter a valid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: AppStyles.primaryButton,
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text("CREATE ACCOUNT"),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final username = _usernameController.text.trim();
                            if (AuthService.usernameExists(username)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Username is already taken"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            AuthService.register(
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                              username: username,
                              course: _selectedCourse ?? '',
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Account created! Welcome to LibraryTracker 📚",
                                ),
                                backgroundColor: Color(0xFF4A6741),
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: AppStyles.warmGrey,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: "Sign in",
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
