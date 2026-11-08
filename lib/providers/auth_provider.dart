import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../l10n/l10n.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, signedIn, signedOut }

enum AuthError { failed, network, generic }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  User? _user;
  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  AuthError? _error;

  User? get user => _user;
  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _status == AuthStatus.signedIn;
  AuthError? get error => _error;

  // Nom d'affichage raccourci (prénom uniquement).
  String get displayName {
    final name = _user?.displayName ?? '';
    return name.isNotEmpty ? name.split(' ').first : appL10n.commonMe;
  }

  String? get avatarUrl => _user?.photoURL;
  String? get uid => _user?.uid;

  AuthProvider() {
    _service.authStateChanges.listen((user) {
      _user = user;
      _status = user != null ? AuthStatus.signedIn : AuthStatus.signedOut;
      notifyListeners();
      if (user != null) _service.storeFcmToken(user.uid);
      syncLocale();
    });
  }

  /// Écrit la langue courante sur users/{uid} (no-op si déconnecté).
  Future<void> syncLocale() async {
    final uid = _user?.uid;
    if (uid != null) await _service.saveLocale(uid);
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _service.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      final msg = e.toString();
      if (msg.contains('10') || msg.contains('sign_in_failed')) {
        _error = AuthError.failed;
      } else if (msg.contains('network')) {
        _error = AuthError.network;
      } else {
        _error = AuthError.generic;
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
  }

  Future<void> requestNotificationPermission() async {
    await _service.requestNotificationPermission();
  }
}
