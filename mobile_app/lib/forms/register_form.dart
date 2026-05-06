import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import '../screens/main_navigation_screen.dart';


class RegisterForm extends StatefulWidget {
  final VoidCallback onLoginTap;

  const RegisterForm({super.key, required this.onLoginTap});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _name = '';
  String _email = '';
  String _dob = '';
  String _studentNumber = '';
  String _password = '';
  String _confirmPassword = '';

  String? _nameError;
  String? _emailError;
  String? _dobError;
  String? _studentNumberError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _serverError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_name.isEmpty || _email.isEmpty || _password.isEmpty) return;

    setState(() { _isLoading = true; _serverError = null; });
    try {
      await AuthService.register(
        name: _name,
        email: _email,
        dob: _dob,
        studentNumber: _studentNumber,
        password: _password,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() { _isLoading = false; _serverError = e.message; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _serverError = 'Something went wrong. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'CREATE ACCOUNT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: textColor,
                        letterSpacing: 4.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    label: 'Full Name',
                    icon: Icons.person,
                    errorText: _nameError,
                    isSuccess: _name.isNotEmpty && _nameError == null,
                    onChanged: (value) => _name = value,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email Address',
                    icon: Icons.mail,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    isSuccess: _email.isNotEmpty && _emailError == null,
                    onChanged: (value) => _email = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'DOB (DD/MM/YY)',
                          icon: Icons.calendar_today,
                          errorText: _dobError,
                          isSuccess: _dob.isNotEmpty && _dobError == null,
                          onChanged: (value) => _dob = value,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: 'Student ID',
                          icon: Icons.badge,
                          errorText: _studentNumberError,
                          isSuccess: _studentNumber.isNotEmpty && _studentNumberError == null,
                          onChanged: (value) => _studentNumber = value,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    errorText: _passwordError,
                    isSuccess: _password.isNotEmpty && _passwordError == null,
                    onChanged: (value) => _password = value,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Confirm Password',
                    icon: Icons.lock,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    errorText: _confirmPasswordError,
                    isSuccess: _confirmPassword.isNotEmpty && _confirmPasswordError == null,
                    onChanged: (value) => _confirmPassword = value,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: CustomButton(
                      text: 'SIGN UP',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ),
                  if (_serverError != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _serverError!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: widget.onLoginTap,
                      style: TextButton.styleFrom(
                        foregroundColor: textColor,
                      ),
                      child: Text(
                        'ALREADY REGISTERED? SIGN IN',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

