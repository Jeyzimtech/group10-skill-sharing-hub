import 'dart:ui';
import 'dart:math';
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
      duration: const Duration(milliseconds: 800),
    );
    _forgotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Silky smooth transitions
    _modeAnimation = CurvedAnimation(
      parent: _modeController,
      curve: Curves.easeInOutQuart,
    );

    _forgotAnimation = CurvedAnimation(
      parent: _forgotController,
      curve: Curves.easeInOutQuart,
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
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF0F172A), // Dark base
      body: Stack(
        children: [
          _buildNexusBackground(),
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

  Widget _buildNexusBackground() {
    return Stack(
      children: [
        // Main gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.5, -0.5),
              radius: 1.5,
              colors: [
                Color(0xFF1E293B),
                Color(0xFF0F172A),
              ],
            ),
          ),
        ),
        // Geometric Nexus
        Positioned.fill(
          child: CustomPaint(
            painter: NexusPainter(),
          ),
        ),
        // Soft Glows
        Positioned(
          top: -100,
          right: -100,
          child: _buildGlow(300, const Color(0xFF0D9488).withOpacity(0.15)),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: _buildGlow(400, const Color(0xFF0F172A).withOpacity(0.3)),
        ),
      ],
    );
  }

  Widget _buildGlow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2DD4BF).withOpacity(0.2),
                const Color(0xFF134E4A).withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLoginFormContainer() {
    double value = _modeAnimation.value;
    double forgotValue = _forgotAnimation.value;
    final screenWidth = MediaQuery.of(context).size.width;

    double slideOffset = -(value * screenWidth * 1.1) - (forgotValue * screenWidth * 1.1);
    double opacity = (1.0 - (value * 1.5)).clamp(0.0, 1.0);
    opacity = (opacity - (forgotValue * 1.5)).clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(slideOffset, 0),
      child: Opacity(
        opacity: opacity,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              Center(
                child: _buildGlassCard(
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
    );
  }

  Widget _buildRegisterFormContainer() {
    double value = _modeAnimation.value;
    final screenWidth = MediaQuery.of(context).size.width;

    double slideOffset = (1.0 - value) * screenWidth * 1.1;
    double opacity = (value * 1.5 - 0.5).clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(slideOffset, 0),
      child: Opacity(
        opacity: opacity,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              Center(
                child: _buildGlassCard(
                  child: RegisterForm(
                    onLoginTap: _switchToLogin,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordFormContainer() {
    double value = _forgotAnimation.value;
    final screenWidth = MediaQuery.of(context).size.width;

    double slideOffset = (1.0 - value) * screenWidth * 1.1;
    double opacity = (value * 1.5 - 0.5).clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(slideOffset, 0),
      child: Opacity(
        opacity: opacity,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              Center(
                child: _buildGlassCard(
                  child: ForgotPasswordForm(
                    onBackTap: _switchToLogin,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NexusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2DD4BF).withOpacity(0.1)
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = const Color(0xFF2DD4BF).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for stability
    final points = List.generate(35, (index) {
      return Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
    });

    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        final distance = (points[i] - points[j]).distance;
        if (distance < 120) {
          // Draw Line
          paint.color = const Color(0xFF2DD4BF).withOpacity((1 - distance / 120) * 0.1);
          canvas.drawLine(points[i], points[j], paint);
          
          // Draw semi-transparent triangle if a 3rd point is close
          for (var k = j + 1; k < points.length; k++) {
            final dist2 = (points[i] - points[k]).distance;
            final dist3 = (points[j] - points[k]).distance;
            if (dist2 < 120 && dist3 < 120) {
              final path = Path()
                ..moveTo(points[i].dx, points[i].dy)
                ..lineTo(points[j].dx, points[j].dy)
                ..lineTo(points[k].dx, points[k].dy)
                ..close();
              canvas.drawPath(path, Paint()..color = const Color(0xFF2DD4BF).withOpacity(0.03));
            }
          }
        }
      }
      canvas.drawCircle(points[i], 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
