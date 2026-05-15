import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Settings Section Widget
/// Provides profile-related settings and options
class SettingsSection extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onNotifications;
  final VoidCallback onTheme;
  final VoidCallback onLogout;
  final bool isDarkMode;

  const SettingsSection({
    super.key,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onNotifications,
    required this.onTheme,
    required this.onLogout,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _SettingItem(
                icon: Icons.edit,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: onEditProfile,
              ),
              _SettingItem(
                icon: Icons.lock,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: onChangePassword,
              ),
              _SettingItem(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: onNotifications,
              ),
              _SettingItem(
                icon: Icons.palette,
                title: isDarkMode ? 'Light Mode' : 'Dark Mode',
                subtitle: isDarkMode ? 'Switch to light theme' : 'Switch to dark theme',
                onTap: onTheme,
              ),
              _SettingItem(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out from your account',
                onTap: onLogout,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual Settings Item
class _SettingItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_SettingItem> createState() => _SettingItemState();
}

class _SettingItemState extends State<_SettingItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovering
                ? (widget.isDestructive ? Colors.red.withOpacity(0.05) : AppColors.backgroundColor)
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.transparent,
              width: 1,
            ),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.isDestructive
                      ? Colors.red.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isDestructive ? Colors.red : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.isDestructive ? Colors.red : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: widget.isDestructive
                    ? Colors.red.withOpacity(0.5)
                    : AppColors.textSecondary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
