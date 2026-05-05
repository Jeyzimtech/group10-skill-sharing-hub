import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';
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

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _fullName = '';
  String _studentId = '';

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _fullNameError;
  String? _studentIdError;
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
      _fullNameError = _fullName.isEmpty ? null : (_fullName.length < 3 ? 'Name too short' : null);
      _studentIdError = _studentId.isEmpty ? null : (_studentId.length < 5 ? 'Invalid Student ID' : null);
      _emailError = _email.isEmpty ? null : Validators.validateEmail(_email);
      _passwordError = _password.isEmpty ? null : Validators.validatePassword(_password);
      _confirmPasswordError = _confirmPassword.isEmpty ? null : 
          (_confirmPassword != _password ? 'Passwords do not match' : null);
    });
  }

  bool get _isValid => _email.isNotEmpty && _password.isNotEmpty && 
      _fullName.isNotEmpty && _studentId.isNotEmpty &&
      _emailError == null && _passwordError == null && 
      _confirmPasswordError == null && _fullNameError == null && _studentIdError == null;

  void _submit() async {
    _validate();
    if (!_isValid) return;

    setState(() { _isLoading = true; _serverError = null; });
    try {
      await AuthService.register(
        email: _email,
        password: _password,
        fullName: _fullName,
        studentId: _studentId,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 4.0,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              CustomTextField(
                label: 'Full Name',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                errorText: _fullNameError,
                isSuccess: _fullName.isNotEmpty && _fullNameError == null,
                onChanged: (value) {
                  _fullName = value;
                  _validate();
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Student ID',
                icon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
                errorText: _studentIdError,
                isSuccess: _studentId.isNotEmpty && _studentIdError == null,
                onChanged: (value) {
                  _studentId = value;
                  _validate();
                },
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                textInputAction: TextInputAction.next,
                errorText: _passwordError,
                isSuccess: _password.isNotEmpty && _passwordError == null,
                onChanged: (value) {
                  _password = value;
                  _validate();
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Confirm Password',
                icon: Icons.lock_reset,
                isPassword: true,
                textInputAction: TextInputAction.done,
                errorText: _confirmPasswordError,
                isSuccess: _confirmPassword.isNotEmpty && _confirmPasswordError == null,
                onChanged: (value) {
                  _confirmPassword = value;
                  _validate();
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'REGISTER',
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
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              icon: Icons.lock,
              isPassword: true,
              errorText: _passwordError,
              isSuccess: _password.isNotEmpty && _passwordError == null,
              onChanged: (value) {
                _password = value;
                _validate();
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Confirm Password',
              icon: Icons.lock,
              isPassword: true,
              textInputAction: TextInputAction.done,
              errorText: _confirmPasswordError,
              isSuccess: _confirmPassword.isNotEmpty && _confirmPasswordError == null,
              onChanged: (value) {
                _confirmPassword = value;
                _validate();
              },
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'SIGN UP',
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
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: widget.onLoginTap,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.8),
                ),
                child: const Text(
                  'ALREADY REGISTERED? SIGN IN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                  GestureDetector(
                    onTap: widget.onLoginTap,
                    child: const Text(
                      'SIGN IN',
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
