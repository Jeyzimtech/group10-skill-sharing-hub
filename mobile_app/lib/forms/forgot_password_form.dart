import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class ForgotPasswordForm extends StatefulWidget {
  final VoidCallback onBackTap;

  const ForgotPasswordForm({super.key, required this.onBackTap});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _email = '';
  String? _emailError;
  String? _serverError;
  bool _isLoading = false;
  bool _isSuccess = false;

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
    });
  }

  bool get _isValid => _email.isNotEmpty && _emailError == null;

  void _submit() async {
    _validate();
    if (!_isValid) return;

    setState(() { _isLoading = true; _serverError = null; });
    try {
      await AuthService.forgotPassword(_email);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: _isSuccess ? _buildSuccessState(textColor, subTextColor) : _buildFormState(textColor, subTextColor, isDark),
      ),
    );
  }

  Widget _buildSuccessState(Color textColor, Color subTextColor) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'CHECK YOUR EMAIL',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We have sent recovery instructions to\n$_email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: subTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          CustomButton(
            text: 'BACK TO LOGIN',
            onPressed: widget.onBackTap,
          ),
        ],
      ),
    );

  }

  Widget _buildFormState(Color textColor, Color subTextColor, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: widget.onBackTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF0B3B24),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'RESET PASSWORD',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: textColor,
                letterSpacing: 4.0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Enter your email to receive recovery instructions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: subTextColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 40),
          CustomTextField(
            label: 'Email',
            icon: Icons.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            errorText: _emailError,
            isSuccess: _email.isNotEmpty && _emailError == null,
            onChanged: (value) {
              _email = value;
              _validate();
            },
          ),
          const SizedBox(height: 40),
          Center(
            child: CustomButton(
              text: 'SEND INSTRUCTIONS',
              isLoading: _isLoading,
              onPressed: _isValid ? _submit : null,
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
        ],
      ),
    );

  }
}
