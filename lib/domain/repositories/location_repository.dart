import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_app/domain/models/camino_route.dart';
import 'package:my_flutter_app/domain/models/map_marker.dart';

/// 위치 관련 데이터를 처리하는 리포지토리 인터페이스
abstract class LocationRepository {
  /// 위치 업데이트 스트림을 반환합니다.
  Stream<LatLng> getLocationUpdates();

  /// 주어진 위치가 경로에서 벗어났는지 확인합니다.
  /// [location] 현재 위치
  /// [thresholdMeters] 경로 이탈로 간주할 임계값 (미터)
  Future<bool> isOffRoute(LatLng location, double thresholdMeters);

  /// 현재 위치에 가장 가까운 카미노 스테이지를 반환합니다.
  Future<CaminoStage?> getCurrentStage();

  /// 경로에서 현재 위치와 가장 가까운 점을 찾습니다.
  Future<LatLng> getNearestPointOnRoute(LatLng currentLocation);

  /// 카미노 경로 내부에 있는지 확인합니다 (순례자 모드 자동 활성화용)
  Future<bool> isWithinCaminoRoute(LatLng location, double thresholdMeters);

  // 사용자 위치 관련
  Future<LatLng?> getCurrentLocation();
  Future<bool> isLocationPermissionGranted();
  Future<bool> requestLocationPermission();

  // 카미노 경로 관련
  Future<CaminoRoute> getCaminoRoute();

  // 마커 관련
  Future<List<MapMarker>> getNearbyMarkers(
    LatLng center,
    double radiusKm,
    List<MarkerType> types,
  );

  // 주요 위치 유형별 아이콘 가져오기
  Future<BitmapDescriptor> getMarkerIcon(MarkerType type);
}
