import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/profile_models.dart';

/// Firebase Service for Profile Management
/// Handles all Firestore and Firebase Storage operations
class FirebaseProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get user email
  String? get userEmail => _auth.currentUser?.email;

  /// Stream of student profile data
  Stream<StudentProfile?> getProfileStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value(null);

    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return StudentProfile.fromFirestore(snapshot.data()!, uid);
    });
  }

  /// Get student profile once
  Future<StudentProfile?> getProfile() async {
    try {
      final uid = currentUserId;
      if (uid == null) return null;

      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (!snapshot.exists) return null;

      return StudentProfile.fromFirestore(snapshot.data()!, uid);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  /// Update student profile
  Future<bool> updateProfile({
    required String fullName,
    required String department,
    required String semester,
    required String programType,
    required String batch,
    String? phone,
    double? cgpa,
  }) async {
    try {
      final uid = currentUserId;
      if (uid == null) return false;

      await _firestore.collection('users').doc(uid).update({
        'fullName': fullName,
        'department': department,
        'semester': semester,
        'programType': programType,
        'batch': batch,
        'phone': phone,
        'cgpa': cgpa,
        'updatedAt': DateTime.now(),
      });

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  /// Upload and update profile image
  Future<bool> uploadProfileImage(String imagePath) async {
    try {
      final uid = currentUserId;
      if (uid == null) return false;

      final fileName = 'profile_images/$uid.jpg';
      final ref = _storage.ref().child(fileName);

      await ref.putFile(File(imagePath));
      final url = await ref.getDownloadURL();

      await _firestore.collection('users').doc(uid).update({
        'profileImage': url,
        'updatedAt': DateTime.now(),
      });

      return true;
    } catch (e) {
      print('Error uploading profile image: $e');
      return false;
    }
  }

  /// Get academic statistics
  Future<AcademicStats> getAcademicStats() async {
    try {
      final uid = currentUserId;
      if (uid == null) return AcademicStats.empty();

      final statsDoc =
          await _firestore.collection('users').doc(uid).collection('stats').doc('academic').get();

      if (!statsDoc.exists) return AcademicStats.empty();

      return AcademicStats.fromFirestore(statsDoc.data()!);
    } catch (e) {
      print('Error fetching academic stats: $e');
      return AcademicStats.empty();
    }
  }

  /// Stream of academic statistics
  Stream<AcademicStats> getAcademicStatsStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value(AcademicStats.empty());

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc('academic')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return AcademicStats.empty();
      return AcademicStats.fromFirestore(snapshot.data()!);
    });
  }

  /// Get recent activities
  Future<List<StudentActivity>> getRecentActivities({int limit = 5}) async {
    try {
      final uid = currentUserId;
      if (uid == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => StudentActivity.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching activities: $e');
      return [];
    }
  }

  /// Stream of recent activities
  Stream<List<StudentActivity>> getRecentActivitiesStream({int limit = 5}) {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudentActivity.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get upcoming deadlines
  Future<List<StudentDeadline>> getUpcomingDeadlines() async {
    try {
      final uid = currentUserId;
      if (uid == null) return [];

      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('deadlines')
          .where('dueDate', isGreaterThanOrEqualTo: now)
          .where('isCompleted', isEqualTo: false)
          .orderBy('dueDate')
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => StudentDeadline.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching deadlines: $e');
      return [];
    }
  }

  /// Stream of upcoming deadlines
  Stream<List<StudentDeadline>> getUpcomingDeadlinesStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    final now = DateTime.now();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('deadlines')
        .where('dueDate', isGreaterThanOrEqualTo: now)
        .where('isCompleted', isEqualTo: false)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudentDeadline.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get achievement badges
  Future<List<AchievementBadge>> getAchievementBadges() async {
    try {
      final uid = currentUserId;
      if (uid == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('badges')
          .orderBy('unlockedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AchievementBadge.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching badges: $e');
      return [];
    }
  }

  /// Stream of achievement badges
  Stream<List<AchievementBadge>> getAchievementBadgesStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('badges')
        .orderBy('unlockedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AchievementBadge.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get total notes count
  Future<int> getTotalNotesCount() async {
    try {
      final uid = currentUserId;
      if (uid == null) return 0;

      final snapshot =
          await _firestore.collection('notes').where('uid', isEqualTo: uid).get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching notes count: $e');
      return 0;
    }
  }

  /// Get assignments statistics
  Future<Map<String, int>> getAssignmentsStats() async {
    try {
      final uid = currentUserId;
      if (uid == null) return {'pending': 0, 'completed': 0};

      final pendingSnapshot = await _firestore
          .collection('assignments')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: 'pending')
          .get();

      final completedSnapshot = await _firestore
          .collection('assignments')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .get();

      return {
        'pending': pendingSnapshot.docs.length,
        'completed': completedSnapshot.docs.length,
      };
    } catch (e) {
      print('Error fetching assignments stats: $e');
      return {'pending': 0, 'completed': 0};
    }
  }

  /// Set online status
  Future<void> setOnlineStatus(bool isOnline) async {
    try {
      final uid = currentUserId;
      if (uid == null) return;

      await _firestore.collection('users').doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now(),
      });
    } catch (e) {
      print('Error setting online status: $e');
    }
  }

  /// Create user document on first sign-up
  Future<bool> createUserProfile({
    required String fullName,
    required String email,
    required String studentId,
    required String department,
    required String semester,
  }) async {
    try {
      final uid = currentUserId;
      if (uid == null) return false;

      await _firestore.collection('users').doc(uid).set({
        'fullName': fullName,
        'email': email,
        'studentId': studentId,
        'department': department,
        'semester': semester,
        'programType': 'Undergraduate',
        'university': 'Not Set',
        'cgpa': 0.0,
        'batch': '',
        'phone': null,
        'profileImage': null,
        'isVerified': false,
        'isOnline': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      return true;
    } catch (e) {
      print('Error creating user profile: $e');
      return false;
    }
  }

  /// Log activity
  Future<bool> logActivity({
    required String type,
    required String title,
    String? description,
    required String icon,
  }) async {
    try {
      final uid = currentUserId;
      if (uid == null) return false;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('activities')
          .add({
        'type': type,
        'title': title,
        'description': description,
        'icon': icon,
        'timestamp': DateTime.now(),
      });

      return true;
    } catch (e) {
      print('Error logging activity: $e');
      return false;
    }
  }
}
