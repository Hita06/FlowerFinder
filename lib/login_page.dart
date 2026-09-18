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

  // ------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------

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
          content: Text('Something went wrong. Please try again.'),
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

  // ------------------------------------------------------------
  // SIGN UP POPUP
  // ------------------------------------------------------------

  void showSignUpPopup() {
    final signUpEmailController = TextEditingController();
    final signUpPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureSignUpPassword = true;
    bool obscureConfirmPassword = true;
    bool isCreatingAccount = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (popupContext) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            Future<void> createAccount() async {
              final email = signUpEmailController.text.trim();
              final password = signUpPasswordController.text;
              final confirmPassword =
                  confirmPasswordController.text;

              // Check fields
              if (email.isEmpty ||
                  password.isEmpty ||
                  confirmPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields.'),
                  ),
                );
                return;
              }

              // Check password match
              if (password != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match.'),
                  ),
                );
                return;
              }

              setPopupState(() {
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

                if (!context.mounted) return;

                // Close the sign-up popup
                Navigator.pop(context);

                // Open the main application
                Navigator.pushReplacement(
                  context,
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
                    message = 'Password is too weak.';
                    break;

                  case 'email-already-in-use':
                    message =
                        'An account already exists with this email.';
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

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );
              } catch (e) {
                debugPrint(
                  'SIGN UP UNKNOWN ERROR: $e',
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Something went wrong. Please try again.',
                    ),
                  ),
                );
              } finally {
                if (context.mounted) {
                  setPopupState(() {
                    isCreatingAccount = false;
                  });
                }
              }
            }

            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 24,
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
                    // ------------------------------------------------
                    // POPUP HANDLE
                    // ------------------------------------------------

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

                    // ------------------------------------------------
                    // TITLE
                    // ------------------------------------------------

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

                    // ------------------------------------------------
                    // EMAIL
                    // ------------------------------------------------

                    TextField(
                      controller: signUpEmailController,
                      keyboardType:
                          TextInputType.emailAddress,
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

                    // ------------------------------------------------
                    // PASSWORD
                    // ------------------------------------------------

                    TextField(
                      controller: signUpPasswordController,
                      obscureText: obscureSignUpPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureSignUpPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setPopupState(() {
                              obscureSignUpPassword =
                                  !obscureSignUpPassword;
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

                    // ------------------------------------------------
                    // CONFIRM PASSWORD
                    // ------------------------------------------------

                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
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
                            setPopupState(() {
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

                    const SizedBox(height: 24),

                    // ------------------------------------------------
                    // CREATE ACCOUNT BUTTON
                    // ------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isCreatingAccount
                            ? null
                            : createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.green.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
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

                    // ------------------------------------------------
                    // CLOSE BUTTON
                    // ------------------------------------------------

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
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
          },
        );
      },
    ).whenComplete(() {
      signUpEmailController.dispose();
      signUpPasswordController.dispose();
      confirmPasswordController.dispose();
    });
  }

  // ------------------------------------------------------------
  // FORGOT PASSWORD
  // ------------------------------------------------------------

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email address first.',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent.',
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
          message = 'No account found with this email.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        default:
          message =
              'Could not send password reset email.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // LOGIN PAGE UI
  // ------------------------------------------------------------

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
                // --------------------------------------------------
                // FLOWER ICON
                // --------------------------------------------------

                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
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

                // --------------------------------------------------
                // TITLE
                // --------------------------------------------------

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
                  style:
                      Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 35),

                // --------------------------------------------------
                // EMAIL FIELD
                // --------------------------------------------------

                TextField(
                  controller: emailController,
                  keyboardType:
                      TextInputType.emailAddress,
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

                const SizedBox(height: 16),

                // --------------------------------------------------
                // PASSWORD FIELD
                // --------------------------------------------------

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

                const SizedBox(height: 10),

                // --------------------------------------------------
                // FORGOT PASSWORD
                // --------------------------------------------------

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: forgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // --------------------------------------------------
                // LOGIN BUTTON
                // --------------------------------------------------

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
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
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
                            'Login',
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                // --------------------------------------------------
                // SIGN UP
                // --------------------------------------------------

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
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