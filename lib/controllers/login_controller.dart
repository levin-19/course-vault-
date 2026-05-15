import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    // Pre-fill with demo credentials
    emailController.text = 'ss@gmail.com';
    passwordController.text = 'demo123';
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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

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
