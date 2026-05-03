import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'auth_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _textController;
  
  final String _message = "WELCOME TO THE SKILL SHARING HUB";
  String _displayedText = "";
  int _charIndex = 0;
  Timer? _typeTimer;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _startTypewriter();
    
    // Smooth transition to AuthScreen after 4.5 seconds
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeInCirc),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 1200),
          ),
        );
      }
    });
  }

  void _startTypewriter() {
    _typeTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_charIndex < _message.length) {
        setState(() {
          _displayedText += _message[_charIndex];
          _charIndex++;
        });
      } else {
        _typeTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _textController.dispose();
    _typeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Rotating 3D Node Network
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                painter: NodeNetworkPainter(_rotationController.value),
                size: Size.infinite,
              );
            },
          ),
          
          // Branding & Loading Text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 4),
                _buildPulseRing(),
                const SizedBox(height: 60),
                SizedBox(
                  height: 30,
                  child: Text(
                    _displayedText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildProgressBar(),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseRing() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF2DD4BF).withValues(alpha: (1 - value) * 0.5),
              width: 2.0 + (value * 10),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: 200,
      height: 2,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(1),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 4000),
        builder: (context, value, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NodeNetworkPainter extends CustomPainter {
  final double rotation;
  NodeNetworkPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF2DD4BF).withValues(alpha: 0.15)
      ..strokeWidth = 0.5;

    final dotPaint = Paint()
      ..color = const Color(0xFF2DD4BF).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final List<Map<String, double>> points3d = [];
    final random = Random(42);
    for (int i = 0; i < 40; i++) {
      points3d.add({
        'x': (random.nextDouble() - 0.5) * 800,
        'y': (random.nextDouble() - 0.5) * 800,
        'z': (random.nextDouble() - 0.5) * 800,
      });
    }

    final double angle = rotation * 2 * pi;
    final List<Offset> points2d = [];

    for (var p in points3d) {
      double x = p['x']! * cos(angle) - p['z']! * sin(angle);
      double z = p['x']! * sin(angle) + p['z']! * cos(angle);
      double y = p['y']!;

      double perspective = 1000 / (1000 + z);
      points2d.add(Offset(center.dx + x * perspective, center.dy + y * perspective));
    }

    for (int i = 0; i < points2d.length; i++) {
      for (int j = i + 1; j < points2d.length; j++) {
        final dist = (points2d[i] - points2d[j]).distance;
        if (dist < 180) {
          paint.color = const Color(0xFF2DD4BF).withValues(alpha: (1 - dist / 180) * 0.1);
          canvas.drawLine(points2d[i], points2d[j], paint);
        }
      }
      canvas.drawCircle(points2d[i], 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
