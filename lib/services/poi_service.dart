import 'package:my_flutter_app/models/poi_model.dart';
import 'dart:math' as math;

class PoiService {
  // 싱글톤 패턴 적용
  static final PoiService _instance = PoiService._internal();
  factory PoiService() => _instance;
  PoiService._internal();

  // 목업 POI 데이터
  final List<Poi> _mockPois = [
    Poi(
      id: 'acc1',
      name: '알베르게 오로츠 바탕',
      latitude: 42.9098,
      longitude: -1.8642,
      type: PoiType.accommodation,
      description: '순례자들을 위한 전통적인 알베르게. 공용 숙소와 개인 객실 제공.',
      address: 'Calle Mayor 14, Oroz-Betelu',
      phone: '+34 123456789',
      rating: 4.5,
      imageUrl: 'https://example.com/images/albergue1.jpg',
      facilities: ['Wi-Fi', '아침식사', '세탁실'],
    ),
    Poi(
      id: 'acc2',
      name: '호스텔 에스텔라',
      latitude: 42.9056,
      longitude: -1.8690,
      type: PoiType.accommodation,
      description: '편안한 호스텔. 시내 중심에 위치해 있어 접근성이 좋음.',
      address: 'Plaza Santiago 4, Estella',
      phone: '+34 987654321',
      rating: 4.2,
      imageUrl: 'https://example.com/images/hostel1.jpg',
      facilities: ['Wi-Fi', '개인 사물함', '주방'],
    ),
    Poi(
      id: 'rest1',
      name: '메손 델 카미노',
      latitude: 42.9102,
      longitude: -1.8650,
      type: PoiType.restaurant,
      description: '순례자 메뉴와 현지 요리를 제공하는 레스토랑.',
      address: 'Calle Mayor 8, Pamplona',
      phone: '+34 111222333',
      rating: 4.7,
      imageUrl: 'https://example.com/images/restaurant1.jpg',
    ),
    Poi(
      id: 'rest2',
      name: '타파스 바 산티아고',
      latitude: 42.9080,
      longitude: -1.8670,
      type: PoiType.restaurant,
      description: '다양한 타파스와 리오하 와인을 즐길 수 있는 곳.',
      address: 'Plaza Mayor 10, Logroño',
      phone: '+34 444555666',
      rating: 4.4,
      imageUrl: 'https://example.com/images/restaurant2.jpg',
    ),
    Poi(
      id: 'pharm1',
      name: '산티아고 약국',
      latitude: 42.9110,
      longitude: -1.8645,
      type: PoiType.pharmacy,
      description: '순례자들의 건강 문제를 위한 약국. 영어 서비스 제공.',
      address: 'Calle Santiago 5, Puente la Reina',
      phone: '+34 777888999',
      rating: 4.3,
      imageUrl: 'https://example.com/images/pharmacy1.jpg',
    ),
    Poi(
      id: 'pharm2',
      name: '파르마시아 카미노',
      latitude: 42.9090,
      longitude: -1.8675,
      type: PoiType.pharmacy,
      description: '24시간 운영되는 약국. 응급처치 키트 판매.',
      address: 'Calle Real 21, Leon',
      phone: '+34 000111222',
      rating: 4.1,
      imageUrl: 'https://example.com/images/pharmacy2.jpg',
    ),
    Poi(
      id: 'land1',
      name: '산티아고 데 콤포스텔라 대성당',
      latitude: 42.8806,
      longitude: -8.5446,
      type: PoiType.landmark,
      description: '산티아고 순례길의 종착지, 유네스코 세계문화유산으로 지정된 대성당.',
      address: 'Praza do Obradoiro, Santiago de Compostela',
      phone: '+34 981583548',
      rating: 4.9,
      imageUrl: 'https://example.com/images/cathedral.jpg',
    ),
    Poi(
      id: 'land2',
      name: '팜플로나 성벽',
      latitude: 42.8198,
      longitude: -1.6432,
      type: PoiType.landmark,
      description: '16세기에 지어진 팜플로나의 역사적인 성벽.',
      address: 'Calle Amaya, Pamplona',
      rating: 4.6,
      imageUrl: 'https://example.com/images/walls.jpg',
    ),
  ];

  // 주변 POI 조회 (최대 2개씩 반환)
  Future<Map<PoiType, List<Poi>>> getNearbyPois({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    // 실제 구현에서는 API 호출하거나 DB에서 조회할 것
    await Future.delayed(const Duration(milliseconds: 300)); // API 호출 시뮬레이션

    // POI 타입별로 분류
    final Map<PoiType, List<Poi>> result = {};

    for (final type in PoiType.values) {
      // 타입별로 POI 필터링
      final poisByType = _mockPois.where((poi) => poi.type == type).toList();

      // 거리 계산 및 정렬
      poisByType.sort((a, b) {
        final distA =
            _calculateDistance(latitude, longitude, a.latitude, a.longitude);
        final distB =
            _calculateDistance(latitude, longitude, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });

      // 반경 내에 있는지 확인하고 최대 2개만 선택
      final nearbyPois = poisByType
          .where((poi) =>
              _calculateDistance(
                  latitude, longitude, poi.latitude, poi.longitude) <=
              radiusKm)
          .take(2)
          .toList();

      if (nearbyPois.isNotEmpty) {
        result[type] = nearbyPois;
      }
    }

    return result;
  }

  // 간단한 거리 계산 함수 (Haversine 공식 활용)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 지구 반경 (km)
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // 추천 POI 조회
  Future<List<Poi>> getRecommendedPois() async {
    // 실제 구현에서는 사용자 위치, 선호도 등을 고려하여 추천
    await Future.delayed(const Duration(milliseconds: 300));

    // 랭킹 순으로 상위 5개 POI 추천
    return _mockPois.where((poi) => poi.rating != null).toList()
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0))
      ..take(5).toList();
  }

  // POI 상세 정보 조회
  Future<Poi?> getPoiDetails(String id) async {
    // API 호출 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      return _mockPois.firstWhere((poi) => poi.id == id);
    } catch (e) {
      return null;
    }
  }
}
