import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Quick Access Section Widget
/// Horizontal scrollable quick action cards
class QuickAccessSection extends StatelessWidget {
  final Function(String) onActionTap;

  const QuickAccessSection({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'title': 'My Notes', 'icon': Icons.note, 'color': Colors.orange},
      {'title': 'Assignments', 'icon': Icons.assignment, 'color': Colors.green},
      {'title': 'Exam Routine', 'icon': Icons.calendar_today, 'color': Colors.purple},
      {'title': 'Resources', 'icon': Icons.bookmark, 'color': Colors.blue},
      {'title': 'Videos', 'icon': Icons.play_circle, 'color': Colors.red},
      {'title': 'Dashboard', 'icon': Icons.dashboard, 'color': AppColors.primary},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: actions
                .map((action) => _QuickActionCard(
                      title: action['title'] as String,
                      icon: action['icon'] as IconData,
                      color: action['color'] as Color,
                      onTap: () => onActionTap(action['title'] as String),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Individual Quick Action Card
class _QuickActionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _animationController.forward();
      },
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        ),
        child: Container(
          width: 100,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: widget.color.withOpacity(0.4),
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
