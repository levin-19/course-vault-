import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/student_profile.dart';

/// Academic Information Card Widget
/// Displays CGPA, department, program type, semester, batch, and university email
class AcademicInfoCard extends StatelessWidget {
  final StudentProfile profile;

  const AcademicInfoCard({
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Academic Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // CGPA Section
          _AcademicInfoItem(
            label: 'CGPA',
            value: '${profile.cgpa}',
            icon: '📊',
            highlightColor: AppColors.success,
          ),
          const Divider(height: 16, color: AppColors.extraLightGrey),

          // Department
          _AcademicInfoItem(
            label: 'Department',
            value: profile.department,
            icon: '🏢',
          ),
          const Divider(height: 16, color: AppColors.extraLightGrey),

          // Program Type
          _AcademicInfoItem(
            label: 'Program Type',
            value: profile.programType,
            icon: '🎓',
          ),
          const Divider(height: 16, color: AppColors.extraLightGrey),

          // Semester
          _AcademicInfoItem(
            label: 'Current Semester',
            value: profile.semester,
            icon: '📅',
          ),
          const Divider(height: 16, color: AppColors.extraLightGrey),

          // Batch
          _AcademicInfoItem(
            label: 'Batch',
            value: profile.batch,
            icon: '👥',
          ),
          const Divider(height: 16, color: AppColors.extraLightGrey),

          // University Email
          _AcademicInfoItem(
            label: 'University Email',
            value: profile.universityEmail,
            icon: '✉️',
            isCopyable: true,
          ),
        ],
      ),
    );
  }
}

/// Reusable Academic Info Item Widget
class _AcademicInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color? highlightColor;
  final bool isCopyable;

  const _AcademicInfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.highlightColor,
    this.isCopyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Label
        Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // Value
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: highlightColor?.withOpacity(0.1) ??
                    AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: highlightColor ?? AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCopyable) ...[
                    const SizedBox(width: 8),
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
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
