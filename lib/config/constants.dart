/// Application Constants
/// Central place for all static strings, lists, and values used throughout the app

class AppConstants {
  AppConstants._(); // Private constructor

  // ============ University Data ============
  /// List of supported universities with their domains and departments
  static const Map<String, UniversityData> universities = {
    'harvard.edu': UniversityData(
      name: 'Harvard University',
      domain: 'harvard.edu',
      departments: [
        'Engineering',
        'Arts and Sciences',
        'Business',
        'Law',
        'Medicine',
        'Public Health',
      ],
    ),
    'mit.edu': UniversityData(
      name: 'Massachusetts Institute of Technology',
      domain: 'mit.edu',
      departments: [
        'Engineering',
        'Science',
        'Architecture and Planning',
        'Business',
        'Humanities',
      ],
    ),
    'stanford.edu': UniversityData(
      name: 'Stanford University',
      domain: 'stanford.edu',
      departments: [
        'Engineering',
        'Business',
        'Law',
        'Medicine',
        'Humanities and Sciences',
      ],
    ),
    'berkeley.edu': UniversityData(
      name: 'UC Berkeley',
      domain: 'berkeley.edu',
      departments: [
        'Engineering',
        'Science',
        'Business',
        'Law',
        'Haas School of Business',
      ],
    ),
    'caltech.edu': UniversityData(
      name: 'California Institute of Technology',
      domain: 'caltech.edu',
      departments: [
        'Engineering and Applied Science',
        'Science',
        'Medical Engineering',
        'Computing',
      ],
    ),
    'yale.edu': UniversityData(
      name: 'Yale University',
      domain: 'yale.edu',
      departments: [
        'School of Engineering and Applied Science',
        'School of the Arts',
        'School of Management',
        'School of Medicine',
      ],
    ),
    'columbia.edu': UniversityData(
      name: 'Columbia University',
      domain: 'columbia.edu',
      departments: [
        'School of Engineering and Applied Science',
        'School of the Arts',
        'Business School',
        'School of Medicine',
      ],
    ),
    'upenn.edu': UniversityData(
      name: 'University of Pennsylvania',
      domain: 'upenn.edu',
      departments: [
        'School of Engineering',
        'Wharton School',
        'School of Arts and Sciences',
        'School of Medicine',
      ],
    ),
  };

  // ============ Semester/Year Options ============
  static const List<String> semesters = [
    'Spring Semester',
    'Summer Semester',
    'Fall Semester',
    'Winter Break',
  ];

  static const List<int> yearOptions = [
    2024,
    2025,
    2026,
    2027,
  ];

  // ============ Student ID Format ============
  static const String studentIdPattern = '[0-9]{8,10}';

  // ============ Validation Messages ============
  static const String emailRequiredError = 'Email is required';
  static const String emailInvalidError = 'Please enter a valid email';
  static const String universitySupportError =
      'Please use a supported university email domain';
  static const String passwordRequiredError = 'Password is required';
  static const String passwordWeakError =
      'Password must be at least 8 characters';
  static const String passwordMismatchError = 'Passwords do not match';
  static const String nameRequiredError = 'Full name is required';
  static const String studentIdRequiredError = 'Student ID is required';
  static const String studentIdInvalidError = 'Student ID must be 8-10 digits';
  static const String departmentRequiredError = 'Please select a department';
  static const String semesterRequiredError = 'Please select a semester';
  static const String termsRequiredError =
      'Please accept the terms and conditions';

  // ============ Password Requirements ============
  static const int minimumPasswordLength = 8;
  static bool isValidPassword(String password) {
    return password.length >= minimumPasswordLength;
  }

  // ============ App Strings ============
  static const String appName = 'CourseVault';
  static const String appTagline = 'Your Complete Academic Companion';
  static const String secureAccessFooter =
      'Secure student access • Protected data';

  // ============ Social Auth Providers ============
  static const String googleAuthProvider = 'google';
  static const String universityEmailProvider = 'university';

  // ============ Terms and Privacy ============
  static const String termsLink = 'https://coursevault.edu/terms';
  static const String privacyLink = 'https://coursevault.edu/privacy';
}

/// University Data Model
class UniversityData {
  final String name;
  final String domain;
  final List<String> departments;

  const UniversityData({
    required this.name,
    required this.domain,
    required this.departments,
  });

  @override
  String toString() => name;
}

/// Helper to extract university from email
class UniversityHelper {
  static UniversityData? getUniversityFromEmail(String email) {
    final domain = email.split('@').last.toLowerCase();
    return AppConstants.universities[domain];
  }

  static String? getUniversityDomain(String email) {
    try {
      return email.split('@').last.toLowerCase();
    } catch (_) {
      return null;
    }
  }

  static bool isUniversityEmailValid(String email) {
    final domain = getUniversityDomain(email);
    return domain != null && AppConstants.universities.containsKey(domain);
  }
}
