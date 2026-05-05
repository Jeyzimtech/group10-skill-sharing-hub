import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: onPressed != null
              ? LinearGradient(
                  colors: [
                    const Color(0xFF2DD4BF),
                    const Color(0xFF2DD4BF).withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: onPressed == null ? Colors.white.withValues(alpha: 0.1) : null,
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: onPressed != null ? Colors.black : Colors.white38,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
