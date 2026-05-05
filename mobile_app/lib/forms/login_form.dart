import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';
import '../services/auth_service.dart';

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

  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String? _emailError;
  String? _passwordError;
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

  void _validate() {
    setState(() {
      _emailError = _email.isEmpty ? null : Validators.validateEmail(_email);
      _passwordError = _password.isEmpty ? null : Validators.validatePassword(_password);
    });
  }

  bool get _isValid => _email.isNotEmpty && _password.isNotEmpty && _emailError == null && _passwordError == null;

  void _submit() async {
    _validate();
    if (!_isValid) return;

    setState(() { _isLoading = true; _serverError = null; });
    try {
      await AuthService.login(_email, _password);
      // Main app will handle navigation via auth state listener
    } on AuthException catch (e) {
      if (mounted) setState(() { _isLoading = false; _serverError = e.message; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _serverError = 'An unexpected error occurred. Please try again.'; });
    }
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
            const Center(
              child: Text(
                'SIGN IN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 8.0,
                ),
              ),
            ),
            const SizedBox(height: 40),
            CustomTextField(
              label: 'Email Address',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: _emailError,
              isSuccess: _email.isNotEmpty && _emailError == null,
              onChanged: (value) {
                _email = value;
                _validate();
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              textInputAction: TextInputAction.done,
              errorText: _passwordError,
              isSuccess: _password.isNotEmpty && _passwordError == null,
              onChanged: (value) {
                _password = value;
                _validate();
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onForgotPasswordTap,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'LOGIN',
              isLoading: _isLoading,
              onPressed: _isValid ? _submit : null,
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
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                ),
                GestureDetector(
                  onTap: widget.onRegisterTap,
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
