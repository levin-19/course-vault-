import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _bootstrap();
  }

  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  AppUser? _appUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _appUser != null;
  AppUser? get appUser => _appUser;
  String? get errorMessage => _errorMessage;

  Future<void> _bootstrap() async {
    try {
      final AppUser? sessionUser = await _authService.restoreSession();
      if (sessionUser == null) {
        _appUser = null;
      } else {
        _appUser = await _profileService.fetchUserProfile(sessionUser.uid) ??
            sessionUser;
      }
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Failed to restore session.';
      _appUser = null;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final AppUser newUser = await _authService.signUp(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );

      try {
        await _profileService.createUserProfile(newUser);
      } catch (e) {
        // Profile creation failed, but user was created - continue
      }

      _appUser = newUser;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _mapAuthErrorCode(e.code, fallback: e.message);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error occurred during sign up: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final AppUser signedIn = await _authService.signIn(
        email: email.trim(),
        password: password,
      );

      _appUser =
          await _profileService.fetchUserProfile(signedIn.uid) ?? signedIn;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _mapAuthErrorCode(e.code, fallback: e.message);
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Unable to sign in. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String name,
    String? password,
  }) async {
    if (_appUser == null) {
      _errorMessage = 'Please sign in again.';
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      final String cleanedName = name.trim();

      await _profileService.updateUserProfile(
        uid: _appUser!.uid,
        name: cleanedName,
      );
      await _authService.updateDisplayName(
          uid: _appUser!.uid, name: cleanedName);

      if (password != null && password.trim().isNotEmpty) {
        await _authService.updatePassword(
          uid: _appUser!.uid,
          newPassword: password.trim(),
        );
      }

      _appUser = AppUser(
        uid: _appUser!.uid,
        name: cleanedName,
        email: _appUser!.email,
        avatarUrl: _appUser!.avatarUrl,
      );

      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _mapAuthErrorCode(e.code, fallback: e.message);
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Unexpected error while updating profile.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();
      _appUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Failed to log out. Try again.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapAuthErrorCode(String code, {required String fallback}) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return fallback;
    }
  }
}
