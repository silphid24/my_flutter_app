import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// GoogleMapComponent
///
/// A reusable component that renders a map using Google Maps.
class GoogleMapComponent extends StatelessWidget {
  final Completer<GoogleMapController> controller;
  final LatLng center;
  final double zoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(LatLng)? onTap;

  const GoogleMapComponent({
    Key? key,
    required this.controller,
    required this.center,
    this.zoom = 12.0,
    this.markers = const {},
    this.polylines = const {},
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: zoom,
      ),
      markers: markers,
      polylines: polylines,
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        if (!this.controller.isCompleted) {
          this.controller.complete(controller);
        }
      },
      onTap: onTap != null ? (position) => onTap!(position) : null,
    );
  }
}
