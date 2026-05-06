import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import '../screens/main_navigation_screen.dart';
import '../utils/app_colors.dart';


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

  void _submit() async {
    if (_email.isEmpty || _password.isEmpty) return;

    setState(() { _isLoading = true; _serverError = null; });
    try {
      await AuthService.login(_email, _password);
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
    final Color subTextColor = isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54;

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
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: isDark ? Colors.white : Colors.grey.shade100,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'MEMBER LOGIN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: textColor,
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
                    onChanged: (value) => _email = value,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    errorText: _passwordError,
                    isSuccess: _password.isNotEmpty && _passwordError == null,
                    onChanged: (value) => _password = value,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: widget.onForgotPasswordTap,
                      style: TextButton.styleFrom(
                        foregroundColor: subTextColor,
                        padding: EdgeInsets.zero,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: subTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            const TextSpan(text: 'Forgot Password? '),
                            TextSpan(
                              text: 'Click Here',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w900,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: CustomButton(
                      text: 'SIGN IN',
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
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: widget.onRegisterTap,
                      style: TextButton.styleFrom(
                        foregroundColor: textColor,
                      ),
                      child: Text(
                        'CREATE NEW ACCOUNT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
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

