import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MarkerType {
  accommodation,
  restaurant,
  pharmacy,
  landmark,
  currentLocation,
  waypoint,
}

class MapMarker extends Equatable {
  final String id;
  final String title;
  final String description;
  final LatLng position;
  final MarkerType type;
  final String? imageUrl;

  const MapMarker({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
    required this.type,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, position, type];
}
