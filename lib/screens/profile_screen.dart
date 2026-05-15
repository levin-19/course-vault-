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
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Edit/Save/Cancel Actions
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (controller.isEditing.value) ...[
                            ElevatedButton.icon(
                              onPressed: () => controller.cancelEdit(),
                              icon: const Icon(Icons.close),
                              label: const Text('Cancel'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => controller.saveProfile(),
                              icon: const Icon(Icons.check),
                              label: const Text('Save'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F6FEB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ] else
                            ElevatedButton.icon(
                              onPressed: () => controller.toggleEditMode(),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F6FEB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Academic Information (Now Editable)
                    _buildAcademicInfo(context, controller, isDarkMode),
                    const SizedBox(height: 24),

                    // Settings
                    _buildSettings(context, controller, isDarkMode),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAcademicInfo(
      BuildContext context, ProfileController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Academic Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name
                if (controller.isEditing.value)
                  _buildEditableField(
                    'Full Name',
                    controller.fullNameController,
                    Icons.person,
                  )
                else
                  _buildInfoRow(
                    'Full Name',
                    controller.userProfile['fullName'].toString(),
                    Icons.person,
                  ),
                const SizedBox(height: 20),

                // Email
                if (controller.isEditing.value)
                  _buildEditableField(
                    'Email',
                    controller.emailController,
                    Icons.email,
                  )
                else
                  _buildInfoRow(
                    'Email',
                    controller.userProfile['email'].toString(),
                    Icons.email,
                  ),
                const Divider(height: 20),

                // Student ID
                if (controller.isEditing.value)
                  _buildEditableField(
                    'Student ID',
                    controller.studentIdController,
                    Icons.badge,
                  )
                else
                  _buildInfoRow(
                    'Student ID',
                    controller.userProfile['studentId'].toString(),
                    Icons.badge,
                  ),
                const Divider(height: 20),

                // Phone
                if (controller.isEditing.value)
                  _buildEditableField(
                    'Phone',
                    controller.phoneController,
                    Icons.phone,
                  )
                else
                  _buildInfoRow(
                    'Phone',
                    controller.userProfile['phone'].toString(),
                    Icons.phone,
                  ),
                const Divider(height: 20),

                // Department (Read-only)
                _buildInfoRow(
                  'Department',
                  controller.userProfile['department'].toString(),
                  Icons.school,
                ),
                const Divider(height: 20),

                // Program Type (Read-only)
                _buildInfoRow(
                  'Program Type',
                  controller.userProfile['programType'].toString(),
                  Icons.book,
                ),
                const Divider(height: 20),

                // Semester (Read-only)
                _buildInfoRow(
                  'Semester',
                  'Semester ${controller.userProfile['semester'].toString()}',
                  Icons.calendar_today,
                ),
                const Divider(height: 20),

                // Batch (Read-only)
                _buildInfoRow(
                  'Batch',
                  controller.userProfile['batch'].toString(),
                  Icons.date_range,
                ),
                const Divider(height: 20),

                // CGPA
                if (controller.isEditing.value)
                  _buildEditableField(
                    'CGPA',
                    controller.cgpaController,
                    Icons.trending_up,
                    keyboardType: TextInputType.number,
                  )
                else
                  _buildInfoRow(
                    'CGPA',
                    controller.userProfile['cgpa'].toString(),
                    Icons.trending_up,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1F6FEB)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettings(
      BuildContext context, ProfileController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            ...controller.settingsItems.map((setting) {
              return GestureDetector(
                onTap: () =>
                    controller.handleSettingsAction(setting['action'].toString()),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F6FEB).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getSettingIcon(setting['icon'].toString()),
                          color: const Color(0xFF1F6FEB),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              setting['title'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              setting['subtitle'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Logout Button
            GestureDetector(
              onTap: () => _showLogoutConfirmation(context, controller),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Logout',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign out from your account',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutConfirmation(
      BuildContext context, ProfileController controller) {
    Get.defaultDialog(
      title: 'Logout',
      content: const Text('Are you sure you want to logout?'),
      textCancel: 'Cancel',
      textConfirm: 'Logout',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        controller.logout();
      },
    );
  }

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
