import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthException implements Exception {
  const AuthException(this.code, this.message);

  final String code;
  final String message;
}

class AuthService {
  late final FirebaseAuth _firebaseAuth;

  AuthService() {
    _firebaseAuth = FirebaseAuth.instance;
  }

  Future<AppUser?> restoreSession() async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        return null;
      }

      return AppUser(
        uid: currentUser.uid,
        name: currentUser.displayName ?? '',
        email: currentUser.email ?? '',
        avatarUrl: currentUser.photoURL,
      );
    } catch (_) {
      return null;
    }
  }

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw const AuthException(
          'user-not-found',
          'Failed to create user account.',
        );
      }

      // Update display name
      await user.updateDisplayName(name.trim());
      await user.reload();

      return AppUser(
        uid: user.uid,
        name: name.trim(),
        email: user.email ?? '',
        avatarUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message ?? 'An error occurred');
    } catch (e) {
      throw AuthException(
        'unknown-error',
        'An unexpected error occurred: $e',
      );
    }
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw const AuthException(
          'user-not-found',
          'Failed to sign in user.',
        );
      }

      return AppUser(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        avatarUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message ?? 'An error occurred');
    } catch (e) {
      throw AuthException(
        'unknown-error',
        'An unexpected error occurred: $e',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(
        'sign-out-error',
        'Failed to sign out: $e',
      );
    }
  }

  Future<void> updatePassword({
    required String uid,
    required String newPassword,
  }) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;

      if (currentUser == null || currentUser.uid != uid) {
        throw const AuthException(
          'user-not-found',
          'Current user not found.',
        );
      }

      await currentUser.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message ?? 'An error occurred');
    } catch (e) {
      throw AuthException(
        'unknown-error',
        'Failed to update password: $e',
      );
    }
  }

  Future<void> updateDisplayName({
    required String uid,
    required String name,
  }) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;

      if (currentUser == null || currentUser.uid != uid) {
        throw const AuthException(
          'user-not-found',
          'Current user not found.',
        );
      }

      await currentUser.updateDisplayName(name.trim());
      await currentUser.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message ?? 'An error occurred');
    } catch (e) {
      throw AuthException(
        'unknown-error',
        'Failed to update display name: $e',
      );
    }
  }
}
