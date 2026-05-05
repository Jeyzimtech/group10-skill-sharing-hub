import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';

import 'forms/login_form.dart';
import 'forms/register_form.dart';
import 'forms/forgot_password_form.dart';
import 'utils/app_colors.dart';

enum AuthMode { login, register, forgotPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _forgotController;
  
  late Animation<double> _flipAnimation;
  late Animation<double> _forgotAnimation;
  
  AuthMode _mode = AuthMode.login;
  bool _showRegisterSide = false;
  bool _showForgotSide = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _forgotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _forgotAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _forgotController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _flipController.addListener(() {
      if (_flipController.value > 0.5) {
        if (!_showRegisterSide) {
          setState(() {
            _showRegisterSide = true;
          });
        }
      } else {
        if (_showRegisterSide) {
          setState(() {
            _showRegisterSide = false;
          });
        }
      }
    });

    _forgotController.addListener(() {
      if (_forgotController.value > 0.5) {
        if (!_showForgotSide) {
          setState(() {
            _showForgotSide = true;
          });
        }
      } else {
        if (_showForgotSide) {
          setState(() {
            _showForgotSide = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _forgotController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_flipController.isAnimating || _forgotController.isAnimating) return;
    
    if (_mode == AuthMode.login) {
      _mode = AuthMode.register;
      _flipController.forward();
    } else {
      _mode = AuthMode.login;
      _flipController.reverse();
    }
  }

  void _switchToForgotPassword() {
    if (_flipController.isAnimating || _forgotController.isAnimating) return;
    _mode = AuthMode.forgotPassword;
    _forgotController.forward();
  }

  void _backFromForgot() {
    if (_flipController.isAnimating || _forgotController.isAnimating) return;
    _mode = AuthMode.login;
    _forgotController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          _buildNexusBackground(),
          _buildMainContainer(),
        ],
      ),
    );
  }

  Widget _buildMainContainer() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.92;

    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _forgotAnimation]),
        builder: (context, child) {
          final flipAngle = _flipAnimation.value;
          final forgotAngle = _forgotAnimation.value;
          
          // Determine which axis to rotate on
          // If we are doing forgot password, use X axis rotation (Vertical Flip)
          // If we are doing register, use Y axis rotation (Horizontal Flip)
          
          Matrix4 transform = Matrix4.identity()..setEntry(3, 2, 0.001);
          
          if (forgotAngle > 0) {
            transform.rotateX(forgotAngle);
          } else {
            transform.rotateY(flipAngle);
          }

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _getCurrentSide(cardWidth),
          );
        },
      ),
    );
  }

  Widget _getCurrentSide(double cardWidth) {
    if (_showForgotSide) {
      // Back side of X-axis flip
      return Transform(
        transform: Matrix4.identity()..rotateX(pi),
        alignment: Alignment.center,
        child: _buildGlassCard(
          width: cardWidth,
          child: ForgotPasswordForm(onBackTap: _backFromForgot),
        ),
      );
    }
    
    if (_showRegisterSide) {
      // Back side of Y-axis flip
      return Transform(
        transform: Matrix4.identity()..rotateY(pi),
        alignment: Alignment.center,
        child: _buildGlassCard(
          width: cardWidth,
          child: RegisterForm(onLoginTap: _toggleFlip),
        ),
      );
    }

    // Front side (Login)
    return _buildGlassCard(
      width: cardWidth,
      child: LoginForm(
        onRegisterTap: _toggleFlip,
        onForgotPasswordTap: _switchToForgotPassword,
      ),
    );
  }

  Widget _buildGlassCard({required double width, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: width,
          padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2DD4BF).withValues(alpha: 0.12),
                const Color(0xFF0F172A).withValues(alpha: 0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 0,
                offset: const Offset(0, -1),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 50,
                spreadRadius: -10,
                offset: const Offset(0, 30),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNexusBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.7, -0.6),
              radius: 1.2,
              colors: [
                Color(0xFF1E293B),
                AppColors.background,
              ],
            ),
          ),
        ),
        // Secondary color accent light source
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.15),
                  AppColors.secondary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        // Soft white light source at bottom right
        Positioned(
          bottom: -150,
          right: -50,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentWhite.withValues(alpha: 0.08),
                  AppColors.accentWhite.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: NexusPainter(),
          ),
        ),
      ],
    );
  }
}

class NexusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2DD4BF).withValues(alpha: 0.08)
      ..strokeWidth = 0.8;

    final dotPaint = Paint()
      ..color = const Color(0xFF2DD4BF).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final points = [
      const Offset(50, 100), const Offset(150, 50), const Offset(250, 150),
      const Offset(100, 300), const Offset(300, 400), const Offset(50, 500),
      const Offset(200, 600), const Offset(350, 200), const Offset(100, 700),
      const Offset(300, 800),
    ];

    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        final distance = (points[i] - points[j]).distance;
        if (distance < 250) {
          paint.color = const Color(0xFF2DD4BF).withValues(alpha: (1 - distance / 250) * 0.1);
          canvas.drawLine(points[i], points[j], paint);
        }
      }
      canvas.drawCircle(points[i], 1.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
