import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore 데이터베이스 서비스를 처리하는 싱글톤 클래스.
/// 앱 전체에서 Firestore 접근을 관리합니다.
class FirestoreService {
  /// 싱글톤 인스턴스
  static final FirestoreService _instance = FirestoreService._internal();

  /// 외부 접근을 위한 싱글톤 팩토리 생성자
  factory FirestoreService() {
    return _instance;
  }

  /// 내부 생성자
  FirestoreService._internal();

  /// Firestore 인스턴스
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// 테스트용 문서 생성
  Future<void> createTestDocument() async {
    try {
      // 테스트 컬렉션에 문서 생성
      await firestore.collection('test').doc('test_doc').set({
        'name': 'Test Document',
        'createdAt': FieldValue.serverTimestamp(),
        'isTest': true,
      });
      debugPrint('테스트 문서 생성 성공');
    } catch (e) {
      debugPrint('테스트 문서 생성 실패: $e');
      rethrow;
    }
  }

  /// 테스트용 문서 읽기
  Future<Map<String, dynamic>?> readTestDocument() async {
    try {
      final docSnapshot =
          await firestore.collection('test').doc('test_doc').get();
      if (docSnapshot.exists) {
        debugPrint('테스트 문서 조회 성공: ${docSnapshot.data()}');
        return docSnapshot.data();
      } else {
        debugPrint('테스트 문서가 존재하지 않습니다.');
        return null;
      }
    } catch (e) {
      debugPrint('테스트 문서 조회 실패: $e');
      rethrow;
    }
  }

  /// 사용자 정보 저장
  Future<void> saveUserProfile(
      String userId, Map<String, dynamic> userData) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .set(userData, SetOptions(merge: true));
      debugPrint('사용자 프로필 저장 성공: $userId');
    } catch (e) {
      debugPrint('사용자 프로필 저장 실패: $e');
      rethrow;
    }
  }

  /// 사용자 정보 조회
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final docSnapshot = await firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      debugPrint('사용자 프로필 조회 실패: $e');
      rethrow;
    }
  }
}
