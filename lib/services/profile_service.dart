import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_user.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _usersCollection = 'users';

  Future<void> createUserProfile(AppUser user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Create comprehensive user profile with academic data
  /// Called during registration to save all student information
  Future<void> createUserProfileWithAcademicData({
    required String uid,
    required String name,
    required String email,
    required String studentId,
    required String department,
    required String programType,
    required String semester,
    required String batch,
    required String phone,
    double? cgpa,
    String? profileImagePath,
  }) async {
    try {
      String? profileImageUrl;

      // Upload profile image if provided
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        try {
          final Reference ref =
              _storage.ref().child('profile_images').child('$uid.jpg');
          await ref.putFile(File(profileImagePath));
          profileImageUrl = await ref.getDownloadURL();
        } catch (e) {
          print('Profile image upload failed: $e');
          // Continue without image
        }
      }

      // Create student profile document
      final Map<String, dynamic> profileData = {
        'uid': uid,
        'fullName': name,
        'email': email,
        'studentId': studentId,
        'department': department,
        'programType': programType,
        'semester': semester,
        'batch': batch,
        'phone': phone,
        'cgpa': cgpa,
        'profileImageUrl': profileImageUrl,
        'university': 'Tech University', // Can be dynamic based on email domain
        'isVerified': false,
        'isOnline': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(profileData, SetOptions(merge: true));

      // Initialize empty sub-collections and initial stats
      await _initializeUserCollections(uid);
    } catch (e) {
      throw Exception('Failed to create academic user profile: $e');
    }
  }

  /// Initialize user sub-collections and default statistics
  Future<void> _initializeUserCollections(String uid) async {
    try {
      // Initialize academic stats
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection('stats')
          .doc('academic')
          .set({
        'totalNotesUploaded': 0,
        'pendingAssignments': 0,
        'completedAssignments': 0,
        'savedResources': 0,
        'upcomingExams': 0,
        'assignmentCompletionPercentage': 0.0,
        'studyStreak': 0,
        'badges': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to initialize user collections: $e');
      // Don't throw - collections can be created on first use
    }
  }

  Future<AppUser?> fetchUserProfile(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection(_usersCollection).doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      final Map<String, dynamic>? data = doc.data();
      if (data == null) {
        return null;
      }

      return AppUser.fromMap(data);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final Map<String, dynamic> updateData = <String, dynamic>{};

      if (name != null) {
        updateData['name'] = name;
      }
      if (avatarUrl != null) {
        updateData['avatarUrl'] = avatarUrl;
      }

      if (updateData.isEmpty) {
        return;
      }

      await _firestore.collection(_usersCollection).doc(uid).update(updateData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}
