import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class ProfileService {
  static const String _profilesKey = 'cv_profiles';

  Future<void> createUserProfile(AppUser user) async {
    final Map<String, dynamic> profiles = await _readProfiles();
    profiles[user.uid] = user.toMap();
    await _writeProfiles(profiles);
  }

  Future<AppUser?> fetchUserProfile(String uid) async {
    final Map<String, dynamic> profiles = await _readProfiles();
    final dynamic value = profiles[uid];
    if (value == null) {
      return null;
    }

    return AppUser.fromMap(Map<String, dynamic>.from(value as Map));
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? avatarUrl,
  }) async {
    final Map<String, dynamic> profiles = await _readProfiles();
    final Map<String, dynamic> existing = Map<String, dynamic>.from(
      (profiles[uid] as Map?) ?? <String, dynamic>{'uid': uid},
    );

    if (name != null) {
      existing['name'] = name;
    }
    if (avatarUrl != null) {
      existing['avatarUrl'] = avatarUrl;
    }

    profiles[uid] = existing;
    await _writeProfiles(profiles);
  }

  Future<Map<String, dynamic>> _readProfiles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_profilesKey);

    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }

    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> _writeProfiles(Map<String, dynamic> profiles) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilesKey, jsonEncode(profiles));
  }
}
