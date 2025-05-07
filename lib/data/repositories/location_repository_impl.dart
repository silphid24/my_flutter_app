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
import 'package:my_flutter_app/services/stage_service.dart';
import 'package:my_flutter_app/presentation/features/camino/utils/map_utils.dart';
import 'package:my_flutter_app/utils/stage_converter.dart';

class LocationRepositoryImpl implements LocationRepository {
  final Location _location = Location();
  final StageService _stageService = StageService();
  final GpxService _gpxService = GpxService();

  // 스트림 컨트롤러
  final StreamController<LatLng> _locationStreamController =
      StreamController<LatLng>.broadcast();

  // 카미노 경로 캐싱
  CaminoRoute? _caminoRoute;
  List<LatLng> _completePath = [];

  // 마커 아이콘 캐싱
  final Map<MarkerType, BitmapDescriptor> _markerIcons = {};

  LocationRepositoryImpl() {
    _initLocationService();
  }

  /// 위치 서비스 초기화
  Future<void> _initLocationService() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      // 위치 정확도 설정
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 900000, // 15분(15 * 60 * 1000 = 900,000밀리초)마다 업데이트
      );

      // 위치 업데이트 구독 및 스트림으로 변환
      _location.onLocationChanged.listen((LocationData locationData) {
        if (locationData.latitude != null && locationData.longitude != null) {
          _locationStreamController.add(
            LatLng(locationData.latitude!, locationData.longitude!),
          );
        }
      });

      // 카미노 전체 경로 로드
      await _loadCompletePath();
    } catch (e) {
      debugPrint('위치 서비스 초기화 오류: $e');
    }
  }

  /// 전체 카미노 경로 로드
  Future<void> _loadCompletePath() async {
    try {
      debugPrint('카미노 전체 경로 로드 시작');
      final stageService = StageService();
      final gmapsPoints = stageService.getAllStagesPoints();
      debugPrint('스테이지 포인트 로드 완료: ${gmapsPoints.length}개');

      _completePath = [];
      for (final point in gmapsPoints) {
        _completePath.add(LatLng(point.latitude, point.longitude));
      }

      debugPrint('카미노 전체 경로 로드 완료: ${_completePath.length}개 포인트');
    } catch (e) {
      debugPrint('카미노 경로 로드 오류: $e');
      _completePath = []; // 오류 발생 시 빈 리스트로 초기화
    }
  }

  @override
  Stream<LatLng> getLocationUpdates() {
    return _locationStreamController.stream;
  }

  @override
  Future<bool> isOffRoute(LatLng location, double thresholdMeters) async {
    // 향후 구현 예정: 경로 이탈 감지 기능
    // 현재 버전에서는 항상 경로 내에 있는 것으로 간주

    debugPrint('경로 이탈 감지 기능은 향후 업데이트에서 구현 예정입니다.');
    return false;

    /* 향후 구현 예정 코드:
    if (_completePath.isEmpty) {
      await _loadCompletePath();
      if (_completePath.isEmpty) return false;
    }

    double minDistance = double.infinity;
    for (final pathPoint in _completePath) {
      final distance = MapUtils.calculateDistanceInMeters(
        location,
        pathPoint,
      );

      if (distance < minDistance) {
        minDistance = distance;
      }

      // 임계값보다 가까운 점을 발견하면 경로 이탈이 아님
      if (distance <= thresholdMeters) {
        return false;
      }
    }

    // 모든 점과의 거리가 임계값보다 크면 경로 이탈
    debugPrint('경로 이탈 감지: 최소 거리 ${minDistance}m (임계값: ${thresholdMeters}m)');
    return true;
    */
  }

  @override
  Future<CaminoStage?> getCurrentStage() async {
    final currentLocation = await getCurrentLocation();
    if (currentLocation == null) return null;

    final modelStages = await _stageService.getAllStages();
    if (modelStages.isEmpty) return null;

    CaminoStage? closestStage;
    double minDistance = double.infinity;

    // 각 스테이지를 도메인 모델로 변환하고 가장 가까운 스테이지 찾기
    for (final modelStage in modelStages) {
      // 데이터 모델을 도메인 모델로 변환
      final stage = StageConverter.convertToMapStage(modelStage);

      if (stage.path.isEmpty) continue;

      // 현재 위치와 스테이지 경로 사이의 최소 거리 계산
      double stageMinDistance = double.infinity;
      for (final pathPoint in stage.path) {
        final distance = MapUtils.calculateDistanceInMeters(
          currentLocation,
          pathPoint,
        );

        if (distance < stageMinDistance) {
          stageMinDistance = distance;
        }
      }

      // 가장 가까운 스테이지 갱신
      if (stageMinDistance < minDistance) {
        minDistance = stageMinDistance;
        closestStage = stage;
      }
    }

    return closestStage;
  }

  @override
  Future<LatLng> getNearestPointOnRoute(LatLng currentLocation) async {
    if (_completePath.isEmpty) {
      await _loadCompletePath();
      if (_completePath.isEmpty) return currentLocation;
    }

    double minDistance = double.infinity;
    LatLng nearestPoint = currentLocation;

    for (final pathPoint in _completePath) {
      final distance = MapUtils.calculateDistanceInMeters(
        currentLocation,
        pathPoint,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = pathPoint;
      }
    }

    return nearestPoint;
  }

  @override
  Future<bool> isWithinCaminoRoute(
      LatLng location, double thresholdMeters) async {
    // 향후 구현 예정: 경로 내 위치 확인 기능
    // 현재 버전에서는 항상 경로 내에 있는 것으로 간주
    return true;
  }

  @override
  Future<LatLng?> getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        return LatLng(locationData.latitude!, locationData.longitude!);
      }
    } catch (e) {
      debugPrint('현재 위치 가져오기 오류: $e');
    }
    return null;
  }

  @override
  Future<bool> isLocationPermissionGranted() async {
    PermissionStatus permissionStatus = await _location.hasPermission();
    return permissionStatus == PermissionStatus.granted;
  }

  @override
  Future<bool> requestLocationPermission() async {
    PermissionStatus permissionStatus = await _location.requestPermission();
    return permissionStatus == PermissionStatus.granted;
  }

  @override
  Future<CaminoRoute> getCaminoRoute() async {
    try {
      debugPrint('getCaminoRoute 시작');

      if (_caminoRoute != null) {
        debugPrint('캐시된 카미노 경로 반환');
        return _caminoRoute!;
      }

      debugPrint('모든 스테이지 로드 시작');
      // 모든 스테이지 가져오기
      final stages = await _stageService.getAllStages();
      debugPrint('스테이지 로드 완료: ${stages.length}개');

      debugPrint('도메인 모델로 변환 시작');
      // 도메인 모델로 변환
      final List<CaminoStage> mappedStages = [];
      for (int i = 0; i < stages.length; i++) {
        debugPrint('스테이지 변환 중: ${i + 1}/${stages.length} (${stages[i].id})');
        try {
          final mappedStage = StageConverter.convertToMapStage(stages[i]);
          mappedStages.add(mappedStage);
        } catch (e) {
          debugPrint('스테이지 변환 오류 (${stages[i].id}): $e');
          // 오류가 있는 스테이지는 건너뜀
        }
      }
      debugPrint('도메인 모델 변환 완료: ${mappedStages.length}개');

      debugPrint('카미노 경로 생성');
      // 카미노 경로 생성
      _caminoRoute = CaminoRoute(
        id: 'camino_frances',
        name: '카미노 프란세스',
        description: '생장 피에드포르부터 산티아고 데 콤포스텔라까지의 프랑스 길',
        stages: mappedStages,
      );
      debugPrint('카미노 경로 생성 완료');

      return _caminoRoute!;
    } catch (e, stackTrace) {
      debugPrint('카미노 경로 로드 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');

      // 기본 비어있는 경로 반환 (예외 전파 방지)
      return CaminoRoute(
        id: 'camino_frances_fallback',
        name: '카미노 프란세스',
        description: '데이터 로드 중 오류가 발생했습니다',
        stages: [],
      );
    }
  }

  @override
  Future<List<MapMarker>> getNearbyMarkers(
    LatLng center,
    double radiusKm,
    List<MarkerType> types,
  ) async {
    try {
      // TODO: 실제 POI 데이터베이스나 API 연동 시 확장 필요
      // 현재는 하드코딩된 데모 마커 반환
      List<MapMarker> allMarkers = [
        MapMarker(
          id: 'alb001',
          title: '알베르게 산 요선',
          description: '순례자 전용 숙소, 10€/박',
          position: LatLng(42.8781, -7.4107),
          type: MarkerType.accommodation,
        ),
        MapMarker(
          id: 'alb002',
          title: '알베르게 두 카미노',
          description: '순례자 전용 숙소, 12€/박',
          position: LatLng(42.8755, -7.4198),
          type: MarkerType.accommodation,
        ),
        MapMarker(
          id: 'rest001',
          title: 'Casa Pepe',
          description: '현지 음식, 순례자 메뉴: 10€',
          position: LatLng(42.8764, -7.4154),
          type: MarkerType.restaurant,
        ),
        MapMarker(
          id: 'pharm001',
          title: 'Farmacia Santiago',
          description: '09:00-20:00 영업',
          position: LatLng(42.8792, -7.4135),
          type: MarkerType.pharmacy,
        ),
        MapMarker(
          id: 'wp001',
          title: '산티아고 대성당',
          description: '카미노 프란세스의 최종 목적지',
          position: LatLng(42.8806, -8.5459),
          type: MarkerType.landmark,
        ),
      ];

      // 현재 위치에서 설정된 반경 내에 있는 마커만 필터링
      List<MapMarker> nearbyMarkers = allMarkers.where((marker) {
        // 요청된 마커 타입인지 확인
        if (!types.contains(marker.type)) {
          return false;
        }

        // 거리 계산
        final distance = MapUtils.calculateDistance(
          center.latitude,
          center.longitude,
          marker.position.latitude,
          marker.position.longitude,
        );

        // 지정된 반경 내에 있는지 확인
        return distance <= radiusKm;
      }).toList();

      return nearbyMarkers;
    } catch (e) {
      debugPrint('마커 로드 오류: $e');
      return [];
    }
  }

  @override
  Future<BitmapDescriptor> getMarkerIcon(MarkerType type) async {
    if (_markerIcons.containsKey(type)) {
      return _markerIcons[type]!;
    }

    // 마커 타입에 따라 다른 아이콘 설정
    BitmapDescriptor icon;
    switch (type) {
      case MarkerType.accommodation:
        icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          'assets/icons/albergue_marker.png',
        );
        break;
      case MarkerType.restaurant:
        icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          'assets/icons/restaurant_marker.png',
        );
        break;
      case MarkerType.waypoint:
        icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          'assets/icons/waypoint_marker.png',
        );
        break;
      case MarkerType.landmark:
        icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          'assets/icons/viewpoint_marker.png',
        );
        break;
      case MarkerType.pharmacy:
        icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          'assets/icons/pharmacy_marker.png',
        );
        break;
      case MarkerType.currentLocation:
        // 현재 위치는 파란색 원 아이콘 사용
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      default:
        icon = BitmapDescriptor.defaultMarker;
    }

    _markerIcons[type] = icon;
    return icon;
  }

  /// 리소스 해제
  void dispose() {
    _locationStreamController.close();
  }
}
