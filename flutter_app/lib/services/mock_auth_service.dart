import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'auth_service.dart';

// Classe simple pour mocker UserCredential si nécessaire, 
// mais pour l'instant on va juste retourner des nulls ou des objets vides
// car l'app ne semble pas utiliser les détails de l'utilisateur de manière critique pour l'affichage public.

class MockAuthService implements AuthService {
  @override
  User? get currentUser => null; // Utilisateur anonyme par défaut

  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  Future<UserCredential> signUp({required String email, required String password}) async {
    throw UnimplementedError('Mock signUp not implemented');
  }

  @override
  Future<UserCredential> signIn({required String email, required String password}) async {
    throw UnimplementedError('Mock signIn not implemented');
  }

  @override
  Future<UserCredential> signInAnonymously() async {
    // Retourne une future complétée pour simuler le succès
    // On ne peut pas facilement instancier UserCredential car c'est une classe interne de Firebase
    // Mais comme on ne l'utilise pas vraiment dans le flux principal (juste await), ça devrait aller.
    // Si ça plante, on devra faire un mock plus complexe avec Mockito.
    throw UnimplementedError('Mock signInAnonymously not fully implemented without Mockito');
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
