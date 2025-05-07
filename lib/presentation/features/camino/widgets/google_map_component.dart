import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// GoogleMapComponent
///
/// Google Maps를 사용하는 지도 컴포넌트
class GoogleMapComponent extends StatelessWidget {
  final Completer<GoogleMapController> controller;
  final LatLng center;
  final double zoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(LatLng)? onTap;
  final MapType mapType;

  const GoogleMapComponent({
    Key? key,
    required this.controller,
    required this.center,
    this.zoom = 13.0,
    this.markers = const {},
    this.polylines = const {},
    this.onTap,
    this.mapType = MapType.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: mapType,
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: zoom,
      ),
      onMapCreated: (GoogleMapController ctrl) {
        if (!controller.isCompleted) {
          controller.complete(ctrl);
        }
      },
      markers: markers,
      polylines: polylines,
      onTap: onTap != null ? (position) => onTap!(position) : null,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: true,
    );
  }
}
