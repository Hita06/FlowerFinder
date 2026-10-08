import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main_navigation.dart';
import 'theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('LOGIN SUCCESS');
      debugPrint(
        'User email: ${FirebaseAuth.instance.currentUser?.email}',
      );
      debugPrint(
        'User UID: ${FirebaseAuth.instance.currentUser?.uid}',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigation(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('LOGIN ERROR CODE: ${e.code}');
      debugPrint('LOGIN ERROR MESSAGE: ${e.message}');

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
          message = 'Incorrect password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        default:
          message = 'Login failed. Please try again.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      debugPrint('LOGIN UNKNOWN ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SIGN UP POPUP
  // ============================================================

  void showSignUpPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (popupContext) {
        return const SignUpPopup();
      },
    );
  }

  // ============================================================
  // FORGOT PASSWORD POPUP
  // ============================================================

  void showForgotPasswordPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (popupContext) {
        return const ForgotPasswordPopup();
      },
    );
  }

  // ============================================================
  // LOGIN PAGE UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flower icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_florist,
                    size: 48,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Flower Finder',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Discover the flowers around you',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 35),

                // Email
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: showForgotPasswordPopup,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.green.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),

                const SizedBox(height: 18),

                // Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style:
                          Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: showSignUpPopup,
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.bold,
                        ),
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

// ================================================================
// SIGN UP POPUP
// ================================================================

class SignUpPopup extends StatefulWidget {
  const SignUpPopup({super.key});

  @override
  State<SignUpPopup> createState() => _SignUpPopupState();
}

class _SignUpPopupState extends State<SignUpPopup> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isCreatingAccount = false;

  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // CREATE ACCOUNT
  // ------------------------------------------------------------

  Future<void> createAccount() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    setState(() {
      errorMessage = null;
    });

    // Empty fields
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    // Password confirmation
    if (password != confirmPassword) {
      setState(() {
        errorMessage =
            'Passwords do not match. Please enter the same password.';
      });
      return;
    }

    setState(() {
      isCreatingAccount = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('SIGN UP SUCCESS');
      debugPrint(
        'User email: ${credential.user?.email}',
      );
      debugPrint(
        'User UID: ${credential.user?.uid}',
      );

      if (!mounted) return;

      // Close popup
      Navigator.of(context).pop();

      // Wait for popup animation to finish
      await Future.delayed(
        const Duration(milliseconds: 250),
      );

      if (!mounted) return;

      // Open main application
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigation(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'SIGN UP ERROR CODE: ${e.code}',
      );
      debugPrint(
        'SIGN UP ERROR MESSAGE: ${e.message}',
      );

      String message;

      switch (e.code) {
        case 'weak-password':
          message =
              'Password is too weak. Please use a stronger password.';
          break;

        case 'email-already-in-use':
          message =
              'This email is already registered. Please use a different email or log in.';
          break;

        case 'invalid-email':
          message =
              'Please enter a valid email address.';
          break;

        case 'operation-not-allowed':
          message =
              'Email/password sign-up is not enabled.';
          break;

        case 'too-many-requests':
          message =
              'Too many attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message =
              'Please check your internet connection.';
          break;

        default:
          message =
              'Sign up failed. Please try again.';
      }

      if (!mounted) return;

      setState(() {
        errorMessage = message;
        isCreatingAccount = false;
      });
    } catch (e) {
      debugPrint(
        'SIGN UP UNKNOWN ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        errorMessage =
            'Something went wrong. Please try again.';
        isCreatingAccount = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,

        // Extra bottom padding keeps the popup above
        // the Android navigation bar.
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            35,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 45,
              height: 5,
              margin: const EdgeInsets.only(
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Title
            Text(
              'Create Account',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Create your Flower Finder account',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Email
            TextField(
              controller: emailController,
              keyboardType:
                  TextInputType.emailAddress,
              onChanged: (_) {
                if (errorMessage != null) {
                  setState(() {
                    errorMessage = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Password
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              onChanged: (_) {
                if (errorMessage != null) {
                  setState(() {
                    errorMessage = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Password',
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
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Confirm password
            TextField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              onChanged: (_) {
                if (errorMessage != null) {
                  setState(() {
                    errorMessage = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword =
                          !obscureConfirmPassword;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // Error message
            if (errorMessage != null) ...[
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Create account button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isCreatingAccount
                    ? null
                    : createAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.green,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      AppColors.green.withOpacity(0.6),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                child: isCreatingAccount
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Account',
                      ),
              ),
            ),

            const SizedBox(height: 10),

            // Close
            TextButton(
              onPressed: isCreatingAccount
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// FORGOT PASSWORD POPUP
// ================================================================

class ForgotPasswordPopup extends StatefulWidget {
  const ForgotPasswordPopup({super.key});

  @override
  State<ForgotPasswordPopup> createState() =>
      _ForgotPasswordPopupState();
}

class _ForgotPasswordPopupState
    extends State<ForgotPasswordPopup> {
  final TextEditingController emailController =
      TextEditingController();

  bool isSending = false;

  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // SEND RESET EMAIL
  // ------------------------------------------------------------

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();

    setState(() {
      errorMessage = null;
    });

    if (email.isEmpty) {
      setState(() {
        errorMessage =
            'Please enter your email address.';
      });
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );

      debugPrint(
        'PASSWORD RESET EMAIL SENT',
      );
      debugPrint(
        'Email: $email',
      );

      if (!mounted) return;

      // Close popup
      Navigator.of(context).pop();

      // Wait for popup animation
      await Future.delayed(
        const Duration(milliseconds: 250),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Check your inbox.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'PASSWORD RESET ERROR CODE: ${e.code}',
      );
      debugPrint(
        'PASSWORD RESET ERROR MESSAGE: ${e.message}',
      );

      String message;

      switch (e.code) {
        case 'user-not-found':
          message =
              'No account found with this email.';
          break;

        case 'invalid-email':
          message =
              'Please enter a valid email address.';
          break;

        case 'network-request-failed':
          message =
              'Please check your internet connection.';
          break;

        case 'too-many-requests':
          message =
              'Too many attempts. Please try again later.';
          break;

        default:
          message =
              'Could not send password reset email.';
      }

      if (!mounted) return;

      setState(() {
        errorMessage = message;
        isSending = false;
      });
    } catch (e) {
      debugPrint(
        'PASSWORD RESET UNKNOWN ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        errorMessage =
            'Something went wrong. Please try again.';
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,

        // Extra bottom padding keeps the popup above
        // the Android navigation bar.
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            35,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 45,
              height: 5,
              margin: const EdgeInsets.only(
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),

            // Title
            Text(
              'Reset Password',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Enter your email and we will send you a '
              'password reset link.',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Email
            TextField(
              controller: emailController,
              keyboardType:
                  TextInputType.emailAddress,
              onChanged: (_) {
                if (errorMessage != null) {
                  setState(() {
                    errorMessage = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // Error message
            if (errorMessage != null) ...[
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Send reset link
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    isSending ? null : sendResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.green,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      AppColors.green.withOpacity(0.6),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                child: isSending
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Send Reset Link',
                      ),
              ),
            ),

            const SizedBox(height: 10),

            // Close
            TextButton(
              onPressed: isSending
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}