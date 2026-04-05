import 'package:ding/data/models/user_model.dart';
import 'package:ding/data/repositories/user_repository.dart';
import 'package:ding/data/services/session_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// [UserRepository] implementation backed by Firebase Authentication.
///
/// Registration and online login go through Firebase Auth.
/// The session (email + display name) is also saved in [SessionStorageService]
/// so the app can allow read-only access when there is no internet.
///
/// Passwords are NEVER stored locally.
class FirebaseUserRepository implements UserRepository {
  final SessionStorageService _session;

  FirebaseUserRepository({required SessionStorageService sessionStorage})
      : _session = sessionStorage;

  // ---------------------------------------------------------------------------
  // Register
  // ---------------------------------------------------------------------------

  @override
  Future<void> register(UserModel user) async {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );
    await credential.user?.updateDisplayName(user.name);
    await _session.saveSession(email: user.email, name: user.name);
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  @override
  Future<UserModel?> login(String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) return null;

    final name = firebaseUser.displayName ?? _nameFromEmail(email);
    await _session.saveSession(email: email, name: name);

    return UserModel(id: firebaseUser.uid, name: name, email: email);
  }

  // ---------------------------------------------------------------------------
  // Current user (online + offline fallback)
  // ---------------------------------------------------------------------------

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final name =
          firebaseUser.displayName ?? _nameFromEmail(firebaseUser.email ?? '');
      final email = firebaseUser.email ?? '';
      // Keep local session in sync.
      await _session.saveSession(email: email, name: name);
      return UserModel(id: firebaseUser.uid, name: name, email: email);
    }

    // Offline fallback: allow access if a saved session exists.
    if (await _session.hasSession()) {
      final email = await _session.getUserEmail() ?? '';
      final name = await _session.getUserName() ?? _nameFromEmail(email);
      return UserModel(id: '', name: name, email: email);
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Update profile
  // ---------------------------------------------------------------------------

  @override
  Future<void> updateUser(UserModel user) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      if (user.name != firebaseUser.displayName) {
        await firebaseUser.updateDisplayName(user.name);
      }
      // Password update requires recent authentication; only attempt when
      // a new non-empty password is provided.
      if (user.password.isNotEmpty) {
        await firebaseUser.updatePassword(user.password);
      }
      // Email update via Firebase requires re-authentication and email
      // verification, which is beyond the scope of this lab flow.
    }
    await _session.saveSession(email: user.email, name: user.name);
  }

  // ---------------------------------------------------------------------------
  // Delete account
  // ---------------------------------------------------------------------------

  @override
  Future<void> deleteUser() async {
    await FirebaseAuth.instance.currentUser?.delete();
    await _session.clearSession();
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  @override
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await _session.clearSession();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _nameFromEmail(String email) =>
      email.contains('@') ? email.split('@').first : email;
}
