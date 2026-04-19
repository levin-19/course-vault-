import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

/// Modern Registration Screen with student-specific features
/// Enhanced with university email, student ID, department, and semester selection
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String routeName = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedDepartment;
  String? _selectedSemester;
  bool _acceptTerms = false;
  PasswordStrength _passwordStrength = PasswordStrength.empty;
  UniversityData? _detectedUniversity;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle email change to validate email format
  void _onEmailChanged(String email) {
    setState(() {
      // Check if email format is valid
      if (FormValidators.validateEmail(email) != null) {
        // Clear selections if email format is invalid
        _detectedUniversity = null;
        _selectedDepartment = null;
      }
    });
  }

  /// Handle password change to update strength indicator
  void _onPasswordChanged(String password) {
    setState(() {
      _passwordStrength = FormValidators.getPasswordStrength(password);
    });
  }

  Future<void> _signUp() async {
    final AuthProvider authProvider = context.read<AuthProvider>();

    if (!_formKey.currentState!.validate()) return;

    final bool success = await authProvider.signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Show success animation/message
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

  /// Show success animation
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
                  'Success!',
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
    final departments = _detectedUniversity?.departments ?? [];

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
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Header
                      Text(
                        'Join CourseVault',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      const Text(
                        'Start managing your academic life today',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingXXL),

                      // Full Name
                      CustomTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.person_outline,
                        hint: 'John Doe',
                        validator: FormValidators.validateFullName,
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Student ID
                      CustomTextField(
                        label: 'Student ID',
                        controller: _studentIdController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.badge_outlined,
                        hint: '12345678',
                        validator: FormValidators.validateStudentId,
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Email
                      CustomTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.email_outlined,
                        hint: 'your.email@example.com',
                        validator: FormValidators.validateEmail,
                        onChanged: _onEmailChanged,
                      ),
                      const SizedBox(height: AppTheme.spacingM),

                      // University Detection Message (optional - only shown if valid email and university found)
                      if (_detectedUniversity != null)
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: AppColors.infoLight,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(
                              color: AppColors.info.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                                size: 18,
                              ),
                              const SizedBox(width: AppTheme.spacingM),
                              Expanded(
                                child: Text(
                                  'Detected: ${_detectedUniversity!.name}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Department Dropdown (only show if university detected)
                      if (_detectedUniversity != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdownField<String>(
                              label: 'Department',
                              items: departments,
                              hint: 'Select your department',
                              value: _selectedDepartment,
                              prefixIcon: Icons.business_outlined,
                              onChanged: (value) {
                                setState(() => _selectedDepartment = value);
                              },
                              validator: (value) =>
                                  FormValidators.validateDropdown(
                                value,
                                'department',
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingL),
                          ],
                        ),

                      // Semester Dropdown
                      CustomDropdownField<String>(
                        label: 'Current Semester',
                        items: AppConstants.semesters,
                        hint: 'Select semester',
                        value: _selectedSemester,
                        prefixIcon: Icons.calendar_month_outlined,
                        onChanged: (value) {
                          setState(() => _selectedSemester = value);
                        },
                        validator: (value) =>
                            FormValidators.validateDropdown(value, 'semester'),
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.lock_outlined,
                        hint: 'At least 8 characters',
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
                        label: 'Confirm Password',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_outlined,
                        validator: (value) =>
                            FormValidators.validatePasswordMatch(
                          _passwordController.text,
                          value,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXL),

                      // Terms & Conditions Checkbox
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

                      // Sign Up Button
                      PrimaryButton(
                        label: 'Create Account',
                        isLoading: authProvider.isLoading,
                        onPressed: _signUp,
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Divider
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

                      // Google Sign Up
                      SocialAuthButton(
                        label: 'Sign up with Google',
                        icon: Icons.search,
                        onPressed: _handleGoogleAuth,
                      ),
                      const SizedBox(height: AppTheme.spacingXXL),

                      // Login Link
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
