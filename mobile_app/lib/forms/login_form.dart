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

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  String _email = '';
  String _password = '';
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimations = List.generate(
      5,
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
      5,
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
                    Icons.person,
                    size: 40,
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
                'MEMBER LOGIN',
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
              label: 'Email',
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
          const SizedBox(height: 20),
          _buildAnimatedItem(
            3,
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
          ),
          const SizedBox(height: 12),
          _buildAnimatedItem(
            4,
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
          ),
          const SizedBox(height: 32),
          _buildAnimatedItem(
            4,
            CustomButton(
              text: 'SIGN IN',
              isLoading: _isLoading,
              onPressed: _isValid ? _submit : null,
            ),
          ),
          const SizedBox(height: 24),
          _buildAnimatedItem(
            4,
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
