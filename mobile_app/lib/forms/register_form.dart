import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import '../screens/main_navigation_screen.dart';
import '../utils/page_transitions.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onLoginTap;

  const RegisterForm({super.key, required this.onLoginTap});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> with SingleTickerProviderStateMixin {
  late AnimationController _staggeredController;
  final List<Animation<double>> _fadeAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];

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
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 8 items for registration form
    for (int i = 0; i < 8; i++) {
      double start = i * 0.08;
      double end = (start + 0.4).clamp(0.0, 1.0);
      
      _fadeAnimations.add(CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));

      _slideAnimations.add(Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(start, end, curve: Curves.backOut),
      )));
    }

    _staggeredController.forward();
  }

  @override
  void dispose() {
    _staggeredController.dispose();
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
          PremiumPageRoute(child: const MainNavigationScreen()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() { _isLoading = false; _serverError = e.message; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _serverError = 'Something went wrong. Please try again.'; });
    }
  }

  Widget _animatedItem(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Stack(
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
                _animatedItem(0, Center(
                  child: Text(
                    'CREATE ACCOUNT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                      letterSpacing: 4.0,
                    ),
                  ),
                )),
                const SizedBox(height: 30),
                _animatedItem(1, CustomTextField(
                  label: 'Full Name',
                  icon: Icons.person,
                  errorText: _nameError,
                  isSuccess: _name.isNotEmpty && _nameError == null,
                  onChanged: (value) => _name = value,
                )),
                const SizedBox(height: 16),
                _animatedItem(2, CustomTextField(
                  label: 'Email Address',
                  icon: Icons.mail,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  isSuccess: _email.isNotEmpty && _emailError == null,
                  onChanged: (value) => _email = value,
                )),
                const SizedBox(height: 16),
                _animatedItem(3, Row(
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
                )),
                const SizedBox(height: 16),
                _animatedItem(4, CustomTextField(
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  errorText: _passwordError,
                  isSuccess: _password.isNotEmpty && _passwordError == null,
                  onChanged: (value) => _password = value,
                )),
                const SizedBox(height: 16),
                _animatedItem(5, CustomTextField(
                  label: 'Confirm Password',
                  icon: Icons.lock,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  errorText: _confirmPasswordError,
                  isSuccess: _confirmPassword.isNotEmpty && _confirmPasswordError == null,
                  onChanged: (value) => _confirmPassword = value,
                )),
                const SizedBox(height: 32),
                _animatedItem(6, Center(
                  child: CustomButton(
                    text: 'SIGN UP',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                )),
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
                _animatedItem(7, Align(
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
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
