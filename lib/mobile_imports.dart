import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

// Google Maps 웹 초기화 - 모바일에서는 사용하지 않는 더미 함수
void initializeGoogleMapsForWeb() {
  // 모바일 버전에서는 web_imports.dart의 함수가 호출됨
}

// 모바일용 더미 함수 - 웹에서 사용하지 않음
void initializeDatabaseForWeb() {
  // 모바일 버전에서는 사용하지 않음
}

// SQLite 모바일 초기화
void initializeDatabaseForMobile() {
  try {
    // FFI 초기화
    sqfliteFfiInit();
    // 모바일용 FFI 데이터베이스 팩토리 설정
    databaseFactory = databaseFactoryFfi;
    print('모바일 SQLite 초기화 완료');
  } catch (e) {
    print('모바일 SQLite 초기화 오류: $e');
  }
}
