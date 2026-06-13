import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_management_controller.dart';
import '../models/app_user.dart';

/// Screen showing all registered users.
/// Admin can tap a user to view their full profile and content.
class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  static const routeName = '/users-list';

  @override
  Widget build(BuildContext context) {
    // Use Get.put to create the controller if it doesn't exist,
    // or reuse it if already created (e.g. from AdminDashboardController).
    final controller = Get.put(UserManagementController());
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Users Management'),
        backgroundColor: const Color(0xFF1F6FEB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Refresh button
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
                          return _buildUserCard(
                              context, controller, user, isDarkMode);
                        },
                      ),
              ),
      ),
    );
  }

  /// Shown when the users collection is empty
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
            'Users will appear here once they register',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// A card for each user in the list.
  /// Tapping it navigates to UserDetailsScreen.
  Widget _buildUserCard(
    BuildContext context,
    UserManagementController controller,
    AppUser user,
    bool isDarkMode,
  ) {
    // Determine status colors based on user.status from Firestore
    final isSuspended = user.status == 'suspended';
    final statusColor = isSuspended
        ? Colors.orange // Suspended = orange badge
        : const Color(0xFF4CAF50); // Active = green badge
    final statusLabel = isSuspended ? 'Suspended' : 'Active';

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
        // Tap card → go to UserDetailsScreen for this user
        onTap: () {
          controller.selectUser(user); // Loads user's content too
          Get.toNamed('/user-details');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ── Avatar ──────────────────────────────────
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF1F6FEB).withOpacity(0.1),
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Color(0xFF1F6FEB),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ── User Info ────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full name
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Student ID
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ID: ${user.studentId ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Department
                    Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 14,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.department ?? 'No Department',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Status Badge & Chevron ────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Dynamic status badge (reads from user.status)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: statusColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Action menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color:
                          isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    itemBuilder: (context) => [
                      // View user details
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 18),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      // Activate account
                      const PopupMenuItem(
                        value: 'activate',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 18, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Activate'),
                          ],
                        ),
                      ),
                      // Suspend account
                      const PopupMenuItem(
                        value: 'suspend',
                        child: Row(
                          children: [
                            Icon(Icons.block,
                                size: 18, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Suspend'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          // Navigate to user details
                          controller.selectUser(user);
                          Get.toNamed('/user-details');
                          break;
                        case 'activate':
                          _showActivateDialog(controller, user.uid);
                          break;
                        case 'suspend':
                          _showSuspendDialog(controller, user.uid);
                          break;
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Confirmation dialog before activating a user
  void _showActivateDialog(
      UserManagementController controller, String userId) {
    Get.defaultDialog(
      title: 'Activate User',
      content: const Text('Are you sure you want to activate this user?'),
      textCancel: 'Cancel',
      textConfirm: 'Activate',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back(); // Close dialog
        controller.activateUser(userId);
      },
    );
  }

  /// Confirmation dialog before suspending a user
  void _showSuspendDialog(
      UserManagementController controller, String userId) {
    Get.defaultDialog(
      title: 'Suspend User',
      content: const Text('Are you sure you want to suspend this user?'),
      textCancel: 'Cancel',
      textConfirm: 'Suspend',
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () {
        Get.back(); // Close dialog
        controller.suspendUser(userId);
      },
    );
  }
}
