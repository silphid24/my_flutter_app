// import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_flutter_app/data/repositories/auth_repository_impl.dart';

abstract class AuthRepository {
  Future<DummyUser?> signInWithGoogle();
  Future<DummyUser?> signInWithEmailAndPassword(String email, String password);
  Future<DummyUser?> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<void> signOut();
  DummyUser? getCurrentUser();
  Stream<DummyUser?> authStateChanges();
}
