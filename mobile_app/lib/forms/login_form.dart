import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';
import '../services/auth_service.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onRegisterTap;
  final VoidCallback onForgotPasswordTap;

  const LoginForm({
    required this.onRegisterTap,
    required this.onForgotPasswordTap,
    super.key,
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

  bool get _isValid =>
      _email.isNotEmpty && _password.isNotEmpty && _emailError == null && _passwordError == null;

  void _submit() async {
    _validate();
    if (!_isValid) return;

    setState(() { _isLoading = true; _serverError = null; });
    try {
      await AuthService.login(_email, _password);
    } on AuthException catch (e) {
      if (mounted) setState(() { _isLoading = false; _serverError = e.message; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _serverError = 'Something went wrong. Please try again.'; });
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
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2DD4BF).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFF1B2838),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            const Center(
              child: Text(
                'MEMBER LOGIN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 4.0,
                ),
              ),
            ),
            const SizedBox(height: 40),
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
            const SizedBox(height: 20),
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
                  foregroundColor: Colors.white.withOpacity(0.6),
                  padding: EdgeInsets.zero,
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      const TextSpan(text: 'Forgot Password? '),
                      TextSpan(
                        text: 'Click Here',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'SIGN IN',
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
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: widget.onRegisterTap,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE0E0E0),
                ),
                child: const Text(
                  'CREATE NEW ACCOUNT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
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
