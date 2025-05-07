# 카미노 데 산티아고 순례길 앱 개발 기록

## 개발 개요
- Flutter를 사용한 카미노 데 산티아고 순례길 앱 개발
- 주요 기능: 지도 화면, 스테이지별 정보, GPS 위치 추적

## 해결된 문제
1. 로그인 화면 관련 문제
   - 관리자 로그인 버튼 추가 및 Firebase 인증 우회 처리
   - DummyUser 객체를 직접 생성하여 인증 상태 처리

2. 네비게이션 바 중복 문제
   - MapScreen, CommunityScreenContainer, InfoScreenContainer에서 중복 BottomNavBar 제거
   - 컨테이너 위젯에서 단순 Scaffold.body만 사용하도록 수정

3. API 관련 문제
   - Unsplash 이미지 로드 오류 (via.placeholder.com 접속 불가) 확인
   - OpenStreetMap 타일 서버 경고 확인

4. 코드 구조 개선
   - 단일 책임 원칙(SRP)에 맞게 앱 리팩토링
   - 중복된 페이지 참조 수정 및 import 정리
   - 불필요한 디렉토리 삭제 및 라우팅 정리
   - 홈 화면을 작은 위젯으로 분리 (HomeHeader, TodayStageCard, StageProgress, BottomNavBar 등)

## 주요 기술 스택
- Flutter/Dart - UI 프레임워크
- Riverpod - 상태 관리
- GoRouter - 라우팅
- Hooks - 상태 관리 보조
- Firebase - 인증 및 백엔드
- latlong2, geolocator - 위치 정보

## 테스트
- 안드로이드 기기에서 테스트 확인 완료
- 위젯 테스트 업데이트 완료

## 다음 작업
- Unsplash 이미지 로드 오류 수정 필요
- OpenStreetMap 타일 서버 경고 해결 필요

