import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/profile_models.dart';

/// Profile Completion Card
/// Shows progress towards completing profile with missing fields
class ProfileCompletionCard extends StatelessWidget {
  final StudentProfile profile;
  final VoidCallback onTapComplete;

  const ProfileCompletionCard({
    super.key,
    required this.profile,
    required this.onTapComplete,
  });

  @override
  Widget build(BuildContext context) {
    final completionPercentage = profile.completionPercentage;
    final missingFields = profile.missingFields;

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
          // Header with percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Completion',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${missingFields.length} field${missingFields.length != 1 ? 's' : ''} to complete',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _getProgressColor(completionPercentage),
                      _getProgressColor(completionPercentage).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '${completionPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completionPercentage / 100,
              minHeight: 10,
              backgroundColor: AppColors.extraLightGrey,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(completionPercentage),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Missing Fields List
          if (missingFields.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Missing Information:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...missingFields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 6,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatFieldName(field),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Complete Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTapComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getProgressColor(completionPercentage),
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get color based on completion percentage
  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  /// Format field name for display
  String _formatFieldName(String field) {
    final map = {
      'fullName': 'Full Name',
      'email': 'Email Address',
      'phone': 'Phone Number',
      'department': 'Department',
      'semester': 'Semester',
      'profileImage': 'Profile Picture',
    };
    return map[field] ?? field;
  }
}
