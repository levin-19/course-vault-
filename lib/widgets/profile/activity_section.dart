import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/student_profile.dart';

/// Activity Section Widget
/// Displays recent student activities (notes, assignments, resources, exams)
class ActivitySection extends StatelessWidget {
  final StudentProfile profile;

  const ActivitySection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View all activities'),
                      duration: Duration(milliseconds: 1500),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Activities List
        if (profile.recentActivities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: AppColors.lightGrey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No recent activities',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profile.recentActivities.length,
            itemBuilder: (context, index) {
              final activity = profile.recentActivities[index];
              return _ActivityItemWidget(
                activity: activity,
                isFirst: index == 0,
                isLast: index == profile.recentActivities.length - 1,
              );
            },
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}

/// Individual Activity Item Widget
class _ActivityItemWidget extends StatefulWidget {
  final ActivityItem activity;
  final bool isFirst;
  final bool isLast;

  const _ActivityItemWidget({
    required this.activity,
    required this.isFirst,
    required this.isLast,
  });

  @override
  State<_ActivityItemWidget> createState() => _ActivityItemWidgetState();
}

class _ActivityItemWidgetState extends State<_ActivityItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.isFirst ? 0 : 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        ),
        child: Container(
          margin: EdgeInsets.fromLTRB(
            16,
            widget.isFirst ? 8 : 0,
            16,
            widget.isLast ? 8 : 0,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Activity Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getActivityBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.activity.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Activity Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.activity.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.activity.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('View ${widget.activity.title}'),
                      duration: const Duration(milliseconds: 1500),
                    ),
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get background color based on activity type
  Color _getActivityBackgroundColor() {
    switch (widget.activity.type) {
      case ActivityType.noteUploaded:
        return Colors.orange.withOpacity(0.1);
      case ActivityType.assignmentSubmitted:
        return AppColors.success.withOpacity(0.1);
      case ActivityType.resourceSaved:
        return AppColors.primary.withOpacity(0.1);
      case ActivityType.examReminder:
        return AppColors.secondary.withOpacity(0.1);
      case ActivityType.profileUpdated:
        return AppColors.info.withOpacity(0.1);
    }
  }
}
