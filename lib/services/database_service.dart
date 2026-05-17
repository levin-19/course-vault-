import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DatabaseService extends GetxService {
  static DatabaseService get to => Get.find();

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
}
