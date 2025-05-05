import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_app/config/theme.dart';
import 'package:my_flutter_app/domain/models/camino_route.dart';
import 'package:my_flutter_app/domain/models/map_marker.dart';
import 'package:my_flutter_app/presentation/bloc/map_bloc.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  final List<String> _layers = ['Normal', 'Satellite', 'Terrain', 'Hybrid'];

  // Saint-Jean-Pied-de-Port 위치
  final LatLng _saintJeanLocation = const LatLng(43.1634, -1.2374);

  // 마커 필터링 상태
  bool _showAccommodations = true;
  bool _showRestaurants = true;
  bool _showPharmacies = true;
  bool _showLandmarks = true;

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(LoadMap());
  }

  // 지도 컨트롤러 획득 함수
  Future<GoogleMapController> _getMapController() async {
    if (_mapController.isCompleted) {
      return _mapController.future;
    }
    return Future.error('Map controller not initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camino Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsOptions,
            tooltip: '지도 설정',
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _showLayerOptions,
            tooltip: '지도 레이어',
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterOptions,
            tooltip: '마커 필터',
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showStagesList,
            tooltip: '모든 스테이지 목록',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildGoogleMap(context),
          _buildLoadingIndicator(),
          _buildRoutDeviationWarning(),
          _buildMapControls(),
          _buildMarkerTypeOptions(),
          _buildLocationInfo(),
          _buildStageSelector(),
        ],
      ),
      floatingActionButton: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoaded) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 생장 피드 포르트로 이동하는 플로팅 버튼
                FloatingActionButton(
                  heroTag: 'saint_jean_button',
                  mini: true,
                  onPressed: () => _centerMapOnLocation(_saintJeanLocation),
                  backgroundColor: Colors.indigo,
                  tooltip: 'Saint-Jean-Pied-de-Port',
                  child: const Icon(Icons.home),
                ),
                const SizedBox(height: 8),
                // 현재 위치 버튼
                FloatingActionButton(
                  heroTag: 'current_location_button',
                  onPressed: () {
                    if (state.currentLocation != null) {
                      _centerMapOnLocation(state.currentLocation!);
                    }
                  },
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.my_location),
                ),
                FloatingActionButton(
                  onPressed: () {
                    _showFilterOptions();
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.filter_alt),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is MapLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MapLoaded) {
          return _buildMap(state);
        } else if (state is MapError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const Center(child: Text('지도를 로드하는 중...'));
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is MapLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRoutDeviationWarning() {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is! MapLoaded) return const SizedBox.shrink();

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.red.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '카미노 경로에서 벗어났습니다. 경로로 돌아가세요.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    context.read<MapBloc>().add(DismissRouteDeviationWarning());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapControls() {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is! MapLoaded) return const SizedBox.shrink();

        return Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            children: [
              _buildMapControlButton(
                icon: Icons.my_location,
                onPressed: () {
                  if (state.currentLocation != null) {
                    context.read<MapBloc>().add(FocusOnCurrentLocation());
                    _centerMapOnLocation(state.currentLocation!);
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                icon: Icons.add,
                onPressed: () {
                  _zoomMap(1);
                },
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                icon: Icons.remove,
                onPressed: () {
                  _zoomMap(-1);
                },
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                icon: Icons.fullscreen,
                onPressed: () {
                  // 전체 경로가 보이게 설정
                  List<LatLng> allPoints = [];
                  for (var stage in state.caminoRoute.stages) {
                    allPoints.addAll(stage.path);
                  }
                  _fitMapToRoute(allPoints);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarkerTypeOptions() {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is! MapLoaded) return const SizedBox.shrink();

        return Positioned(
          right: 16,
          bottom: 220,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _showFilterOptions();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_alt, color: Colors.blue),
                    const SizedBox(height: 4),
                    const Text(
                      '마커 필터',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationInfo() {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is! MapLoaded) return const SizedBox.shrink();

        return Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Camino Frances - ${state.currentStage?.name ?? "Full Route"}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStageSelector() {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is! MapLoaded) return const SizedBox.shrink();

        return Positioned(
          bottom: 220,
          right: 16,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _showStageSelectionSheet(
                  context,
                  state.caminoRoute.stages,
                  state.selectedStage,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.route, color: Colors.blue),
                    const SizedBox(height: 4),
                    Text(
                      state.selectedStage?.name ?? '스테이지 선택',
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMap(MapLoaded state) {
    return Stack(
      children: [
        // 구글 맵
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _saintJeanLocation, // 시작점으로 변경
            zoom: 12, // 더 멀리 보기
          ),
          mapType: state.mapType,
          markers: state.markers,
          polylines: state.polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          onMapCreated: (controller) {
            if (!_mapController.isCompleted) {
              _mapController.complete(controller);

              // 지도 로드 후 경로 전체가 보이도록 카메라 위치 조정
              if (state.caminoRoute.stages.isNotEmpty &&
                  state.caminoRoute.stages.first.path.isNotEmpty) {
                // 전체 경로가 보이게 설정
                List<LatLng> allPoints = [];
                for (var stage in state.caminoRoute.stages) {
                  allPoints.addAll(stage.path);
                }
                _fitMapToRoute(allPoints);
              }
            }
          },
        ),

        // 맵 타이틀
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Camino Frances - ${state.currentStage?.name ?? "Full Route"}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),

        // 다음 경로 포인트 방향 표시기
        if (state.currentStage != null && state.currentLocation != null)
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(child: _buildDirectionIndicator(state)),
          ),

        // 위치 관련 컨트롤
        Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            children: [
              _buildMapControlButton(
                icon: Icons.my_location,
                onPressed: () {
                  if (state.currentLocation != null) {
                    context.read<MapBloc>().add(FocusOnCurrentLocation());
                    _centerMapOnLocation(state.currentLocation!);
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                icon: Icons.add,
                onPressed: () {
                  _zoomMap(1);
                },
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                icon: Icons.remove,
                onPressed: () {
                  _zoomMap(-1);
                },
              ),
              const SizedBox(height: 8),
              _buildMapControlButton(
                icon: Icons.fullscreen,
                onPressed: () {
                  // 전체 경로가 보이게 설정
                  List<LatLng> allPoints = [];
                  for (var stage in state.caminoRoute.stages) {
                    allPoints.addAll(stage.path);
                  }
                  _fitMapToRoute(allPoints);
                },
              ),
            ],
          ),
        ),

        // 하단 정보 패널
        Positioned(bottom: 0, left: 0, right: 0, child: _buildInfoPanel(state)),
      ],
    );
  }

  // 경로에 맞게 지도 조정
  void _fitMapToRoute(List<LatLng> route) {
    if (route.isEmpty) return;

    // 경로 내 모든 지점의 위도/경도 범위를 계산
    double minLat = route.first.latitude;
    double maxLat = route.first.latitude;
    double minLng = route.first.longitude;
    double maxLng = route.first.longitude;

    for (var point in route) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // 경로 주변에 약간의 여백 추가
    final latPadding = (maxLat - minLat) * 0.2;
    final lngPadding = (maxLng - minLng) * 0.2;

    // 경로 전체가 화면에 들어오는 카메라 위치 계산
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    // 지도 이동
    _getMapController()
        .then((controller) {
          controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
        })
        .catchError((e) {
          debugPrint('지도 경로 조정 오류: $e');
        });
  }

  Widget _buildDirectionIndicator(MapLoaded state) {
    // 현재 위치가 없으면 표시하지 않음
    if (state.currentLocation == null || state.currentStage == null) {
      return const SizedBox.shrink();
    }

    // 현재 스테이지에서 다음 웨이포인트를 계산
    final nextWaypoint = _findNextWaypoint(
      state.currentStage!.path,
      state.currentLocation!,
    );

    if (nextWaypoint == null) {
      return const SizedBox.shrink();
    }

    // 다음 웨이포인트까지의 방향 계산
    final heading = _calculateHeading(state.currentLocation!, nextWaypoint);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: heading * (3.1415926 / 180),
            child: const Icon(
              Icons.arrow_upward,
              color: AppTheme.primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '다음 경로 포인트: ${_formatDistance(_calculateDistance(state.currentLocation!, nextWaypoint))}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // 현재 위치에서 가장 가까운 다음 웨이포인트를 찾는 함수
  LatLng? _findNextWaypoint(List<LatLng> path, LatLng current) {
    if (path.isEmpty) return null;

    int closestPointIndex = 0;
    double minDistance = double.infinity;

    // 가장 가까운 경로 포인트 찾기
    for (int i = 0; i < path.length; i++) {
      final distance = _calculateDistance(current, path[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestPointIndex = i;
      }
    }

    // 다음 웨이포인트를 찾기 (가장 가까운 포인트 이후의 포인트)
    int nextPointIndex = closestPointIndex + 1;
    if (nextPointIndex >= path.length) {
      // 마지막 포인트에 도달했으면 마지막 포인트 반환
      return path.last;
    }

    return path[nextPointIndex];
  }

  // 두 위치 간의 대략적인 거리를 미터 단위로 계산 (Haversine 공식)
  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371000; // 지구 반경 (미터)
    final double lat1Rad = pos1.latitude * (math.pi / 180);
    final double lat2Rad = pos2.latitude * (math.pi / 180);
    final double deltaLatRad =
        (pos2.latitude - pos1.latitude) * (math.pi / 180);
    final double deltaLngRad =
        (pos2.longitude - pos1.longitude) * (math.pi / 180);

    final double a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  // 방향 각도 계산 (북쪽 0도, 시계방향)
  double _calculateHeading(LatLng from, LatLng to) {
    final double fromLat = from.latitude * (math.pi / 180);
    final double fromLng = from.longitude * (math.pi / 180);
    final double toLat = to.latitude * (math.pi / 180);
    final double toLng = to.longitude * (math.pi / 180);

    final double y = math.sin(toLng - fromLng) * math.cos(toLat);
    final double x =
        math.cos(fromLat) * math.sin(toLat) -
        math.sin(fromLat) * math.cos(toLat) * math.cos(toLng - fromLng);
    final double bearing = math.atan2(y, x);
    return (bearing * (180 / math.pi) + 360) % 360;
  }

  // 거리 형식화 (미터/킬로미터)
  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  void _centerMapOnLocation(LatLng location) async {
    try {
      final controller = await _getMapController();
      await controller.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
    } catch (e) {
      debugPrint('지도 중심 이동 오류: $e');
    }
  }

  void _zoomMap(int zoomDelta) async {
    try {
      final controller = await _getMapController();
      final position = await controller.getVisibleRegion();
      final zoom = await controller.getZoomLevel();

      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            (position.northeast.latitude + position.southwest.latitude) / 2,
            (position.northeast.longitude + position.southwest.longitude) / 2,
          ),
          zoom + zoomDelta,
        ),
      );
    } catch (e) {
      debugPrint('줌 동작 오류: $e');
    }
  }

  // 하단 정보 패널
  Widget _buildInfoPanel(MapLoaded state) {
    if (state.currentStage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  state.currentStage!.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(state.currentStage!.difficulty),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.currentStage!.difficulty,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.straighten, size: 16),
              const SizedBox(width: 4),
              Text('${state.currentStage!.distanceKm.toStringAsFixed(1)} km'),
              const SizedBox(width: 16),
              const Icon(Icons.trending_up, size: 16),
              const SizedBox(width: 4),
              Text('↑${state.currentStage!.elevationGainM} m'),
              const SizedBox(width: 16),
              const Icon(Icons.timer, size: 16),
              const SizedBox(width: 4),
              Text(
                '${state.currentStage!.estimatedTime.inHours}시간 ${state.currentStage!.estimatedTime.inMinutes % 60}분',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            state.currentStage!.description,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('이전 구간'),
                onPressed:
                    _getPreviousStageIndex(state) != null
                        ? () => _switchToStage(
                          state,
                          _getPreviousStageIndex(state)!,
                        )
                        : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              Text(
                '${_getCurrentStageIndex(state) + 1}/${state.caminoRoute.stages.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('다음 구간'),
                onPressed:
                    _getNextStageIndex(state) != null
                        ? () =>
                            _switchToStage(state, _getNextStageIndex(state)!)
                        : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 난이도에 따른 색상 반환
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // 현재 스테이지의 인덱스 반환
  int _getCurrentStageIndex(MapLoaded state) {
    if (state.currentStage == null) return 0;

    for (int i = 0; i < state.caminoRoute.stages.length; i++) {
      if (state.caminoRoute.stages[i].id == state.currentStage!.id) {
        return i;
      }
    }
    return 0;
  }

  // 이전 스테이지의 인덱스 반환 (있을 경우)
  int? _getPreviousStageIndex(MapLoaded state) {
    int currentIndex = _getCurrentStageIndex(state);
    if (currentIndex > 0) {
      return currentIndex - 1;
    }
    return null;
  }

  // 다음 스테이지의 인덱스 반환 (있을 경우)
  int? _getNextStageIndex(MapLoaded state) {
    int currentIndex = _getCurrentStageIndex(state);
    if (currentIndex < state.caminoRoute.stages.length - 1) {
      return currentIndex + 1;
    }
    return null;
  }

  // 특정 스테이지로 전환
  void _switchToStage(MapLoaded state, int stageIndex) {
    final stage = state.caminoRoute.stages[stageIndex];

    // 선택한 스테이지 업데이트
    context.read<MapBloc>().add(UpdateSelectedStage(stage));

    // 스테이지 경로가 있으면 지도를 해당 경로에 맞추기
    if (stage.path.isNotEmpty) {
      // 경로의 시작과 끝 지점에 마커 표시
      final startPoint = stage.path.first;
      final endPoint = stage.path.last;

      // 전체 경로가 보이도록 맵 조정
      _fitMapToRoute(stage.path);

      // 시작점 정보 업데이트
      final startLocationName = stage.name.split('→').first.trim();
      context.read<MapBloc>().add(
        UpdateSelectedLocation(startPoint, startLocationName),
      );
    }

    // 바텀시트 닫기
    Navigator.pop(context);
  }

  // 지도 컨트롤 버튼 스타일
  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.black87,
    Color backgroundColor = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
      ),
    );
  }

  // 맵 레이어 옵션 표시
  void _showLayerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                _layers.map((layer) {
                  return ListTile(
                    title: Text(layer),
                    onTap: () {
                      Navigator.pop(context);
                      // 지도 타입 변경
                      MapType mapType;
                      switch (layer) {
                        case 'Satellite':
                          mapType = MapType.satellite;
                          break;
                        case 'Terrain':
                          mapType = MapType.terrain;
                          break;
                        case 'Hybrid':
                          mapType = MapType.hybrid;
                          break;
                        case 'Normal':
                        default:
                          mapType = MapType.normal;
                          break;
                      }
                      context.read<MapBloc>().add(ChangeMapType(mapType));
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  // 필터 옵션 표시
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('마커 필터링', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      MarkerType.values
                          .where(
                            (type) =>
                                type != MarkerType.currentLocation &&
                                type != MarkerType.waypoint,
                          )
                          .map((type) => _buildFilterChip(type))
                          .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(MarkerType type) {
    final isVisible = _getMarkerVisibility(type);

    return FilterChip(
      label: Text(_getMarkerTypeName(type)),
      selected: isVisible,
      checkmarkColor: Colors.white,
      selectedColor: _getMarkerColor(type),
      onSelected: (bool selected) {
        setState(() {
          _toggleMarkerVisibility(type);
        });
      },
    );
  }

  String _getMarkerTypeName(MarkerType type) {
    switch (type) {
      case MarkerType.accommodation:
        return '숙소';
      case MarkerType.restaurant:
        return '식당';
      case MarkerType.pharmacy:
        return '약국';
      case MarkerType.landmark:
        return '명소';
      case MarkerType.currentLocation:
        return '현재 위치';
      case MarkerType.waypoint:
        return '경로 포인트';
      default:
        return '기타';
    }
  }

  Color _getMarkerColor(MarkerType type) {
    switch (type) {
      case MarkerType.accommodation:
        return Colors.blue;
      case MarkerType.restaurant:
        return Colors.orange;
      case MarkerType.pharmacy:
        return Colors.green;
      case MarkerType.landmark:
        return Colors.purple;
      case MarkerType.currentLocation:
        return Colors.red;
      case MarkerType.waypoint:
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  bool _getMarkerVisibility(MarkerType type) {
    switch (type) {
      case MarkerType.accommodation:
        return _showAccommodations;
      case MarkerType.restaurant:
        return _showRestaurants;
      case MarkerType.pharmacy:
        return _showPharmacies;
      case MarkerType.landmark:
        return _showLandmarks;
      default:
        return true;
    }
  }

  void _toggleMarkerVisibility(MarkerType type) {
    switch (type) {
      case MarkerType.accommodation:
        _showAccommodations = !_showAccommodations;
        break;
      case MarkerType.restaurant:
        _showRestaurants = !_showRestaurants;
        break;
      case MarkerType.pharmacy:
        _showPharmacies = !_showPharmacies;
        break;
      case MarkerType.landmark:
        _showLandmarks = !_showLandmarks;
        break;
      default:
        break;
    }
    _updateVisibleMarkers();
  }

  // 마커 필터링 업데이트
  void _updateVisibleMarkers() {
    setState(() {
      // 여기서 마커 가시성을 업데이트하는 로직 구현
      // 예: BLoC 이벤트 발생 또는 직접 마커 리스트 필터링
    });
  }

  // 모든 스테이지 목록 표시
  void _showStagesList() {
    if (context.read<MapBloc>().state is! MapLoaded) return;

    final mapState = context.read<MapBloc>().state as MapLoaded;
    final stages = mapState.caminoRoute.stages;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '카미노 프란세스 전체 스테이지',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: stages.length,
                  itemBuilder: (context, index) {
                    final stage = stages[index];
                    final isCurrentStage =
                        mapState.currentStage?.id == stage.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color:
                          isCurrentStage
                              ? stage.color.withOpacity(0.2)
                              : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color:
                              isCurrentStage
                                  ? stage.color
                                  : Colors.grey.shade300,
                          width: isCurrentStage ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _switchToStage(mapState, index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Stage ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: stage.color,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(
                                        stage.difficulty,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      stage.difficulty,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stage.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.straighten, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${stage.distanceKm}km'),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.timer, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${stage.estimatedTime.inHours}시간 ${stage.estimatedTime.inMinutes % 60}분',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 지도 설정 옵션 표시
  void _showSettingsOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '지도 설정',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // 순례자 모드 설정
                    _buildSettingSwitch(
                      icon: Icons.directions_walk,
                      title: '순례자 모드',
                      subtitle: '현재 순례길을 걷는 중인지 설정합니다',
                      value: state.pilgrimModeEnabled,
                      onChanged: (value) {
                        context.read<MapBloc>().add(TogglePilgrimMode(value));
                      },
                    ),

                    const Divider(),

                    // 경로 이탈 감지 설정
                    _buildSettingSwitch(
                      icon: Icons.route,
                      title: '경로 이탈 감지',
                      subtitle: '카미노 경로에서 벗어날 경우 알려줍니다',
                      value: state.deviationModeEnabled,
                      onChanged: (value) {
                        context.read<MapBloc>().add(ToggleDeviationMode(value));
                      },
                    ),

                    if (state.pilgrimModeEnabled && state.deviationModeEnabled)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '✓ 경로 이탈 감지가 활성화되었습니다. 카미노 경로에서 벗어나면 화면 상단에 경고가 표시됩니다.',
                          style: TextStyle(
                            color: Colors.green,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else if (state.pilgrimModeEnabled &&
                        !state.deviationModeEnabled)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '경로 이탈 감지를 활성화하려면 위 스위치를 켜세요.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else if (!state.pilgrimModeEnabled)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '경로 이탈 감지를 사용하려면 먼저 순례자 모드를 활성화하세요.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
            return const SizedBox(height: 100);
          },
        );
      },
    );
  }

  // 설정 스위치 위젯
  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: value ? Colors.blue : Colors.grey),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  // 스테이지 선택 바텀시트 보여주기
  void _showStageSelectionSheet(
    BuildContext context,
    List<CaminoStage> stages,
    CaminoStage? selectedStage,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '스테이지 선택하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: stages.length,
                  itemBuilder: (context, index) {
                    final stage = stages[index];
                    final isSelected = selectedStage?.id == stage.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                      elevation: isSelected ? 2 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          context.read<MapBloc>().add(
                            UpdateSelectedStage(stage),
                          );
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: stage.color,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      stage.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.blue,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.straighten,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${stage.distanceKm.toStringAsFixed(1)} km',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.trending_up,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${stage.elevationGainM.toStringAsFixed(0)} m',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.timelapse,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${stage.estimatedTime.inHours}시간 ${stage.estimatedTime.inMinutes % 60}분',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stage.description,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildDifficultyIndicator(stage.difficulty),
                                  const Spacer(),
                                  OutlinedButton(
                                    onPressed: () {
                                      context.read<MapBloc>().add(
                                        UpdateSelectedStage(stage),
                                      );

                                      // 지도 이동
                                      if (stage.path.isNotEmpty) {
                                        LatLng center = _calculateCenterOfPath(
                                          stage.path,
                                        );
                                        _moveToLatLng(center);

                                        // 적절한 줌 레벨 계산 및 적용
                                        double zoomLevel =
                                            _calculateZoomLevelForPath(
                                              stage.path,
                                            );
                                        _moveToLatLng(center, zoomLevel);
                                      }

                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      side: const BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    child: const Text('경로 보기'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 난이도 표시 위젯
  Widget _buildDifficultyIndicator(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'moderate':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hiking, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            difficulty,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 경로의 중간 지점 계산
  LatLng _calculateCenterOfPath(List<LatLng> path) {
    if (path.isEmpty) return const LatLng(0, 0);
    if (path.length == 1) return path.first;

    int middleIndex = path.length ~/ 2;
    return path[middleIndex];
  }

  // 경로에 맞는 줌 레벨 계산
  double _calculateZoomLevelForPath(List<LatLng> points) {
    if (points.isEmpty) return 12.0;

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    // 경로의 바운딩 박스 계산
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;

    // 경험적 수치로 계산 (값이 낮을수록 더 확대됨)
    final zoomLevel =
        14.0 - math.log(math.max(latDiff, lngDiff) * 111.0) / math.ln2;

    return math.min(math.max(zoomLevel, 10.0), 15.0); // 줌 범위 제한
  }

  Future<void> _moveToLatLng(LatLng latLng, [double zoom = 15.0]) async {
    try {
      final controller = await _getMapController();
      controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, zoom));
    } catch (e) {
      debugPrint('Error moving camera: $e');
    }
  }

  Future<void> _animateCameraToCurrentLocation() async {
    try {
      final controller = await _getMapController();
      final state = context.read<MapBloc>().state;
      if (state is MapLoaded && state.currentLocation != null) {
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(state.currentLocation!, 18.0),
        );
      }
    } catch (e) {
      debugPrint('Error animating to current location: $e');
    }
  }

  Future<void> _moveToNearestStagePoint() async {
    try {
      final controller = await _getMapController();
      final state = context.read<MapBloc>().state;
      if (state is MapLoaded &&
          state.currentStage != null &&
          state.currentStage!.path.isNotEmpty) {
        // 현재 스테이지의 첫 번째 포인트로 이동
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(state.currentStage!.path.first, 16.0),
        );
      }
    } catch (e) {
      debugPrint('Error moving to nearest stage point: $e');
    }
  }
}
