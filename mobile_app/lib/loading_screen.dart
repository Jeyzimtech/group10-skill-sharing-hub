import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'utils/app_colors.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _textController;
  late Animation<int> _typewriterAnimation;
  
  final String _fullText = 'WELCOME TO THE\nSKILL SHARING HUB';

  @override
  void initState() {
    super.initState();
    
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Even slower rotation
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // Smoother typing
    );

    _typewriterAnimation = IntTween(begin: 0, end: _fullText.length).animate(
      CurvedAnimation(parent: _textController, curve: Curves.linear),
    );

    _textController.forward();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Ultra-premium smooth entry
              const curve = Curves.fastLinearToSlowEaseIn;
              
              var fadeAnimation = CurvedAnimation(
                parent: animation, 
                curve: const Interval(0.0, 0.6, curve: Curves.easeIn)
              );
              
              var scaleAnimation = Tween<double>(begin: 1.05, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: curve)
              );

              var blurAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
                CurvedAnimation(parent: animation, curve: curve)
              );

              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: blurAnimation.value,
                      sigmaY: blurAnimation.value,
                    ),
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 2000), // 2 seconds for ultra-smoothness
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          _buildBackground(bgColor),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSkillNetwork3D(isDark),
                const SizedBox(height: 80),
                _buildTypewriterText(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillNetwork3D(bool isDark) {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_rotateController.value * 2 * pi)
            ..rotateX(_rotateController.value * pi / 6),
          alignment: Alignment.center,
          child: SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: NodeNetworkPainter(_rotateController.value, isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypewriterText(bool isDark) {
    final Color textColor = isDark ? Colors.white : const Color(0xFF0B3B24);
    
    return AnimatedBuilder(
      animation: _typewriterAnimation,
      builder: (context, child) {
        String displayedText = _fullText.substring(0, _typewriterAnimation.value);
        return Column(
          children: [
            SizedBox(
              height: 60,
              child: Text(
                displayedText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 4,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildConnectivityIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildConnectivityIndicator() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'CONNECTING MINDS',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(Color bgColor) {
    return Container(color: bgColor);
  }
}

class NodeNetworkPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  NodeNetworkPainter(this.animationValue, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    final points = <Offset>[];
    const int count = 14; // Slightly more nodes for density
    for (var i = 0; i < count; i++) {
      final phi = acos(-1 + (2 * i) / count);
      final theta = sqrt(count * pi) * phi;
      final x = center.dx + radius * sin(phi) * cos(theta);
      final y = center.dy + radius * sin(phi) * sin(theta);
      points.add(Offset(x, y));
    }

    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        final distance = (points[i] - points[j]).distance;
        if (distance < radius * 1.6) {
          final opacity = (1 - (distance / (radius * 1.6))).clamp(0.0, 1.0);
          final color = i % 3 == 0 ? AppColors.secondary : AppColors.primary;
          paint.color = color.withValues(alpha: opacity * 0.3);
          canvas.drawLine(points[i], points[j], paint);
        }
      }
      final pulse = sin(animationValue * 2 * pi + i) * 0.5 + 0.5;
      canvas.drawCircle(points[i], 2.5 + pulse * 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
