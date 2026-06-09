import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/database_service.dart';
import '../services/user_service.dart';

class AdminController extends GetxController {
  final _databaseService = DatabaseService.to;
  final _userService = UserService.to;
  final _firebaseAuth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var isAdmin = false.obs;

  // Observable for all users
  var allUsers = <AppUser>[].obs;

  // Observable for all notes across the system
  var allNotes = <Map<String, dynamic>>[].obs;

  // Observable for all resources across the system
  var allResources = <Map<String, dynamic>>[].obs;

  // Tab index for navigation
  var selectedTabIndex = 0.obs;

  // Filter and search
  var searchQuery = ''.obs;
  var filteredUsers = <AppUser>[].obs;
  var filteredNotes = <Map<String, dynamic>>[].obs;
  var filteredResources = <Map<String, dynamic>>[].obs;

  // Statistics
  var totalUsers = 0.obs;
  var totalNotes = 0.obs;
  var totalResources = 0.obs;

  // Store subscriptions for cleanup
  late StreamSubscription _usersSubscription;
  late StreamSubscription _notesSubscription;
  late StreamSubscription _resourcesSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeAdmin();
  }

  /// Initialize admin dashboard by verifying admin role and setting up streams
  Future<void> _initializeAdmin() async {
    isLoading.value = true;

    try {
      // Get current user ID
      String userId = _userService.getCurrentUserId();
      if (userId.isEmpty) {
        userId = _firebaseAuth.currentUser?.uid ?? '';
        if (userId.isNotEmpty) {
          _userService.setCurrentUserId(userId);
          print('DEBUG: Retrieved user ID from Firebase Auth: $userId');
        }
      }

      if (userId.isEmpty) {
        print('ERROR: No user ID found');
        Get.snackbar('Error', 'User not authenticated');
        isLoading.value = false;
        return;
      }

      // Verify if current user is admin
      bool adminStatus = await _databaseService.checkIfAdmin(userId);
      isAdmin.value = adminStatus;

      if (!adminStatus) {
        print('ERROR: User is not an admin');
        Get.snackbar('Unauthorized', 'You do not have admin privileges');
        isLoading.value = false;
        return;
      }

      print('DEBUG: Admin verified, loading data...');

      // Set up real-time streams for all data
      _setupUserStream();
      _setupNotesStream();
      _setupResourcesStream();

      isLoading.value = false;
    } catch (e) {
      print('ERROR: Failed to initialize admin: $e');
      Get.snackbar('Error', 'Failed to load admin dashboard');
      isLoading.value = false;
    }
  }

  /// Set up stream for all users
  void _setupUserStream() {
    _usersSubscription = _databaseService.getAllUsersStream().listen(
      (users) {
        allUsers.value = users;
        totalUsers.value = users.length;
        updateFilteredUsers();
        print('DEBUG: Loaded ${users.length} users');
      },
      onError: (e) {
        print('ERROR: Failed to load users: $e');
        Get.snackbar('Error', 'Failed to load users');
      },
    );
  }

  /// Set up stream for all notes
  void _setupNotesStream() {
    _notesSubscription = _databaseService.getAllNotesStream().listen(
      (notes) {
        allNotes.value = notes;
        totalNotes.value = notes.length;
        updateFilteredNotes();
        print('DEBUG: Loaded ${notes.length} notes');
      },
      onError: (e) {
        print('ERROR: Failed to load notes: $e');
        Get.snackbar('Error', 'Failed to load notes');
      },
    );
  }

  /// Set up stream for all resources
  void _setupResourcesStream() {
    _resourcesSubscription = _databaseService.getAllResourcesStream().listen(
      (resources) {
        allResources.value = resources;
        totalResources.value = resources.length;
        updateFilteredResources();
        print('DEBUG: Loaded ${resources.length} resources');
      },
      onError: (e) {
        print('ERROR: Failed to load resources: $e');
        Get.snackbar('Error', 'Failed to load resources');
      },
    );
  }

  /// Update filtered users based on search query
  void updateFilteredUsers() {
    if (searchQuery.isEmpty) {
      filteredUsers.value = allUsers;
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredUsers.value = allUsers
          .where((user) =>
              user.fullName.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.studentId?.toLowerCase().contains(query) == true)
          .toList();
    }
  }

  /// Update filtered notes based on search query
  void updateFilteredNotes() {
    if (searchQuery.isEmpty) {
      filteredNotes.value = allNotes;
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredNotes.value = allNotes
          .where((note) =>
              note['title']?.toString().toLowerCase().contains(query) == true ||
              note['subject']?.toString().toLowerCase().contains(query) == true ||
              note['userId']?.toString().toLowerCase().contains(query) == true)
          .toList();
    }
  }

  /// Update filtered resources based on search query
  void updateFilteredResources() {
    if (searchQuery.isEmpty) {
      filteredResources.value = allResources;
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredResources.value = allResources
          .where((resource) =>
              resource['title']?.toString().toLowerCase().contains(query) == true ||
              resource['type']?.toString().toLowerCase().contains(query) == true ||
              resource['userId']?.toString().toLowerCase().contains(query) == true)
          .toList();
    }
  }

  /// Update search query and filter results
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    updateFilteredUsers();
    updateFilteredNotes();
    updateFilteredResources();
  }

  /// Change user role (make admin or regular user)
  Future<void> changeUserRole(String userId, String newRole) async {
    try {
      await _databaseService.updateUserRole(userId, newRole);
      Get.snackbar('Success', 'User role updated to $newRole');

      // Refresh users list
      _setupUserStream();
    } catch (e) {
      print('ERROR: Failed to change user role: $e');
      Get.snackbar('Error', 'Failed to update user role');
    }
  }

  /// Delete a note from the system
  Future<void> deleteNote(String noteId, String userId) async {
    try {
      await _databaseService.deleteNote(noteId, userId);
      allNotes.removeWhere((note) => note['id'] == noteId);
      totalNotes.value = allNotes.length;
      updateFilteredNotes();
      Get.snackbar('Success', 'Note deleted successfully');
    } catch (e) {
      print('ERROR: Failed to delete note: $e');
      Get.snackbar('Error', 'Failed to delete note');
    }
  }

  /// Delete a resource from the system
  Future<void> deleteResource(String resourceId, String userId) async {
    try {
      await _databaseService.deleteResource(resourceId, userId);
      allResources.removeWhere((resource) => resource['id'] == resourceId);
      totalResources.value = allResources.length;
      updateFilteredResources();
      Get.snackbar('Success', 'Resource deleted successfully');
    } catch (e) {
      print('ERROR: Failed to delete resource: $e');
      Get.snackbar('Error', 'Failed to delete resource');
    }
  }

  /// Deactivate/ban a user
  Future<void> deactivateUser(String userId) async {
    try {
      await _databaseService.deactivateUser(userId);
      allUsers.removeWhere((user) => user.uid == userId);
      totalUsers.value = allUsers.length;
      updateFilteredUsers();
      Get.snackbar('Success', 'User deactivated');
    } catch (e) {
      print('ERROR: Failed to deactivate user: $e');
      Get.snackbar('Error', 'Failed to deactivate user');
    }
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    isLoading.value = true;
    try {
      // Cancel existing subscriptions
      _usersSubscription.cancel();
      _notesSubscription.cancel();
      _resourcesSubscription.cancel();

      // Restart streams
      _setupUserStream();
      _setupNotesStream();
      _setupResourcesStream();

      Get.snackbar('Success', 'Data refreshed');
    } catch (e) {
      print('ERROR: Failed to refresh data: $e');
      Get.snackbar('Error', 'Failed to refresh data');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update selected tab
  void selectTab(int index) {
    selectedTabIndex.value = index;
  }

  @override
  void onClose() {
    _usersSubscription.cancel();
    _notesSubscription.cancel();
    _resourcesSubscription.cancel();
    super.onClose();
  }
}
