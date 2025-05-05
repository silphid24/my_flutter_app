import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:html' as html;

// Google Maps 웹 초기화
void initializeGoogleMapsForWeb() {
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is! GoogleMapsPlugin) {
    GoogleMapsFlutterPlatform.instance = GoogleMapsPlugin();
    print('Google Maps for Web initialized');
  }
}

// 웹용 데이터베이스 초기화
void initializeDatabaseForWeb() {
  try {
    // SQLite Web Worker 경로가 올바른지 확인
    final scriptElement =
        html.document.createElement('script') as html.ScriptElement;
    scriptElement.type = 'text/javascript';
    scriptElement.text = '''
      // SQLite 웹 워커 설정
      window.sqlite3InitModule = function(config) {
        return {
          locateFile: function(fileName) {
            console.log('SQLite trying to load:', fileName);
            return '/sqflite_sw.js';
          }
        };
      };
    ''';
    html.document.head?.append(scriptElement);

    databaseFactory = databaseFactoryFfiWeb;
    print('Web database factory set successfully');
  } catch (e) {
    print('Error initializing web database: $e');
  }
}

// 모바일용 더미 함수 (모바일 버전에서는 사용하지 않음)
void initializeDatabaseForMobile() {
  // 모바일 버전에서는 mobile_imports.dart의 함수가 호출됨
}
