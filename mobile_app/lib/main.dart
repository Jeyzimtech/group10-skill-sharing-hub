import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final token = await AuthService.getToken();
  runApp(SkillSharingApp(isAuthenticated: token != null));
}

class SkillSharingApp extends StatelessWidget {
  final bool isAuthenticated;
  const SkillSharingApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skill Sharing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF7F9F7),
      ),
      // TODO: replace Placeholder with your actual home screen widget
      home: isAuthenticated ? const Placeholder() : const AuthScreen(),
    );
  }
}
