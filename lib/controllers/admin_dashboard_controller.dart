import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/app_user.dart';
import '../controllers/user_management_controller.dart';

/// Controller for the Admin Dashboard screen.
/// Fetches real statistics from Firestore and provides navigation helpers.
class AdminDashboardController extends GetxController {
  // Firestore instance
  final _firestore = FirebaseFirestore.instance;

  // Loading state
  var isLoading = false.obs;

  // For hardcoded admin login, isAdmin is always true
  var isAdmin = true.obs;

  // Platform-wide statistics (real counts from Firestore)
  var totalUsers = 0.obs;
  var totalNotes = 0.obs;
  var totalAssignments = 0.obs;
  var totalResources = 0.obs;
  var totalExams = 0.obs;

  // Recent users shown in dashboard preview (latest 5)
  var recentUsers = <AppUser>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAdminDashboard();
  }

  /// Initialize the admin dashboard by loading all data
  Future<void> _initializeAdminDashboard() async {
    isLoading.value = true;

    try {
      // Load all dashboard statistics from Firestore
      await _loadDashboardData();
    } catch (e) {
      print('ERROR: Failed to initialize admin dashboard: $e');
      Get.snackbar('Error', 'Failed to load admin dashboard');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load real statistics from Firestore collections
  Future<void> _loadDashboardData() async {
    try {
      // ---- Load all users ----
      final usersSnapshot = await _firestore.collection('users').get();
      totalUsers.value = usersSnapshot.docs.length;

      // Show only the 5 most recent users in the preview section
      recentUsers.value = usersSnapshot.docs
          .map((doc) => AppUser.fromMap(doc.id, doc.data()))
          .toList()
          .take(5)
          .toList();

      // ---- Load notes count ----
      final notesSnapshot = await _firestore.collection('notes').get();
      totalNotes.value = notesSnapshot.docs.length;

      // ---- Load assignments count ----
      final assignmentsSnapshot =
          await _firestore.collection('assignments').get();
      totalAssignments.value = assignmentsSnapshot.docs.length;

      // ---- Load resources count ----
      final resourcesSnapshot = await _firestore.collection('resources').get();
      totalResources.value = resourcesSnapshot.docs.length;

      // ---- Load exams count ----
      final examsSnapshot = await _firestore.collection('exams').get();
      totalExams.value = examsSnapshot.docs.length;

      print('DEBUG: Dashboard data loaded successfully');
      print(
          '  Users: ${totalUsers.value}, Notes: ${totalNotes.value}, '
          'Assignments: ${totalAssignments.value}, '
          'Resources: ${totalResources.value}, Exams: ${totalExams.value}');
    } catch (e) {
      print('ERROR: Failed to load dashboard data: $e');
    }
  }

  /// Refresh all dashboard data (called on pull-to-refresh)
  Future<void> refreshDashboard() async {
    await _loadDashboardData();
    Get.snackbar('Success', 'Dashboard refreshed',
        snackPosition: SnackPosition.BOTTOM);
  }

  /// Navigate to Admin Profile screen
  void navigateToAdminProfile() {
    Get.toNamed('/admin-profile');
  }

  /// Navigate to Users List screen (used by content monitoring rows)
  /// Admin must select a user first before viewing their content.
  void navigateToContent(String contentType) {
    // Guide admin to pick a user first
    Get.toNamed('/users-list');
  }

  /// View user details — navigate to the full UserDetailsScreen.
  /// Uses UserManagementController to set the selected user.
  void viewUserDetails(AppUser user) {
    // Get or create the UserManagementController
    final userMgmtController = Get.put(UserManagementController());
    // Select the user and load their content
    userMgmtController.selectUser(user);
    // Navigate to the user details screen
    Get.toNamed('/user-details');
  }

  /// Suspend a user account (sets status to 'suspended' in Firestore)
  Future<void> suspendUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'suspended',
      });

      Get.back(); // Close dialog
      Get.snackbar('Success', 'User suspended successfully');

      // Refresh dashboard to reflect updated status
      await _loadDashboardData();
    } catch (e) {
      print('ERROR: Failed to suspend user: $e');
      Get.snackbar('Error', 'Failed to suspend user');
    }
  }

  /// Activate a user account (sets status to 'active' in Firestore)
  Future<void> activateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'active',
      });

      Get.snackbar('Success', 'User activated successfully');

      // Refresh dashboard to reflect updated status
      await _loadDashboardData();
    } catch (e) {
      print('ERROR: Failed to activate user: $e');
      Get.snackbar('Error', 'Failed to activate user');
    }
  }
}
