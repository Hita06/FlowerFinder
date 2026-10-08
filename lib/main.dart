// FlowerFinder Application
// Includes the shared navigation, Firebase and environment configuration.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'login_page.dart';
import 'main_navigation.dart';
import 'theme.dart';
import 'user_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FlowerFinderApp());
}

class FlowerFinderApp extends StatelessWidget {
  const FlowerFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flower Finder',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = snapshot.data;
        if (firebaseUser != null) {
          return MainNavigation(account: _accountFromFirebase(firebaseUser));
        }

        return const LoginPage();
      },
    );
  }

  UserAccount _accountFromFirebase(User user) {
    final email = user.email ?? '${user.uid}@flowerfinder.local';
    final username = email.contains('@') ? email.split('@').first : email;
    return UserAccount(
      name: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : username,
      username: username,
      email: email,
    );
  }
}
