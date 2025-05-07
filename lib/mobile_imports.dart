import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    // 기본 sqflite는 자동으로 초기화됨
    print('모바일 SQLite 초기화 완료');
  } catch (e) {
    print('모바일 SQLite 초기화 오류: $e');
  }
}
