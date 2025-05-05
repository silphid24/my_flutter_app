import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'track_point.dart';

class Track {
  final String id;
  final String name;
  final String type;
  final List<TrackPoint> points;
  final DateTime createdAt;

  Track({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
    required this.createdAt,
  });

  // 경로에 대한 경계 상자 계산
  LatLngBounds get bounds {
    if (points.isEmpty) {
      // 기본값: 산티아고 순례길 대략적인 영역
      return LatLngBounds(
        LatLng(42.5, -2.0), // 남서쪽
        LatLng(43.5, -1.0), // 북동쪽
      );
    }

    double minLat = points.first.position.latitude;
    double maxLat = points.first.position.latitude;
    double minLng = points.first.position.longitude;
    double maxLng = points.first.position.longitude;

    for (var point in points) {
      if (point.position.latitude < minLat) minLat = point.position.latitude;
      if (point.position.latitude > maxLat) maxLat = point.position.latitude;
      if (point.position.longitude < minLng) minLng = point.position.longitude;
      if (point.position.longitude > maxLng) maxLng = point.position.longitude;
    }

    return LatLngBounds(
      LatLng(minLat, minLng), // 남서쪽
      LatLng(maxLat, maxLng), // 북동쪽
    );
  }

  // 시작점 위치
  LatLng? get startPoint {
    return points.isNotEmpty ? points.first.position : null;
  }

  // 종료점 위치
  LatLng? get endPoint {
    return points.isNotEmpty ? points.last.position : null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Track.fromMap(
    Map<String, dynamic> map,
    List<TrackPoint> trackPoints,
  ) {
    return Track(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      points: trackPoints,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
