import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/models/poi_model.dart';
import 'dart:math' as math;

class PoiService {
  // 싱글톤 패턴
  static final PoiService _instance = PoiService._internal();
  factory PoiService() => _instance;
  PoiService._internal();

  // 모든 POI 데이터 캐시
  List<PointOfInterest> _allPois = [];
  // POI 필터링 설정
  Set<PoiType> _visibleTypes = Set<PoiType>.from(PoiType.values);

  static const String _visibleTypesKey = 'visible_poi_types';
  static const String _favoritesKey = 'favorite_pois';
  Set<String> _favoritePois = {};

  // 목업 POI 데이터
  final List<Poi> _mockPois = [
    Poi(
      id: 'acc1',
      name: '알베르게 오로츠 바탕',
      latitude: 42.9098,
      longitude: -1.8642,
      type: PoiType.albergue,
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
      type: PoiType.hotel,
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
      type: PoiType.bar,
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
      type: PoiType.medical,
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
      type: PoiType.medical,
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
      type: PoiType.monument,
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
      type: PoiType.monument,
      description: '16세기에 지어진 팜플로나의 역사적인 성벽.',
      address: 'Calle Amaya, Pamplona',
      rating: 4.6,
      imageUrl: 'https://example.com/images/walls.jpg',
    ),
  ];

  // POI 데이터 로드
  Future<List<PointOfInterest>> loadPois() async {
    if (_allPois.isNotEmpty) {
      return _allPois;
    }

    try {
      // assets/data/camino_pois.json 파일에서 데이터 로드
      final String data =
          await rootBundle.loadString('assets/data/camino_pois.json');
      final List<dynamic> poisJson = json.decode(data);

      _allPois =
          poisJson.map((json) => PointOfInterest.fromJson(json)).toList();

      // 즐겨찾기 목록 로드
      await _loadFavorites();

      return _allPois;
    } catch (e) {
      print('POI 데이터 로드 중 오류: $e');

      // 오류 발생 시 기본 데이터 제공
      _allPois = _buildSamplePois();
      return _allPois;
    }
  }

  // 필터링된 POI 목록 가져오기
  Future<List<PointOfInterest>> getFilteredPois() async {
    if (_allPois.isEmpty) {
      await loadPois();
    }

    // 필터링된 POI 목록 반환
    return _allPois.where((poi) => _visibleTypes.contains(poi.type)).toList();
  }

  // 특정 스테이지의 POI 목록 가져오기
  Future<List<PointOfInterest>> getPoisByStage(int stageNumber) async {
    if (_allPois.isEmpty) {
      await loadPois();
    }

    return _allPois
        .where((poi) =>
            poi.stageNumber == stageNumber && _visibleTypes.contains(poi.type))
        .toList();
  }

  // 특정 POI 유형의 가시성 설정
  Future<void> setPoiTypeVisibility(PoiType type, bool isVisible) async {
    if (isVisible) {
      _visibleTypes.add(type);
    } else {
      _visibleTypes.remove(type);
    }

    // 설정 저장
    await _saveVisibleTypes();
  }

  // POI 유형 필터 초기화
  Future<void> resetPoiTypeFilters() async {
    _visibleTypes = Set<PoiType>.from(PoiType.values);
    await _saveVisibleTypes();
  }

  // 모든 POI 유형 숨기기
  Future<void> hideAllPoiTypes() async {
    _visibleTypes.clear();
    await _saveVisibleTypes();
  }

  // POI를 즐겨찾기에 추가/제거
  Future<bool> toggleFavorite(String poiId) async {
    if (_favoritePois.contains(poiId)) {
      _favoritePois.remove(poiId);
    } else {
      _favoritePois.add(poiId);
    }

    // 즐겨찾기 저장
    await _saveFavorites();
    return _favoritePois.contains(poiId);
  }

  // 즐겨찾기 POI 목록 가져오기
  Future<List<PointOfInterest>> getFavoritePois() async {
    if (_allPois.isEmpty) {
      await loadPois();
    }

    return _allPois.where((poi) => _favoritePois.contains(poi.id)).toList();
  }

  // POI가 즐겨찾기에 있는지 확인
  bool isFavorite(String poiId) {
    return _favoritePois.contains(poiId);
  }

  // 필터 설정 저장
  Future<void> _saveVisibleTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typesStrList =
          _visibleTypes.map((type) => type.toString().split('.').last).toList();
      await prefs.setStringList(_visibleTypesKey, typesStrList);
    } catch (e) {
      print('POI 필터 설정 저장 중 오류: $e');
    }
  }

  // 필터 설정 로드
  Future<void> _loadVisibleTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typesStrList = prefs.getStringList(_visibleTypesKey);

      if (typesStrList != null && typesStrList.isNotEmpty) {
        _visibleTypes.clear();

        for (final typeStr in typesStrList) {
          for (final type in PoiType.values) {
            if (type.toString().split('.').last == typeStr) {
              _visibleTypes.add(type);
              break;
            }
          }
        }
      } else {
        // 기본값: 모든 POI 유형 표시
        _visibleTypes = Set<PoiType>.from(PoiType.values);
      }
    } catch (e) {
      print('POI 필터 설정 로드 중 오류: $e');
      // 기본값: 모든 POI 유형 표시
      _visibleTypes = Set<PoiType>.from(PoiType.values);
    }
  }

  // 즐겨찾기 저장
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoritePois.toList());
    } catch (e) {
      print('즐겨찾기 저장 중 오류: $e');
    }
  }

  // 즐겨찾기 로드
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList(_favoritesKey);

      if (favoritesList != null) {
        _favoritePois = Set<String>.from(favoritesList);
      }
    } catch (e) {
      print('즐겨찾기 로드 중 오류: $e');
      _favoritePois = {};
    }
  }

  // 샘플 POI 데이터 생성 (파일 로드 실패 시 사용)
  List<PointOfInterest> _buildSamplePois() {
    return [
      PointOfInterest(
        id: 'albergue1',
        name: 'Albergue de Peregrinos de Roncesvalles',
        type: PoiType.albergue,
        position: LatLng(43.009275, -1.319519),
        description: '론세스바예스의 대표적인 순례자 숙소',
        stageNumber: 1,
      ),
      PointOfInterest(
        id: 'church1',
        name: 'Colegiata de Roncesvalles',
        type: PoiType.church,
        position: LatLng(43.009100, -1.319750),
        description: '12세기에 건립된 고딕 양식의 교회',
        stageNumber: 1,
      ),
      PointOfInterest(
        id: 'fountain1',
        name: 'Fuente de Roldán',
        type: PoiType.fountain,
        position: LatLng(43.008954, -1.321093),
        description: '론세스바예스의 유명한 식수대',
        stageNumber: 1,
      ),
      PointOfInterest(
        id: 'restaurant1',
        name: 'La Posada de Roncesvalles',
        type: PoiType.restaurant,
        position: LatLng(43.009368, -1.318878),
        description: '지역 특산물을 활용한 음식을 제공하는 식당',
        stageNumber: 1,
      ),
      PointOfInterest(
        id: 'hotel1',
        name: 'Hotel Roncesvalles',
        type: PoiType.hotel,
        position: LatLng(43.009502, -1.319010),
        description: '론세스바예스의 유일한 호텔',
        stageNumber: 1,
      ),
    ];
  }

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
