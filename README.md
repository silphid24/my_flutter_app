# Camino de Santiago 앱

## 최근 개선사항

### 지도 및 GPS 기능 개선 (2024-07-10)

지도 및 GPS 관련 기능이 강화되었습니다:

1. 오프라인 지도 캐싱 서비스 추가:
   - `MapCacheService` 클래스 구현
   - 타일 데이터의 로컬 저장 및 접근 기능
   - 오프라인 모드에서 지도 사용 가능

2. POI(관심 지점) 기능 확장:
   - `PoiModel` 클래스 개선
   - POI 유형별 필터링 기능
   - 즐겨찾기 관리 기능 추가
   - 유형별 마커 스타일링

3. 지도 컨트롤 개선:
   - 레이어 토글 UI 추가
   - 위치 추적 기능 강화
   - 확대/축소 컨트롤 개선

### CaminoStage 모델 개선 및 린터 오류 수정 (2024-07-09)

카미노 스테이지 모델을 개선하여 더 많은 정보를 제공하고 린터 오류를 수정했습니다:

1. CaminoStage 모델 확장:
   - `stageNumber` - 스테이지 번호
   - `startName` - 출발 지점 이름 
   - `endName` - 도착 지점 이름
   - `difficulty` - 난이도 (1-5)

2. 린터 오류 수정:
   - 모델 속성 타입 문제 해결
   - null 안전성 개선
   - Google Maps InfoWindow 기본값 설정

### 소스코드 마이그레이션 완료 (2024-07-08)

모든 주요 화면 파일을 `screens` 폴더에서 `presentation/features` 폴더 구조로 마이그레이션했습니다:

1. 각 기능별 폴더 구조화:
   - `presentation/features/home` - 홈 화면 관련 파일
   - `presentation/features/map` - 지도 화면 관련 파일
   - `presentation/features/community` - 커뮤니티 화면 관련 파일
   - `presentation/features/info` - 정보 화면 관련 파일
   - `presentation/features/shared` - 공통 컴포넌트 파일

2. 각 화면별 클래스 분리:
   - 컨테이너 클래스 (`XXXScreen`) - AppScaffold를 사용하여 일관된 하단 네비게이션 바 제공
   - 콘텐츠 클래스 (`XXXScreenContent`) - 실제 화면 콘텐츠 표시

3. 공통 레이아웃 컴포넌트:
   - AppScaffold 공통 컴포넌트 구현으로 모든 화면에서 일관된 UI 제공
   - 하단 네비게이션 바를 모든 화면에서 재사용

이 모든 개선을 통해 앱의 구조가 더 모듈화되었고, 화면 간 일관된 사용자 경험을 제공하게 되었습니다.

## 앱 구조

### 주요 네비게이션

앱은 GoRouter를 사용하여 다음과 같은 메인 화면으로 구성됩니다:

1. 홈 (`/home`) - 순례 여정 정보와 진행 상황 표시
2. 지도 (`/map`) - 카미노 경로 지도 보기
3. 커뮤니티 (`/community`) - 다른 순례자들과의 소통 기능
4. 정보 (`/info`) - 카미노 데 산티아고에 관한 일반 정보

### 앱 레이아웃

`AppScaffold` 위젯을 사용하여 모든 화면에 일관된 레이아웃을 제공합니다:
- 상단 앱바 (옵션)
- 본문 콘텐츠
- 하단 네비게이션 바 (4개 메인 탭)

### 최적화 및 개선 사항

- 모듈화된 코드 구조로 유지보수성 향상
- 일관된 사용자 인터페이스로 사용자 경험 개선
- 중복 코드 제거를 통한 성능 최적화

## 주요 기능

- **실시간 위치 기반 탐색**: GPS를 활용한 카미노 순례길 트래킹과 경로 이탈 알림
- **스테이지별 정보 제공**: 33개 프랑스 길 스테이지에 대한 상세 정보와 경로 제공
- **맞춤형 여정 계획**: 사용자 경험 수준과 일정에 맞는 일별 스테이지 추천
- **커뮤니티 공간**: 순례자들의 팁, 질문, 경로 상태 정보 공유
- **다양한 지도 서비스**: OpenStreetMap과 Google Maps 지원

## 시작하기

### 요구사항

- Flutter SDK (3.0.0 이상)
- Dart SDK (3.0.0 이상)
- Android Studio / Visual Studio Code
- Android SDK / Xcode (iOS 빌드용)

### 설치

1. 저장소 클론:
   ```
   git clone https://github.com/yourusername/camino-app.git
   ```

2. 프로젝트 디렉토리로 이동:
   ```
   cd camino-app
   ```

3. 의존성 설치:
   ```
   flutter pub get
   ```

4. 앱 실행:
   ```
   flutter run
   ```

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── stage_model.dart      # 카미노 스테이지 모델
│   └── track.dart            # 트랙 데이터 모델
├── services/                 # 서비스 클래스
│   ├── gpx_service.dart      # GPX 파일 처리 서비스
│   └── stage_service.dart    # 스테이지 데이터 관리 서비스
├── utils/                    # 유틸리티 함수
├── providers/                # Riverpod 프로바이더
├── presentation/            
│   ├── router/               # 라우팅 설정
│   │   └── app_router.dart   # GoRouter 설정
│   └── features/             # 기능별 UI 모듈
│       ├── home/             # 홈 화면 관련 위젯
│       ├── map/              # 지도 화면 관련 위젯
│       ├── camino/           # 카미노 지도 위젯
│       ├── community/        # 커뮤니티 화면 관련 위젯
│       ├── info/             # 정보 화면 관련 위젯
│       ├── tracks/           # 트랙 관련 위젯
│       ├── routes/           # 경로 관련 위젯
│       └── shared/           # 공유 UI 컴포넌트
│           └── layout/       # 레이아웃 컴포넌트
└── config/                   # 앱 설정
```

## 기술 스택

- **프레임워크**: Flutter
- **상태 관리**: Riverpod (flutter_riverpod, hooks_riverpod)
- **지도 서비스**: 
  - OpenStreetMap (flutter_map)
  - Google Maps (google_maps_flutter)
- **경로 데이터**: GPX 파일 파싱
- **라우팅**: GoRouter
- **위치 서비스**: location
- **UI 컴포넌트**: Flutter Hooks
- **이미지 캐싱**: cached_network_image

## 기여하기

기여를 환영합니다! Pull Request를 통해 자유롭게 기여해 주세요.

## 라이센스

이 프로젝트는 MIT 라이센스를 따릅니다 - 자세한 내용은 LICENSE 파일을 참조하세요.

## 감사의 말

- 카미노 데 산티아고 공식 자료
- Flutter 팀과 커뮤니티
- 이 프로젝트에 기여한 모든 분들
