import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onRegisterTap;
  final VoidCallback onForgotPasswordTap;

  const LoginForm({
    super.key,
    required this.onRegisterTap,
    required this.onForgotPasswordTap,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _email = '';
  String _password = '';
  String? _emailError;
  String? _passwordError;
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

  void _validate() {
    setState(() {
      _emailError = _email.isEmpty ? null : Validators.validateEmail(_email);
      _passwordError =
          _password.isEmpty ? null : Validators.validatePassword(_password);
    });
  }

  bool get _isValid =>
      _email.isNotEmpty &&
      _password.isNotEmpty &&
      _emailError == null &&
      _passwordError == null;

  void _submit() async {
    _validate();
    if (_emailError != null || _passwordError != null) return;
    if (!_isValid) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            const Center(
              child: Text(
                'MEMBER LOGIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 6.0,
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Email',
              icon: Icons.mail,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
              isSuccess: _email.isNotEmpty && _emailError == null,
              onChanged: (value) {
                _email = value;
                _validate();
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              icon: Icons.lock,
              isPassword: true,
              textInputAction: TextInputAction.done,
              errorText: _passwordError,
              isSuccess: _password.isNotEmpty && _passwordError == null,
              onChanged: (value) {
                _password = value;
                _validate();
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: widget.onForgotPasswordTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 30),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      const TextSpan(text: 'Forgot Password? '),
                      TextSpan(
                        text: 'Click Here',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'SIGN IN',
              isLoading: _isLoading,
              onPressed: _isValid ? _submit : null,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: widget.onRegisterTap,
                child: const Text(
                  'CREATE NEW ACCOUNT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
