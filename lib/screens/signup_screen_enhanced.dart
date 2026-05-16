import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/checkbox_field.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_auth_button.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

/// Enhanced Modern Registration Screen
/// Collects all required academic information for the new StudentProfile system
class SignupScreenEnhanced extends StatefulWidget {
  const SignupScreenEnhanced({super.key});

  static const String routeName = '/signup-enhanced';

  @override
  State<SignupScreenEnhanced> createState() => _SignupScreenEnhancedState();
}

class _SignupScreenEnhancedState extends State<SignupScreenEnhanced> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Personal Information Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Academic Information Controllers
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();

  // Password Controllers
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Dropdown selections
  String? _selectedDepartment;
  String? _selectedProgramType;
  String? _selectedSemester;

  // Form state
  bool _acceptTerms = false;
  bool _showPasswordMismatch = false;
  PasswordStrength _passwordStrength = PasswordStrength.empty;
  File? _selectedProfileImage;

  // Department constants
  static const Map<String, List<String>> _departmentsByUniversity = {
    'Tech University': [
      'Computer Science',
      'Information Technology',
      'Software Engineering',
      'Electrical Engineering',
      'Mechanical Engineering',
      'Civil Engineering',
      'Business Administration',
      'Finance',
      'Marketing',
      'Engineering Physics',
    ],
  };

  // Program type to semester mapping
  static const Map<String, int> _maxSemestersByProgram = {
    'Undergraduate': 8,
    'Diploma': 6,
    'Masters': 4,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _batchController.dispose();
    _cgpaController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Get list of departments available
  List<String> _getDepartments() {
    return _departmentsByUniversity['Tech University'] ?? [];
  }

  /// Get list of semesters based on program type
  List<String> _getAvailableSemesters() {
    if (_selectedProgramType == null) return [];

    final int maxSemesters =
        _maxSemestersByProgram[_selectedProgramType] ?? 8;
    return List.generate(maxSemesters, (index) => 'Semester ${index + 1}');
  }

  /// Handle program type change and reset semester if needed
  void _onProgramTypeChanged(String? value) {
    setState(() {
      _selectedProgramType = value;
      // Reset semester if it exceeds max for new program type
      if (_selectedSemester != null && value != null) {
        final maxSemesters = _maxSemestersByProgram[value] ?? 8;
        final currentSemesterNum =
            int.tryParse(_selectedSemester!.replaceAll('Semester ', '')) ?? 0;
        if (currentSemesterNum > maxSemesters) {
          _selectedSemester = null;
        }
      }
    });
  }

  /// Handle password change for real-time validation
  void _onPasswordChanged(String password) {
    setState(() {
      _passwordStrength = FormValidators.getPasswordStrength(password);
      // Check if confirm password matches (if not empty)
      if (_confirmPasswordController.text.isNotEmpty) {
        _showPasswordMismatch = password != _confirmPasswordController.text;
      }
    });
  }

  /// Handle confirm password change for real-time validation
  void _onConfirmPasswordChanged(String confirmPassword) {
    setState(() {
      if (confirmPassword.isNotEmpty) {
        _showPasswordMismatch =
            _passwordController.text != confirmPassword;
      } else {
        _showPasswordMismatch = false;
      }
    });
  }

  /// Pick image from gallery or camera
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _selectedProfileImage = File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image =
                    await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _selectedProfileImage = File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Register user with all academic information
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_showPasswordMismatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final AuthProvider authProvider = context.read<AuthProvider>();

    final bool success = await authProvider.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      studentId: _studentIdController.text.trim(),
      department: _selectedDepartment ?? 'Not Selected',
      programType: _selectedProgramType ?? 'Not Selected',
      semester: _selectedSemester ?? 'Not Selected',
      batch: _batchController.text.trim(),
      phone: _phoneController.text.trim(),
      cgpa: _cgpaController.text.trim().isEmpty
          ? null
          : _cgpaController.text.trim(),
      profileImagePath: _selectedProfileImage?.path,
    );

    if (!mounted) return;

    if (success) {
      _showSuccessAnimation();
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, ProfileScreen.routeName);
        }
      });
      return;
    }

    final String message = authProvider.errorMessage ?? 'Sign up failed.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success animation after registration
  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              boxShadow: const [AppTheme.shadowLarge],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 60,
                  color: AppColors.success,
                ),
                SizedBox(height: AppTheme.spacingM),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleGoogleAuth() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-Up coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final availableSemesters = _getAvailableSemesters();
    final departments = _getDepartments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundColor,
                AppColors.backgroundColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    isSmallScreen ? AppTheme.spacingL : AppTheme.spacingXXL,
                vertical: AppTheme.spacingXL,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // ============ HEADER ============
                      Text(
                        'Join CourseVault',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      const Text(
                        'Your Academic Management Platform',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingXXL),

                      // ============ PROFILE IMAGE SECTION ============
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(bottom: AppTheme.spacingXL),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.borderLight,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            image: _selectedProfileImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedProfileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedProfileImage == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 32,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),

                      // ============ SECTION 1: PERSONAL INFORMATION ============
                      _buildSectionHeader('Personal Information'),
                      const SizedBox(height: AppTheme.spacingL),

                      CustomTextField(
                        label: 'Full Name*',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.person_outline,
                        hint: 'John Doe',
                        validator: FormValidators.validateFullName,
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      CustomTextField(
                        label: 'Student ID*',
                        controller: _studentIdController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.badge_outlined,
                        hint: '12345678',
                        validator: FormValidators.validateStudentId,
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      CustomTextField(
                        label: 'University Email*',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.email_outlined,
                        hint: 'yourname@university.edu',
                        validator: FormValidators.validateEmail,
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      CustomTextField(
                        label: 'Phone Number*',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.phone_outlined,
                        hint: '+1 (555) 123-4567',
                        validator: FormValidators.validatePhone,
                      ),
                      const SizedBox(height: AppTheme.spacingXXL),

                      // ============ SECTION 2: ACADEMIC INFORMATION ============
                      _buildSectionHeader('Academic Information'),
                      const SizedBox(height: AppTheme.spacingL),

                      // Program Type Dropdown
                      CustomDropdownField<String>(
                        label: 'Program Type*',
                        items: const ['Undergraduate', 'Diploma', 'Masters'],
                        hint: 'Select your program',
                        value: _selectedProgramType,
                        prefixIcon: Icons.school_outlined,
                        onChanged: _onProgramTypeChanged,
                        validator: (value) =>
                            FormValidators.validateDropdown(value, 'program'),
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Department Dropdown
                      CustomDropdownField<String>(
                        label: 'Department*',
                        items: departments,
                        hint: 'Select your department',
                        value: _selectedDepartment,
                        prefixIcon: Icons.business_outlined,
                        onChanged: (value) {
                          setState(() => _selectedDepartment = value);
                        },
                        validator: (value) =>
                            FormValidators.validateDropdown(value, 'department'),
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Semester Dropdown (disabled until program type selected)
                      CustomDropdownField<String>(
                        label: 'Current Semester*',
                        items: availableSemesters,
                        hint: _selectedProgramType == null
                            ? 'Select program type first'
                            : 'Select semester',
                        value: _selectedSemester,
                        enabled: _selectedProgramType != null,
                        prefixIcon: Icons.calendar_month_outlined,
                        onChanged: (value) {
                          setState(() => _selectedSemester = value);
                        },
                        validator: (value) =>
                            FormValidators.validateDropdown(value, 'semester'),
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Batch
                      CustomTextField(
                        label: 'Batch*',
                        controller: _batchController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.calendar_today_outlined,
                        hint: '2022-2026',
                        validator: FormValidators.validateBatch,
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // CGPA (Optional)
                      CustomTextField(
                        label: 'CGPA (Optional)',
                        controller: _cgpaController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.grade_outlined,
                        hint: '3.85',
                        validator: FormValidators.validateCGPA,
                      ),
                      const SizedBox(height: AppTheme.spacingXXL),

                      // ============ SECTION 3: SECURITY ============
                      _buildSectionHeader('Security'),
                      const SizedBox(height: AppTheme.spacingL),

                      CustomTextField(
                        label: 'Password*',
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.lock_outlined,
                        hint: 'Minimum 8 characters',
                        validator: FormValidators.validatePassword,
                        onChanged: _onPasswordChanged,
                      ),
                      const SizedBox(height: AppTheme.spacingM),

                      // Password Strength Indicator
                      if (_passwordStrength != PasswordStrength.empty)
                        _buildPasswordStrengthIndicator(),
                      const SizedBox(height: AppTheme.spacingL),

                      // Confirm Password
                      CustomTextField(
                        label: 'Confirm Password*',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_outlined,
                        hint: 'Re-enter your password',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm password is required';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onChanged: _onConfirmPasswordChanged,
                      ),

                      // Real-time password mismatch indicator
                      if (_showPasswordMismatch)
                        Padding(
                          padding: const EdgeInsets.only(top: AppTheme.spacingM),
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              border: Border.all(color: AppColors.error),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                                SizedBox(width: AppTheme.spacingM),
                                Text(
                                  'Passwords do not match',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: AppTheme.spacingXXL),

                      // ============ TERMS & CONDITIONS ============
                      CustomCheckboxField(
                        label: 'I agree to the',
                        link: 'Terms & Conditions',
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() => _acceptTerms = value ?? false);
                        },
                        validator: (value) =>
                            FormValidators.validateCheckbox(value, 'terms'),
                      ),
                      const SizedBox(height: AppTheme.spacingXXL),

                      // ============ SIGN UP BUTTON ============
                      PrimaryButton(
                        label: 'Create Account',
                        isLoading: authProvider.isLoading,
                        onPressed: _signUp,
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // ============ DIVIDER ============
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.spacingM,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.borderLight,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                              ),
                              child: Text(
                                'Or',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.borderLight,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // ============ GOOGLE SIGN UP ============
                      SocialAuthButton(
                        label: 'Sign up with Google',
                        icon: Icons.search,
                        onPressed: _handleGoogleAuth,
                      ),
                      const SizedBox(height: AppTheme.spacingXXL),

                      // ============ LOGIN LINK ============
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign In',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                      context,
                                      LoginScreen.routeName,
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXL),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build section header widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// Build password strength indicator widget
  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Password Strength',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              _passwordStrength.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getPasswordStrengthColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: Stack(
            children: [
              Container(
                height: 4,
                color: AppColors.lightGrey,
              ),
              Container(
                height: 4,
                width: MediaQuery.of(context).size.width *
                    (_passwordStrength.percentFilled / 100),
                color: _getPasswordStrengthColor(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get color based on password strength
  Color _getPasswordStrengthColor() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.fair:
        return AppColors.warning;
      case PasswordStrength.good:
        return Colors.amber;
      case PasswordStrength.strong:
        return AppColors.success;
      default:
        return AppColors.textHint;
    }
  }
}
