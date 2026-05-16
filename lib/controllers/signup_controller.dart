import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user_service.dart';
import '../services/database_service.dart';

class SignupController extends GetxController {
  // Form controllers
  final fullNameController = TextEditingController();
  final studentIdController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Reactive variables
  final selectedDepartment = Rxn<String>();
  final selectedProgramType = Rxn<String>();
  final selectedSemester = Rxn<String>();
  final selectedBatch = Rxn<String>();
  final cgpaController = TextEditingController();
  
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final acceptTerms = false.obs;
  final isLoading = false.obs;
  final passwordStrength = 0.obs;
  final showPasswordMismatch = false.obs;

  // Static data
  final departments = [
    'Computer Science',
    'Engineering',
    'Business Administration',
    'Medicine',
    'Law',
    'Arts',
    'Sciences',
  ].obs;

  final programTypes = [
    'Undergraduate',
    'Diploma',
    'Masters',
  ].obs;

  final batches = [
    '2022-2026',
    '2023-2027',
    '2024-2028',
    '2025-2029',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Watch password changes for strength
    passwordController.addListener(() {
      calculatePasswordStrength();
      checkPasswordMismatch();
    });
    confirmPasswordController.addListener(() {
      checkPasswordMismatch();
    });
  }

  // Get available semesters based on program type
  List<String> getAvailableSemesters() {
    final programType = selectedProgramType.value;
    if (programType == 'Undergraduate') {
      return ['1', '2', '3', '4', '5', '6', '7', '8'];
    } else if (programType == 'Diploma') {
      return ['1', '2', '3', '4', '5', '6'];
    } else if (programType == 'Masters') {
      return ['1', '2', '3', '4'];
    }
    return [];
  }

  // Calculate password strength
  void calculatePasswordStrength() {
    final password = passwordController.text;
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    passwordStrength(strength);
  }

  // Check password mismatch
  void checkPasswordMismatch() {
    showPasswordMismatch(passwordController.text != confirmPasswordController.text &&
        confirmPasswordController.text.isNotEmpty);
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.toggle();
  }

  // Toggle accept terms
  void toggleAcceptTerms() {
    acceptTerms.toggle();
  }

  // Handle program type change
  void onProgramTypeChanged(String? programType) {
    selectedProgramType(programType);
    selectedSemester(null); // Reset semester
  }

  // Handle signup
  Future<void> signup() async {
    // Validation
    if (fullNameController.text.isEmpty ||
        studentIdController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedDepartment.value == null ||
        selectedProgramType.value == null ||
        selectedSemester.value == null) {
      Get.snackbar('Error', 'Please fill all required fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!acceptTerms.value) {
      Get.snackbar('Error', 'Please accept terms and conditions',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading(true);
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Use email as userId (simple approach)
      final userId = emailController.text;
      final cgpaValue = double.tryParse(cgpaController.text) ?? 0.0;

      // Save user data to Firestore
      final databaseService = DatabaseService.to;
      await databaseService.saveUserProfile(
        userId: userId,
        fullName: fullNameController.text,
        email: emailController.text,
        studentId: studentIdController.text,
        phone: phoneController.text,
        department: selectedDepartment.value ?? '',
        programType: selectedProgramType.value ?? '',
        semester: selectedSemester.value ?? '',
        batch: selectedBatch.value ?? '',
        cgpa: cgpaValue,
        password: passwordController.text,
      );

      // Set current user session in UserService
      final userService = UserService.to;
      userService.setCurrentUserId(userId);
      userService.setCurrentUser(emailController.text);

      // Navigate to home screen
      Get.offAllNamed('/home');

      Get.snackbar('Success', 'Account created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Signup failed: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    studentIdController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    cgpaController.dispose();
    super.onClose();
  }
}
