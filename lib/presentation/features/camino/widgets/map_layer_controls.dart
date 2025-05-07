import 'package:flutter/material.dart';
import 'package:my_flutter_app/models/poi_model.dart';
import 'package:my_flutter_app/services/poi_service.dart';
import 'package:my_flutter_app/services/map_cache_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final mapLayersControllerProvider =
    StateNotifierProvider<MapLayersController, MapLayersState>((ref) {
  return MapLayersController();
});

/// 지도 레이어 상태 클래스
class MapLayersState {
  final bool showRoutes; // 경로 표시 여부
  final bool showPois; // POI 표시 여부
  final bool showAltitudes; // 고도 정보 표시 여부
  final bool isDownloadingOfflineMaps; // 오프라인 지도 다운로드 중 여부
  final double downloadProgress; // 다운로드 진행률 (0.0 - 1.0)
  final List<PoiType> visiblePoiTypes; // 표시할 POI 유형들

  const MapLayersState({
    this.showRoutes = true,
    this.showPois = true,
    this.showAltitudes = false,
    this.isDownloadingOfflineMaps = false,
    this.downloadProgress = 0.0,
    this.visiblePoiTypes = const [],
  });

  // 상태 복사 메소드
  MapLayersState copyWith({
    bool? showRoutes,
    bool? showPois,
    bool? showAltitudes,
    bool? isDownloadingOfflineMaps,
    double? downloadProgress,
    List<PoiType>? visiblePoiTypes,
  }) {
    return MapLayersState(
      showRoutes: showRoutes ?? this.showRoutes,
      showPois: showPois ?? this.showPois,
      showAltitudes: showAltitudes ?? this.showAltitudes,
      isDownloadingOfflineMaps:
          isDownloadingOfflineMaps ?? this.isDownloadingOfflineMaps,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      visiblePoiTypes: visiblePoiTypes ?? this.visiblePoiTypes,
    );
  }
}

/// 지도 레이어 컨트롤러
class MapLayersController extends StateNotifier<MapLayersState> {
  final PoiService _poiService = PoiService();
  final MapCacheService _mapCacheService = MapCacheService();

  MapLayersController()
      : super(const MapLayersState(visiblePoiTypes: [
          PoiType.albergue,
          PoiType.hotel,
          PoiType.restaurant,
          PoiType.fountain
        ])) {
    _loadSettings();
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    // TODO: 설정을 SharedPreferences에서 로드하는 코드 추가
  }

  /// 경로 표시 토글
  void toggleRoutes() {
    state = state.copyWith(showRoutes: !state.showRoutes);
  }

  /// POI 표시 토글
  void togglePois() {
    state = state.copyWith(showPois: !state.showPois);
  }

  /// 고도 정보 표시 토글
  void toggleAltitudes() {
    state = state.copyWith(showAltitudes: !state.showAltitudes);
  }

  /// POI 유형 표시 토글
  Future<void> togglePoiType(PoiType type) async {
    final List<PoiType> visibleTypes = List.from(state.visiblePoiTypes);

    if (visibleTypes.contains(type)) {
      visibleTypes.remove(type);
    } else {
      visibleTypes.add(type);
    }

    state = state.copyWith(visiblePoiTypes: visibleTypes);
    await _poiService.setPoiTypeVisibility(type, visibleTypes.contains(type));
  }

  /// 모든 POI 유형 표시
  Future<void> showAllPoiTypes() async {
    state = state.copyWith(visiblePoiTypes: List.from(PoiType.values));
    await _poiService.resetPoiTypeFilters();
  }

  /// 모든 POI 유형 숨기기
  Future<void> hideAllPoiTypes() async {
    state = state.copyWith(visiblePoiTypes: []);
    await _poiService.hideAllPoiTypes();
  }

  /// 오프라인 지도 다운로드
  Future<void> downloadOfflineMaps(LatLng southWest, LatLng northEast) async {
    if (state.isDownloadingOfflineMaps) return;

    state = state.copyWith(
      isDownloadingOfflineMaps: true,
      downloadProgress: 0.0,
    );

    try {
      await _mapCacheService.cacheRegion(
        southWest: southWest,
        northEast: northEast,
        minZoom: 10,
        maxZoom: 16,
        progressCallback: (progress) {
          state = state.copyWith(downloadProgress: progress);
        },
      );

      // 성공 메시지
    } catch (e) {
      // 오류 처리
    } finally {
      state = state.copyWith(
        isDownloadingOfflineMaps: false,
        downloadProgress: 1.0,
      );
    }
  }

  /// 캐시 크기 조회
  Future<int> getCacheSize() async {
    return await _mapCacheService.getCacheSize();
  }

  /// 오래된 캐시 정리
  Future<void> clearOldCache() async {
    await _mapCacheService.clearOldCache();
  }

  /// 모든 캐시 정리
  Future<void> clearAllCache() async {
    await _mapCacheService.clearAllCache();
  }
}

/// 지도 레이어 컨트롤 위젯
class MapLayerControls extends HookConsumerWidget {
  const MapLayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layersState = ref.watch(mapLayersControllerProvider);
    final layersController = ref.read(mapLayersControllerProvider.notifier);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Map Layers',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    // 닫기 이벤트 처리
                    Navigator.of(context).pop();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // 메인 컨트롤
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 메인 레이어 토글
                _buildLayerToggle(
                  context,
                  title: 'Show Route',
                  icon: Icons.route,
                  value: layersState.showRoutes,
                  onChanged: (_) => layersController.toggleRoutes(),
                ),
                _buildLayerToggle(
                  context,
                  title: 'Show POI',
                  icon: Icons.place,
                  value: layersState.showPois,
                  onChanged: (_) => layersController.togglePois(),
                ),
                _buildLayerToggle(
                  context,
                  title: 'Show Elevation',
                  icon: Icons.terrain,
                  value: layersState.showAltitudes,
                  onChanged: (_) => layersController.toggleAltitudes(),
                ),

                const Divider(height: 32),

                // POI 유형 선택
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'POI Filters',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PoiType.values.map((type) {
                        final isVisible =
                            layersState.visiblePoiTypes.contains(type);

                        return FilterChip(
                          label: Text(type.name),
                          selected: isVisible,
                          onSelected: (_) =>
                              layersController.togglePoiType(type),
                          avatar: Icon(
                            type.icon,
                            size: 18,
                            color: isVisible
                                ? Colors.white
                                : Theme.of(context).iconTheme.color,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => layersController.showAllPoiTypes(),
                          child: const Text('Select All'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => layersController.hideAllPoiTypes(),
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(height: 32),

                // 오프라인 지도 컨트롤
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Maps',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (layersState.isDownloadingOfflineMaps)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: layersState.downloadProgress,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Downloading... ${(layersState.downloadProgress * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {
                          // 현재 화면에 표시된 영역 다운로드
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Download Offline Map'),
                              content: const Text(
                                'Do you want to download the current map area for offline use? This may use a significant amount of data.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // 실제 구현 시 현재 지도 영역 좌표 구해서 전달
                                    layersController.downloadOfflineMaps(
                                      LatLng(42.8, -2.0),
                                      LatLng(43.2, -1.0),
                                    );
                                  },
                                  child: const Text('Download'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download This Area'),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder<int>(
                          future: layersController.getCacheSize(),
                          builder: (context, snapshot) {
                            final cacheSize = snapshot.data ?? 0;
                            return Text(
                              'Cache Size: ${_formatBytes(cacheSize)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Clear Cache'),
                                content: const Text(
                                  'Do you want to delete all offline map caches?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      layersController.clearAllCache();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Clear Cache'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerToggle(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(title),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
