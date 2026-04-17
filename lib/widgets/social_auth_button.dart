import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/theme.dart';

/// Social Authentication Button
/// Supports Google, Email, and other social auth providers
class SocialAuthButton extends StatefulWidget {
  const SocialAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  State<SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<SocialAuthButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.white;
    final textColor = widget.textColor ?? AppColors.textPrimary;
    final borderColor =
        bgColor == AppColors.white ? AppColors.borderMedium : bgColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isPressed && !widget.isLoading
              ? bgColor.withOpacity(0.8)
              : bgColor,
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow:
              _isPressed && !widget.isLoading ? [AppTheme.shadowSmall] : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  else if (widget.icon != null)
                    Icon(widget.icon, color: textColor, size: 20),
                  if (!widget.isLoading && widget.icon != null)
                    const SizedBox(width: 8),
                  if (!widget.isLoading)
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
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
