import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  static const routeName = '/signup';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Personal Information
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Full Name
            TextField(
              controller: controller.fullNameController,
              decoration: InputDecoration(
                hintText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),

            // Student ID
            TextField(
              controller: controller.studentIdController,
              decoration: InputDecoration(
                hintText: 'Student ID',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),

            // Email
            TextField(
              controller: controller.emailController,
              decoration: InputDecoration(
                hintText: 'University Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),

            // Phone
            TextField(
              controller: controller.phoneController,
              decoration: InputDecoration(
                hintText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Academic Information
            Text(
              'Academic Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Department Dropdown
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedDepartment.value,
                decoration: InputDecoration(
                  hintText: 'Select Department',
                  prefixIcon: const Icon(Icons.school_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                ),
                items: controller.departments
                    .map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        ))
                    .toList(),
                onChanged: (value) => controller.selectedDepartment(value),
              ),
            ),
            const SizedBox(height: 12),

            // Program Type Dropdown
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedProgramType.value,
                decoration: InputDecoration(
                  hintText: 'Select Program Type',
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                ),
                items: controller.programTypes
                    .map((program) => DropdownMenuItem(
                          value: program,
                          child: Text(program),
                        ))
                    .toList(),
                onChanged: controller.onProgramTypeChanged,
              ),
            ),
            const SizedBox(height: 12),

            // Semester Dropdown
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedSemester.value,
                decoration: InputDecoration(
                  hintText: 'Select Semester',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: controller.selectedProgramType.value == null
                      ? Colors.grey[300]
                      : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                ),
                items: controller.getAvailableSemesters()
                    .map((sem) => DropdownMenuItem(
                          value: sem,
                          child: Text('Semester $sem'),
                        ))
                    .toList(),
                onChanged: controller.selectedProgramType.value == null
                    ? null
                    : (value) => controller.selectedSemester(value),
              ),
            ),
            const SizedBox(height: 12),

            // Batch
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedBatch.value,
                decoration: InputDecoration(
                  hintText: 'Select Batch',
                  prefixIcon: const Icon(Icons.date_range),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                ),
                items: controller.batches
                    .map((batch) => DropdownMenuItem(
                          value: batch,
                          child: Text(batch),
                        ))
                    .toList(),
                onChanged: (value) => controller.selectedBatch(value),
              ),
            ),
            const SizedBox(height: 12),

            // CGPA (Optional)
            TextField(
              controller: controller.cgpaController,
              decoration: InputDecoration(
                hintText: 'CGPA (Optional)',
                prefixIcon: const Icon(Icons.grade_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Section 3: Security
            Text(
              'Security',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Password with Strength Indicator
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller.passwordController,
                    obscureText: !controller.isPasswordVisible.value,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Password Strength Indicator
                  LinearProgressIndicator(
                    value: controller.passwordStrength.value / 5,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      controller.passwordStrength.value < 2
                          ? Colors.red
                          : controller.passwordStrength.value < 4
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Password Strength: ${_getPasswordStrengthText(controller.passwordStrength.value)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Confirm Password with Mismatch Detection
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller.confirmPasswordController,
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isConfirmPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed:
                            controller.toggleConfirmPasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: controller.showPasswordMismatch.value
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    ),
                  ),
                  if (controller.showPasswordMismatch.value)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              size: 16, color: Colors.red),
                          SizedBox(width: 4),
                          Text(
                            'Passwords do not match',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Terms & Conditions Checkbox
            Obx(
              () => Row(
                children: [
                  Checkbox(
                    value: controller.acceptTerms.value,
                    onChanged: (_) => controller.toggleAcceptTerms(),
                    activeColor: const Color(0xFF1F6FEB),
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(color: Colors.black87),
                          ),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              color: Color(0xFF1F6FEB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Up Button
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.signup(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F6FEB),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                GestureDetector(
                  onTap: () => Get.toNamed('/login'),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFF1F6FEB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
      case 3:
        return 'Medium';
      case 4:
      case 5:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }
}
