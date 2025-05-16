import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../config/firebase_options.dart';

/// Firebase 서비스를 처리하는 싱글톤 클래스.
/// 앱 전체에서 Firebase 앱의 초기화 및 접근을 관리합니다.
class FirebaseService {
  /// 싱글톤 인스턴스
  static final FirebaseService _instance = FirebaseService._internal();

  /// 인스턴스가 이미 초기화되었는지 확인하는 플래그
  bool _initialized = false;

  /// 외부 접근을 위한 싱글톤 팩토리 생성자
  factory FirebaseService() {
    return _instance;
  }

  /// 내부 생성자
  FirebaseService._internal();

  /// Firebase 앱이 초기화되었는지 확인
  bool get isInitialized => _initialized;

  /// Firebase 앱 인스턴스를 반환
  FirebaseApp? get app {
    if (!_initialized) return null;
    try {
      return Firebase.app();
    } catch (e) {
      debugPrint('Firebase 앱 접근 오류: $e');
      return null;
    }
  }

  /// Firebase 초기화 메소드.
  /// 앱이 이미 초기화되었는지 확인하고, 필요한 경우에만 초기화합니다.
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('Firebase가 이미 초기화되어 있습니다.');
      return;
    }

    try {
      // 먼저 Firebase.apps를 확인하여 이미 초기화된 앱이 있는지 확인
      if (Firebase.apps.isNotEmpty) {
        debugPrint('기존 Firebase 앱 발견: ${Firebase.apps.length}개');
        _initialized = true;
        return;
      }

      // 새로 초기화 진행 (DefaultFirebaseOptions 사용)
      final app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _initialized = true;
      debugPrint('Firebase 초기화 완료: ${app.name}');

      // 초기화 성공 후 앱 정보 로깅
      for (final fapp in Firebase.apps) {
        debugPrint('- Firebase 앱: ${fapp.name}');
      }
    } catch (e) {
      debugPrint('Firebase 초기화 오류: $e');
      _initialized = false;
      // 오류 발생 시 기존 앱이 있을 경우 사용하려고 시도
      if (Firebase.apps.isNotEmpty) {
        debugPrint('기존 Firebase 앱 사용 시도...');
        _initialized = true;
      }
    }
  }
}
