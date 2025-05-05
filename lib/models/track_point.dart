import 'package:latlong2/latlong.dart';

class TrackPoint {
  final LatLng position;
  final double elevation;
  final DateTime time;

  TrackPoint({
    required this.position,
    required this.elevation,
    required this.time,
  });

  factory TrackPoint.fromGpx(Map<String, dynamic> data) {
    return TrackPoint(
      position: LatLng(data['lat'] as double, data['lon'] as double),
      elevation: data['ele'] as double,
      time: DateTime.parse(data['time'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'elevation': elevation,
      'timestamp': time.toIso8601String(),
    };
  }

  factory TrackPoint.fromMap(Map<String, dynamic> map) {
    return TrackPoint(
      position: LatLng(map['latitude'] as double, map['longitude'] as double),
      elevation: map['elevation'] as double,
      time: DateTime.parse(map['timestamp'] as String),
    );
  }
}
