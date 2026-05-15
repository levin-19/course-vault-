import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user_service.dart';

class ProfileController extends GetxController {
  // Reactive variables
  final isLoading = false.obs;
  final isEditing = false.obs;

  // User profile data - Static (now editable)
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final studentIdController = TextEditingController();
  final phoneController = TextEditingController();
  final cgpaController = TextEditingController();

  final userProfile = {
    'fullName': '',
    'email': '',
    'studentId': '',
    'university': 'FAST University',
    'department': '',
    'programType': '',
    'semester': '',
    'batch': '',
    'phone': '',
    'cgpa': 0.0,
    'joinDate': DateTime.now().toString().split(' ')[0],
    'profileImageUrl': null,
  }.obs;

  final settingsItems = [
    {
      'title': 'Edit Profile',
      'subtitle': 'Update your personal information',
      'icon': 'edit',
      'action': 'edit_profile',
    },
    {
      'title': 'Change Password',
      'subtitle': 'Update your security settings',
      'icon': 'lock',
      'action': 'change_password',
    },
    {
      'title': 'Theme Settings',
      'subtitle': 'Choose dark or light mode',
      'icon': 'theme',
      'action': 'theme',
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  // Load profile data from UserService
  Future<void> loadProfileData() async {
    try {
      isLoading(true);
      // Get user data from UserService
      final userService = UserService.to;
      final userData = userService.getUserData();
      
      // Update userProfile with data from UserService
      userProfile(userData);
      
      // Initialize controllers with profile data
      fullNameController.text = userData['fullName']?.toString() ?? '';
      emailController.text = userData['email']?.toString() ?? '';
      studentIdController.text = userData['studentId']?.toString() ?? '';
      phoneController.text = userData['phone']?.toString() ?? '';
      cgpaController.text = userData['cgpa']?.toString() ?? '';
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // Toggle edit mode
  void toggleEditMode() {
    isEditing.toggle();
  }

  // Save profile changes
  Future<void> saveProfile() async {
    try {
      isLoading(true);
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Create a new map with updated values
      final updatedProfile = {
        ...userProfile.value,
        'fullName': fullNameController.text,
        'email': emailController.text,
        'studentId': studentIdController.text,
        'phone': phoneController.text,
        'cgpa': double.tryParse(cgpaController.text) ?? 0.0,
      };
      
      // Reassign the entire map to trigger reactivity
      userProfile(updatedProfile);
      
      // Also update UserService
      final userService = UserService.to;
      userService.updateField('fullName', fullNameController.text);
      userService.updateField('email', emailController.text);
      userService.updateField('studentId', studentIdController.text);
      userService.updateField('phone', phoneController.text);
      userService.updateField('cgpa', double.tryParse(cgpaController.text) ?? 0.0);
      
      isEditing(false);
      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // Cancel editing
  void cancelEdit() {
    // Reset controllers to original values
    fullNameController.text = userProfile['fullName'].toString();
    emailController.text = userProfile['email'].toString();
    studentIdController.text = userProfile['studentId'].toString();
    phoneController.text = userProfile['phone'].toString();
    cgpaController.text = userProfile['cgpa'].toString();
    isEditing(false);
  }

  // Handle settings action
  void handleSettingsAction(String action) {
    switch (action) {
      case 'edit_profile':
        toggleEditMode();
        break;
      case 'change_password':
        Get.snackbar('Change Password', 'Change password feature coming soon',
            snackPosition: SnackPosition.BOTTOM);
        break;
      case 'theme':
        Get.snackbar('Theme', 'Theme settings coming soon',
            snackPosition: SnackPosition.BOTTOM);
        break;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      isLoading(true);
      // Simulate logout
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Clear user data from UserService
      final userService = UserService.to;
      userService.clearUserData();
      
      Get.offAllNamed('/login');
      Get.snackbar('Success', 'Logged out successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    studentIdController.dispose();
    phoneController.dispose();
    cgpaController.dispose();
    super.onClose();
  }
}
