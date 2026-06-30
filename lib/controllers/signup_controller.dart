import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/user_service.dart';

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

  /// Form key used by [SignupScreen] to trigger field-level validation.
  final formKey = GlobalKey<FormState>();

  // Profile image
  final profileImagePath = Rxn<String>();
  final _picker = ImagePicker();

  /// Opens the image gallery to pick a profile photo.
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Clears the locally selected image path.
  void removeProfileImage() {
    profileImagePath.value = null;
  }

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
    // Validate all TextFormFields via AppValidators
    if (!(formKey.currentState?.validate() ?? false)) return;

    // Validate dropdown selections not covered by Form fields
    if (selectedDepartment.value == null) {
      Get.snackbar('Error', 'Please select a department',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedProgramType.value == null) {
      Get.snackbar('Error', 'Please select a program type',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedSemester.value == null) {
      Get.snackbar('Error', 'Please select a semester',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!acceptTerms.value) {
      Get.snackbar('Error', 'Please accept terms and conditions',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading(true);
      
      // Create user with Firebase Authentication
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User creation succeeded but no user was returned.',
        );
      }
      final userId = user.uid;

      String? profileImageUrl;
      if (profileImagePath.value != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('$userId.jpg');
          final uploadTask = await storageRef.putFile(File(profileImagePath.value!));
          profileImageUrl = await uploadTask.ref.getDownloadURL();
        } catch (e) {
          print('Error uploading profile image: $e');
        }
      }

      final cgpaValue = double.tryParse(cgpaController.text) ?? 0.0;

      // Save user profile to Firestore — role is always 'student' on signup
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'uid': userId,
        'fullName': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'studentId': studentIdController.text.trim(),
        'phone': phoneController.text.trim(),
        'department': selectedDepartment.value ?? '',
        'programType': selectedProgramType.value ?? '',
        'semester': selectedSemester.value ?? '',
        'batch': selectedBatch.value ?? '',
        'cgpa': cgpaValue,
        'role': 'student', // every new user is a student by default
        'status': 'active',
        'profileImageUrl': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Set the current user ID in UserService
      UserService.to.setCurrentUserId(userId);

      // Navigate to home screen
      Get.offAllNamed('/home');

      Get.snackbar('Success', 'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Signup failed';
      if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for this email';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      }
      Get.snackbar('Error', errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Signup failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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
