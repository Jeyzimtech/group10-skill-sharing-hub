import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';

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
      _nameError = _name.isEmpty ? null : Validators.validateName(_name);
      _emailError = _email.isEmpty ? null : Validators.validateEmail(_email);
      _dobError = _dob.isEmpty ? null : (_dob.length < 5 ? 'Invalid date' : null);
      _studentNumberError = _studentNumber.isEmpty ? null : (_studentNumber.length < 4 ? 'Invalid number' : null);
      _passwordError = _password.isEmpty ? null : Validators.validatePassword(_password);
      _confirmPasswordError = _confirmPassword.isEmpty 
          ? null 
          : (_confirmPassword != _password ? 'Passwords do not match' : null);
    });
  }

  bool get _isValid =>
      _name.isNotEmpty &&
      _email.isNotEmpty &&
      _dob.isNotEmpty &&
      _studentNumber.isNotEmpty &&
      _password.isNotEmpty &&
      _confirmPassword.isNotEmpty &&
      _nameError == null &&
      _emailError == null &&
      _dobError == null &&
      _studentNumberError == null &&
      _passwordError == null &&
      _confirmPasswordError == null;

  void _submit() async {
    _validate();
    if (_nameError != null || _emailError != null || _passwordError != null) {
      return;
    }
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
              icon: Icons.person,
              errorText: _nameError,
              isSuccess: _name.isNotEmpty && _nameError == null,
              onChanged: (value) {
                _name = value;
                _validate();
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email Address',
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
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'DOB (DD/...',
                    icon: Icons.calendar_today,
                    errorText: _dobError,
                    isSuccess: _dob.isNotEmpty && _dobError == null,
                    onChanged: (value) {
                      _dob = value;
                      _validate();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Student ID',
                    icon: Icons.badge,
                    errorText: _studentNumberError,
                    isSuccess: _studentNumber.isNotEmpty && _studentNumberError == null,
                    onChanged: (value) {
                      _studentNumber = value;
                      _validate();
                    },
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
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: widget.onLoginTap,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.8),
                ),
                child: const Text(
                  'ALREADY REGISTERED? SIGN IN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
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
