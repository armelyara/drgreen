import 'auth_service.dart';

class MockAuthService implements AuthService {
  @override
  dynamic get currentUser => null; // Utilisateur anonyme par défaut

  @override
  Stream<dynamic> get authStateChanges => Stream.value(null);

  @override
  Future<dynamic> signUp({required String email, required String password}) async {
    // Return a dummy object
    return {'user': {'uid': 'mock_uid', 'email': email}};
  }

  @override
  Future<dynamic> signIn({required String email, required String password}) async {
    // Return a dummy object
    return {'user': {'uid': 'mock_uid', 'email': email}};
  }

  @override
  Future<dynamic> signInAnonymously() async {
    // Return a dummy object
    return {'user': {'uid': 'mock_uid', 'isAnonymous': true}};
  }

  @override
  Future<void> signOut() async {
    // No-op
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // No-op
  }
}
