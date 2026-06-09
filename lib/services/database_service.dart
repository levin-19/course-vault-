import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import '../models/app_user.dart';

class DatabaseService extends GetxService {
  static DatabaseService get to => Get.put(DatabaseService());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user profile to Firestore
  Future<void> saveUserProfile({
    required String userId,
    required String fullName,
    required String email,
    required String studentId,
    required String phone,
    required String department,
    required String programType,
    required String semester,
    required String batch,
    required double cgpa,
    required String password,
    String? profileImagePath, // optional
  }) async {
    try {
      final data = <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'studentId': studentId,
        'phone': phone,
        'department': department,
        'programType': programType,
        'semester': semester,
        'batch': batch,
        'cgpa': cgpa,
        'password': password,
        'university': 'FAST University',
        'joinDate': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (profileImagePath != null) {
        data['profileImageUrl'] = profileImagePath;
      }
      await _firestore.collection('users').doc(userId).set(data);
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Delete user profile from Firestore
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // Stream user profile (real-time updates)
  Stream<Map<String, dynamic>?> getUserProfileStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      return doc.exists ? doc.data() : null;
    });
  }

  // Validate user credentials for login
  Future<bool> validateCredentials(String email, String password) async {
    try {
      final doc = await _firestore.collection('users').doc(email).get();
      if (doc.exists) {
        final data = doc.data();
        final storedPassword = data?['password'];
        
        // Debug: Check if password field exists
        if (storedPassword == null) {
          print('DEBUG: Password field not found for $email. Document data: $data');
          return false;
        }
        
        final isValid = storedPassword == password;
        print('DEBUG: Password validation - Input: $password, Stored: $storedPassword, Match: $isValid');
        return isValid;
      }
      print('DEBUG: No user document found for $email');
      return false;
    } catch (e) {
      print('DEBUG: Validation error: $e');
      throw Exception('Failed to validate credentials: $e');
    }
  }

  // Get user data for debugging
  Future<Map<String, dynamic>?> getUserDataForDebug(String email) async {
    try {
      final doc = await _firestore.collection('users').doc(email).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('DEBUG: Error fetching user data: $e');
      return null;
    }
  }

  // Add or update password for existing user
  Future<void> addPasswordToUser(String email, String password) async {
    try {
      await _firestore.collection('users').doc(email).update({
        'password': password,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('DEBUG: Password added/updated for $email');
    } catch (e) {
      print('DEBUG: Error adding password: $e');
      throw Exception('Failed to add password: $e');
    }
  }

  // ============ Dashboard Methods ============

  // Get all assignments for a specific user
  Future<List<Map<String, dynamic>>> getUserAssignments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('assignments')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching user assignments: $e');
      return [];
    }
  }

  // Stream of assignments for real-time updates
  Stream<List<Map<String, dynamic>>> getUserAssignmentsStream(String userId) {
    return _firestore
        .collection('assignments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Get all exams for a specific user
  Future<List<Map<String, dynamic>>> getUserExams(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('exams')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching user exams: $e');
      return [];
    }
  }

  // Stream of exams for real-time updates
  Stream<List<Map<String, dynamic>>> getUserExamsStream(String userId) {
    return _firestore
        .collection('exams')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Get all notes for a specific user
  Future<List<Map<String, dynamic>>> getUserNotes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching user notes: $e');
      return [];
    }
  }

  // Stream of notes for real-time updates
  Stream<List<Map<String, dynamic>>> getUserNotesStream(String userId) {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Get upcoming deadlines (pending assignments sorted by due date)
  Future<List<Map<String, dynamic>>> getUpcomingDeadlines(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('assignments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      final assignments = snapshot.docs.map((doc) => doc.data()).toList();

      // Sort by dueDate
      assignments.sort((a, b) {
        final dateA = DateTime.parse(a['dueDate'] ?? '');
        final dateB = DateTime.parse(b['dueDate'] ?? '');
        return dateA.compareTo(dateB);
      });

      return assignments;
    } catch (e) {
      print('Error fetching upcoming deadlines: $e');
      return [];
    }
  }

  // Stream of upcoming deadlines for real-time updates
  Stream<List<Map<String, dynamic>>> getUpcomingDeadlinesStream(
      String userId) {
    return _firestore
        .collection('assignments')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final assignments = snapshot.docs.map((doc) => doc.data()).toList();

          // Sort by dueDate
          assignments.sort((a, b) {
            final dateA = DateTime.parse(a['dueDate'] ?? '');
            final dateB = DateTime.parse(b['dueDate'] ?? '');
            return dateA.compareTo(dateB);
          });

          return assignments;
        });
  }

  // Get dashboard stats (calculated from user data)
  Stream<Map<String, dynamic>> getDashboardStatsStream(String userId) {
    // Combine data from assignments, exams, and user profile
    return rxdart.CombineLatestStream.combine3<
        List<Map<String, dynamic>>,
        List<Map<String, dynamic>>,
        Map<String, dynamic>?,
        Map<String, dynamic>>(
      getUserAssignmentsStream(userId),
      getUserExamsStream(userId),
      getUserProfileStream(userId),
      (assignments, exams, userProfile) {
        // Calculate completed and pending assignments
        final completedCount = assignments
            .where((a) => a['status'] == 'completed')
            .length;
        final pendingCount = assignments
            .where((a) => a['status'] == 'pending')
            .length;

        // Calculate upcoming exams (exams with date >= today)
        final now = DateTime.now();
        final upcomingExamCount = exams
            .where((e) {
              try {
                final examDate = DateTime.parse(e['examDate'] ?? '');
                return examDate.isAfter(now);
              } catch (e) {
                return false;
              }
            })
            .length;

        // Get GPA from user profile (default to 0 if not available)
        final gpa = userProfile?['cgpa'] ?? userProfile?['gpa'] ?? 0.0;

        return {
          'completedAssignments': completedCount,
          'pendingAssignments': pendingCount,
          'upcomingExams': upcomingExamCount,
          'gpa': gpa is String ? double.tryParse(gpa) ?? 0.0 : gpa,
        };
      },
    );
  }

  // ==================== ADMIN METHODS ====================

  /// Check if a user is an admin
  Future<bool> checkIfAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final role = doc.data()?['role'] ?? 'user';
        return role == 'admin';
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  /// Get all users (admin only)
  Future<List<AppUser>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  /// Stream of all users for real-time updates (admin only)
  Stream<List<AppUser>> getAllUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Get all notes across all users (admin only)
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    try {
      final snapshot = await _firestore.collection('notes').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching all notes: $e');
      return [];
    }
  }

  /// Stream of all notes for real-time updates (admin only)
  Stream<List<Map<String, dynamic>>> getAllNotesStream() {
    return _firestore.collection('notes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get all resources across all users (admin only)
  Future<List<Map<String, dynamic>>> getAllResources() async {
    try {
      final snapshot = await _firestore.collection('resources').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching all resources: $e');
      return [];
    }
  }

  /// Stream of all resources for real-time updates (admin only)
  Stream<List<Map<String, dynamic>>> getAllResourcesStream() {
    return _firestore.collection('resources').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Update user role (admin only)
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Delete a note from the system (admin only)
  Future<void> deleteNote(String noteId, String userId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  /// Delete a resource from the system (admin only)
  Future<void> deleteResource(String resourceId, String userId) async {
    try {
      await _firestore.collection('resources').doc(resourceId).delete();
    } catch (e) {
      throw Exception('Failed to delete resource: $e');
    }
  }

  /// Deactivate/ban a user (admin only)
  Future<void> deactivateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  /// Get user by ID (for admin profile view)
  Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }
}
