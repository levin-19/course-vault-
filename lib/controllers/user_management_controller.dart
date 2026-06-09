import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

/// Controller for managing users and viewing user-specific content
class UserManagementController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  // All users list
  var allUsers = <AppUser>[].obs;
  var isLoading = false.obs;

  // Selected user for viewing details
  var selectedUser = Rx<AppUser?>(null);

  // User-specific content
  var userNotes = <Map<String, dynamic>>[].obs;
  var userAssignments = <Map<String, dynamic>>[].obs;
  var userResources = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllUsers();
  }

  /// Load all registered users from Firestore
  Future<void> loadAllUsers() async {
    try {
      isLoading.value = true;

      final usersSnapshot = await _firestore.collection('users').get();

      allUsers.value = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return AppUser.fromMap(doc.id, data);
      }).toList();

      print('DEBUG: Loaded ${allUsers.length} users');
    } catch (e) {
      print('ERROR: Failed to load users: $e');
      Get.snackbar('Error', 'Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }

  /// Select a user to view their details and content
  void selectUser(AppUser user) {
    selectedUser.value = user;
    loadUserContent(user.uid);
  }

  /// Load content specific to the selected user
  Future<void> loadUserContent(String userId) async {
    try {
      isLoading.value = true;

      // Load user's notes
      await loadUserNotes(userId);

      // Load user's assignments
      await loadUserAssignments(userId);

      // Load user's resources
      await loadUserResources(userId);

      print('DEBUG: Loaded content for user: $userId');
    } catch (e) {
      print('ERROR: Failed to load user content: $e');
      Get.snackbar('Error', 'Failed to load user content');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load notes uploaded by specific user
  Future<void> loadUserNotes(String userId) async {
    try {
      final notesSnapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .get();

      userNotes.value = notesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      print('DEBUG: Loaded ${userNotes.length} notes for user: $userId');
    } catch (e) {
      print('ERROR: Failed to load user notes: $e');
      userNotes.value = [];
    }
  }

  /// Load assignments created by specific user
  Future<void> loadUserAssignments(String userId) async {
    try {
      final assignmentsSnapshot = await _firestore
          .collection('assignments')
          .where('userId', isEqualTo: userId)
          .get();

      userAssignments.value = assignmentsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      print('DEBUG: Loaded ${userAssignments.length} assignments for user: $userId');
    } catch (e) {
      print('ERROR: Failed to load user assignments: $e');
      userAssignments.value = [];
    }
  }

  /// Load resources saved by specific user
  Future<void> loadUserResources(String userId) async {
    try {
      final resourcesSnapshot = await _firestore
          .collection('resources')
          .where('userId', isEqualTo: userId)
          .get();

      userResources.value = resourcesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      print('DEBUG: Loaded ${userResources.length} resources for user: $userId');
    } catch (e) {
      print('ERROR: Failed to load user resources: $e');
      userResources.value = [];
    }
  }

  /// Activate user account
  Future<void> activateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'active',
      });

      Get.snackbar('Success', 'User activated successfully');
      await loadAllUsers();
    } catch (e) {
      print('ERROR: Failed to activate user: $e');
      Get.snackbar('Error', 'Failed to activate user');
    }
  }

  /// Suspend user account
  Future<void> suspendUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'suspended',
      });

      Get.snackbar('Success', 'User suspended successfully');
      await loadAllUsers();
    } catch (e) {
      print('ERROR: Failed to suspend user: $e');
      Get.snackbar('Error', 'Failed to suspend user');
    }
  }

  /// Delete inappropriate note
  Future<void> deleteNote(String noteId, String userId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();

      Get.snackbar('Success', 'Note deleted successfully');
      await loadUserNotes(userId);
    } catch (e) {
      print('ERROR: Failed to delete note: $e');
      Get.snackbar('Error', 'Failed to delete note');
    }
  }

  /// Delete inappropriate assignment
  Future<void> deleteAssignment(String assignmentId, String userId) async {
    try {
      await _firestore.collection('assignments').doc(assignmentId).delete();

      Get.snackbar('Success', 'Assignment deleted successfully');
      await loadUserAssignments(userId);
    } catch (e) {
      print('ERROR: Failed to delete assignment: $e');
      Get.snackbar('Error', 'Failed to delete assignment');
    }
  }

  /// Delete inappropriate resource
  Future<void> deleteResource(String resourceId, String userId) async {
    try {
      await _firestore.collection('resources').doc(resourceId).delete();

      Get.snackbar('Success', 'Resource deleted successfully');
      await loadUserResources(userId);
    } catch (e) {
      print('ERROR: Failed to delete resource: $e');
      Get.snackbar('Error', 'Failed to delete resource');
    }
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await loadAllUsers();
    if (selectedUser.value != null) {
      await loadUserContent(selectedUser.value!.uid);
    }
  }
}
