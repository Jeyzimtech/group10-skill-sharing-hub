import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'loading_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final isAuthenticated = FirebaseAuth.instance.currentUser != null;
  runApp(SkillSharingApp(isAuthenticated: isAuthenticated));
}

class SkillSharingApp extends StatelessWidget {
  final bool isAuthenticated;
  const SkillSharingApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skill Sharing Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2DD4BF),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2DD4BF),
          brightness: Brightness.dark,
        ),
      ),
      home: isAuthenticated ? const MainNavigationScreen() : const LoadingScreen(),
    );
  }
}
