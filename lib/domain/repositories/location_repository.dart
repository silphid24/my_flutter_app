import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_app/domain/models/camino_route.dart';
import 'package:my_flutter_app/domain/models/map_marker.dart';

abstract class LocationRepository {
  // 사용자 위치 관련
  Future<LatLng?> getCurrentLocation();
  Stream<LatLng> getLocationUpdates();
  Future<bool> isLocationPermissionGranted();
  Future<bool> requestLocationPermission();

  // 카미노 경로 관련
  Future<CaminoRoute> getCaminoRoute();
  Future<CaminoStage?> getCurrentStage();

  // 마커 관련
  Future<List<MapMarker>> getNearbyMarkers(
    LatLng center,
    double radiusKm,
    List<MarkerType> types,
  );

  // 경로 이탈 감지
  Future<bool> isOffRoute(LatLng position, double thresholdMeters);

  // 주요 위치 유형별 아이콘 가져오기
  Future<BitmapDescriptor> getMarkerIcon(MarkerType type);
}
