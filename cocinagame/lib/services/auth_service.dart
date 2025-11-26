import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<User?> get authState => authStateChanges;

  User? get currentUser => _auth.currentUser;


  // Login con email y contraseña
  Future<UserCredential> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred;
    } on FirebaseAuthException catch (e) {
      // Mapear a Exception simple para evitar problemas en Web
      final msg = e.message ?? 'Error de autenticación: ${e.code}';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error inesperado al iniciar sesión');
    }
  }

  // Registro
  Future<UserCredential> register(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred;
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? 'Error de registro: ${e.code}';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error inesperado al registrar la cuenta');
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
