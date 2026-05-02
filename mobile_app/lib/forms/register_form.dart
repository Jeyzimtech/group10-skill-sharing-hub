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

class _RegisterFormState extends State<RegisterForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

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
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimations = List.generate(
      6,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(
            0.1 * index,
            0.5 + 0.1 * index,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _slideAnimations = List.generate(
      6,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(
            0.1 * index,
            0.5 + 0.1 * index,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedItem(
            0,
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
                    Icons.person_add_alt_1,
                    size: 35,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
          _buildAnimatedItem(
            0,
            const Center(
              child: Text(
                'CREATE ACCOUNT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 4.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildAnimatedItem(
            2,
            CustomTextField(
              label: 'Full Name',
              icon: Icons.person_outline,
              errorText: _nameError,
              isSuccess: _name.isNotEmpty && _nameError == null,
              onChanged: (value) {
                _name = value;
                _validate();
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildAnimatedItem(
            3,
            CustomTextField(
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
              isSuccess: _email.isNotEmpty && _emailError == null,
              onChanged: (value) {
                _email = value;
                _validate();
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedItem(
                  3,
                  CustomTextField(
                    label: 'DOB (DD/MM/YY)',
                    icon: Icons.calendar_today_outlined,
                    errorText: _dobError,
                    isSuccess: _dob.isNotEmpty && _dobError == null,
                    onChanged: (value) {
                      _dob = value;
                      _validate();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedItem(
                  3,
                  CustomTextField(
                    label: 'Student ID',
                    icon: Icons.badge_outlined,
                    errorText: _studentNumberError,
                    isSuccess: _studentNumber.isNotEmpty && _studentNumberError == null,
                    onChanged: (value) {
                      _studentNumber = value;
                      _validate();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnimatedItem(
            4,
            CustomTextField(
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              errorText: _passwordError,
              isSuccess: _password.isNotEmpty && _passwordError == null,
              onChanged: (value) {
                _password = value;
                _validate();
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildAnimatedItem(
            4,
            CustomTextField(
              label: 'Confirm Password',
              icon: Icons.lock_reset_outlined,
              isPassword: true,
              textInputAction: TextInputAction.done,
              errorText: _confirmPasswordError,
              isSuccess: _confirmPassword.isNotEmpty && _confirmPasswordError == null,
              onChanged: (value) {
                _confirmPassword = value;
                _validate();
              },
            ),
          ),
          const SizedBox(height: 40),
          _buildAnimatedItem(
            5,
            CustomButton(
              text: 'SIGN UP',
              isLoading: _isLoading,
              onPressed: _isValid ? _submit : null,
            ),
          ),
          const SizedBox(height: 24),
          _buildAnimatedItem(
            5,
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: widget.onLoginTap,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE0E0E0),
                ),
                child: const Text(
                  'ALREADY REGISTERED? SIGN IN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }
}
