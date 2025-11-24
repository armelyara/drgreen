
/// Service d'authentification (Interface)
abstract class AuthService {
  dynamic get currentUser;
  Stream<dynamic> get authStateChanges;

  Future<dynamic> signUp({
    required String email,
    required String password,
  });

  Future<dynamic> signIn({
    required String email,
    required String password,
  });

  Future<dynamic> signInAnonymously();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}
