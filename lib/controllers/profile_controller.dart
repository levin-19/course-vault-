import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';

class ProfileController extends GetxController {
  // Reactive variables
  final isLoading = false.obs;
  final isEditing = false.obs;
  final isAdmin = false.obs;

  // Profile image — UI only (picker not yet connected)
  final profileImagePath = Rxn<String>();

  /// Shows the camera icon in the UI but does NOT open a file picker.
  void pickProfileImage() {
    // TODO: integrate image_picker when backend upload is ready
  }

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
    checkAdminStatus();
  }

  @override
  void onReady() {
    super.onReady();
    loadProfileData();
    checkAdminStatus();
  }


  // Load profile data from Firebase
  Future<void> loadProfileData() async {
    try {
      isLoading(true);
      // Get current user from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        Get.snackbar('Error', 'User not logged in',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      // Fetch user data from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!doc.exists) {
        // Initialize with basic data
        Map<String, dynamic> profileData = {
          'fullName': '',
          'email': user.email ?? '',
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
        userProfile(profileData);
      } else {
        final userData = doc.data()!;
        Map<String, dynamic> profileData = {
          'fullName': userData['fullName'] ?? '',
          'email': userData['email'] ?? '',
          'studentId': userData['studentId'] ?? '',
          'university': 'FAST University',
          'department': userData['department'] ?? '',
          'programType': userData['programType'] ?? '',
          'semester': userData['semester'] ?? '',
          'batch': userData['batch'] ?? '',
          'phone': userData['phone'] ?? '',
          'cgpa': userData['cgpa'] ?? 0.0,
          'joinDate': userData['createdAt']?.toString().split(' ')[0] ?? DateTime.now().toString().split(' ')[0],
          'profileImageUrl': null,
        };
        userProfile(profileData);
        
        // Initialize controllers
        fullNameController.text = profileData['fullName']?.toString() ?? '';
        emailController.text = profileData['email']?.toString() ?? '';
        studentIdController.text = profileData['studentId']?.toString() ?? '';
        phoneController.text = profileData['phone']?.toString() ?? '';
        cgpaController.text = profileData['cgpa']?.toString() ?? '';
      }
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
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not logged in',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fullName': fullNameController.text,
        'studentId': studentIdController.text,
        'phone': phoneController.text,
        'cgpa': double.tryParse(cgpaController.text) ?? 0.0,
      });
      
      // Update local state
      Map<String, dynamic> updatedProfile = Map.from(userProfile);
      updatedProfile.addAll({
        'fullName': fullNameController.text,
        'studentId': studentIdController.text,
        'phone': phoneController.text,
        'cgpa': double.tryParse(cgpaController.text) ?? 0.0,
      });
      userProfile(updatedProfile);
      
      isEditing(false);
      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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
      
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      Get.offAllNamed('/login');
      Get.snackbar('Success', 'Logged out successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  // Check if user is admin (used only to conditionally show UI elements)
  Future<void> checkAdminStatus() async {
    try {
      // Check hardcoded admin email first from UserService
      final sessionEmail = UserService.to.getCurrentUserEmail();
      if (sessionEmail == 'admin@coursevault.com') {
        isAdmin.value = true;
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (user.email == 'admin@coursevault.com') {
        isAdmin.value = true;
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final role = doc.data()?['role'] ?? 'student';
        isAdmin.value = role == 'admin';
      }
    } catch (e) {
      // silently ignore — profile screen still works without admin check
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
