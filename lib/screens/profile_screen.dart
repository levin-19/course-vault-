import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Professional Gradient Header
                  SliverAppBar(
                    expandedHeight: 280,
                    floating: false,
                    pinned: true,
                    backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeaderBackground(context, controller, isDarkMode),
                    ),
                  ),
                  // Main Content
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Academic Stats Cards
                            _buildStatsSection(context, controller, isDarkMode),
                            const SizedBox(height: 28),

                            // Personal Information
                            _buildSectionHeader('Personal Information', Icons.person_outline),
                            _buildPersonalInfoSection(context, controller, isDarkMode),
                            const SizedBox(height: 28),

                            // Academic Details
                            _buildSectionHeader('Academic Details', Icons.school_outlined),
                            _buildAcademicDetailsSection(context, controller, isDarkMode),
                            const SizedBox(height: 28),

                            // Contact Information
                            _buildSectionHeader('Contact Information', Icons.contact_mail_outlined),
                            _buildContactInfoSection(context, controller, isDarkMode),
                            const SizedBox(height: 28),

                            // Settings & Actions
                            _buildSectionHeader('Preferences', Icons.settings_outlined),
                            _buildSettingsSection(context, controller, isDarkMode),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Professional Gradient Header Background
  Widget _buildHeaderBackground(
      BuildContext context, ProfileController controller, bool isDarkMode) {
    return Obx(() {
      final localPath = controller.profileImagePath.value;
      final remoteUrl = controller.userProfile['profileImageUrl']?.toString();
      final name = controller.userProfile['fullName']?.toString() ?? '';
      final studentId = controller.userProfile['studentId']?.toString() ?? '';
      final department = controller.userProfile['department']?.toString() ?? '';

      ImageProvider? avatarImage;
      if (localPath != null && !kIsWeb) {
        avatarImage = FileImage(File(localPath));
      } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
        avatarImage = NetworkImage(remoteUrl);
      }

      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1F6FEB),
              Color(0xFF5E35B1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Positioned(
              left: -50,
              bottom: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white.withOpacity(0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar with Ring
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: avatarImage,
                          child: avatarImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        GestureDetector(
                          onTap: controller.pickProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF1F6FEB),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    name.isNotEmpty ? name : 'Student',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Department & ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.badge, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              studentId.isNotEmpty ? studentId : 'No ID',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.school, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              department.isNotEmpty ? department : 'Department',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Edit Profile Button
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (controller.isEditing.value) ...[
                          ElevatedButton.icon(
                            onPressed: () => controller.cancelEdit(),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Cancel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () => controller.saveProfile(),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1F6FEB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ] else
                          ElevatedButton.icon(
                            onPressed: () => controller.toggleEditMode(),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1F6FEB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Stats Section with CGPA and Progress
  Widget _buildStatsSection(
      BuildContext context, ProfileController controller, bool isDarkMode) {
    return Obx(
      () {
        final cgpa = controller.userProfile['cgpa'] ?? 0.0;
        final semester = controller.userProfile['semester'] ?? 'N/A';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                // CGPA Card
                _buildStatCard(
                  context,
                  'CGPA',
                  cgpa.toString(),
                  '/4.0',
                  Icons.trending_up,
                  const Color(0xFF4CAF50),
                  isDarkMode,
                ),
                // Semester Card
                _buildStatCard(
                  context,
                  'Semester',
                  semester.toString(),
                  '',
                  Icons.calendar_today,
                  const Color(0xFF2196F3),
                  isDarkMode,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Single Stat Card
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    String suffix,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (suffix.isNotEmpty)
                    Text(
                      suffix,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section Header with Icon
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F6FEB), Color(0xFF5E35B1)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Personal Information Section
  Widget _buildPersonalInfoSection(
      BuildContext context, ProfileController controller, bool isDarkMode) {
    return Obx(
      () => Column(
        children: [
          if (controller.isEditing.value)
            _buildEditableFieldCard(
              'Full Name',
              controller.fullNameController,
              Icons.person,
              isDarkMode,
            )
          else
            _buildInfoCard(
              'Full Name',
              controller.userProfile['fullName'].toString(),
              Icons.person,
              isDarkMode,
            ),
          const SizedBox(height: 12),
          if (controller.isEditing.value)
            _buildEditableFieldCard(
              'Email',
              controller.emailController,
              Icons.email,
              isDarkMode,
            )
          else
            _buildInfoCard(
              'Email',
              controller.userProfile['email'].toString(),
              Icons.email,
              isDarkMode,
            ),
        ],
      ),
    );
  }

  /// Academic Details Section
  Widget _buildAcademicDetailsSection(
      BuildContext context, ProfileController controller, bool isDarkMode) {
    return Obx(
      () => Column(
        children: [
          _buildInfoCard(
            'Department',
            controller.userProfile['department'].toString(),
            Icons.school,
            isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            'Program Type',
            controller.userProfile['programType'].toString(),
            Icons.book,
            isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            'Batch',
            controller.userProfile['batch'].toString(),
            Icons.date_range,
            isDarkMode,
          ),
          const SizedBox(height: 12),
          if (controller.isEditing.value)
            _buildEditableFieldCard(
              'CGPA',
              controller.cgpaController,
              Icons.trending_up,
              isDarkMode,
              keyboardType: TextInputType.number,
            )
          else
            _buildInfoCard(
              'CGPA',
              controller.userProfile['cgpa'].toString(),
              Icons.trending_up,
              isDarkMode,
            ),
        ],
      ),
    );
  }

  /// Contact Information Section
  Widget _buildContactInfoSection(
      BuildContext context, ProfileController controller, bool isDarkMode) {
    return Obx(
      () => Column(
        children: [
          if (controller.isEditing.value)
            _buildEditableFieldCard(
              'Student ID',
              controller.studentIdController,
              Icons.badge,
              isDarkMode,
            )
          else
            _buildInfoCard(
              'Student ID',
              controller.userProfile['studentId'].toString(),
              Icons.badge,
              isDarkMode,
            ),
          const SizedBox(height: 12),
          if (controller.isEditing.value)
            _buildEditableFieldCard(
              'Phone',
              controller.phoneController,
              Icons.phone,
              isDarkMode,
            )
          else
            _buildInfoCard(
              'Phone',
              controller.userProfile['phone'].toString(),
              Icons.phone,
              isDarkMode,
            ),
        ],
      ),
    );
  }

  /// Settings Section
  Widget _buildSettingsSection(
      BuildContext context, ProfileController controller, bool isDarkMode) {
    return Obx(
      () => Column(
        children: [
          // Debug Admin Tool Button (always visible for testing)
          GestureDetector(
            onTap: () => Get.toNamed('/debug-admin'),
            child: _buildSettingCard(
              'Debug Admin Tool',
              'Test and fix admin access',
              Icons.build,
              Colors.orange,
              isDarkMode,
            ),
          ),
          const SizedBox(height: 12),
          // Admin Profile Button (only visible to admins)
          if (controller.isAdmin.value) ...
          [
            GestureDetector(
              onTap: () => Get.toNamed('/admin-profile'),
              child: _buildSettingCard(
                'Admin Profile',
                'View your admin profile dashboard',
                Icons.account_circle,
                const Color(0xFF8B5CF6),
                isDarkMode,
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Admin Dashboard Button (only visible to admins)
          if (controller.isAdmin.value) ...
          [
            GestureDetector(
              onTap: () => Get.toNamed('/admin-dashboard'),
              child: _buildSettingCard(
                'Admin Dashboard',
                'Analytics and platform overview',
                Icons.dashboard,
                const Color(0xFF6366F1),
                isDarkMode,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Get.toNamed('/admin'),
              child: _buildSettingCard(
                'User Management',
                'View all users, notes, and resources',
                Icons.admin_panel_settings,
                const Color(0xFF9C27B0),
                isDarkMode,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...controller.settingsItems.map((setting) {
            return GestureDetector(
              onTap: () =>
                  controller.handleSettingsAction(setting['action'].toString()),
              child: _buildSettingCard(
                setting['title'].toString(),
                setting['subtitle'].toString(),
                _getSettingIcon(setting['icon'].toString()),
                const Color(0xFF1F6FEB),
                isDarkMode,
              ),
            );
          }),
          const SizedBox(height: 12),
          // Logout Button
          GestureDetector(
            onTap: () => _showLogoutConfirmation(context, controller),
            child: _buildSettingCard(
              'Logout',
              'Sign out from your account',
              Icons.logout,
              Colors.red,
              isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  /// Info Card (Read-only)
  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F6FEB).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1F6FEB), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Editable Field Card
  Widget _buildEditableFieldCard(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isDarkMode, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1F6FEB).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF1F6FEB), size: 18),
          labelText: label,
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
    );
  }

  /// Setting Card
  Widget _buildSettingCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: color.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  /// Show Logout Confirmation
  void _showLogoutConfirmation(
      BuildContext context, ProfileController controller) {
    Get.defaultDialog(
      title: 'Logout',
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      content: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Are you sure you want to logout? You will need to login again to access your account.',
          textAlign: TextAlign.center,
        ),
      ),
      textCancel: 'Cancel',
      textConfirm: 'Logout',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.logout();
      },
    );
  }

  /// Get Setting Icon
  IconData _getSettingIcon(String icon) {
    switch (icon) {
      case 'edit':
        return Icons.edit;
      case 'lock':
        return Icons.lock;
      case 'theme':
        return Icons.palette;
      default:
        return Icons.settings;
    }
  }
}
