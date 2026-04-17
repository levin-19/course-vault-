import '../config/constants.dart';

/// Validation utilities for form fields across the app
class FormValidators {
  // Private constructor - use static methods only
  FormValidators._();

  // ============ Email Validation ============
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.emailRequiredError;
    }

    final String email = value.trim().toLowerCase();
    final bool isValid = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);

    if (!isValid) {
      return AppConstants.emailInvalidError;
    }

    return null;
  }

  static String? validateUniversityEmail(String? value) {
    final emailError = validateEmail(value);
    if (emailError != null) return emailError;

    if (!UniversityHelper.isUniversityEmailValid(value ?? '')) {
      return AppConstants.universitySupportError;
    }

    return null;
  }

  // ============ Password Validation ============
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequiredError;
    }

    if (value.length < AppConstants.minimumPasswordLength) {
      return '${AppConstants.passwordWeakError} (currently ${value.length})';
    }

    return null;
  }

  static String? validatePasswordMatch(
      String? password, String? confirmPassword) {
    if (password != confirmPassword) {
      return AppConstants.passwordMismatchError;
    }
    return null;
  }

  // ============ Name Validation ============
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.nameRequiredError;
    }

    final String name = value.trim();
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (name.length > 100) {
      return 'Name cannot exceed 100 characters';
    }

    return null;
  }

  // ============ Student ID Validation ============
  static String? validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.studentIdRequiredError;
    }

    final String studentId = value.trim();
    final bool isValid = RegExp(r'^[0-9]{8,10}$').hasMatch(studentId);

    if (!isValid) {
      return AppConstants.studentIdInvalidError;
    }

    return null;
  }

  // ============ Dropdown Validation ============
  static String? validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please select a $fieldName';
    }
    return null;
  }

  // ============ Checkbox Validation ============
  static String? validateCheckbox(bool? value, String fieldName) {
    if (value != true) {
      return 'Please accept the $fieldName';
    }
    return null;
  }

  // ============ Password Strength Indicator ============
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 6) return PasswordStrength.weak;
    if (password.length < 8) return PasswordStrength.fair;
    if (_hasStrongCharacteristics(password)) return PasswordStrength.strong;
    return PasswordStrength.good;
  }

  static bool _hasStrongCharacteristics(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return (hasUppercase && hasLowercase && hasNumbers) ||
        (hasSpecialChars && hasNumbers && hasUppercase);
  }
}

/// Password strength enumeration
enum PasswordStrength {
  empty,
  weak,
  fair,
  good,
  strong;

  String get label {
    switch (this) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'Too weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  int get percentFilled {
    switch (this) {
      case PasswordStrength.empty:
        return 0;
      case PasswordStrength.weak:
        return 25;
      case PasswordStrength.fair:
        return 50;
      case PasswordStrength.good:
        return 75;
      case PasswordStrength.strong:
        return 100;
    }
  }
}
