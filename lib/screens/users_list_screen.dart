import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_management_controller.dart';
import '../models/app_user.dart';

/// Screen to display all registered users
class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  static const routeName = '/users-list';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Users Management'),
        backgroundColor: const Color(0xFF1F6FEB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadAllUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: controller.loadAllUsers,
                child: controller.allUsers.isEmpty
                    ? _buildEmptyState(isDarkMode)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.allUsers.length,
                        itemBuilder: (context, index) {
                          final user = controller.allUsers[index];
                          return _buildUserCard(context, controller, user, isDarkMode);
                        },
                      ),
              ),
      ),
    );
  }

  /// Empty state when no users found
  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Users Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Users will appear here once registered',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// User card widget
  Widget _buildUserCard(
    BuildContext context,
    UserManagementController controller,
    AppUser user,
    bool isDarkMode,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF1F6FEB).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          controller.selectUser(user);
          Get.toNamed('/user-details');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF1F6FEB).withOpacity(0.1),
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Color(0xFF1F6FEB),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ID: ${user.studentId ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.department ?? 'No Department',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status Badge & Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
