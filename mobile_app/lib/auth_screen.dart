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
  late AnimationController _bgController;
  
  AuthMode _mode = AuthMode.login;
  bool _showRegisterSide = false;
  bool _showForgotSide = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _forgotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOutQuart,
      ),
    );

    _forgotAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _forgotController,
        curve: Curves.easeInOutQuart,
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

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _forgotController.dispose();
    _bgController.dispose();
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
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgColor,
      body: Stack(
        children: [
          _buildNexusBackground(bgColor, isDark),
          _buildMainContainer(isDark),
        ],
      ),
    );
  }

  Widget _buildMainContainer(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.92;

    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _forgotAnimation]),
        builder: (context, child) {
          final flipAngle = _flipAnimation.value;
          final forgotAngle = _forgotAnimation.value;
          
          Matrix4 transform = Matrix4.identity()..setEntry(3, 2, 0.001);
          
          if (forgotAngle > 0) {
            transform.rotateX(forgotAngle);
          } else {
            transform.rotateY(flipAngle);
          }

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _getCurrentSide(cardWidth, isDark),
          );
        },
      ),
    );
  }

  Widget _getCurrentSide(double cardWidth, bool isDark) {
    if (_showForgotSide) {
      return Transform(
        transform: Matrix4.identity()..rotateX(pi),
        alignment: Alignment.center,
        child: _buildGlassCard(
          width: cardWidth,
          isDark: isDark,
          child: ForgotPasswordForm(onBackTap: _backFromForgot),
        ),
      );
    }
    
    if (_showRegisterSide) {
      return Transform(
        transform: Matrix4.identity()..rotateY(pi),
        alignment: Alignment.center,
        child: _buildGlassCard(
          width: cardWidth,
          isDark: isDark,
          child: RegisterForm(onLoginTap: _toggleFlip),
        ),
      );
    }

    return _buildGlassCard(
      width: cardWidth,
      isDark: isDark,
      child: LoginForm(
        onRegisterTap: _toggleFlip,
        onForgotPasswordTap: _switchToForgotPassword,
      ),
    );
  }

  Widget _buildGlassCard({required double width, required Widget child, required bool isDark}) {
    final Color cardColor = isDark ? AppColors.surface : Colors.white;
    final double borderOpacity = isDark ? 1.0 : 0.2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: width,
          padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: isDark ? 0.9 : 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: borderOpacity),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                blurRadius: 0,
                offset: const Offset(0, -1),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildNexusBackground(Color bgColor, bool isDark) {
    return Stack(
      children: [
        Container(color: bgColor),
        AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: NexusPainter(_bgController.value, isDark),
            );
          },
        ),
      ],
    );
  }
}

class NexusPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  NexusPainter(this.animationValue, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.5)
      ..style = PaintingStyle.fill;

    final points = [
      Offset(size.width * 0.1, size.height * 0.1 + sin(animationValue * 2 * pi) * 20),
      Offset(size.width * 0.3, size.height * 0.05 + cos(animationValue * 2 * pi) * 15),
      Offset(size.width * 0.6, size.height * 0.15 + sin(animationValue * 2 * pi) * 25),
      Offset(size.width * 0.8, size.height * 0.08 + cos(animationValue * 2 * pi) * 10),
      Offset(size.width * 0.2, size.height * 0.4 + sin(animationValue * 2 * pi) * 30),
      Offset(size.width * 0.7, size.height * 0.5 + cos(animationValue * 2 * pi) * 20),
      Offset(size.width * 0.1, size.height * 0.7 + sin(animationValue * 2 * pi) * 15),
      Offset(size.width * 0.4, size.height * 0.8 + cos(animationValue * 2 * pi) * 25),
      Offset(size.width * 0.8, size.height * 0.9 + sin(animationValue * 2 * pi) * 20),
      Offset(size.width * 0.5, size.height * 0.3 + cos(animationValue * 2 * pi) * 15),
    ];

    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        final distance = (points[i] - points[j]).distance;
        if (distance < size.width * 0.6) {
          paint.color = AppColors.primary.withValues(
            alpha: (1 - distance / (size.width * 0.6)) * (isDark ? 0.15 : 0.25),
          );
          canvas.drawLine(points[i], points[j], paint);
        }
      }
      canvas.drawCircle(points[i], 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(NexusPainter oldDelegate) => true;
}
