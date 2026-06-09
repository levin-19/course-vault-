import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';
import '../services/database_service.dart';

class AdminProfileController extends GetxController {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _userService = UserService.to;
  final _databaseService = DatabaseService.to;

  var isLoading = false.obs;
  var isAdmin = false.obs;

  // Admin profile data
  var adminName = ''.obs;
  var adminEmail = ''.obs;
  var adminPhone = ''.obs;
  var adminRole = 'Administrator'.obs;
  var joinDate = ''.obs;

  // Admin statistics
  var managedUsers = 0.obs;
  var reviewedNotes = 0.obs;
  var deletedContent = 0.obs;
  var totalActions = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAdminProfile();
  }

  /// Load admin profile data
  Future<void> _loadAdminProfile() async {
    isLoading.value = true;

    try {
      // Get current user
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'User not authenticated');
        isLoading.value = false;
        return;
      }

      // Get user ID
      String userId = _userService.getCurrentUserId();
      if (userId.isEmpty) {
        userId = currentUser.uid;
        _userService.setCurrentUserId(userId);
      }

      // Verify admin status
      bool adminStatus = await _databaseService.checkIfAdmin(userId);
      isAdmin.value = adminStatus;

      if (!adminStatus) {
        Get.snackbar('Unauthorized', 'You do not have admin privileges');
        isLoading.value = false;
        return;
      }

      // Load profile data from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        adminName.value = data['fullName'] ?? 'Admin';
        adminEmail.value = data['email'] ?? currentUser.email ?? '';
        adminPhone.value = data['phone'] ?? 'Not set';
        
        // Get join date
        if (data['createdAt'] != null) {
          final timestamp = data['createdAt'] as Timestamp;
          final date = timestamp.toDate();
          joinDate.value = '${date.day}/${date.month}/${date.year}';
        } else {
          joinDate.value = 'N/A';
        }
      }

      // Load admin statistics (mock data for now)
      await _loadAdminStats();

      isLoading.value = false;
    } catch (e) {
      print('ERROR: Failed to load admin profile: $e');
      Get.snackbar('Error', 'Failed to load admin profile');
      isLoading.value = false;
    }
  }

  /// Load admin statistics
  Future<void> _loadAdminStats() async {
    try {
      // Get total users
      final users = await _databaseService.getAllUsers();
      managedUsers.value = users.length;

      // Mock statistics (replace with actual data)
      reviewedNotes.value = 156;
      deletedContent.value = 23;
      totalActions.value = managedUsers.value + reviewedNotes.value + deletedContent.value;
    } catch (e) {
      print('ERROR: Failed to load admin stats: $e');
    }
  }

  /// Edit profile
  void editProfile() {
    Get.snackbar('Info', 'Edit profile feature coming soon');
  }

  /// Change password
  void changePassword() {
    Get.snackbar('Info', 'Change password feature coming soon');
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      Get.offAllNamed('/login');
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      print('ERROR: Failed to logout: $e');
      Get.snackbar('Error', 'Failed to logout');
    }
  }
}
