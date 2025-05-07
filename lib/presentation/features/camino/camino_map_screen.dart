import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:my_flutter_app/models/track.dart';
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:my_flutter_app/services/stage_service.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/bottom_nav_bar.dart';
import 'package:my_flutter_app/presentation/features/camino/widgets/flutter_map_component.dart';
import 'package:my_flutter_app/presentation/features/camino/widgets/google_map_component.dart';
import 'package:my_flutter_app/presentation/features/camino/widgets/location_service_handler.dart';
import 'package:my_flutter_app/presentation/features/camino/utils/map_utils.dart';

/// Camino Map Screen
///
/// A detailed map view of the Camino de Santiago routes.
/// Supports both OpenStreetMap (flutter_map) and Google Maps.
class CaminoMapScreen extends ConsumerStatefulWidget {
  final String? trackId;
  final bool useGoogleMaps;

  const CaminoMapScreen({
    super.key,
    this.trackId,
    this.useGoogleMaps = false,
  });

  @override
  ConsumerState<CaminoMapScreen> createState() => _CaminoMapScreenState();
}

class _CaminoMapScreenState extends ConsumerState<CaminoMapScreen> {
  final GpxService _gpxService = GpxService();
  final StageService _stageService = StageService();

  // Controllers
  final MapController _mapController = MapController();
  final Completer<gmaps.GoogleMapController> _googleMapController = Completer();

  // Track data
  Track? _track;
  List<latlong2.LatLng> _routePoints = [];
  List<latlong2.LatLng> _completeRoutePoints = [];

  // Google Maps specific data
  Set<gmaps.Marker> _googleMarkers = {};
  Set<gmaps.Polyline> _googlePolylines = {};
  Set<gmaps.Polyline> _googleCompleteRoutePolylines = {};

  // UI state
  bool _isLoading = true;
  bool _isLocationEnabled = false;
  String? _loadingMessage;
  String? _loadError;
  bool _isMapReady = false;

  // Location
  LocationData? _currentLocation;
  late LocationServiceHandler _locationHandler;

  // Map settings
  latlong2.LatLng _center =
      latlong2.LatLng(42.9, -1.8); // Approximate Camino location
  double _zoom = 8.0;
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();

    // Initialize location handler
    _locationHandler = LocationServiceHandler(
      onLocationChanged: _onLocationChanged,
    );
    _locationHandler.initLocationService();

    // Load complete Camino route points
    _completeRoutePoints = _stageService.getAllStagesPoints();

    // Load track data
    _loadTrackData();

    // Setup Google Maps components if needed
    if (widget.useGoogleMaps) {
      _setupGoogleMapsComponents();
    }
  }

  @override
  void dispose() {
    _locationHandler.dispose();
    super.dispose();
  }

  void _onLocationChanged(LocationData locationData) {
    setState(() {
      _currentLocation = locationData;
      _updateMarkers();
    });

    // Move map camera to current location if tracking is enabled
    if (_isLocationEnabled && _currentLocation != null) {
      _moveMapToCurrentLocation();
    }
  }

  Future<void> _loadTrackData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      // If trackId starts with 'stage', load that specific stage
      if (widget.trackId != null && widget.trackId!.startsWith('stage')) {
        final stage = _stageService.getStageById(widget.trackId!);
        if (stage != null) {
          await _loadGpxFromStage(stage.assetPath);
        } else {
          await _loadDefaultTrack();
        }
      } else {
        await _loadDefaultTrack();
      }

      setState(() {
        _isLoading = false;
        _isMapReady = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadError = 'Error loading map data: $e';
      });
    }
  }

  Future<void> _loadGpxFromStage(String assetPath) async {
    _loadingMessage = 'Loading stage GPX data...';
    final track = await _gpxService.loadGpxFromAsset(assetPath);

    if (track != null) {
      setState(() {
        _track = track;
        _routePoints = MapUtils.extractRoutePointsFromTrack(track);
        _center = track.bounds.center;
        _updateMarkers();
      });
    }
  }

  Future<void> _loadDefaultTrack() async {
    _loadingMessage = 'Loading default track...';
    final track = await _gpxService
        .loadGpxFromAsset('assets/data/Stage-1-Camino-Frances.gpx');

    if (track != null) {
      setState(() {
        _track = track;
        _routePoints = MapUtils.extractRoutePointsFromTrack(track);
        _center = track.bounds.center;
        _updateMarkers();
      });
    }
  }

  void _updateMarkers() {
    if (_track == null) return;

    _markers.clear();

    // Add route start marker
    if (_track!.startPoint != null) {
      _markers.add(MapUtils.createFlutterMapMarker(
        position: _track!.startPoint!,
        child: const Icon(Icons.trip_origin, color: Colors.green, size: 30),
      ));
    }

    // Add route end marker
    if (_track!.endPoint != null) {
      _markers.add(MapUtils.createFlutterMapMarker(
        position: _track!.endPoint!,
        child: const Icon(Icons.flag, color: Colors.red, size: 30),
      ));
    }

    // Add current location marker if available
    if (_currentLocation != null) {
      _markers.add(MapUtils.createFlutterMapMarker(
        position: latlong2.LatLng(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.my_location, color: Colors.white, size: 20),
        ),
      ));
    }

    // Update Google Maps markers if using Google Maps
    if (widget.useGoogleMaps) {
      _updateGoogleMapMarkers();
    }
  }

  void _setupGoogleMapsComponents() {
    // Setup polylines for the complete route
    _googleCompleteRoutePolylines = {
      MapUtils.createGoogleMapPolyline(
        points: MapUtils.convertToGoogleLatLngList(_completeRoutePoints),
        id: 'complete_route',
        color: Colors.grey.shade600,
        width: 3,
      ),
    };

    // Will be updated in _updateGoogleMapMarkers
    _googleMarkers = {};
    _googlePolylines = {};
  }

  void _updateGoogleMapMarkers() {
    _googleMarkers = {};
    _googlePolylines = {};

    // Add route polyline
    if (_routePoints.isNotEmpty) {
      _googlePolylines.add(MapUtils.createGoogleMapPolyline(
        points: MapUtils.convertToGoogleLatLngList(_routePoints),
        id: 'route',
        color: Colors.blue,
        width: 4,
      ));
    }

    // Add start point marker
    if (_track != null && _track!.startPoint != null) {
      _googleMarkers.add(MapUtils.createGoogleMapMarker(
        position: MapUtils.convertToGoogleLatLng(_track!.startPoint!),
        id: 'start',
        title: 'Start',
      ));
    }

    // Add end point marker
    if (_track != null && _track!.endPoint != null) {
      _googleMarkers.add(MapUtils.createGoogleMapMarker(
        position: MapUtils.convertToGoogleLatLng(_track!.endPoint!),
        id: 'end',
        title: 'End',
      ));
    }

    // Add current location marker
    if (_currentLocation != null) {
      _googleMarkers.add(MapUtils.createGoogleMapMarker(
        position: gmaps.LatLng(
            _currentLocation!.latitude!, _currentLocation!.longitude!),
        id: 'current_location',
        title: 'Your Location',
      ));
    }
  }

  void _moveMapToCurrentLocation() {
    if (_currentLocation == null) return;

    final location = latlong2.LatLng(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
    );

    try {
      if (widget.useGoogleMaps) {
        _moveGoogleMapToLocation(location);
      } else {
        _moveFlutterMapToLocation(location);
      }
    } catch (e) {
      debugPrint('Error moving map: $e');
    }
  }

  void _moveFlutterMapToLocation(latlong2.LatLng location) {
    if (_mapController.camera != null) {
      _mapController.move(location, _zoom);
    }
  }

  void _moveGoogleMapToLocation(latlong2.LatLng location) async {
    if (!_googleMapController.isCompleted) return;

    try {
      final controller = await _googleMapController.future;
      controller.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: MapUtils.convertToGoogleLatLng(location),
            zoom: _zoom,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error moving Google Map: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_track?.name ?? 'Camino de Santiago Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              setState(() {
                _isLocationEnabled = !_isLocationEnabled;
              });
              if (_isLocationEnabled && _currentLocation != null) {
                _moveMapToCurrentLocation();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrackData,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_loadingMessage ?? 'Loading map data...'),
          ],
        ),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _loadError!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTrackData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.useGoogleMaps ? _buildGoogleMap() : _buildFlutterMap();
  }

  Widget _buildFlutterMap() {
    // Create polylines
    final List<Polyline> polylines = [
      // Complete route polyline (grey)
      MapUtils.createFlutterMapPolyline(
        points: _completeRoutePoints,
        color: Colors.grey.shade600,
        strokeWidth: 3.0,
      ),
    ];

    // Add current route polyline if available
    if (_routePoints.isNotEmpty) {
      polylines.add(MapUtils.createFlutterMapPolyline(
        points: _routePoints,
        color: Colors.blue,
        strokeWidth: 4.0,
      ));
    }

    return FlutterMapComponent(
      mapController: _mapController,
      center: _center,
      zoom: _zoom,
      markers: _markers,
      polylines: polylines,
      onTap: (tapPosition, latLng) {
        // Handle map tap if needed
      },
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMapComponent(
      controller: _googleMapController,
      center: MapUtils.convertToGoogleLatLng(_center),
      zoom: _zoom,
      markers: _googleMarkers,
      polylines: {..._googleCompleteRoutePolylines, ..._googlePolylines},
      onTap: (position) {
        // Handle map tap if needed
      },
    );
  }
}
