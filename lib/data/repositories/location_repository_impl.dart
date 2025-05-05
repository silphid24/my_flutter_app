import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:my_flutter_app/domain/models/camino_route.dart';
import 'package:my_flutter_app/domain/models/map_marker.dart';
import 'package:my_flutter_app/domain/repositories/location_repository.dart';
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:my_flutter_app/models/track.dart';
import 'package:my_flutter_app/models/track_point.dart';

class LocationRepositoryImpl implements LocationRepository {
  final Location _location = Location();
  late CaminoRoute _caminoRoute;
  List<Track>? _gpxTracks;
  bool _isInitialized = false;

  // 샘플 데이터 (실제로는 API나 DB에서 가져옴)
  final List<MapMarker> _allMarkers = [
    MapMarker(
      id: 'accom-1',
      title: 'Albergue San Lazaro',
      description: '순례자들이 많이 이용하는 인기 있는 알베르게',
      position: const LatLng(42.7806, -7.4149), // Sarria
      type: MarkerType.accommodation,
    ),
    MapMarker(
      id: 'accom-2',
      title: 'Albergue Portomarin',
      description: '포르토마린 중심부에 위치한 알베르게',
      position: const LatLng(42.8042, -7.6153), // Portomarín
      type: MarkerType.accommodation,
    ),
    MapMarker(
      id: 'rest-1',
      title: 'Cafe del Camino',
      description: '순례자들을 위한 카페 및 레스토랑',
      position: const LatLng(42.7826, -7.4169), // Near Sarria
      type: MarkerType.restaurant,
    ),
    MapMarker(
      id: 'rest-2',
      title: 'Restaurant O Mirador',
      description: '갈리시아 전통 음식을 맛볼 수 있는 레스토랑',
      position: const LatLng(42.8052, -7.6143), // Near Portomarín
      type: MarkerType.restaurant,
    ),
    MapMarker(
      id: 'pharm-1',
      title: 'Farmacia Sarria',
      description: '사리아 중심부에 위치한 약국',
      position: const LatLng(42.7816, -7.4159), // Near Sarria
      type: MarkerType.pharmacy,
    ),
    MapMarker(
      id: 'pharm-2',
      title: 'Farmacia Portomarín',
      description: '포르토마린 약국',
      position: const LatLng(42.8047, -7.6163), // Near Portomarín
      type: MarkerType.pharmacy,
    ),
    MapMarker(
      id: 'landmark-1',
      title: 'Iglesia de San Salvador',
      description: '사리아의 역사적인 교회',
      position: const LatLng(42.7811, -7.4144), // Sarria
      type: MarkerType.landmark,
    ),
    MapMarker(
      id: 'landmark-2',
      title: 'Iglesia de San Juan',
      description: '포르토마린의 유명한 로마네스크 교회',
      position: const LatLng(42.8037, -7.6158), // Portomarín
      type: MarkerType.landmark,
    ),
    MapMarker(
      id: 'accom-sjpdp',
      title: 'Albergue Ultreia',
      description: '생장 피드 포르트 순례자 숙소',
      position: const LatLng(43.1634, -1.2374), // Saint Jean
      type: MarkerType.accommodation,
    ),
    MapMarker(
      id: 'accom-roncesvalles',
      title: 'Albergue de Peregrinos de Roncesvalles',
      description: '론세스바예스 순례자 숙소',
      position: const LatLng(43.0096, -1.3195), // Roncesvalles
      type: MarkerType.accommodation,
    ),
    MapMarker(
      id: 'landmark-sjpdp',
      title: 'Puerta de Santiago',
      description: '생장 피드 포르트의 산티아고 문',
      position: const LatLng(43.1636, -1.2368),
      type: MarkerType.landmark,
    ),
    MapMarker(
      id: 'landmark-roncesvalles',
      title: 'Colegiata de Roncesvalles',
      description: '론세스바예스 순례자 교회',
      position: const LatLng(43.0092, -1.3197),
      type: MarkerType.landmark,
    ),
  ];

  StreamController<LatLng>? _locationController;

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // 모든 스테이지 GPX 파일 로드
      _gpxTracks = await _loadAllGpxTracks();

      if (_gpxTracks != null && _gpxTracks!.isNotEmpty) {
        // GPX 트랙을 사용하여 CaminoRoute 생성
        _caminoRoute = await _createCaminoRouteFromGpxTracks(_gpxTracks!);
      } else {
        // GPX 로드 실패 시 기본 경로 생성
        _caminoRoute = _createDefaultCaminoRoute();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('경로 초기화 오류: $e');
      // 오류 발생 시 기본 경로 사용
      _caminoRoute = _createDefaultCaminoRoute();
      _isInitialized = true;
    }
  }

  // 모든 스테이지 GPX 파일 로드
  Future<List<Track>> _loadAllGpxTracks() async {
    final gpxService = GpxService();
    List<Track> tracks = [];

    try {
      // 파일 이름 패턴 생성
      List<String> stageFiles = [];

      // Stage 1~33 파일 이름 생성 (Stage-27-28은 특별 처리)
      for (int i = 1; i <= 33; i++) {
        if (i == 27 || i == 28) {
          if (!stageFiles.contains(
            'assets/data/Stages-27-28.-Camino-Frances.gpx',
          )) {
            stageFiles.add('assets/data/Stages-27-28.-Camino-Frances.gpx');
          }
        } else {
          if (i == 1) {
            stageFiles.add('assets/data/Stage-1-Camino-Frances.gpx');
          } else {
            stageFiles.add('assets/data/Stage-$i.-Camino-Frances.gpx');
          }
        }
      }

      // 디버깅: 로드할 파일 목록 출력
      debugPrint('로드할 스테이지 파일 목록: ${stageFiles.join(', ')}');

      // 각 파일 로드
      for (String file in stageFiles) {
        try {
          Track? track = await gpxService.loadGpxFromAsset(file);
          if (track != null) {
            // 트랙 이름 설정 (파일 이름에서 추출)
            String stageName = file.split('/').last;
            stageName = stageName
                .replaceAll('Stage-', '')
                .replaceAll('Stages-', '');
            stageName = stageName
                .replaceAll('-Camino-Frances.gpx', '')
                .replaceAll('.-Camino-Frances.gpx', '');

            // Stage 번호와 이름을 매핑
            String fullName = _getStageFullName(stageName);
            track = Track(
              id: 'stage_${stageName.replaceAll('-', '_')}',
              name: fullName,
              type: 'walking',
              points: track.points,
              createdAt: DateTime.now(),
            );

            tracks.add(track);
            debugPrint(
              '로드됨: $file (${track.name}, 포인트 수: ${track.points.length})',
            );
          }
        } catch (e) {
          debugPrint('파일 로드 오류: $file - $e');
        }
      }

      // 스테이지 순서대로 정렬
      tracks.sort((a, b) {
        // Stage 1을 항상 첫 번째로
        if (a.name.contains('Saint-Jean') ?? false) return -1;
        if (b.name.contains('Saint-Jean') ?? false) return 1;

        // 숫자로 정렬
        int? numA = _extractStageNumber(a.name ?? '');
        int? numB = _extractStageNumber(b.name ?? '');

        if (numA != null && numB != null) {
          return numA.compareTo(numB);
        }

        return (a.name ?? '').compareTo(b.name ?? '');
      });

      debugPrint('총 로드된 스테이지 수: ${tracks.length}');
      for (int i = 0; i < tracks.length; i++) {
        debugPrint('스테이지 #${i + 1}: ${tracks[i].name}');
      }
    } catch (e) {
      debugPrint('GPX 트랙 로드 오류: $e');
    }

    return tracks;
  }

  // 스테이지 이름 매핑
  String _getStageFullName(String stageId) {
    final Map<String, String> stageNames = {
      '1': 'Saint-Jean-Pied-de-Port → Roncesvalles',
      '2': 'Roncesvalles → Zubiri',
      '3': 'Zubiri → Pamplona',
      '4': 'Pamplona → Puente la Reina',
      '5': 'Puente la Reina → Estella',
      '6': 'Estella → Los Arcos',
      '7': 'Los Arcos → Logroño',
      '8': 'Logroño → Nájera',
      '9': 'Nájera → Santo Domingo de la Calzada',
      '10': 'Santo Domingo de la Calzada → Belorado',
      '11': 'Belorado → San Juan de Ortega',
      '12': 'San Juan de Ortega → Burgos',
      '13': 'Burgos → Hontanas',
      '14': 'Hontanas → Boadilla del Camino',
      '15': 'Boadilla del Camino → Carrión de los Condes',
      '16': 'Carrión de los Condes → Terradillos de los Templarios',
      '17': 'Terradillos de los Templarios → El Burgo Ranero',
      '18': 'El Burgo Ranero → León',
      '19': 'León → San Martín del Camino',
      '20': 'San Martín del Camino → Astorga',
      '21': 'Astorga → Rabanal del Camino',
      '22': 'Rabanal del Camino → Ponferrada',
      '23': 'Ponferrada → Villafranca del Bierzo',
      '24': 'Villafranca del Bierzo → O Cebreiro',
      '25': 'O Cebreiro → Triacastela',
      '26': 'Triacastela → Sarria',
      '27-28': 'Sarria → Portomarín → Palas de Rei',
      '29': 'Palas de Rei → Arzúa',
      '30': 'Arzúa → O Pedrouzo',
      '31': 'O Pedrouzo → Santiago de Compostela',
      '32': 'Santiago de Compostela → Negreira',
      '33': 'Negreira → Olveiroa',
    };

    return stageNames[stageId] ?? '스테이지 $stageId';
  }

  // 스테이지 이름에서 번호 추출
  int? _extractStageNumber(String stageName) {
    // "27-28" 같은 복합 스테이지 처리
    if (stageName.contains('-')) {
      try {
        return int.parse(stageName.split('-')[0]);
      } catch (e) {
        return null;
      }
    }

    // 일반 숫자 추출
    RegExp regExp = RegExp(r'(\d+)');
    Match? match = regExp.firstMatch(stageName);
    if (match != null) {
      try {
        return int.parse(match.group(1) ?? '');
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  Future<CaminoRoute> _createCaminoRouteFromGpxTracks(
    List<Track> tracks,
  ) async {
    List<CaminoStage> stages = [];

    // 스테이지별 색상 (순환)
    List<Color> stageColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    // 각 트랙을 하나의 스테이지로 변환
    for (int i = 0; i < tracks.length; i++) {
      final track = tracks[i];
      final stageName = track.name ?? 'Stage ${i + 1}';

      // 경로 포인트 추출 및 변환
      List<LatLng> routePath =
          track.points
              .map(
                (point) =>
                    LatLng(point.position.latitude, point.position.longitude),
              )
              .toList();

      // 경로가 너무 길면 샘플링하여 포인트 수 줄이기
      if (routePath.length > 300) {
        routePath = _samplePoints(routePath, 300);
      }

      // 거리 계산 (대략적인 거리)
      double distanceKm = 0;
      for (int j = 0; j < routePath.length - 1; j++) {
        distanceKm += _calculateDistance(routePath[j], routePath[j + 1]) / 1000;
      }

      // 고도 변화 계산 (대략적인 값, GPX에서 추출 가능하면 사용)
      double elevationGain = 0;
      for (int j = 0; j < track.points.length - 1; j++) {
        double diff =
            (track.points[j + 1].elevation ?? 0) -
            (track.points[j].elevation ?? 0);
        if (diff > 0) elevationGain += diff;
      }

      // 난이도 결정 (거리와 고도 변화에 따라)
      String difficulty;
      if (distanceKm > 25 || elevationGain > 800) {
        difficulty = 'Hard';
      } else if (distanceKm > 20 || elevationGain > 500) {
        difficulty = 'Moderate';
      } else {
        difficulty = 'Easy';
      }

      // 예상 소요 시간 (4km/h 기준)
      int minutes = (distanceKm * 60 / 4).round();

      // 스테이지 생성
      CaminoStage stage = CaminoStage(
        id: 'stage-${i + 1}',
        name: stageName,
        description: '카미노 프란세스 스테이지 ${i + 1}',
        distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
        elevationGainM: elevationGain,
        path: routePath,
        estimatedTime: Duration(minutes: minutes),
        difficulty: difficulty,
        color: stageColors[i % stageColors.length], // 색상 순환 할당
      );

      stages.add(stage);
    }

    // 전체 경로를 담은 CaminoRoute 생성
    return CaminoRoute(
      id: 'camino-frances-full',
      name: 'Camino Frances',
      description: '생장에서 산티아고까지의 카미노 프란세스 전체 경로',
      stages: stages,
    );
  }

  List<LatLng> _samplePoints(List<LatLng> points, int targetCount) {
    if (points.length <= targetCount) return points;

    // 균등한 간격으로 샘플링
    List<LatLng> sampled = [];
    double interval = points.length / targetCount;

    for (int i = 0; i < targetCount; i++) {
      int index = (i * interval).floor();
      if (index >= points.length) index = points.length - 1;
      sampled.add(points[index]);
    }

    // 시작점과 끝점은 반드시 포함
    if (sampled.first != points.first) sampled[0] = points.first;
    if (sampled.last != points.last) sampled[sampled.length - 1] = points.last;

    return sampled;
  }

  // 경로의 일부분을 추출하는 헬퍼 함수
  List<LatLng> _extractPathSegment(List<LatLng> fullPath, int start, int end) {
    if (start < 0) start = 0;
    if (end >= fullPath.length) end = fullPath.length - 1;

    return fullPath.sublist(start, end);
  }

  CaminoRoute _createDefaultCaminoRoute() {
    // GPX 로드 실패 시 사용할 기본 경로
    return CaminoRoute(
      id: 'camino-frances-stage-1',
      name: 'Camino Frances - Stage 1',
      description: '카미노 프란세스의 첫 번째 구간',
      stages: [
        CaminoStage(
          id: 'sjpdp-roncesvalles',
          name: 'Saint-Jean-Pied-de-Port → Roncesvalles',
          description: '피레네 산맥을 넘는 첫 번째 구간',
          distanceKm: 25.1,
          elevationGainM: 1200,
          path: [
            // 단순화된 경로
            const LatLng(43.1634, -1.2374), // Saint-Jean
            const LatLng(43.1589, -1.2412),
            const LatLng(43.1523, -1.2467),
            const LatLng(43.1445, -1.2518),
            const LatLng(43.1387, -1.2602),
            const LatLng(43.1310, -1.2691),
            const LatLng(43.1225, -1.2784),
            const LatLng(43.1156, -1.2839),
            const LatLng(43.1078, -1.2907),
            const LatLng(43.0974, -1.2989),
            const LatLng(43.0847, -1.3078),
            const LatLng(43.0096, -1.3195), // Roncesvalles
          ],
          estimatedTime: const Duration(hours: 8),
          difficulty: 'Hard',
        ),
        CaminoStage(
          id: 'roncesvalles-zubiri',
          name: 'Roncesvalles → Zubiri',
          description: '피레네 산맥을 지나 완만한 구간으로 들어서는 길',
          distanceKm: 22.0,
          elevationGainM: 570,
          path: [
            const LatLng(43.0096, -1.3195), // Roncesvalles
            const LatLng(43.0050, -1.3300),
            const LatLng(42.9950, -1.3400),
            const LatLng(42.9800, -1.3500),
            const LatLng(42.9600, -1.4000),
            const LatLng(42.9519, -1.4950), // Zubiri
          ],
          estimatedTime: const Duration(hours: 6),
          difficulty: 'Moderate',
        ),
        CaminoStage(
          id: 'zubiri-pamplona',
          name: 'Zubiri → Pamplona',
          description: '카미노 프란세스의 주요 도시 팜플로나로 향하는 구간',
          distanceKm: 20.5,
          elevationGainM: 300,
          path: [
            const LatLng(42.9519, -1.4950), // Zubiri
            const LatLng(42.9400, -1.5100),
            const LatLng(42.9300, -1.5300),
            const LatLng(42.9200, -1.5500),
            const LatLng(42.9100, -1.6000),
            const LatLng(42.8167, -1.6333), // Pamplona
          ],
          estimatedTime: const Duration(hours: 5, minutes: 30),
          difficulty: 'Easy',
        ),
      ],
    );
  }

  @override
  Future<LatLng?> getCurrentLocation() async {
    if (!await isLocationPermissionGranted()) {
      await requestLocationPermission();
    }

    try {
      final locationData = await _location.getLocation();
      return LatLng(locationData.latitude!, locationData.longitude!);
    } catch (e) {
      debugPrint('위치를 가져오는 중 오류 발생: $e');
      // 오류 발생 시 기본 위치를 생장 피드 포르트로 설정
      return const LatLng(43.1634, -1.2374); // Saint-Jean
    }
  }

  @override
  Stream<LatLng> getLocationUpdates() {
    if (_locationController == null) {
      _locationController = StreamController<LatLng>.broadcast();

      _setupLocationUpdates();
    }

    return _locationController!.stream;
  }

  void _setupLocationUpdates() async {
    if (!await isLocationPermissionGranted()) {
      await requestLocationPermission();
    }

    _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 3000, // 3초마다 위치 업데이트
      distanceFilter: 5, // 5미터 이상 움직였을 때만 업데이트
    );

    _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        _locationController?.add(
          LatLng(locationData.latitude!, locationData.longitude!),
        );
      }
    });
  }

  @override
  Future<bool> isLocationPermissionGranted() async {
    var permissionStatus = await _location.hasPermission();
    return permissionStatus == PermissionStatus.granted;
  }

  @override
  Future<bool> requestLocationPermission() async {
    var permissionStatus = await _location.requestPermission();
    return permissionStatus == PermissionStatus.granted;
  }

  @override
  Future<CaminoRoute> getCaminoRoute() async {
    await _initialize();
    return _caminoRoute;
  }

  @override
  Future<CaminoStage?> getCurrentStage() async {
    await _initialize();

    // 현재 위치 확인
    LatLng? currentLocation = await getCurrentLocation();

    if (currentLocation == null) {
      // 위치를 확인할 수 없는 경우 첫 번째 스테이지 반환
      return _caminoRoute.stages.first;
    }

    // 가장 가까운 스테이지 찾기
    CaminoStage? closestStage;
    double minDistance = double.infinity;

    for (var stage in _caminoRoute.stages) {
      for (var point in stage.path) {
        double distance = _calculateDistance(currentLocation, point);
        if (distance < minDistance) {
          minDistance = distance;
          closestStage = stage;
        }
      }
    }

    // 가장 가까운 스테이지 또는 없으면 첫번째 스테이지 반환
    return closestStage ?? _caminoRoute.stages.first;
  }

  @override
  Future<List<MapMarker>> getNearbyMarkers(
    LatLng center,
    double radiusKm,
    List<MarkerType> types,
  ) async {
    // 실제로는 DB 쿼리나 API 호출로 가져옴
    // 여기서는 간단한 구현을 위해 하드코딩된 마커 중 타입에 맞는 것만 반환
    return _allMarkers.where((marker) => types.contains(marker.type)).toList();
  }

  @override
  Future<bool> isOffRoute(LatLng position, double thresholdMeters) async {
    CaminoStage? currentStage = await getCurrentStage();
    if (currentStage == null) return false;

    // 현재 스테이지의 모든 경로 포인트에 대해 최소 거리 계산
    double minDistance = double.infinity;

    for (var point in currentStage.path) {
      double distance = _calculateDistance(position, point);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    // 임계값(thresholdMeters)보다 최소 거리가 크면 경로 이탈로 간주
    return minDistance > thresholdMeters;
  }

  // 두 위치 간의 대략적인 거리를 미터 단위로 계산 (Haversine 공식)
  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371000; // 지구 반경 (미터)
    double lat1Rad = pos1.latitude * (math.pi / 180);
    double lat2Rad = pos2.latitude * (math.pi / 180);
    double deltaLatRad = (pos2.latitude - pos1.latitude) * (math.pi / 180);
    double deltaLngRad = (pos2.longitude - pos1.longitude) * (math.pi / 180);

    double a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  @override
  Future<BitmapDescriptor> getMarkerIcon(MarkerType type) async {
    try {
      switch (type) {
        case MarkerType.accommodation:
          return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          );
        case MarkerType.restaurant:
          return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          );
        case MarkerType.pharmacy:
          return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta,
          );
        case MarkerType.landmark:
          return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          );
        case MarkerType.waypoint:
          return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        case MarkerType.currentLocation:
          return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          );
        default:
          return BitmapDescriptor.defaultMarker;
      }
    } catch (e) {
      debugPrint('마커 아이콘 생성 실패: $e');
      // 실패 시 대체 방법으로 컬러 원형 마커 생성
      return _createColoredCircleMarker(type);
    }
  }

  // 커스텀 컬러 마커 생성 (아이콘 로드 실패 시 대체용)
  BitmapDescriptor _createColoredCircleMarker(MarkerType type) {
    Color color;
    switch (type) {
      case MarkerType.accommodation:
        color = Colors.blue;
        break;
      case MarkerType.restaurant:
        color = Colors.orange;
        break;
      case MarkerType.pharmacy:
        color = Colors.purple;
        break;
      case MarkerType.landmark:
        color = Colors.green;
        break;
      case MarkerType.waypoint:
        color = Colors.red;
        break;
      case MarkerType.currentLocation:
        color = Colors.blue.shade400;
        break;
      default:
        color = Colors.grey;
    }

    return BitmapDescriptor.defaultMarkerWithHue(HSVColor.fromColor(color).hue);
  }

  // 리소스 정리
  void dispose() {
    _locationController?.close();
    _locationController = null;
  }
}
