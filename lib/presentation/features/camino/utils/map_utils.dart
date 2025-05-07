import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:flutter_map/flutter_map.dart';
import 'package:my_flutter_app/models/track.dart';
import 'dart:math' as math;

/// MapUtils
///
/// 다양한 지도 라이브러리 간 변환을 위한 유틸리티 메소드를 제공합니다.
class MapUtils {
  /// Create a marker for the flutter_map package
  static Marker createFlutterMapMarker({
    required latlong2.LatLng position,
    required Widget child,
    double width = 40,
    double height = 40,
  }) {
    return Marker(
      point: position,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Create a polyline for the flutter_map package
  static Polyline createFlutterMapPolyline({
    required List<latlong2.LatLng> points,
    Color color = Colors.blue,
    double strokeWidth = 4.0,
  }) {
    return Polyline(
      points: points,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  /// Create a marker for the Google Maps
  static gmaps.Marker createGoogleMapMarker({
    required gmaps.LatLng position,
    required String id,
    gmaps.BitmapDescriptor? icon,
    String? title,
    String? snippet,
  }) {
    return gmaps.Marker(
      markerId: gmaps.MarkerId(id),
      position: position,
      icon: icon ?? gmaps.BitmapDescriptor.defaultMarker,
      infoWindow: gmaps.InfoWindow(
        title: title,
        snippet: snippet,
      ),
    );
  }

  /// Create a polyline for the Google Maps
  static gmaps.Polyline createGoogleMapPolyline({
    required List<gmaps.LatLng> points,
    required String id,
    Color color = Colors.blue,
    int width = 4,
  }) {
    return gmaps.Polyline(
      polylineId: gmaps.PolylineId(id),
      points: points,
      color: color,
      width: width,
    );
  }

  /// LatLng (latlong2) -> LatLng (Google Maps) 변환
  static gmaps.LatLng convertToGoogleLatLng(latlong2.LatLng point) {
    return gmaps.LatLng(point.latitude, point.longitude);
  }

  /// LatLng (Google Maps) -> LatLng (latlong2) 변환
  static latlong2.LatLng convertFromGoogleLatLng(gmaps.LatLng point) {
    return latlong2.LatLng(point.latitude, point.longitude);
  }

  /// LatLng 리스트 (latlong2) -> LatLng 리스트 (Google Maps) 변환
  static List<gmaps.LatLng> convertListToGoogleLatLng(
      List<latlong2.LatLng> points) {
    return points
        .map((point) => gmaps.LatLng(point.latitude, point.longitude))
        .toList();
  }

  /// LatLng 리스트 (Google Maps) -> LatLng 리스트 (latlong2) 변환
  static List<latlong2.LatLng> convertListFromGoogleLatLng(
      List<gmaps.LatLng> points) {
    return points
        .map((point) => latlong2.LatLng(point.latitude, point.longitude))
        .toList();
  }

  /// 두 지점 간 거리 계산 (km)
  static double calculateDistance(
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
    return earthRadius * c;
  }

  /// Google Maps LatLng 두 지점 간 거리 계산 (미터)
  static double calculateDistanceInMeters(
      gmaps.LatLng point1, gmaps.LatLng point2) {
    const double earthRadius = 6371000; // 지구 반경 (미터)
    final double lat1Rad = _degreesToRadians(point1.latitude);
    final double lat2Rad = _degreesToRadians(point2.latitude);
    final double dLat = _degreesToRadians(point2.latitude - point1.latitude);
    final double dLon = _degreesToRadians(point2.longitude - point1.longitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // 헬퍼 메소드
  static double _degreesToRadians(double degrees) => degrees * (math.pi / 180);

  /// Track에서 경로 포인트 추출 (FlutterMap용)
  static List<latlong2.LatLng> extractRoutePointsForFlutterMap(Track track) {
    return track.points
        .map((point) =>
            latlong2.LatLng(point.position.latitude, point.position.longitude))
        .toList();
  }

  /// Track에서 경로 포인트 추출 (GoogleMap용)
  static List<gmaps.LatLng> extractRoutePointsForGoogleMap(Track track) {
    return track.points
        .map((point) =>
            gmaps.LatLng(point.position.latitude, point.position.longitude))
        .toList();
  }
}

/// 위치 계산 유틸리티
class LocationUtils {
  /// 킬로미터 단위로 두 지점 간 거리 계산 (FlutterMap용)
  static double calculateDistanceForFlutterMap(
      latlong2.LatLng point1, latlong2.LatLng point2) {
    const latlong2.Distance distance = latlong2.Distance();
    return distance.as(latlong2.LengthUnit.Kilometer, point1, point2);
  }

  /// 킬로미터 단위로 두 지점 간 거리 계산 (GoogleMap용)
  static double calculateDistanceForGoogleMap(
      gmaps.LatLng point1, gmaps.LatLng point2) {
    return MapUtils.calculateDistance(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// 두 좌표 사이의 중심점 찾기 (FlutterMap용)
  static latlong2.LatLng findCenterBetweenPointsForFlutterMap(
      latlong2.LatLng point1, latlong2.LatLng point2) {
    final centerLat = (point1.latitude + point2.latitude) / 2;
    final centerLng = (point1.longitude + point2.longitude) / 2;
    return latlong2.LatLng(centerLat, centerLng);
  }

  /// 두 좌표 사이의 중심점 찾기 (GoogleMap용)
  static gmaps.LatLng findCenterBetweenPointsForGoogleMap(
      gmaps.LatLng point1, gmaps.LatLng point2) {
    final centerLat = (point1.latitude + point2.latitude) / 2;
    final centerLng = (point1.longitude + point2.longitude) / 2;
    return gmaps.LatLng(centerLat, centerLng);
  }

  /// 주어진 위치가 경로 내에 있는지 확인 (경로 이탈 감지) - FlutterMap용
  static bool isWithinRouteForFlutterMap(
    latlong2.LatLng currentLocation,
    List<latlong2.LatLng> routePoints,
    double thresholdKm,
  ) {
    if (routePoints.isEmpty) return false;

    // 경로의 모든 점과 비교하여 임계값 내에 있는지 확인
    for (final routePoint in routePoints) {
      final distance =
          calculateDistanceForFlutterMap(currentLocation, routePoint);
      if (distance <= thresholdKm) {
        return true; // 임계값 내에 있으면 경로 내에 있음
      }
    }

    return false; // 모든 점이 임계값보다 멀면 경로 이탈
  }

  /// 주어진 위치가 경로 내에 있는지 확인 (경로 이탈 감지) - GoogleMap용
  static bool isWithinRouteForGoogleMap(
    gmaps.LatLng currentLocation,
    List<gmaps.LatLng> routePoints,
    double thresholdKm,
  ) {
    if (routePoints.isEmpty) return false;

    // 경로의 모든 점과 비교하여 임계값 내에 있는지 확인
    for (final routePoint in routePoints) {
      final distance =
          calculateDistanceForGoogleMap(currentLocation, routePoint);
      if (distance <= thresholdKm) {
        return true; // 임계값 내에 있으면 경로 내에 있음
      }
    }

    return false; // 모든 점이 임계값보다 멀면 경로 이탈
  }

  /// 경로에서 가장 가까운 점 찾기 - FlutterMap용
  static latlong2.LatLng findNearestPointOnRouteForFlutterMap(
    latlong2.LatLng currentLocation,
    List<latlong2.LatLng> routePoints,
  ) {
    if (routePoints.isEmpty) return currentLocation;

    latlong2.LatLng nearestPoint = routePoints.first;
    double minDistance =
        calculateDistanceForFlutterMap(currentLocation, nearestPoint);

    for (final routePoint in routePoints) {
      final distance =
          calculateDistanceForFlutterMap(currentLocation, routePoint);
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = routePoint;
      }
    }

    return nearestPoint;
  }

  /// 경로에서 가장 가까운 점 찾기 - GoogleMap용
  static gmaps.LatLng findNearestPointOnRouteForGoogleMap(
    gmaps.LatLng currentLocation,
    List<gmaps.LatLng> routePoints,
  ) {
    if (routePoints.isEmpty) return currentLocation;

    gmaps.LatLng nearestPoint = routePoints.first;
    double minDistance =
        calculateDistanceForGoogleMap(currentLocation, nearestPoint);

    for (final routePoint in routePoints) {
      final distance =
          calculateDistanceForGoogleMap(currentLocation, routePoint);
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = routePoint;
      }
    }

    return nearestPoint;
  }
}
