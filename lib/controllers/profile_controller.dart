import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user_service.dart';
import '../services/database_service.dart';

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

  @override
  void onReady() {
    super.onReady();
    // Reload data when screen comes into view
    loadProfileData();
  }

  // Load profile data from Firebase
  Future<void> loadProfileData() async {
    try {
      isLoading(true);
      // Get current user ID from UserService
      final userService = UserService.to;
      final userId = userService.currentUserId.value;
      
      if (userId.isEmpty) {
        Get.snackbar('Error', 'User not logged in',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      // Fetch user data from Firestore
      final databaseService = DatabaseService.to;
      var userData = await databaseService.getUserProfile(userId);
      
      // If profile doesn't exist, show message
      if (userData == null) {
        Get.snackbar('Info', 'Please complete your profile by signing up',
            snackPosition: SnackPosition.BOTTOM);
        // Initialize with empty profile
        userData = {
          'fullName': '',
          'email': userService.currentUserEmail.value,
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
        };
      }
      
      // Update userProfile with data from Firestore
      Map<String, dynamic> profileData = {
        'fullName': userData['fullName'] ?? '',
        'email': userData['email'] ?? '',
        'studentId': userData['studentId'] ?? '',
        'university': userData['university'] ?? 'FAST University',
        'department': userData['department'] ?? '',
        'programType': userData['programType'] ?? '',
        'semester': userData['semester'] ?? '',
        'batch': userData['batch'] ?? '',
        'phone': userData['phone'] ?? '',
        'cgpa': userData['cgpa'] ?? 0.0,
        'joinDate': userData['joinDate'] ?? DateTime.now().toString().split(' ')[0],
        'profileImageUrl': userData['profileImageUrl'],
      };
      
      userProfile(profileData);
      
      // Initialize controllers with profile data
      fullNameController.text = profileData['fullName']?.toString() ?? '';
      emailController.text = profileData['email']?.toString() ?? '';
      studentIdController.text = profileData['studentId']?.toString() ?? '';
      phoneController.text = profileData['phone']?.toString() ?? '';
      cgpaController.text = profileData['cgpa']?.toString() ?? '';
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
      
      // Get current user ID
      final userService = UserService.to;
      final userId = userService.currentUserId.value;
      
      if (userId.isEmpty) {
        Get.snackbar('Error', 'User not logged in',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      // Create updated profile map
      Map<String, dynamic> updatedProfile = Map.from(userProfile);
      updatedProfile.addAll({
        'fullName': fullNameController.text,
        'email': emailController.text,
        'studentId': studentIdController.text,
        'phone': phoneController.text,
        'cgpa': double.tryParse(cgpaController.text) ?? 0.0,
      });
      
      // Save to Firestore
      final databaseService = DatabaseService.to;
      await databaseService.updateUserProfile(
        userId: userId,
        updates: {
          'fullName': fullNameController.text,
          'email': emailController.text,
          'studentId': studentIdController.text,
          'phone': phoneController.text,
          'cgpa': double.tryParse(cgpaController.text) ?? 0.0,
        },
      );
      
      // Update local state
      userProfile(updatedProfile);
      
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
      
      // Clear user session from UserService
      final userService = UserService.to;
      userService.logout();
      
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
