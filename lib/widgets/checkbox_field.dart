import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/theme.dart';

/// Custom Checkbox Field with validation error support
class CustomCheckboxField extends StatefulWidget {
  const CustomCheckboxField({
    super.key,
    required this.label,
    this.value = false,
    this.onChanged,
    this.validator,
    this.link,
    this.linkUrl,
  });

  final String label;
  final bool value;
  final Function(bool?)? onChanged;
  final String? Function(bool?)? validator;
  final String? link;
  final String? linkUrl;

  @override
  State<CustomCheckboxField> createState() => _CustomCheckboxFieldState();
}

class _CustomCheckboxFieldState extends State<CustomCheckboxField> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final validationError = widget.validator?.call(_value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          child: InkWell(
            onTap: () {
              setState(() {
                _value = !_value;
              });
              widget.onChanged?.call(_value);
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _value,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _value = newValue ?? false;
                        });
                        widget.onChanged?.call(_value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _value = !_value;
                        });
                        widget.onChanged?.call(_value);
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.label,
                              style: TextStyle(
                                color: validationError != null
                                    ? AppColors.error
                                    : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.link != null) ...[
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: widget.link,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (validationError != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              validationError,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
