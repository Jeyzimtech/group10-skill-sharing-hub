import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';

class ForgotPasswordForm extends StatefulWidget {
  final VoidCallback onBackTap;

  const ForgotPasswordForm({super.key, required this.onBackTap});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  String _email = '';
  String? _emailError;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimations = List.generate(
      4,
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
      4,
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
    });
  }

  bool get _isValid => _email.isNotEmpty && _emailError == null;

  void _submit() async {
    _validate();
    if (_emailError != null || !_isValid) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: _isSuccess ? _buildSuccessState() : _buildFormState(),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 64,
                  color: Color(0xFF2E7D32),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        const Text(
          'CHECK YOUR EMAIL',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 4.0,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'We have sent password recovery instructions to your email.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        CustomButton(
          text: 'BACK TO LOGIN',
          onPressed: widget.onBackTap,
        ),
      ],
    );
  }

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedItem(
          0,
          GestureDetector(
            onTap: widget.onBackTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1B1B1B),
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildAnimatedItem(
          0,
          const Center(
            child: Text(
              'RESET PASSWORD',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: 4.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildAnimatedItem(
          1,
          Center(
            child: Text(
              'Enter your email to receive recovery instructions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
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
            textInputAction: TextInputAction.done,
            errorText: _emailError,
            isSuccess: _email.isNotEmpty && _emailError == null,
            onChanged: (value) {
              _email = value;
              _validate();
            },
          ),
        ),
        const SizedBox(height: 40),
        _buildAnimatedItem(
          3,
          CustomButton(
            text: 'SEND INSTRUCTIONS',
            isLoading: _isLoading,
            onPressed: _isValid ? _submit : null,
          ),
        ),
      ],
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
