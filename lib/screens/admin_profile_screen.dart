import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_profile_controller.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  static const routeName = '/admin-profile';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminProfileController());
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : !controller.isAdmin.value
                ? _buildUnauthorizedView()
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        _buildProfileHeader(controller, isDarkMode),
                        const SizedBox(height: 24),
                        _buildAccountInformation(controller, isDarkMode),
                        const SizedBox(height: 24),
                        _buildAdministrationStats(controller, isDarkMode),
                        const SizedBox(height: 24),
                        _buildQuickSettings(isDarkMode),
                        const SizedBox(height: 24),
                        _buildSecuritySection(isDarkMode),
                        const SizedBox(height: 24),
                        _buildLogoutButton(controller),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ── Unauthorized view ────────────────────────────────────────────────────

  Widget _buildUnauthorizedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'Access Denied',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'You do not have permission to view this page.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.offAllNamed('/login'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go to Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F6FEB),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile Header ────────────────────────────────────────────────────────

  Widget _buildProfileHeader(
      AdminProfileController controller, bool isDarkMode) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              IconButton(
                onPressed: () => Get.toNamed('/admin-dashboard'),
                icon: const Icon(Icons.dashboard, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
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
          const SizedBox(height: 16),
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
          Obx(
            () => Text(
              controller.adminEmail.value,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Administrator',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Account Information ───────────────────────────────────────────────────

  Widget _buildAccountInformation(
      AdminProfileController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Account Information', isDarkMode),
        const SizedBox(height: 16),
        _buildCard(
          isDarkMode,
          child: Column(
            children: [
              Obx(() => _buildInfoRow(
                  'Full Name', controller.adminName.value,
                  Icons.person_outline, isDarkMode)),
              _buildDivider(isDarkMode),
              Obx(() => _buildInfoRow(
                  'Email', controller.adminEmail.value,
                  Icons.email_outlined, isDarkMode)),
              _buildDivider(isDarkMode),
              Obx(() => _buildInfoRow(
                  'Phone', controller.adminPhone.value,
                  Icons.phone_outlined, isDarkMode)),
              _buildDivider(isDarkMode),
              Obx(() => _buildInfoRow(
                  'Role', controller.adminRole.value,
                  Icons.admin_panel_settings, isDarkMode)),
              _buildDivider(isDarkMode),
              Obx(() => _buildInfoRow(
                  'Join Date', controller.joinDate.value,
                  Icons.calendar_today_outlined, isDarkMode)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Administration Statistics ─────────────────────────────────────────────

  Widget _buildAdministrationStats(
      AdminProfileController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Administration Statistics', isDarkMode),
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
              _buildStatCard('Managed Users',
                  controller.managedUsers.value.toString(),
                  Icons.people, const Color(0xFF1F6FEB), isDarkMode),
              _buildStatCard('Reviewed Notes',
                  controller.reviewedNotes.value.toString(),
                  Icons.note, const Color(0xFF4CAF50), isDarkMode),
              _buildStatCard('Deleted Content',
                  controller.deletedContent.value.toString(),
                  Icons.delete_outline, const Color(0xFFFF9800), isDarkMode),
              _buildStatCard('Total Actions',
                  controller.totalActions.value.toString(),
                  Icons.done_all, const Color(0xFF9C27B0), isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  // ── Quick Settings ────────────────────────────────────────────────────────

  Widget _buildQuickSettings(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Settings', isDarkMode),
        const SizedBox(height: 16),
        _buildCard(
          isDarkMode,
          child: Column(
            children: [
              _buildSettingTile(
                'Manage Users',
                'View and manage all registered users',
                Icons.people_alt,
                () => Get.toNamed('/users-list'),
                isDarkMode,
              ),
              _buildDivider(isDarkMode),
              _buildSettingTile(
                'Admin Dashboard',
                'Go back to the main dashboard',
                Icons.dashboard,
                () => Get.toNamed('/admin-dashboard'),
                isDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Security Section ──────────────────────────────────────────────────────

  Widget _buildSecuritySection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Security', isDarkMode),
        const SizedBox(height: 16),
        _buildCard(
          isDarkMode,
          child: _buildSettingTile(
            'Change Password',
            'Update admin account password',
            Icons.lock_outline,
            () => Get.snackbar('Info', 'Change password coming soon'),
            isDarkMode,
          ),
        ),
      ],
    );
  }

  // ── Logout Button ─────────────────────────────────────────────────────────

  Widget _buildLogoutButton(AdminProfileController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(controller),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Logout',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ── Reusable helpers ──────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildCard(bool isDarkMode, {required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, bool isDarkMode) {
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
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2)),
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
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF1F6FEB)),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 14,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
        height: 1, color: isDarkMode ? Colors.grey[800] : Colors.grey[200]);
  }

  void _showLogoutDialog(AdminProfileController controller) {
    Get.defaultDialog(
      title: 'Confirm Logout',
      content: const Text(
        'Are you sure you want to sign out?',
        textAlign: TextAlign.center,
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
