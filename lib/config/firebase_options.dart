import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// 기본 Firebase 프로젝트 구성 옵션
///
/// 실제 프로젝트에서는 `flutterfire configure` 명령어를 통해 생성된 파일로 대체됩니다.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // 웹 플랫폼 Firebase 설정 (개발 환경용)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDEVELOVERSIONKEYweb123456',
    appId: '1:1234567890:web:1a2b3c4d5e6f7g8h9i0j',
    messagingSenderId: '1234567890',
    projectId: 'camino-app-dev',
    authDomain: 'camino-app-dev.firebaseapp.com',
    storageBucket: 'camino-app-dev.appspot.com',
  );

  // 안드로이드 Firebase 설정 (개발 환경용)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEVELOVERSIONKEYandroid123456',
    appId: '1:1234567890:android:1a2b3c4d5e6f7g8h9i0j',
    messagingSenderId: '1234567890',
    projectId: 'camino-app-dev',
    storageBucket: 'camino-app-dev.appspot.com',
  );

  // iOS Firebase 설정 (개발 환경용)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDEVELOVERSIONKEYios123456',
    appId: '1:1234567890:ios:1a2b3c4d5e6f7g8h9i0j',
    messagingSenderId: '1234567890',
    projectId: 'camino-app-dev',
    storageBucket: 'camino-app-dev.appspot.com',
    iosBundleId: 'com.nextwe.caminandes',
  );

  // macOS Firebase 설정 (개발 환경용)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDEVELOVERSIONKEYmacos123456',
    appId: '1:1234567890:macos:1a2b3c4d5e6f7g8h9i0j',
    messagingSenderId: '1234567890',
    projectId: 'camino-app-dev',
    storageBucket: 'camino-app-dev.appspot.com',
    iosBundleId: 'com.nextwe.caminandes.macos',
  );
}
