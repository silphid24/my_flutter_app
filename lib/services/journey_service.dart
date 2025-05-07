import 'package:my_flutter_app/models/journey_model.dart';

class JourneyService {
  // 싱글톤 패턴 적용
  static final JourneyService _instance = JourneyService._internal();
  factory JourneyService() => _instance;
  JourneyService._internal();

  // 목업 추천 경로 데이터
  final List<Journey> _mockJourneys = [
    Journey(
      id: 'day1',
      title: '1일차: 생장 피에드포르 → 롱세스바예스',
      description: '순례길의 시작, 피레네 산맥을 건너는 첫 번째 구간입니다. 험준한 산길이지만 아름다운 풍경이 기다립니다.',
      startLocation: '생장 피에드포르 (Saint-Jean-Pied-de-Port)',
      endLocation: '롱세스바예스 (Roncesvalles)',
      distance: 25.1,
      estimatedTime: const Duration(hours: 7, minutes: 30),
      difficulty: 5,
      imageUrl: null,
      highlights: ['피레네 산맥 풍경', '국경 통과', '롱세스바예스 수도원'],
      dayNumber: 1,
    ),
    Journey(
      id: 'day2',
      title: '2일차: 롱세스바예스 → 수비리',
      description: '숲과 농촌 지역을 통과하는 평화로운 구간입니다. 스페인 전원 풍경을 감상하세요.',
      startLocation: '롱세스바예스 (Roncesvalles)',
      endLocation: '수비리 (Zubiri)',
      distance: 21.4,
      estimatedTime: const Duration(hours: 6),
      difficulty: 3,
      imageUrl: null,
      highlights: ['중세 다리', '마을 교회', '전통 바스크 가옥'],
      dayNumber: 2,
    ),
    Journey(
      id: 'day3',
      title: '3일차: 수비리 → 팜플로나',
      description: '나바라의 수도 팜플로나로 향하는 구간. 역사적인 도시를 탐험하세요.',
      startLocation: '수비리 (Zubiri)',
      endLocation: '팜플로나 (Pamplona)',
      distance: 19.8,
      estimatedTime: const Duration(hours: 5, minutes: 30),
      difficulty: 2,
      imageUrl: null,
      highlights: ['팜플로나 성벽', '산 니콜라스 성당', '산 피르민 거리'],
      dayNumber: 3,
    ),
    Journey(
      id: 'day4',
      title: '4일차: 팜플로나 → 푸엔테 라 레이나',
      description: '나바라 시골을 통과하며 순례자의 다리가 있는 마을에 도착합니다.',
      startLocation: '팜플로나 (Pamplona)',
      endLocation: '푸엔테 라 레이나 (Puente la Reina)',
      distance: 23.5,
      estimatedTime: const Duration(hours: 6, minutes: 30),
      difficulty: 3,
      imageUrl: null,
      highlights: ['알토 델 페르돈', '순례자의 동상', '로마시대 다리'],
      dayNumber: 4,
    ),
    Journey(
      id: 'day5',
      title: '5일차: 푸엔테 라 레이나 → 에스텔라',
      description: '와인 생산지를 지나며 역사적인 도시 에스텔라로 가는 길입니다.',
      startLocation: '푸엔테 라 레이나 (Puente la Reina)',
      endLocation: '에스텔라 (Estella)',
      distance: 21.6,
      estimatedTime: const Duration(hours: 6),
      difficulty: 2,
      imageUrl: null,
      highlights: ['와인 분수', '성 미구엘 성당', '모나스테리오 데 이라체'],
      dayNumber: 5,
    ),
  ];

  // 추천 경로 조회
  Future<List<Journey>> getRecommendedJourneys({int limit = 3}) async {
    // API 호출 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    // 앞쪽부터 limit 개수만큼 반환 (실제로는 위치, 날짜 등에 따라 추천 알고리즘 적용)
    return _mockJourneys.take(limit).toList();
  }

  // 특정 일차의 경로 조회
  Future<Journey?> getJourneyByDay(int dayNumber) async {
    // API 호출 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      return _mockJourneys
          .firstWhere((journey) => journey.dayNumber == dayNumber);
    } catch (e) {
      return null;
    }
  }

  // 경로 ID로 조회
  Future<Journey?> getJourneyById(String id) async {
    // API 호출 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      return _mockJourneys.firstWhere((journey) => journey.id == id);
    } catch (e) {
      return null;
    }
  }

  // 모든 경로 조회
  Future<List<Journey>> getAllJourneys() async {
    // API 호출 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 300));

    return _mockJourneys;
  }
}
