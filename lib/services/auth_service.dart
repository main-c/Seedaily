import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isSignedIn => _auth.currentUser != null;

  // ── Google Sign-In ────────────────────────────────────────────────────────

  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // annulé par l'utilisateur

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) return null;

    await _upsertUserProfile(user);
    await _storeFcmToken(user.uid);
    return user;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Profil Firestore ──────────────────────────────────────────────────────
  // Crée ou met à jour users/{uid} à chaque connexion.

  Future<void> _upsertUserProfile(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    await ref.set({
      'displayName': user.displayName ?? 'Utilisateur',
      'email': user.email,
      'avatarUrl': user.photoURL,
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Token FCM ─────────────────────────────────────────────────────────────
  // Stocke le token sur users/{uid} pour que Cloud Functions puisse envoyer des pushs.

  Future<void> _storeFcmToken(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await _db.collection('users').doc(uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );

      // Rafraîchit automatiquement si le token change.
      _messaging.onTokenRefresh.listen((newToken) {
        _db.collection('users').doc(uid).update({'fcmToken': newToken});
      });
    } catch (_) {
      // Token FCM non critique — échec silencieux.
    }
  }

  // ── Permissions notifications ─────────────────────────────────────────────

  Future<void> requestNotificationPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
