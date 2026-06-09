import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_profile_controller.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  static const routeName = '/admin-profile';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminProfileController());
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : !controller.isAdmin.value
                ? _buildUnauthorizedView()
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        // Profile Header
                        _buildProfileHeader(controller, isDarkMode),
                        const SizedBox(height: 24),

                        // Account Information Card
                        _buildAccountInformation(controller, isDarkMode),
                        const SizedBox(height: 24),

                        // Administration Statistics
                        _buildAdministrationStats(controller, isDarkMode),
                        const SizedBox(height: 24),

                        // Quick Settings
                        _buildQuickSettings(controller, isDarkMode),
                        const SizedBox(height: 24),

                        // Security Section
                        _buildSecuritySection(controller, isDarkMode),
                        const SizedBox(height: 24),

                        // Logout Button
                        _buildLogoutButton(controller, isDarkMode),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
      ),
    );
  }

  /// Profile Header
  Widget _buildProfileHeader(AdminProfileController controller, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F6FEB), Color(0xFF5E35B1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Back Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Back',
              ),
              IconButton(
                onPressed: () => Get.offAllNamed('/home'),
                icon: const Icon(Icons.home, color: Colors.white),
                tooltip: 'Home',
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Profile Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Obx(
              () => CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  controller.adminName.value.isNotEmpty
                      ? controller.adminName.value[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Admin Name
          Obx(
            () => Text(
              controller.adminName.value.isNotEmpty
                  ? controller.adminName.value
                  : 'Administrator',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Admin Email
          Obx(
            () => Text(
              controller.adminEmail.value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Administrator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Account Information Card
  Widget _buildAccountInformation(AdminProfileController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Obx(() => _buildInfoRow(
                    'Full Name',
                    controller.adminName.value,
                    Icons.person_outline,
                    isDarkMode,
                  )),
              _buildDivider(isDarkMode),
              Obx(() => _buildInfoRow(
                    'Email',
                    controller.adminEmail.value,
                    Icons.email_outlined,
                    isDarkMode,
                  )),
              _buildDivider(isDarkMode),
              Obx(() => _buildInfoRow(
                    'Phone Number',
                    controller.adminPhone.value,
                    Icons.phone_outlined,
                    isDarkMode,
                  )),
              _buildDivider(isDarkMode),
              Obx(() => _buildInfoRow(
                    'Role',
                    controller.adminRole.value,
                    Icons.admin_panel_settings,
                    isDarkMode,
                  )),
              _buildDivider(isDarkMode),
              Obx(() => _buildInfoRow(
                    'Join Date',
                    controller.joinDate.value,
                    Icons.calendar_today_outlined,
                    isDarkMode,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  /// Info Row
  Widget _buildInfoRow(String label, String value, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F6FEB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1F6FEB), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Divider
  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      height: 1,
      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
    );
  }

  /// Administration Statistics
  Widget _buildAdministrationStats(AdminProfileController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Administration Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Managed Users',
                controller.managedUsers.value.toString(),
                Icons.people,
                const Color(0xFF1F6FEB),
                isDarkMode,
              ),
              _buildStatCard(
                'Reviewed Notes',
                controller.reviewedNotes.value.toString(),
                Icons.note,
                const Color(0xFF4CAF50),
                isDarkMode,
              ),
              _buildStatCard(
                'Deleted Content',
                controller.deletedContent.value.toString(),
                Icons.delete_outline,
                const Color(0xFFFF9800),
                isDarkMode,
              ),
              _buildStatCard(
                'Total Actions',
                controller.totalActions.value.toString(),
                Icons.done_all,
                const Color(0xFF9C27B0),
                isDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Stat Card
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Profile Information
  Widget _buildProfileInfo(ProfileController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(controller, isDarkMode),
      ],
    );
  }

  /// Info Card
  Widget _buildInfoCard(ProfileController controller, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => _buildInfoRow(
                'Full Name',
                controller.userProfile['fullName']?.toString() ?? 'Not set',
                Icons.person_outline,
                isDarkMode,
              )),
          _buildDivider(isDarkMode),
          Obx(() => _buildInfoRow(
                'Email',
                controller.userProfile['email']?.toString() ?? 'Not set',
                Icons.email_outlined,
                isDarkMode,
              )),
          _buildDivider(isDarkMode),
          Obx(() => _buildInfoRow(
                'Student ID',
                controller.userProfile['studentId']?.toString() ?? 'Not set',
                Icons.badge_outlined,
                isDarkMode,
              )),
          _buildDivider(isDarkMode),
          Obx(() => _buildInfoRow(
                'Department',
                controller.userProfile['department']?.toString() ?? 'Not set',
                Icons.school_outlined,
                isDarkMode,
              )),
        ],
      ),
    );
  }

  /// Info Row
  Widget _buildInfoRow(String label, String value, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Divider
  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      height: 1,
      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
    );
  }

  /// Admin Controls
  Widget _buildAdminControls(ProfileController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Controls',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildControlButton(
          'Admin Dashboard',
          'Manage users and content',
          Icons.dashboard,
          const Color(0xFF6366F1),
          () => Get.toNamed('/admin-dashboard'),
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildControlButton(
          'User Management',
          'View and manage all users',
          Icons.people,
          const Color(0xFF3B82F6),
          () => Get.toNamed('/admin'),
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildControlButton(
          'Content Moderation',
          'Review and moderate content',
          Icons.content_paste,
          const Color(0xFF10B981),
          () => Get.toNamed('/admin'),
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildControlButton(
          'Debug Tools',
          'Access debugging utilities',
          Icons.build,
          const Color(0xFFF59E0B),
          () => Get.toNamed('/debug-admin'),
          isDarkMode,
        ),
      ],
    );
  }

  /// Control Button
  Widget _buildControlButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
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
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  /// Account Settings
  Widget _buildAccountSettings(ProfileController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingTile(
          'Edit Profile',
          'Update your personal information',
          Icons.edit,
          () => controller.toggleEditMode(),
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          'Change Password',
          'Update your account password',
          Icons.lock_outline,
          () {},
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          'Notifications',
          'Manage notification preferences',
          Icons.notifications_outlined,
          () {},
          isDarkMode,
        ),
      ],
    );
  }

  /// Setting Tile
  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
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
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  /// Danger Zone
  Widget _buildDangerZone(ProfileController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red[400],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 24),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Log out from your account',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _showLogoutDialog(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Logout Dialog
  void _showLogoutDialog(ProfileController controller) {
    Get.defaultDialog(
      title: 'Confirm Logout',
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      content: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Are you sure you want to sign out from your admin account?',
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
}
