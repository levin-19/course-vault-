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

  // Hardcoded admin credentials (same as LoginController)
  static const String _adminEmail = 'admin@coursevault.com';

  /// Load admin profile data
  Future<void> _loadAdminProfile() async {
    isLoading.value = true;

    try {
      // Check if this is the hardcoded admin (no Firebase account needed)
      final currentUser = _firebaseAuth.currentUser;
      final sessionEmail = _userService.getCurrentUserEmail();

      if (sessionEmail == _adminEmail) {
        // Hardcoded admin — set profile directly, no Firestore check needed
        isAdmin.value = true;
        adminName.value = 'Administrator';
        adminEmail.value = _adminEmail;
        adminPhone.value = 'Not set';
        adminRole.value = 'Super Admin';
        joinDate.value = 'N/A';
        await _loadAdminStats();
        isLoading.value = false;
        return;
      }

      // Firebase user admin check (for future Firebase-based admins)
      if (currentUser == null) {
        Get.snackbar('Error', 'User not authenticated');
        isLoading.value = false;
        return;
      }

      String userId = _userService.getCurrentUserId();
      if (userId.isEmpty) {
        userId = currentUser.uid;
        _userService.setCurrentUserId(userId);
      }

      bool adminStatus = await _databaseService.checkIfAdmin(userId);
      isAdmin.value = adminStatus;

      if (!adminStatus) {
        Get.snackbar('Unauthorized', 'You do not have admin privileges');
        isLoading.value = false;
        return;
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        adminName.value = data['fullName'] ?? 'Admin';
        adminEmail.value = data['email'] ?? currentUser.email ?? '';
        adminPhone.value = data['phone'] ?? 'Not set';

        if (data['createdAt'] != null) {
          final timestamp = data['createdAt'] as Timestamp;
          final date = timestamp.toDate();
          joinDate.value = '${date.day}/${date.month}/${date.year}';
        } else {
          joinDate.value = 'N/A';
        }
      }

      await _loadAdminStats();
      isLoading.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load admin profile');
      isLoading.value = false;
    }
  }

  /// Load admin statistics from real Firestore data
  Future<void> _loadAdminStats() async {
    try {
      final users = await _databaseService.getAllUsers();
      managedUsers.value = users.length;

      // Count notes platform-wide
      final notesSnapshot =
          await _firestore.collection('notes').get();
      reviewedNotes.value = notesSnapshot.docs.length;

      // We track deletedContent as 0 unless we log it separately
      deletedContent.value = 0;

      totalActions.value =
          managedUsers.value + reviewedNotes.value + deletedContent.value;
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

  /// Logout — clears session and navigates to login.
  /// For hardcoded admin there is no Firebase session, so we only clear UserService.
  Future<void> logout() async {
    try {
      // Clear the stored session email (works for both admin and Firebase users)
      _userService.logout();

      // Only sign out from Firebase if there is an active Firebase session
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.signOut();
      }

      Get.offAllNamed('/login');
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      print('ERROR: Failed to logout: $e');
      Get.snackbar('Error', 'Failed to logout');
    }
  }
}
