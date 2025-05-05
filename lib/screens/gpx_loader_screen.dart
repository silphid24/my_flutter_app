import 'package:flutter/material.dart';
import '../models/track.dart';
import '../services/gpx_service.dart';
import 'track_map_screen.dart';

class GpxLoaderScreen extends StatefulWidget {
  const GpxLoaderScreen({super.key});

  @override
  State<GpxLoaderScreen> createState() => _GpxLoaderScreenState();
}

class _GpxLoaderScreenState extends State<GpxLoaderScreen> {
  final GpxService _gpxService = GpxService();
  List<Track> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGpxFiles();
  }

  Future<void> _loadGpxFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 기존 트랙 로드 시도
      _tracks = await _gpxService.getTracks();

      // 트랙이 없으면 GPX 파일을 로드
      if (_tracks.isEmpty) {
        final track = await _gpxService.loadGpxFromAsset(
          'assets/data/Stage-1-Camino-Frances.gpx',
        );
        if (track != null) {
          _tracks = [track];
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('GPX 파일 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('산티아고 순례길'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGpxFiles),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tracks.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('로드된 트랙이 없습니다.'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadGpxFiles,
                      child: const Text('GPX 파일 로드'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _tracks.length,
                itemBuilder: (context, index) {
                  final track = _tracks[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(track.name),
                      subtitle: Text('포인트 수: ${track.points.length}'),
                      trailing: const Icon(Icons.map),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    TrackMapScreen(initialTrack: track),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
