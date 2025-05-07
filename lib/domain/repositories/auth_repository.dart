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

  // 자동 로그인을 활성화/비활성화합니다
  Future<void> setAutoLogin(bool enabled, {String? email, String? password});

  // 자동 로그인이 활성화되어 있는지 확인합니다
  Future<bool> isAutoLoginEnabled();

  // 저장된 사용자 정보로 자동 로그인합니다
  Future<DummyUser?> loadSavedUser();
}
