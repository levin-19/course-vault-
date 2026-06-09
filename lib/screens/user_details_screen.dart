import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_management_controller.dart';

/// Screen to display selected user's details and content
class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key});

  static const routeName = '/user-details';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserManagementController>();
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: const Color(0xFF1F6FEB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'activate',
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Activate User'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'suspend',
                child: const Row(
                  children: [
                    Icon(Icons.block, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Suspend User'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (controller.selectedUser.value != null) {
                if (value == 'activate') {
                  _showActivateDialog(controller, controller.selectedUser.value!.uid);
                } else if (value == 'suspend') {
                  _showSuspendDialog(controller, controller.selectedUser.value!.uid);
                }
              }
            },
          ),
        ],
      ),
      body: Obx(
        () => controller.selectedUser.value == null
            ? const Center(child: Text('No user selected'))
            : controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Profile Card
                        _buildUserProfile(controller, isDarkMode),
                        const SizedBox(height: 24),

                        // User's Notes Section
                        _buildContentSection(
                          'Notes',
                          Icons.note,
                          const Color(0xFF4CAF50),
                          controller.userNotes,
                          'note',
                          controller,
                          isDarkMode,
                        ),
                        const SizedBox(height: 24),

                        // User's Assignments Section
                        _buildContentSection(
                          'Assignments',
                          Icons.assignment,
                          const Color(0xFFFF9800),
                          controller.userAssignments,
                          'assignment',
                          controller,
                          isDarkMode,
                        ),
                        const SizedBox(height: 24),

                        // User's Resources Section
                        _buildContentSection(
                          'Resources',
                          Icons.folder,
                          const Color(0xFF9C27B0),
                          controller.userResources,
                          'resource',
                          controller,
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  /// User Profile Card
  Widget _buildUserProfile(UserManagementController controller, bool isDarkMode) {
    final user = controller.selectedUser.value!;

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
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProfileInfo('Student ID', user.studentId ?? 'N/A'),
              Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
              _buildProfileInfo('Department', user.department ?? 'N/A'),
              Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
              _buildProfileInfo('Semester', user.semester?.toString() ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Content Section (Notes, Assignments, Resources)
  Widget _buildContentSection(
    String title,
    IconData icon,
    Color color,
    RxList<Map<String, dynamic>> contentList,
    String contentType,
    UserManagementController controller,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(
                () => Text(
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
        Obx(
          () => contentList.isEmpty
              ? Container(
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
                          'No $title',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contentList.length,
                  itemBuilder: (context, index) {
                    final item = contentList[index];
                    return _buildContentItem(
                      item,
                      color,
                      contentType,
                      controller,
                      isDarkMode,
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Content Item Card
  Widget _buildContentItem(
    Map<String, dynamic> item,
    Color color,
    String contentType,
    UserManagementController controller,
    bool isDarkMode,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
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
            if (item['subject'] != null)
              Text(
                'Subject: ${item['subject']}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            if (item['course'] != null)
              Text(
                'Course: ${item['course']}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
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
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(
            Icons.more_vert,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: const Row(
                children: [
                  Icon(Icons.visibility, size: 18),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
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

  /// Show content details dialog
  void _showContentDetailsDialog(Map<String, dynamic> item, String contentType) {
    Get.defaultDialog(
      title: item['title'] ?? 'Content Details',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['subject'] != null) Text('Subject: ${item['subject']}'),
            if (item['course'] != null) Text('Course: ${item['course']}'),
            if (item['description'] != null) ...[
              const SizedBox(height: 8),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(item['description']),
            ],
          ],
        ),
      ),
      textConfirm: 'Close',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteDialog(UserManagementController controller, String contentId, String contentType) {
    Get.defaultDialog(
      title: 'Delete Content',
      content: const Text('Are you sure you want to delete this content?'),
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        final userId = controller.selectedUser.value?.uid ?? '';
        if (contentType == 'note') {
          controller.deleteNote(contentId, userId);
        } else if (contentType == 'assignment') {
          controller.deleteAssignment(contentId, userId);
        } else if (contentType == 'resource') {
          controller.deleteResource(contentId, userId);
        }
        Get.back();
      },
    );
  }

  /// Show activate user dialog
  void _showActivateDialog(UserManagementController controller, String userId) {
    Get.defaultDialog(
      title: 'Activate User',
      content: const Text('Are you sure you want to activate this user?'),
      textCancel: 'Cancel',
      textConfirm: 'Activate',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        controller.activateUser(userId);
        Get.back();
      },
    );
  }

  /// Show suspend user dialog
  void _showSuspendDialog(UserManagementController controller, String userId) {
    Get.defaultDialog(
      title: 'Suspend User',
      content: const Text('Are you sure you want to suspend this user?'),
      textCancel: 'Cancel',
      textConfirm: 'Suspend',
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () {
        controller.suspendUser(userId);
        Get.back();
      },
    );
  }
}
