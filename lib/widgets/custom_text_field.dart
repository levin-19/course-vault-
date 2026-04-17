import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/theme.dart';

/// Enhanced Custom Text Field with modern styling
/// Supports icons, validation, and show/hide password toggle
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.hint,
    this.maxLines = 1,
    this.minLines = 1,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool readOnly;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? hint;
  final int maxLines;
  final int minLines;
  final Function(String)? onChanged;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _hideText;
  late bool _isFocused;

  @override
  void initState() {
    super.initState();
    _hideText = widget.obscureText;
    _isFocused = false;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (isFocused) {
        setState(() {
          _isFocused = isFocused;
        });
      },
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: _hideText,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        maxLines: _hideText ? 1 : widget.maxLines,
        minLines: _hideText ? 1 : widget.minLines,
        onChanged: widget.onChanged,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, size: 20)
              : null,
          suffixIcon: _buildSuffixIcon(),
          // Enhanced border styling
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: const BorderSide(
              color: AppColors.borderLight,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: const BorderSide(
              color: AppColors.borderLight,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          // Styling
          filled: true,
          fillColor:
              widget.enabled ? AppColors.white : AppColors.extraLightGrey,
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  /// Build suffix icon with password toggle or custom icon
  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        onPressed: () {
          setState(() {
            _hideText = !_hideText;
          });
        },
        icon: Icon(
          _hideText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: _isFocused ? AppColors.primary : AppColors.textSecondary,
        ),
        splashRadius: 20,
      );
    }
    return widget.suffixIcon != null ? Icon(widget.suffixIcon, size: 20) : null;
  }
}
