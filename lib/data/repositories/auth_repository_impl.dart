// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/domain/repositories/auth_repository.dart';

// 더미 사용자 클래스
class DummyUser {
  final String uid;
  final String? email;
  final String? displayName;

  DummyUser({required this.uid, this.email, this.displayName});
}

class AuthRepositoryImpl implements AuthRepository {
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  DummyUser? _currentUser;
  final StreamController<DummyUser?> _authStateController =
      StreamController<DummyUser?>.broadcast();

  AuthRepositoryImpl() {
    // 초기화
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<DummyUser?> signInWithGoogle() async {
    try {
      debugPrint('Google 로그인은 현재 모바일에서 구현되지 않았습니다.');

      // 더미 데이터로 로그인 성공 시뮬레이션
      _currentUser = DummyUser(
        uid: 'google-user-123',
        email: 'pilgrim@camino.com',
        displayName: '순례자',
      );
      _authStateController.add(_currentUser);

      return _currentUser;
    } catch (e) {
      debugPrint('Google 로그인 오류: $e');
      return null;
    }
  }

  @override
  Future<DummyUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // 더미 데이터로 로그인 성공 시뮬레이션
      if (email.isNotEmpty && password.isNotEmpty) {
        _currentUser = DummyUser(
          uid: 'email-user-456',
          email: email,
          displayName: '순례자',
        );
        _authStateController.add(_currentUser);
        return _currentUser;
      } else {
        throw Exception('이메일과 비밀번호를 입력해주세요.');
      }
    } catch (e) {
      debugPrint('이메일 로그인 오류: $e');
      rethrow;
    }
  }

  @override
  Future<DummyUser?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // 더미 데이터로 회원가입 성공 시뮬레이션
      if (email.isNotEmpty && password.length >= 6) {
        _currentUser = DummyUser(
          uid: 'new-user-789',
          email: email,
          displayName: '신규 순례자',
        );
        _authStateController.add(_currentUser);
        return _currentUser;
      } else {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      }
    } catch (e) {
      debugPrint('회원가입 오류: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  DummyUser? getCurrentUser() {
    return _currentUser;
  }

  @override
  Stream<DummyUser?> authStateChanges() {
    return _authStateController.stream;
  }
}
