// import 'package:firebase_core/firebase_core.dart';

/// 웹 환경 실행을 위한 더미 Firebase Options
/// 실제 프로젝트에서는 Firebase를 초기화하지 않습니다.
class DefaultFirebaseOptions {
  static dynamic get currentPlatform {
    return DummyFirebaseOptions();
  }
}

class DummyFirebaseOptions {
  final String apiKey = 'dummy';
  final String appId = 'dummy';
  final String messagingSenderId = 'dummy';
  final String projectId = 'dummy';
}
