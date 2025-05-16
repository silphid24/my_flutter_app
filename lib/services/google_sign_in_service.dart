import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Google 로그인 관련 기능을 제공하는 서비스 클래스
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();

  factory GoogleSignInService() => _instance;

  GoogleSignInService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Google Sign In 인스턴스 생성 - 오류 해결을 위해 web 클라이언트 ID는 웹 환경에서만 사용
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    // 웹 환경에서만 clientId를 설정
    clientId: kIsWeb
        ? '523487864273-ml4fucgq0o99g7vglg96bi8ovu68rp3p.apps.googleusercontent.com'
        : null,
  );

  /// Google 로그인 수행
  Future<UserCredential?> signInWithGoogle() async {
    try {
      log('GoogleSignInService: 구글 로그인 시작');

      // 현재 세션 정리
      try {
        await _googleSignIn.signOut();
        await _firebaseAuth.signOut();
        log('GoogleSignInService: 기존 세션 정리 완료');
      } catch (e) {
        log('GoogleSignInService: 세션 정리 중 오류(무시): $e');
      }

      // Google 로그인 프로세스 시작
      log('GoogleSignInService: 구글 로그인 UI 실행');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        log('GoogleSignInService: 로그인 취소됨');
        return null;
      }

      log('GoogleSignInService: 구글 계정 선택됨 - ${googleUser.email}');

      // Google 인증 정보 획득
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      log('GoogleSignInService: 인증 정보 획득 - accessToken: ${googleAuth.accessToken != null}, idToken: ${googleAuth.idToken != null}');

      // 토큰 확인
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        log('GoogleSignInService: 토큰이 모두 null');
        throw Exception('구글 로그인 인증 토큰을 획득할 수 없습니다');
      }

      // 인증 정보 생성
      final AuthCredential credential;
      if (googleAuth.idToken != null) {
        credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        log('GoogleSignInService: ID 토큰으로 인증 정보 생성');
      } else {
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
        );
        log('GoogleSignInService: 액세스 토큰으로 인증 정보 생성');
      }

      // Firebase Auth로 로그인
      try {
        log('GoogleSignInService: Firebase 인증 시작 - accessToken 존재: ${googleAuth.accessToken != null}, idToken 존재: ${googleAuth.idToken != null}');
        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        log('GoogleSignInService: Firebase 인증 성공 - ${userCredential.user?.email}, uid: ${userCredential.user?.uid}');

        // 추가 디버깅: 현재 Firebase 상태 확인
        final currentUser = _firebaseAuth.currentUser;
        log('GoogleSignInService: 현재 Firebase 사용자 - ${currentUser?.email ?? "없음"}, uid: ${currentUser?.uid ?? "없음"}');

        return userCredential;
      } catch (e) {
        log('GoogleSignInService: Firebase 인증 실패 - $e');
        throw Exception('구글 계정 정보로 로그인 처리 중 오류가 발생했습니다: $e');
      }
    } catch (e) {
      log('GoogleSignInService: 구글 로그인 실패 - $e');
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      log('GoogleSignInService: 로그아웃 완료');
    } catch (e) {
      log('GoogleSignInService: 로그아웃 중 오류 발생 - $e');
      rethrow;
    }
  }

  /// 현재 로그인 상태 확인
  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// 현재 사용자 정보 가져오기
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
