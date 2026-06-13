import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

/// Controller for admin user management.
/// Handles loading all users, viewing user-specific content,
/// and activating/suspending user accounts.
class UserManagementController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  // All registered users
  var allUsers = <AppUser>[].obs;
  var isLoading = false.obs;

  // The user currently selected by the admin to inspect
  var selectedUser = Rx<AppUser?>(null);

  // Content belonging to the selected user
  var userNotes = <Map<String, dynamic>>[].obs;
  var userAssignments = <Map<String, dynamic>>[].obs;
  var userResources = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllUsers();
  }

  // ────────────────────────────────────────────────
  // USER LIST
  // ────────────────────────────────────────────────

  /// Load all registered users from Firestore's 'users' collection.
  Future<void> loadAllUsers() async {
    try {
      isLoading.value = true;

      final usersSnapshot = await _firestore.collection('users').get();

      // Map each Firestore document to an AppUser object
      allUsers.value = usersSnapshot.docs.map((doc) {
        return AppUser.fromMap(doc.id, doc.data());
      }).toList();

      print('DEBUG: Loaded ${allUsers.length} users');
    } catch (e) {
      print('ERROR: Failed to load users: $e');
      Get.snackbar('Error', 'Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }

  // ────────────────────────────────────────────────
  // USER SELECTION & CONTENT LOADING
  // ────────────────────────────────────────────────

  /// Select a user and immediately load their content.
  void selectUser(AppUser user) {
    selectedUser.value = user;
    loadUserContent(user.uid);
  }

  /// Load all content (notes, assignments, resources) for a specific user.
  /// Each collection is filtered by the user's UID using the 'userId' field.
  Future<void> loadUserContent(String userId) async {
    try {
      isLoading.value = true;

      // Run all three queries in parallel for performance
      await Future.wait([
        loadUserNotes(userId),
        loadUserAssignments(userId),
        loadUserResources(userId),
      ]);

      print('DEBUG: Loaded content for user: $userId');
    } catch (e) {
      print('ERROR: Failed to load user content: $e');
      Get.snackbar('Error', 'Failed to load user content');
    } finally {
      isLoading.value = false;
    }
  }

  // ────────────────────────────────────────────────
  // CONTENT QUERIES (filtered by userId)
  // ────────────────────────────────────────────────

  /// Load notes uploaded by a specific user.
  /// Firestore query: notes WHERE userId == selectedUser.uid
  Future<void> loadUserNotes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId) // Filter by userId
          .get();

      userNotes.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID for delete operations
        return data;
      }).toList();

      print('DEBUG: Loaded ${userNotes.length} notes for user: $userId');
    } catch (e) {
      print('ERROR: Failed to load user notes: $e');
      userNotes.value = [];
    }
  }

  /// Load assignments created by a specific user.
  /// Firestore query: assignments WHERE userId == selectedUser.uid
  Future<void> loadUserAssignments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('assignments')
          .where('userId', isEqualTo: userId) // Filter by userId
          .get();

      userAssignments.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID for delete operations
        return data;
      }).toList();

      print(
          'DEBUG: Loaded ${userAssignments.length} assignments for user: $userId');
    } catch (e) {
      print('ERROR: Failed to load user assignments: $e');
      userAssignments.value = [];
    }
  }

  /// Load resources saved by a specific user.
  /// Firestore query: resources WHERE userId == selectedUser.uid
  Future<void> loadUserResources(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('resources')
          .where('userId', isEqualTo: userId) // Filter by userId
          .get();

      userResources.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID for delete operations
        return data;
      }).toList();

      print(
          'DEBUG: Loaded ${userResources.length} resources for user: $userId');
    } catch (e) {
      print('ERROR: Failed to load user resources: $e');
      userResources.value = [];
    }
  }

  // ────────────────────────────────────────────────
  // ACCOUNT MANAGEMENT
  // ────────────────────────────────────────────────

  /// Activate a user account — sets 'status' to 'active' in Firestore.
  Future<void> activateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'active',
      });

      Get.snackbar('Success', 'User activated successfully');

      // Reload list to reflect the new status
      await loadAllUsers();

      // If this is the currently selected user, update their object too
      if (selectedUser.value?.uid == userId) {
        selectedUser.value = selectedUser.value?.copyWith(status: 'active');
      }
    } catch (e) {
      print('ERROR: Failed to activate user: $e');
      Get.snackbar('Error', 'Failed to activate user');
    }
  }

  /// Suspend a user account — sets 'status' to 'suspended' in Firestore.
  Future<void> suspendUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'suspended',
      });

      Get.snackbar('Success', 'User suspended successfully');

      // Reload list to reflect the new status
      await loadAllUsers();

      // If this is the currently selected user, update their object too
      if (selectedUser.value?.uid == userId) {
        selectedUser.value = selectedUser.value?.copyWith(status: 'suspended');
      }
    } catch (e) {
      print('ERROR: Failed to suspend user: $e');
      Get.snackbar('Error', 'Failed to suspend user');
    }
  }

  // ────────────────────────────────────────────────
  // CONTENT REMOVAL (Admin can remove inappropriate content)
  // ────────────────────────────────────────────────

  /// Delete an inappropriate note by its document ID.
  Future<void> deleteNote(String noteId, String userId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
      Get.snackbar('Success', 'Note deleted successfully');
      // Refresh note list for this user
      await loadUserNotes(userId);
    } catch (e) {
      print('ERROR: Failed to delete note: $e');
      Get.snackbar('Error', 'Failed to delete note');
    }
  }

  /// Delete an inappropriate assignment by its document ID.
  Future<void> deleteAssignment(String assignmentId, String userId) async {
    try {
      await _firestore.collection('assignments').doc(assignmentId).delete();
      Get.snackbar('Success', 'Assignment deleted successfully');
      // Refresh assignment list for this user
      await loadUserAssignments(userId);
    } catch (e) {
      print('ERROR: Failed to delete assignment: $e');
      Get.snackbar('Error', 'Failed to delete assignment');
    }
  }

  /// Delete an inappropriate resource by its document ID.
  Future<void> deleteResource(String resourceId, String userId) async {
    try {
      await _firestore.collection('resources').doc(resourceId).delete();
      Get.snackbar('Success', 'Resource deleted successfully');
      // Refresh resource list for this user
      await loadUserResources(userId);
    } catch (e) {
      print('ERROR: Failed to delete resource: $e');
      Get.snackbar('Error', 'Failed to delete resource');
    }
  }

  // ────────────────────────────────────────────────
  // REFRESH
  // ────────────────────────────────────────────────

  /// Refresh all users and reload current user content (if any selected).
  Future<void> refreshData() async {
    await loadAllUsers();
    if (selectedUser.value != null) {
      await loadUserContent(selectedUser.value!.uid);
    }
  }
}
