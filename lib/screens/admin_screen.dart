import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../models/app_user.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  static const routeName = '/admin';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF1A1F26) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAllData(),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : !controller.isAdmin.value
                ? _buildUnauthorizedView()
                : Column(
                    children: [
                      // Search Bar
                      _buildSearchBar(controller, isDarkMode),

                      // Admin Stats Summary
                      _buildStatsSummary(controller, isDarkMode),

                      // Tab Navigation
                      _buildTabNavigation(controller, isDarkMode),

                      // Tab Content
                      Expanded(
                        child: Obx(
                          () => IndexedStack(
                            index: controller.selectedTabIndex.value,
                            children: [
                              _buildUsersTab(controller, isDarkMode),
                              _buildNotesTab(controller, isDarkMode),
                              _buildResourcesTab(controller, isDarkMode),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  /// Build unauthorized view
  Widget _buildUnauthorizedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Unauthorized Access',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('You do not have admin privileges.'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  /// Search bar widget
  Widget _buildSearchBar(AdminController controller, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => controller.updateSearchQuery(value),
        decoration: InputDecoration(
          hintText: 'Search users, notes, resources...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  /// Admin Statistics Summary
  Widget _buildStatsSummary(AdminController controller, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Users',
              controller.totalUsers.value.toString(),
              Icons.people,
              const Color(0xFF2196F3),
              isDarkMode,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Notes',
              controller.totalNotes.value.toString(),
              Icons.note,
              const Color(0xFF4CAF50),
              isDarkMode,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Resources',
              controller.totalResources.value.toString(),
              Icons.folder,
              const Color(0xFFFF9800),
              isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  /// Single stat card
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
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
    );
  }

  /// Tab navigation
  Widget _buildTabNavigation(AdminController controller, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildTabButton('Users', 0, controller, isDarkMode),
          _buildTabButton('Notes', 1, controller, isDarkMode),
          _buildTabButton('Resources', 2, controller, isDarkMode),
        ],
      ),
    );
  }

  /// Tab button
  Widget _buildTabButton(
    String label,
    int index,
    AdminController controller,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Obx(
        () => GestureDetector(
          onTap: () => controller.selectTab(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: controller.selectedTabIndex.value == index
                      ? const Color(0xFF1F6FEB)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: controller.selectedTabIndex.value == index
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: controller.selectedTabIndex.value == index
                    ? const Color(0xFF1F6FEB)
                    : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Users Tab
  Widget _buildUsersTab(AdminController controller, bool isDarkMode) {
    return Obx(
      () => controller.filteredUsers.isEmpty
          ? const Center(
              child: Text('No users found'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.filteredUsers.length,
              itemBuilder: (context, index) {
                final user = controller.filteredUsers[index];
                return _buildUserCard(user, controller, isDarkMode);
              },
            ),
    );
  }

  /// User Card
  Widget _buildUserCard(AppUser user, AdminController controller, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.studentId ?? 'No ID',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: user.status == 'suspended'
                          ? Colors.red.withOpacity(0.15)
                          : Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: user.status == 'suspended' ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Department: ${user.department}',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Semester: ${user.semester}',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                'Make Admin',
                Icons.admin_panel_settings,
                Colors.green,
                () => controller.changeUserRole(user.uid, 'admin'),
              ),
              _buildActionButton(
                'Remove Admin',
                Icons.person,
                Colors.orange,
                () => controller.changeUserRole(user.uid, 'user'),
              ),
              if (user.status == 'suspended')
                _buildActionButton(
                  'Activate',
                  Icons.check_circle,
                  Colors.green,
                  () => _showConfirmDialog(
                    'Activate User',
                    'Are you sure you want to activate this user?',
                    () => controller.activateUser(user.uid),
                  ),
                )
              else
                _buildActionButton(
                  'Suspend',
                  Icons.block,
                  Colors.red,
                  () => _showConfirmDialog(
                    'Suspend User',
                    'Are you sure you want to suspend this user?',
                    () => controller.deactivateUser(user.uid),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Notes Tab
  Widget _buildNotesTab(AdminController controller, bool isDarkMode) {
    return Obx(
      () => controller.filteredNotes.isEmpty
          ? const Center(
              child: Text('No notes found'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.filteredNotes.length,
              itemBuilder: (context, index) {
                final note = controller.filteredNotes[index];
                return _buildContentCard(
                  note['title']?.toString() ?? 'Untitled',
                  note['subject']?.toString() ?? 'No Subject',
                  note['userId']?.toString() ?? 'Unknown',
                  Icons.note,
                  const Color(0xFF4CAF50),
                  () => _showConfirmDialog(
                    'Delete Note',
                    'Are you sure you want to delete this note?',
                    () => controller.deleteNote(
                      note['id']?.toString() ?? '',
                      note['userId']?.toString() ?? '',
                    ),
                  ),
                  isDarkMode,
                );
              },
            ),
    );
  }

  /// Resources Tab
  Widget _buildResourcesTab(AdminController controller, bool isDarkMode) {
    return Obx(
      () => controller.filteredResources.isEmpty
          ? const Center(
              child: Text('No resources found'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.filteredResources.length,
              itemBuilder: (context, index) {
                final resource = controller.filteredResources[index];
                return _buildContentCard(
                  resource['title']?.toString() ?? 'Untitled',
                  resource['type']?.toString() ?? 'Unknown Type',
                  resource['userId']?.toString() ?? 'Unknown',
                  Icons.folder,
                  const Color(0xFFFF9800),
                  () => _showConfirmDialog(
                    'Delete Resource',
                    'Are you sure you want to delete this resource?',
                    () => controller.deleteResource(
                      resource['id']?.toString() ?? '',
                      resource['userId']?.toString() ?? '',
                    ),
                  ),
                  isDarkMode,
                );
              },
            ),
    );
  }

  /// Content Card (for notes and resources)
  Widget _buildContentCard(
    String title,
    String subtitle,
    String userId,
    IconData icon,
    Color color,
    VoidCallback onDelete,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'By: $userId',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildActionButton(
                'Delete',
                Icons.delete,
                Colors.red,
                onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Action button
  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }

  /// Show confirmation dialog
  void _showConfirmDialog(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
      textCancel: 'Cancel',
      textConfirm: 'Confirm',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }
}
