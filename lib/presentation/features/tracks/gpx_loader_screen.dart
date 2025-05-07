import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/models/track.dart';
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:my_flutter_app/presentation/features/tracks/track_map_screen.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/bottom_nav_bar.dart';

/// GPX Loader Screen
///
/// A screen that loads and displays available GPX tracks.
/// Users can select a track to view it on the map.
class GpxLoaderScreen extends ConsumerStatefulWidget {
  const GpxLoaderScreen({super.key});

  @override
  ConsumerState<GpxLoaderScreen> createState() => _GpxLoaderScreenState();
}

class _GpxLoaderScreenState extends ConsumerState<GpxLoaderScreen> {
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
      // Try to load existing tracks
      _tracks = await _gpxService.getTracks();

      // If no tracks, load GPX files
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
      print('Error loading GPX files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camino de Santiago Tracks'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGpxFiles),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tracks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No tracks loaded.'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadGpxFiles,
                        child: const Text('Load GPX Files'),
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
                        subtitle: Text('Points: ${track.points.length}'),
                        trailing: const Icon(Icons.map),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TrackMapScreen(initialTrack: track),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
