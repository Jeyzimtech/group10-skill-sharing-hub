import 'dart:ui';
import 'package:flutter/material.dart';

import 'forms/login_form.dart';
import 'forms/register_form.dart';
import 'forms/forgot_password_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _modeController;
  late AnimationController _forgotController;

  late Animation<double> _modeAnimation;
  late Animation<double> _forgotAnimation;

  @override
  void initState() {
    super.initState();
    _modeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _forgotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _modeAnimation = CurvedAnimation(
      parent: _modeController,
      curve: Curves.easeOutBack, // Soft spring finish
    );

    _forgotAnimation = CurvedAnimation(
      parent: _forgotController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _modeController.dispose();
    _forgotController.dispose();
    super.dispose();
  }

  void _switchToRegister() {
    _modeController.forward();
  }

  void _switchToLogin() {
    if (_forgotController.value > 0) {
      _forgotController.reverse();
    } else {
      _modeController.reverse();
    }
  }

  void _switchToForgotPassword() {
    _forgotController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Handle keyboard manually or use scrolling
      body: Stack(
        children: [
          _buildBackground(),
          AnimatedBuilder(
            animation: Listenable.merge([_modeController, _forgotController]),
            builder: (context, child) {
              return Stack(
                children: [
                  _buildLoginFormContainer(),
                  if (_modeController.value > 0) _buildRegisterFormContainer(),
                  if (_forgotController.value > 0) _buildForgotPasswordFormContainer(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: Listenable.merge([_modeController, _forgotController]),
      builder: (context, child) {
        double modeVal = _modeAnimation.value;
        double forgotVal = _forgotAnimation.value;

        // Background moves opposite to forms.
        // Forms move left (-offset) -> Background moves right (+offset)
        double offset = (modeVal * screenWidth * 0.3) + (forgotVal * screenWidth * 0.3);

        return Positioned(
          left: -screenWidth * 0.5,
          top: 0,
          bottom: 0,
          width: screenWidth * 2.0,
          child: Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              left: 50,
              child: _buildAbstractShape(200, 0.1),
            ),
            Positioned(
              bottom: 100,
              right: 150,
              child: _buildAbstractShape(350, 0.08),
            ),
            Positioned(
              top: 300,
              left: 300,
              child: _buildAbstractShape(150, 0.12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbstractShape(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLoginFormContainer() {
    double value = _modeAnimation.value;
    double forgotValue = _forgotAnimation.value;
    final screenWidth = MediaQuery.of(context).size.width;

    double slideOffset = -(value * screenWidth) - (forgotValue * screenWidth);
    
    double scale = lerpDouble(1.0, 0.95, value)!;
    scale = lerpDouble(scale, 0.95, forgotValue)!;
    
    double opacity = lerpDouble(1.0, 0.0, value)!;
    opacity = lerpDouble(opacity, 0.0, forgotValue)!;

    return Transform.translate(
      offset: Offset(slideOffset, 0),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: IgnorePointer(
            ignoring: value > 0.5 || forgotValue > 0.5,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 24),
                children: [
                  Center(
                    child: _buildWhiteCard(
                      child: LoginForm(
                        onRegisterTap: _switchToRegister,
                        onForgotPasswordTap: _switchToForgotPassword,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterFormContainer() {
    double value = _modeAnimation.value;
    final screenWidth = MediaQuery.of(context).size.width;

    double slideOffset = (1 - value) * screenWidth;
    double scale = lerpDouble(0.95, 1.0, value)!;
    double opacity = lerpDouble(0.0, 1.0, value)!;

    return Transform.translate(
      offset: Offset(slideOffset, 0),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: IgnorePointer(
            ignoring: value < 0.5,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 24),
                children: [
                  Center(
                    child: _buildWhiteCard(
                      child: RegisterForm(
                        onLoginTap: _switchToLogin,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordFormContainer() {
    double value = _forgotAnimation.value;
    final screenWidth = MediaQuery.of(context).size.width;

    double slideOffset = (1 - value) * screenWidth;
    double scale = lerpDouble(0.95, 1.0, value)!;
    double opacity = lerpDouble(0.0, 1.0, value)!;

    return Transform.translate(
      offset: Offset(slideOffset, 0),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: IgnorePointer(
            ignoring: value < 0.5,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 24),
                children: [
                  Center(
                    child: _buildWhiteCard(
                      child: ForgotPasswordForm(
                        onBackTap: _switchToLogin,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
