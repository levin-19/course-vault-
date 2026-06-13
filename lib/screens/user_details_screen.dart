import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_management_controller.dart';

/// Screen showing selected user's profile info and their uploaded content.
///
/// Navigation flow:
///   Admin Dashboard → Users List → (tap user) → User Details
///
/// Content shown here is filtered by the selected user's UID:
///   - Notes:       notes WHERE userId == selectedUser.uid
///   - Assignments: assignments WHERE userId == selectedUser.uid
///   - Resources:   resources WHERE userId == selectedUser.uid
class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key});

  static const routeName = '/user-details';

  @override
  Widget build(BuildContext context) {
    // Find the existing UserManagementController (created in UsersListScreen)
    final controller = Get.find<UserManagementController>();
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: const Color(0xFF1F6FEB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Action menu for account management
          Obx(() {
            final user = controller.selectedUser.value;
            if (user == null) return const SizedBox.shrink();
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'activate',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 20, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Activate User'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'suspend',
                  child: Row(
                    children: [
                      Icon(Icons.block, size: 20, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Suspend User'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'activate') {
                  _showActivateDialog(controller, user.uid);
                } else if (value == 'suspend') {
                  _showSuspendDialog(controller, user.uid);
                }
              },
            );
          }),
        ],
      ),
      body: Obx(
        () => controller.selectedUser.value == null
            ? const Center(
                child: Text(
                  'No user selected.\nGo back and select a user.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── User Profile Card ─────────────────────────────────
                        _buildUserProfile(controller, isDarkMode),
                        const SizedBox(height: 24),

                        // ── Notes Section ─────────────────────────────────────
                        _buildContentSection(
                          title: 'Notes',
                          icon: Icons.note,
                          color: const Color(0xFF4CAF50),
                          contentList: controller.userNotes,
                          contentType: 'note',
                          controller: controller,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 24),

                        // ── Assignments Section ───────────────────────────────
                        _buildContentSection(
                          title: 'Assignments',
                          icon: Icons.assignment,
                          color: const Color(0xFFFF9800),
                          contentList: controller.userAssignments,
                          contentType: 'assignment',
                          controller: controller,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 24),

                        // ── Resources Section ─────────────────────────────────
                        _buildContentSection(
                          title: 'Resources',
                          icon: Icons.folder,
                          color: const Color(0xFF9C27B0),
                          contentList: controller.userResources,
                          contentType: 'resource',
                          controller: controller,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // User Profile Header Card
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildUserProfile(
      UserManagementController controller, bool isDarkMode) {
    final user = controller.selectedUser.value!;

    // Show dynamic status badge color
    final isSuspended = user.status == 'suspended';
    final statusColor = isSuspended ? Colors.orange : const Color(0xFF4CAF50);
    final statusLabel = isSuspended ? 'Suspended' : 'Active';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F6FEB), Color(0xFF5E35B1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with first letter of name
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Full Name
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          // Status badge (shows 'Active' or 'Suspended')
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor, width: 1.5),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Student info row (ID / Department / Semester)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn('Student ID', user.studentId ?? 'N/A'),
              Container(
                  width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
              _buildInfoColumn('Department', user.department ?? 'N/A'),
              Container(
                  width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
              _buildInfoColumn('Semester', user.semester?.toString() ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  /// Small column used inside the profile card
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Content Section (Notes / Assignments / Resources)
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildContentSection({
    required String title,
    required IconData icon,
    required Color color,
    required RxList<Map<String, dynamic>> contentList,
    required String contentType,
    required UserManagementController controller,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            // Count badge
            Obx(
              () => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${contentList.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Content items or empty state
        Obx(
          () => contentList.isEmpty
              ? _buildEmptyContent(title, icon, color, isDarkMode)
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contentList.length,
                  itemBuilder: (context, index) {
                    return _buildContentItem(
                      item: contentList[index],
                      color: color,
                      contentType: contentType,
                      controller: controller,
                      isDarkMode: isDarkMode,
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Empty placeholder when user has no content of a given type
  Widget _buildEmptyContent(
      String title, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'No $title uploaded yet',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Single Content Item Card
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildContentItem({
    required Map<String, dynamic> item,
    required Color color,
    required String contentType,
    required UserManagementController controller,
    required bool isDarkMode,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Content icon
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            contentType == 'note'
                ? Icons.note
                : contentType == 'assignment'
                    ? Icons.assignment
                    : Icons.folder,
            color: color,
            size: 18,
          ),
        ),
        title: Text(
          item['title'] ?? 'Untitled',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Show subject if available (notes)
            if (item['subject'] != null)
              Text(
                'Subject: ${item['subject']}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            // Show course if available (assignments)
            if (item['course'] != null)
              Text(
                'Course: ${item['course']}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            // Show description snippet (notes)
            if (item['description'] != null)
              Text(
                item['description'],
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            // Show URL for resources
            if (item['url'] != null)
              Text(
                item['url'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1F6FEB),
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        // View / Delete popup actions
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'view') {
              _showContentDetailsDialog(item, contentType);
            } else if (value == 'delete') {
              _showDeleteDialog(controller, item['id'], contentType);
            }
          },
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Dialogs
  // ────────────────────────────────────────────────────────────────────────────

  /// View full content details in a dialog
  void _showContentDetailsDialog(
      Map<String, dynamic> item, String contentType) {
    Get.defaultDialog(
      title: item['title'] ?? 'Content Details',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item['subject'] != null)
              Text('Subject: ${item['subject']}'),
            if (item['course'] != null)
              Text('Course: ${item['course']}'),
            if (item['url'] != null) ...[
              const SizedBox(height: 8),
              const Text('URL:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(item['url'],
                  style: const TextStyle(color: Color(0xFF1F6FEB))),
            ],
            if (item['description'] != null) ...[
              const SizedBox(height: 8),
              const Text('Description:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(item['description']),
            ],
            if (item['content'] != null) ...[
              const SizedBox(height: 8),
              const Text('Content:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(item['content']),
            ],
          ],
        ),
      ),
      textConfirm: 'Close',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  /// Delete confirmation dialog for content removal
  void _showDeleteDialog(
      UserManagementController controller, String contentId, String contentType) {
    Get.defaultDialog(
      title: 'Delete Content',
      content: const Text(
          'Are you sure you want to delete this content?\nThis action cannot be undone.'),
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        final userId = controller.selectedUser.value?.uid ?? '';
        // Call the appropriate delete method based on content type
        if (contentType == 'note') {
          controller.deleteNote(contentId, userId);
        } else if (contentType == 'assignment') {
          controller.deleteAssignment(contentId, userId);
        } else if (contentType == 'resource') {
          controller.deleteResource(contentId, userId);
        }
        Get.back(); // Close dialog
      },
    );
  }

  /// Activate user confirmation dialog
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
        Get.back();
        controller.activateUser(userId);
      },
    );
  }

  /// Suspend user confirmation dialog
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
        Get.back();
        controller.suspendUser(userId);
      },
    );
  }
}
