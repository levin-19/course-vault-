import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
