import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/track.dart';
import '../services/gpx_service.dart';

class TrackMapScreen extends StatefulWidget {
  final String? trackId;
  final Track? initialTrack;

  const TrackMapScreen({super.key, this.trackId, this.initialTrack})
    : assert(
        trackId != null || initialTrack != null,
        'trackId 또는 initialTrack 중 하나는 반드시 제공되어야 합니다.',
      );

  @override
  State<TrackMapScreen> createState() => _TrackMapScreenState();
}

class _TrackMapScreenState extends State<TrackMapScreen> {
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
        // 지도 중심을 트랙 위치로 이동
        _mapController.move(
          _track!.bounds.center,
          13.0, // 초기 줌 레벨
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('트랙 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_track?.name ?? '순례길 지도'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTrack),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _track == null
              ? const Center(child: Text('트랙 정보를 찾을 수 없습니다.'))
              : _buildMap(),
    );
  }

  Widget _buildMap() {
    if (_track == null || _track!.points.isEmpty) {
      return const Center(child: Text('지도에 표시할 경로 포인트가 없습니다.'));
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
            // 시작점 마커
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
            // 종료점 마커
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
