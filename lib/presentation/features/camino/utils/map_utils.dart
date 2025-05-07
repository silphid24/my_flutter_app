import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:my_flutter_app/models/track.dart';

/// MapUtils
///
/// Utility class for map-related operations like creating markers, polylines, etc.
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

  /// Create a marker for the Google Maps package
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

  /// Create a polyline for the Google Maps package
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

  /// Convert LatLng from latlong2 to Google Maps format
  static gmaps.LatLng convertToGoogleLatLng(latlong2.LatLng point) {
    return gmaps.LatLng(point.latitude, point.longitude);
  }

  /// Convert a list of LatLng from latlong2 to Google Maps format
  static List<gmaps.LatLng> convertToGoogleLatLngList(
      List<latlong2.LatLng> points) {
    return points.map((point) => convertToGoogleLatLng(point)).toList();
  }

  /// Extract route points from a Track
  static List<latlong2.LatLng> extractRoutePointsFromTrack(Track track) {
    return track.points.map((point) => point.position).toList();
  }
}

/// Location calculation utilities
class LocationUtils {
  /// Calculate distance between two points in kilometers
  static double calculateDistance(
      latlong2.LatLng point1, latlong2.LatLng point2) {
    const latlong2.Distance distance = latlong2.Distance();
    return distance.as(latlong2.LengthUnit.Kilometer, point1, point2);
  }

  /// Find the center point between two coordinates
  static latlong2.LatLng findCenterBetweenPoints(
      latlong2.LatLng point1, latlong2.LatLng point2) {
    final centerLat = (point1.latitude + point2.latitude) / 2;
    final centerLng = (point1.longitude + point2.longitude) / 2;
    return latlong2.LatLng(centerLat, centerLng);
  }
}
