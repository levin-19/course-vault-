import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

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

  // Hardcoded admin credentials
  static const String ADMIN_EMAIL = 'admin@coursevault.com';
  static const String ADMIN_PASSWORD = 'admin123';

  // Handle login
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading(true);
      
      // Check for hardcoded admin credentials first
      if (emailController.text.trim() == ADMIN_EMAIL &&
          passwordController.text == ADMIN_PASSWORD) {
        // Admin login - navigate directly to admin dashboard
        Get.snackbar('Success', 'Admin login successful!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        
        // Navigate to admin dashboard
        Get.offAllNamed('/admin-dashboard');
        return;
      }
      
      // Regular student login with Firebase Authentication
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Set the current user ID in UserService
      UserService.to.setCurrentUserId(userCredential.user!.uid);

      // Navigate to home screen for students
      Get.offAllNamed('/home');

      Get.snackbar('Success', 'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled';
      }
      Get.snackbar('Error', errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Login failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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
