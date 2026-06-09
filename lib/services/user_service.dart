import 'package:get/get.dart';

class UserService extends GetxService {
  static UserService get to => Get.put(UserService());

  // Track logged-in user
  final currentUserId = ''.obs;
  final currentUserEmail = ''.obs;

  // Set current user session
  void setCurrentUser(String email) {
    currentUserEmail(email);
  }

  // Set user ID
  void setCurrentUserId(String userId) {
    currentUserId(userId);
  }

  // Get current user email
  String getCurrentUserEmail() => currentUserEmail.value;

  // Get current user ID
  String getCurrentUserId() => currentUserId.value;

  // Clear user data on logout
  void logout() {
    currentUserId('');
    currentUserEmail('');
  }
}
