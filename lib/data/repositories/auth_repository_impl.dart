// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';

// 임시 사용자 모델
class DummyUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;

  DummyUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
  });

  factory DummyUser.fromFirebaseUser(User user) {
    return DummyUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // 자동 로그인을 위한 SharedPreferences 키
  static const String _autoLoginKey = 'auto_login_enabled';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';

  // 스트림 컨트롤러 추가
  final StreamController<DummyUser?> _authStateController =
      StreamController<DummyUser?>.broadcast();

  AuthRepositoryImpl({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn() {
    // Firebase 인증 상태 변경 리스닝
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        _authStateController.add(DummyUser.fromFirebaseUser(user));
      } else {
        _authStateController.add(null);
      }
    });
  }

  @override
  Future<DummyUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) return null;
      return DummyUser.fromFirebaseUser(user);
    } catch (e) {
      log('Google 로그인 에러: $e');
      return null;
    }
  }

  @override
  Future<DummyUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('이메일과 비밀번호를 입력해주세요');
      }

      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user == null) return null;
      return DummyUser.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('사용자가 없습니다');
        case 'wrong-password':
          throw Exception('비밀번호가 올바르지 않습니다');
        default:
          print('이메일 로그인 에러: ${e.code}');
          throw Exception('로그인에 실패했습니다: ${e.message}');
      }
    } catch (e) {
      print('이메일 로그인 에러: $e');
      throw e;
    }
  }

  @override
  Future<DummyUser?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다');
      }

      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user == null) return null;
      return DummyUser.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('이미 등록된 이메일');
        case 'invalid-email':
          throw Exception('잘못된 이메일 형식');
        case 'weak-password':
          throw Exception('안전하지 않은 비밀번호');
        default:
          print('회원가입 에러: ${e.code}');
          throw Exception('회원가입에 실패했습니다: ${e.message}');
      }
    } catch (e) {
      print('회원가입 에러: $e');
      throw e;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      print('로그아웃 에러: $e');
    }
  }

  @override
  DummyUser? getCurrentUser() {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return DummyUser.fromFirebaseUser(user);
  }

  @override
  Stream<DummyUser?> authStateChanges() {
    return _authStateController.stream;
  }

  // 자동 로그인 설정을 저장합니다
  @override
  Future<void> setAutoLogin(
    bool enabled, {
    String? email,
    String? password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoLoginKey, enabled);

      // 자동 로그인이 활성화된 경우에만 이메일과 비밀번호 저장
      if (enabled && email != null && password != null) {
        await prefs.setString(_savedEmailKey, email);
        // 실제 앱에서는 보안을 위해 비밀번호 암호화 필요
        await prefs.setString(_savedPasswordKey, password);
      } else if (!enabled) {
        // 자동 로그인 비활성화 시 저장된 정보 삭제
        await prefs.remove(_savedEmailKey);
        await prefs.remove(_savedPasswordKey);
      }
    } catch (e) {
      log('자동 로그인 설정 저장 실패: $e');
      throw Exception('자동 로그인 설정을 저장하는 중 오류가 발생했습니다');
    }
  }

  // 자동 로그인 활성화 여부를 확인합니다
  @override
  Future<bool> isAutoLoginEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_autoLoginKey) ?? false;
    } catch (e) {
      log('자동 로그인 설정 확인 실패: $e');
      return false;
    }
  }

  // 저장된 사용자 정보로 자동 로그인합니다
  @override
  Future<DummyUser?> loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isEnabled = await isAutoLoginEnabled();

      if (!isEnabled) {
        log('자동 로그인이 활성화되어 있지 않습니다');
        return null;
      }

      final email = prefs.getString(_savedEmailKey);
      final password = prefs.getString(_savedPasswordKey);

      if (email != null && password != null) {
        log('저장된 사용자 정보로 로그인 시도');
        return await signInWithEmailAndPassword(email, password);
      }

      log('저장된 사용자 정보가 없습니다');
      return null;
    } catch (e) {
      log('자동 로그인 실패: $e');
      return null;
    }
  }
}
