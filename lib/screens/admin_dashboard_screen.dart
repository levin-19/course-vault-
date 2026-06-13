import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const routeName = '/admin-dashboard';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : !controller.isAdmin.value
                ? _buildUnauthorizedView()
                : RefreshIndicator(
                    onRefresh: controller.refreshDashboard,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),

                          // Dashboard Header
                          _buildDashboardHeader(controller, isDarkMode),
                          const SizedBox(height: 24),

                          // Statistics Overview Cards
                          _buildStatisticsOverview(controller, isDarkMode),
                          const SizedBox(height: 24),

                          // Quick Actions Section
                          _buildQuickActions(controller, isDarkMode),
                          const SizedBox(height: 24),

                          // User Management Preview
                          _buildUserManagementPreview(controller, isDarkMode),
                          const SizedBox(height: 24),

                          // Content Monitoring Section
                          _buildContentMonitoring(controller, isDarkMode),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  /// Dashboard Header
  Widget _buildDashboardHeader(AdminDashboardController controller, bool isDarkMode) {
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
      child: Row(
        children: [
          // Admin Avatar
          GestureDetector(
            onTap: controller.navigateToAdminProfile,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Color(0xFF1F6FEB),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Admin Info
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Administrator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Admin Access',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Logout Button
          IconButton(
            onPressed: () => _showLogoutDialog(),
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  /// Show logout dialog
  void _showLogoutDialog() {
    Get.defaultDialog(
      title: 'Logout',
      content: const Text('Are you sure you want to logout?'),
      textCancel: 'Cancel',
      textConfirm: 'Logout',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        // Clear admin session before navigating to login
        try {
          Get.find<UserService>().logout();
        } catch (_) {}
        Get.offAllNamed('/login');
      },
    );
  }

  /// Statistics Overview Cards
  Widget _buildStatisticsOverview(AdminDashboardController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platform Overview',
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
                'Total Users',
                controller.totalUsers.value.toString(),
                Icons.people,
                const Color(0xFF1F6FEB),
                isDarkMode,
              ),
              _buildStatCard(
                'Total Notes',
                controller.totalNotes.value.toString(),
                Icons.note,
                const Color(0xFF4CAF50),
                isDarkMode,
              ),
              _buildStatCard(
                'Total Assignments',
                controller.totalAssignments.value.toString(),
                Icons.assignment,
                const Color(0xFFFF9800),
                isDarkMode,
              ),
              _buildStatCard(
                'Total Resources',
                controller.totalResources.value.toString(),
                Icons.folder,
                const Color(0xFF9C27B0),
                isDarkMode,
              ),
              _buildStatCard(
                'Total Exams',
                controller.totalExams.value.toString(),
                Icons.school,
                const Color(0xFF2196F3),
                isDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Single Stat Card
  Widget _buildStatCard(
    String title,
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
                title,
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

  /// Quick Actions Section
  Widget _buildQuickActions(AdminDashboardController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: [
            _buildQuickActionButton(
              'Manage Users',
              Icons.people_alt,
              const Color(0xFF1F6FEB),
              () => Get.toNamed('/users-list'),
              isDarkMode,
            ),
            _buildQuickActionButton(
              'View Notes',
              Icons.note,
              const Color(0xFF4CAF50),
              () => Get.snackbar('Info', 'Select a user first from Manage Users'),
              isDarkMode,
            ),
            _buildQuickActionButton(
              'View Assignments',
              Icons.assignment,
              const Color(0xFFFF9800),
              () => Get.snackbar('Info', 'Select a user first from Manage Users'),
              isDarkMode,
            ),
            _buildQuickActionButton(
              'View Resources',
              Icons.folder,
              const Color(0xFF9C27B0),
              () => Get.snackbar('Info', 'Select a user first from Manage Users'),
              isDarkMode,
            ),
            _buildQuickActionButton(
              'Admin Profile',
              Icons.person,
              const Color(0xFF2196F3),
              controller.navigateToAdminProfile,
              isDarkMode,
            ),
            _buildQuickActionButton(
              'Reports',
              Icons.analytics,
              const Color(0xFFE91E63),
              () => Get.snackbar('Info', 'Reports feature coming soon'),
              isDarkMode,
            ),
          ],
        ),
      ],
    );
  }

  /// Quick Action Button
  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// User Management Preview
  Widget _buildUserManagementPreview(AdminDashboardController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/users-list'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => Container(
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
            child: controller.recentUsers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 40,
                            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No users yet',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.recentUsers.length,
                    separatorBuilder: (context, index) => Divider(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final user = controller.recentUsers[index];
                      return _buildUserListTile(controller, user, isDarkMode);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  /// User List Tile
  Widget _buildUserListTile(AdminDashboardController controller, AppUser user, bool isDarkMode) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF1F6FEB).withOpacity(0.1),
        child: Text(
          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Color(0xFF1F6FEB),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user.fullName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID: ${user.studentId ?? 'N/A'}',
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            user.department ?? 'No Department',
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              // Dynamic color based on user.status
              color: user.status == 'suspended'
                  ? Colors.orange.withOpacity(0.1)
                  : const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.status == 'suspended' ? 'Suspended' : 'Active',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: user.status == 'suspended'
                    ? Colors.orange
                    : const Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              size: 18,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 18),
                    SizedBox(width: 8),
                    Text('View'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'suspend',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Suspend'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'activate',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Activate'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'view':
                  controller.viewUserDetails(user);
                  break;
                case 'suspend':
                  _showSuspendDialog(controller, user.uid);
                  break;
                case 'activate':
                  controller.activateUser(user.uid);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(AdminDashboardController controller, String userId) {
    Get.defaultDialog(
      title: 'Suspend User',
      content: const Text('Are you sure you want to suspend this user?'),
      textCancel: 'Cancel',
      textConfirm: 'Suspend',
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () => controller.suspendUser(userId),
    );
  }

  /// Content Monitoring Section
  Widget _buildContentMonitoring(AdminDashboardController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Monitoring',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Container(
          padding: const EdgeInsets.all(16),
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
              _buildContentRow(
                'Recent Notes',
                Icons.note,
                const Color(0xFF4CAF50),
                '${controller.totalNotes.value} total',
                () => controller.navigateToContent('notes'),
                isDarkMode,
              ),
              const SizedBox(height: 12),
              Divider(color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),
              const SizedBox(height: 12),
              _buildContentRow(
                'Recent Resources',
                Icons.folder,
                const Color(0xFF9C27B0),
                '${controller.totalResources.value} total',
                () => controller.navigateToContent('resources'),
                isDarkMode,
              ),
              const SizedBox(height: 12),
              Divider(color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),
              const SizedBox(height: 12),
              _buildContentRow(
                'Recent Assignments',
                Icons.assignment,
                const Color(0xFFFF9800),
                '${controller.totalAssignments.value} total',
                () => controller.navigateToContent('assignments'),
                isDarkMode,
              ),
            ],
          ),
        ),
        ),
      ],
    );
  }

  /// Content Row
  Widget _buildContentRow(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  /// Unauthorized View
  Widget _buildUnauthorizedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'Access Denied',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'You don\'t have permission to access the admin dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.offAllNamed('/home'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F6FEB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
