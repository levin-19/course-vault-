import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user_service.dart';
import '../services/database_service.dart';

class LoginController extends GetxController {
  // Reactive variables
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final rememberMe = false.obs;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Empty fields - user must enter credentials (no demo pre-fill)
    emailController.text = '';
    passwordController.text = '';
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  // Handle login
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading(true);
      
      final databaseService = DatabaseService.to;
      final userService = UserService.to;
      
      // Validate credentials against Firestore
      final isValidUser = await databaseService.validateCredentials(
        emailController.text,
        passwordController.text,
      );

      if (!isValidUser) {
        Get.snackbar('Error', 'Invalid email or password. Please sign up first.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Credentials are valid, set user session
      userService.setCurrentUserId(emailController.text);
      userService.setCurrentUser(emailController.text);

      // Navigate to home screen
      Get.offAllNamed('/home');

      Get.snackbar('Success', 'Login successful',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // Toggle remember me
  void toggleRememberMe() {
    rememberMe.toggle();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
