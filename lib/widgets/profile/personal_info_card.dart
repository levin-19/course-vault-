import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/student_profile.dart';

/// Personal Information Card Widget
/// Displays full name, phone number, date of birth, address, and gender
class PersonalInfoCard extends StatelessWidget {
  final StudentProfile profile;

  const PersonalInfoCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Full Name
          _PersonalInfoItem(
            label: 'Full Name',
            value: profile.fullName,
            icon: '👤',
          ),
          const Divider(height: 16, color: AppColors.extraLightGrey),

          // Phone Number
          _PersonalInfoItem(
            label: 'Phone Number',
            value: profile.phoneNumber,
            icon: '📱',
            isCopyable: true,
          ),
          const Divider(height: 16, color: AppColors.extraLightGrey),

          // Date of Birth
          _PersonalInfoItem(
            label: 'Date of Birth',
            value: profile.dateOfBirth,
            icon: '🎂',
          ),
          const Divider(height: 16, color: AppColors.extraLightGrey),

          // Gender
          _PersonalInfoItem(
            label: 'Gender',
            value: profile.gender,
            icon: profile.gender == 'Male' ? '🧑' : '👩',
          ),
          const Divider(height: 16, color: AppColors.extraLightGrey),

          // Address
          _PersonalInfoItem(
            label: 'Address',
            value: profile.address,
            icon: '📍',
            isExpandable: true,
          ),
        ],
      ),
    );
  }
}

/// Reusable Personal Info Item Widget
class _PersonalInfoItem extends StatefulWidget {
  final String label;
  final String value;
  final String icon;
  final bool isCopyable;
  final bool isExpandable;

  const _PersonalInfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isCopyable = false,
    this.isExpandable = false,
  });

  @override
  State<_PersonalInfoItem> createState() => _PersonalInfoItemState();
}

class _PersonalInfoItemState extends State<_PersonalInfoItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.isExpandable
              ? () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label
              Row(
                children: [
                  Text(
                    widget.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Value with actions
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: isExpanded ? null : 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.isCopyable)
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                                duration: Duration(milliseconds: 1500),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.copy,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        )
                      else if (widget.isExpandable)
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
