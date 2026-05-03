import 'dart:math';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final String? errorText;
  final bool isSuccess;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.errorText,
    this.isSuccess = false,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.linear),
    );
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && oldWidget.errorText == null) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final activeColor = hasError
        ? const Color(0xFFE53935)
        : widget.isSuccess
            ? const Color(0xFF43A047)
            : const Color(0xFF2E7D32);

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeOffset = sin(_shakeAnimation.value * pi * 4) * 8;
        return Transform.translate(
          offset: Offset(hasError ? shakeOffset : 0, 0),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B121A).withOpacity(0.9), // Even darker for better block contrast
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: hasError ? Colors.red : Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: TextField(
              obscureText: _obscureText,
              onChanged: widget.onChanged,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              cursorColor: const Color(0xFF2DD4BF),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: widget.label,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  widget.icon,
                  size: 20,
                  color: Colors.white.withOpacity(0.8),
                ),
                suffixIcon: _buildSuffixIcon(activeColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: Text(
                widget.errorText!,
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildSuffixIcon(Color activeColor) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey.shade500,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    
    if (widget.isSuccess) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Icon(
              Icons.check_circle,
              color: activeColor,
              size: 22,
            ),
          );
        },
      );
    }
    return null;
  }
}
