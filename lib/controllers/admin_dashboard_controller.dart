import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../services/user_service.dart';
import '../models/app_user.dart';

class AdminDashboardController extends GetxController {
  final _databaseService = DatabaseService.to;
  final _userService = UserService.to;
  final _firebaseAuth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var isAdmin = false.obs;

  // Statistics
  var totalUsers = 0.obs;
  var totalNotes = 0.obs;
  var totalAssignments = 0.obs;
  var totalResources = 0.obs;
  var totalExams = 0.obs;

  // Recent users
  var recentUsers = <AppUser>[].obs;

  // Recent content
  var recentNotes = <Map<String, dynamic>>[].obs;
  var recentResources = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAdminDashboard();
  }

  /// Initialize admin dashboard
  Future<void> _initializeAdminDashboard() async {
    isLoading.value = true;

    try {
      // For hardcoded admin login, no Firebase user exists
      // Just set admin status to true and load data
      isAdmin.value = true;

      // Load dashboard data
      await _loadDashboardData();

      isLoading.value = false;
    } catch (e) {
      print('ERROR: Failed to initialize admin dashboard: $e');
      Get.snackbar('Error', 'Failed to load admin dashboard');
      isLoading.value = false;
    }
  }

  /// Load all dashboard data
  Future<void> _loadDashboardData() async {
    try {
      // Load all users
      final users = await _databaseService.getAllUsers();
      totalUsers.value = users.length;
      recentUsers.value = users.take(5).toList();

      // Load notes (mock data for now - replace with actual)
      totalNotes.value = 45;
      
      // Load assignments (mock data)
      totalAssignments.value = 28;
      
      // Load resources (mock data)
      totalResources.value = 32;
      
      // Load exams (mock data)
      totalExams.value = 12;

      print('DEBUG: Dashboard data loaded successfully');
    } catch (e) {
      print('ERROR: Failed to load dashboard data: $e');
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await _loadDashboardData();
    Get.snackbar('Success', 'Dashboard refreshed');
  }

  /// Navigate to Manage Users
  void navigateToUserManagement() {
    Get.toNamed('/admin');
  }

  /// Navigate to Admin Profile
  void navigateToAdminProfile() {
    Get.toNamed('/admin-profile');
  }

  /// Navigate to specific content section
  void navigateToContent(String contentType) {
    Get.toNamed('/admin');
  }

  /// View user details
  void viewUserDetails(AppUser user) {
    Get.defaultDialog(
      title: 'User Details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Name: ${user.fullName}'),
          Text('Email: ${user.email}'),
          Text('Student ID: ${user.studentId ?? 'N/A'}'),
          Text('Department: ${user.department ?? 'N/A'}'),
        ],
      ),
    );
  }

  /// Suspend user
  Future<void> suspendUser(String userId) async {
    try {
      await _databaseService.deactivateUser(userId);
      await refreshDashboard();
      Get.back();
      Get.snackbar('Success', 'User suspended successfully');
    } catch (e) {
      print('ERROR: Failed to suspend user: $e');
      Get.snackbar('Error', 'Failed to suspend user');
    }
  }

  /// Activate user
  Future<void> activateUser(String userId) async {
    try {
      await _databaseService.updateUserRole(userId, 'user');
      await refreshDashboard();
      Get.back();
      Get.snackbar('Success', 'User activated successfully');
    } catch (e) {
      print('ERROR: Failed to activate user: $e');
      Get.snackbar('Error', 'Failed to activate user');
    }
  }

  /// Delete content
  Future<void> deleteContent(String contentId, String contentType, String userId) async {
    try {
      if (contentType == 'note') {
        await _databaseService.deleteNote(contentId, userId);
      } else if (contentType == 'resource') {
        await _databaseService.deleteResource(contentId, userId);
      }
      await refreshDashboard();
      Get.snackbar('Success', 'Content deleted successfully');
    } catch (e) {
      print('ERROR: Failed to delete content: $e');
      Get.snackbar('Error', 'Failed to delete content');
    }
  }
}
