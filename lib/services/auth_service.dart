import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class AuthException implements Exception {
  const AuthException(this.code, this.message);

  final String code;
  final String message;
}

class AuthService {
  static const String _usersKey = 'cv_users';
  static const String _sessionUidKey = 'cv_session_uid';

  Future<AppUser?> restoreSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString(_sessionUidKey);

    if (uid == null) {
      return null;
    }

    final List<Map<String, dynamic>> users = await _readUsers();
    Map<String, dynamic>? record;

    for (final Map<String, dynamic> user in users) {
      if (user['uid'] == uid) {
        record = user;
        break;
      }
    }

    if (record == null) {
      await prefs.remove(_sessionUidKey);
      return null;
    }

    return _toAppUser(record);
  }

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final List<Map<String, dynamic>> users = await _readUsers();
    final String emailLower = email.trim().toLowerCase();

    final bool emailExists = users.any(
      (Map<String, dynamic> u) =>
          (u['email'] as String).toLowerCase() == emailLower,
    );

    if (emailExists) {
      throw const AuthException(
        'email-already-in-use',
        'This email is already in use.',
      );
    }

    final String uid = _generateUid();
    final Map<String, dynamic> record = <String, dynamic>{
      'uid': uid,
      'name': name.trim(),
      'email': emailLower,
      'password': password,
      'avatarUrl': null,
    };

    users.add(record);
    await _writeUsers(users);
    await _saveSession(uid);

    return AppUser(
      uid: uid,
      name: name.trim(),
      email: emailLower,
      avatarUrl: null,
    );
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final List<Map<String, dynamic>> users = await _readUsers();
    final String emailLower = email.trim().toLowerCase();

    Map<String, dynamic>? match;
    for (final Map<String, dynamic> u in users) {
      final String storedEmail = (u['email']?.toString() ?? '').toLowerCase();
      final String storedPassword = u['password']?.toString() ?? '';
      if (storedEmail == emailLower && storedPassword == password) {
        match = u;
        break;
      }
    }

    if (match == null) {
      throw const AuthException(
          'invalid-credential', 'Invalid email or password.');
    }

    await _saveSession(match['uid'] as String);

    return _toAppUser(match);
  }

  Future<void> signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionUidKey);
  }

  Future<void> updatePassword({
    required String uid,
    required String newPassword,
  }) async {
    final List<Map<String, dynamic>> users = await _readUsers();
    bool found = false;

    for (final Map<String, dynamic> u in users) {
      if (u['uid'] == uid) {
        u['password'] = newPassword;
        found = true;
      }
    }

    if (!found) {
      throw const AuthException('user-not-found', 'User not found.');
    }

    await _writeUsers(users);
  }

  Future<void> updateDisplayName({
    required String uid,
    required String name,
  }) async {
    final List<Map<String, dynamic>> users = await _readUsers();
    bool found = false;

    for (final Map<String, dynamic> u in users) {
      if (u['uid'] == uid) {
        u['name'] = name;
        found = true;
      }
    }

    if (!found) {
      throw const AuthException('user-not-found', 'User not found.');
    }

    await _writeUsers(users);
  }

  Future<List<Map<String, dynamic>>> _readUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_usersKey);

    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }

      final List<Map<String, dynamic>> users = <Map<String, dynamic>>[];
      for (final dynamic item in decoded) {
        if (item is! Map) {
          continue;
        }

        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final String uid = map['uid']?.toString() ?? '';
        final String email = map['email']?.toString() ?? '';
        final String password = map['password']?.toString() ?? '';
        if (uid.isEmpty || email.isEmpty || password.isEmpty) {
          continue;
        }

        users.add(<String, dynamic>{
          'uid': uid,
          'name': map['name']?.toString() ?? '',
          'email': email,
          'password': password,
          'avatarUrl': map['avatarUrl']?.toString(),
        });
      }

      return users;
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _writeUsers(List<Map<String, dynamic>> users) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<void> _saveSession(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionUidKey, uid);
  }

  String _generateUid() {
    final Random random = Random();
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int rand = random.nextInt(1 << 32);
    return 'cv_${now}_$rand';
  }

  AppUser _toAppUser(Map<String, dynamic> record) {
    final String uid = record['uid']?.toString() ?? '';
    final String name = record['name']?.toString() ?? '';
    final String email = record['email']?.toString() ?? '';
    final String? avatarUrl = record['avatarUrl']?.toString();

    return AppUser(
      uid: uid,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
  }
}
