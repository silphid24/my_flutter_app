import 'package:latlong2/latlong.dart';

class CaminoStage {
  final String id;
  final String name;
  final String assetPath;
  final String title;
  final String? description;
  final LatLng startPoint;
  final LatLng endPoint;
  final double? distance;
  final int? dayNumber;

  const CaminoStage({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.title,
    this.description,
    required this.startPoint,
    required this.endPoint,
    this.distance,
    this.dayNumber,
  });
}
