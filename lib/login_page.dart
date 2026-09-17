import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for the login fields
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // Used to show/hide password
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  void login() {
    final email = emailController.text;
    final password = passwordController.text;

    print('Email: $email');
    print('Password: $password');

    // Firebase login will be added here later.
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  void signUp() {
    print('Sign up pressed');

    // Registration page will be added later.
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  void forgotPassword() {
    print('Forgot password pressed');

    // Firebase password reset will be added later.
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [

                const SizedBox(height: 60),

                // ==================================================
                // TITLE
                // ==================================================

                const Text(
                  'Flower Finder',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // WELCOME
                // ==================================================

                const Text(
                  'Welcome back!',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 50),

                // ==================================================
                // EMAIL
                // ==================================================

                const Text(
                  'Email',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: emailController,

                  keyboardType:
                      TextInputType.emailAddress,

                  decoration: const InputDecoration(
                    hintText: 'Enter your email',

                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),

                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PASSWORD
                // ==================================================

                const Text(
                  'Password',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: passwordController,

                  obscureText: obscurePassword,

                  decoration: InputDecoration(
                    hintText: 'Enter your password',

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),

                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },
                    ),

                    border:
                        const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // LOGIN BUTTON
                // ==================================================

                SizedBox(
                  height: 55,

                  child: ElevatedButton(
                    onPressed: login,

                    child: const Text(
                      'Log In',

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // FORGOT PASSWORD
                // ==================================================

                TextButton(
                  onPressed: forgotPassword,

                  child: const Text(
                    'Forgot Password?',
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // SIGN UP
                // ==================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Text(
                      "Don't have an account?",
                    ),

                    TextButton(
                      onPressed: signUp,

                      child: const Text(
                        'Sign Up',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}