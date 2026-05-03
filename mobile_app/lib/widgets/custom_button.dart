import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;

  const CustomButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    
    // Updated to always use dark navy text for the silver button to match Image 3
    final textColor = const Color(0xFF0F172A); 

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 56,
          width: widget.isLoading ? 56 : double.infinity,
          decoration: BoxDecoration(
            gradient: isDisabled || widget.isLoading
                ? null
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFF0F0F0),
                      Color(0xFFE2E2E2),
                    ],
                    stops: [0.0, 0.4, 1.0], // Metallic highlight
                  ),
            color: isDisabled ? Colors.grey.shade400.withValues(alpha: 0.5) : null,
            borderRadius: BorderRadius.circular(widget.isLoading ? 28 : 4),
            boxShadow: isDisabled || widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 25,
                      spreadRadius: -5,
                      offset: const Offset(0, 12),
                    )
                  ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: textColor,
                    strokeWidth: 3,
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.text,
                    key: ValueKey(widget.text),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.5, // Even wider for that premium look
                    ),
                  ),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
      ),
    );
  }
}
