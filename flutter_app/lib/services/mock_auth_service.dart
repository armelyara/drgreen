import 'auth_service.dart';

class MockAuthService implements AuthService {
  dynamic _currentUser;

  @override
  dynamic get currentUser => _currentUser;

  @override
  Stream<dynamic> get authStateChanges => Stream.value(_currentUser);

  MockAuthService() {
    // Uncomment to start logged in
    // _currentUser = {'uid': 'mock_uid', 'email': 'test@drgreen.com'};
  }

  @override
  Future<dynamic> signUp({required String email, required String password}) async {
    _currentUser = {'uid': 'mock_uid', 'email': email};
    return {'user': _currentUser};
  }

  @override
  Future<dynamic> signIn({required String email, required String password}) async {
    _currentUser = {'uid': 'mock_uid', 'email': email};
    return {'user': _currentUser};
  }

  @override
  Future<dynamic> signInAnonymously() async {
    _currentUser = {'uid': 'mock_uid', 'isAnonymous': true};
    return {'user': _currentUser};
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // No-op
  }
}
