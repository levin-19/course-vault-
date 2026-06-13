import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        // Store admin email in session so AdminProfileController can identify it
        UserService.to.setCurrentUser(ADMIN_EMAIL);

        Get.snackbar('Success', 'Admin login successful!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);

        Get.offAllNamed('/admin-dashboard');
        return;
      }
      
      // Regular student/admin login with Firebase Authentication
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final uid = userCredential.user!.uid;
      UserService.to.setCurrentUserId(uid);

      // Read role from Firestore to decide which dashboard to load
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        // Create basic user profile if document is missing
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'email': emailController.text.trim(),
          'role': 'student',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        Get.offAllNamed('/home');
      } else {
        final role = doc.data()?['role'];
        if (role == 'admin') {
          Get.offAllNamed('/admin-dashboard');
        } else if (role == 'student') {
          Get.offAllNamed('/home');
        } else {
          // Missing or invalid role, update database and fallback to student role
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({'role': 'student'});
          Get.offAllNamed('/home');
        }
      }

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
