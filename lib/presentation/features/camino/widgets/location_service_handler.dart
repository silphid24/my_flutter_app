import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

/// LocationServiceHandler
///
/// A class that encapsulates location service functionality.
/// Handles permission requests, location updates, and provides callbacks.
class LocationServiceHandler {
  final Location _locationService = Location();
  LocationData? currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  bool isLocationEnabled = false;

  // Callback when location updates
  final Function(LocationData) onLocationChanged;

  LocationServiceHandler({required this.onLocationChanged});

  /// Initialize location service and request permissions
  Future<void> initLocationService() async {
    try {
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      PermissionStatus permissionGranted =
          await _locationService.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationService.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      // Subscribe to location updates
      _locationSubscription = _locationService.onLocationChanged
          .listen((LocationData locationData) {
        currentLocation = locationData;
        onLocationChanged(locationData);
      });

      isLocationEnabled = true;
    } catch (e) {
      debugPrint('Error initializing location service: $e');
    }
  }

  /// Get current location once
  Future<LocationData?> getCurrentLocation() async {
    try {
      return await _locationService.getLocation();
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _locationSubscription?.cancel();
  }
}
