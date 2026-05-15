import 'package:get/get.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  // Reactive user data with demo defaults
  final userData = {
    'fullName': 'Ahmed Sarim',
    'email': 'ss@gmail.com',
    'studentId': 'CS-2022-001',
    'university': 'FAST University',
    'department': 'Computer Science',
    'programType': 'Undergraduate',
    'semester': '6',
    'batch': '2022-2026',
    'phone': '+92-300-1234567',
    'cgpa': 3.85,
    'joinDate': '2022-09-01',
    'profileImageUrl': null,
  }.obs;

  // Save user data from signup
  void saveUserData({
    required String fullName,
    required String email,
    required String studentId,
    required String phone,
    required String department,
    required String programType,
    required String semester,
    required String batch,
    required double cgpa,
  }) {
    final updatedData = {
      ...userData.value,
      'fullName': fullName,
      'email': email,
      'studentId': studentId,
      'phone': phone,
      'department': department,
      'programType': programType,
      'semester': semester,
      'batch': batch,
      'cgpa': cgpa,
    };
    userData(updatedData);
  }

  // Update single field
  void updateField(String key, dynamic value) {
    final updatedData = {...userData.value, key: value};
    userData(updatedData);
  }

  // Get user data
  Map<String, dynamic> getUserData() => userData.value;

  // Clear user data on logout
  void clearUserData() {
    userData({
      'fullName': '',
      'email': '',
      'studentId': '',
      'university': 'FAST University',
      'department': '',
      'programType': '',
      'semester': '',
      'batch': '',
      'phone': '',
      'cgpa': 0.0,
      'joinDate': DateTime.now().toString().split(' ')[0],
      'profileImageUrl': null,
    });
  }
}
