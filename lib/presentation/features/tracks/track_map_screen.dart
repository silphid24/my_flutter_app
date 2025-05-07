import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/models/track.dart';
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:my_flutter_app/presentation/features/shared/layout/app_scaffold.dart';

/// Track Map Screen
///
/// Displays a map view of a GPX track with start and end points.
class TrackMapScreen extends ConsumerStatefulWidget {
  final String? trackId;
  final Track? initialTrack;

  const TrackMapScreen({super.key, this.trackId, this.initialTrack})
      : assert(
          trackId != null || initialTrack != null,
          'Either trackId or initialTrack must be provided.',
        );

  @override
  ConsumerState<TrackMapScreen> createState() => _TrackMapScreenState();
}

class _TrackMapScreenState extends ConsumerState<TrackMapScreen> {
  final GpxService _gpxService = GpxService();
  Track? _track;
  bool _isLoading = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadTrack();
  }

  Future<void> _loadTrack() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.initialTrack != null) {
        _track = widget.initialTrack;
      } else if (widget.trackId != null) {
        _track = await _gpxService.getTrack(widget.trackId!);
      }

      setState(() {
        _isLoading = false;
      });

      if (_track != null && _track!.points.isNotEmpty) {
        // Move map to the track's center
        _mapController.move(
          _track!.bounds.center,
          13.0, // Initial zoom level
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading track: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 1,
      appBar: AppBar(
        title: Text(_track?.name ?? 'Pilgrim Route Map'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTrack),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _track == null
              ? const Center(child: Text('Track information not found.'))
              : _buildMap(),
    );
  }

  Widget _buildMap() {
    if (_track == null || _track!.points.isEmpty) {
      return const Center(
          child: Text('No route points to display on the map.'));
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _track!.bounds.center,
        initialZoom: 12.0,
        minZoom: 4,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.my_flutter_app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: _track!.points.map((p) => p.position).toList(),
              color: Colors.blue,
              strokeWidth: 4.0,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            // Start point marker
            if (_track!.startPoint != null)
              Marker(
                point: _track!.startPoint!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.trip_origin,
                  color: Colors.green,
                  size: 30,
                ),
              ),
            // End point marker
            if (_track!.endPoint != null)
              Marker(
                point: _track!.endPoint!,
                width: 40,
                height: 40,
                child: const Icon(Icons.flag, color: Colors.red, size: 30),
              ),
          ],
        ),
      ],
    );
  }
}
