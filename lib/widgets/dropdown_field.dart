import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/theme.dart';

/// Custom Dropdown Field for selections like Department, Semester
class CustomDropdownField<T> extends StatefulWidget {
  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.hint,
    this.value,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.itemLabelBuilder,
  });

  final String label;
  final List<T> items;
  final String hint;
  final T? value;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final String Function(T)? itemLabelBuilder;

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  late bool _isFocused;

  @override
  void initState() {
    super.initState();
    _isFocused = false;
  }

  @override
  Widget build(BuildContext context) {
    final validationError = widget.validator?.call(widget.value);

    return Focus(
      onFocusChange: (isFocused) {
        setState(() {
          _isFocused = isFocused;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: validationError != null
                    ? AppColors.error
                    : _isFocused
                        ? AppColors.primary
                        : AppColors.borderLight,
                width: validationError != null
                    ? 1.5
                    : _isFocused
                        ? 2
                        : 1.5,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              color: AppColors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                isExpanded: true,
                value: widget.value,
                hint: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    widget.hint,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 14,
                    ),
                  ),
                ),
                onChanged: widget.onChanged,
                items: widget.items.map((T item) {
                  final itemLabel =
                      widget.itemLabelBuilder?.call(item) ?? item.toString();
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        itemLabel,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.expand_more,
                    color: _isFocused
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                dropdownColor: AppColors.white,
                menuMaxHeight: 300,
              ),
            ),
          ),
          if (validationError != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
      ),
    );
  }
}
