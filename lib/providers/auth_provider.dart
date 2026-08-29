import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

enum AuthStatus { unknown, signedIn, signedOut }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  User? _user;
  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _status == AuthStatus.signedIn;
  String? get error => _error;

  // Nom d'affichage raccourci (prénom uniquement).
  String get displayName {
    final name = _user?.displayName ?? '';
    return name.isNotEmpty ? name.split(' ').first : 'Moi';
  }

  String? get avatarUrl => _user?.photoURL;
  String? get uid => _user?.uid;

  AuthProvider() {
    _service.authStateChanges.listen((user) {
      _user = user;
      _status = user != null ? AuthStatus.signedIn : AuthStatus.signedOut;
      notifyListeners();
    });
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
      _error = 'Connexion impossible. Réessayez.';
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
