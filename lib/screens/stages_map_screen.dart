import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_flutter_app/models/stage_model.dart';
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:my_flutter_app/services/stage_service.dart';
import 'package:my_flutter_app/models/track.dart';
import 'package:my_flutter_app/screens/camino_map_screen.dart';
import 'package:my_flutter_app/screens/home_screen.dart';
import 'package:my_flutter_app/screens/community/community_screen.dart';
import 'package:my_flutter_app/screens/info/info_screen.dart';
import 'package:location/location.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StagesMapScreen extends ConsumerStatefulWidget {
  const StagesMapScreen({super.key});

  @override
  ConsumerState<StagesMapScreen> createState() => _StagesMapScreenState();
}

class _StagesMapScreenState extends ConsumerState<StagesMapScreen> {
  late MapController _mapController;
  final StageService _stageService = StageService();
  final GpxService _gpxService = GpxService();
  final Location _location = Location();

  late List<CaminoStage> _stages;
  CaminoStage? _selectedStage;
  CaminoStage? _currentLocationStage;
  Track? _track;
  bool _isLoading = false;
  bool _showStagesList = false;
  String? _errorMessage;
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;

  List<Marker> _markers = [];
  List<LatLng> _routePoints = [];
  List<LatLng> _completeRoutePoints = []; // 전체 카미노 경로

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _stages = _stageService.getAllStages();

    // 전체 카미노 경로 포인트 가져오기
    _completeRoutePoints = _stageService.getAllStagesPoints();

    // 초기화 시 첫 번째 스테이지를 선택
    if (_stages.isNotEmpty) {
      // 첫 스테이지를 선택 상태로 지정
      _selectedStage = _stages.first;
      // 첫 스테이지 GPX 로드 시작
      _loadFirstStage();
    }

    // 사용자 위치 가져오기
    _initLocationService();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  // 위치 서비스 초기화
  Future<void> _initLocationService() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      // 위치 변경 구독
      _locationSubscription =
          _location.onLocationChanged.listen((locationData) {
        setState(() {
          _currentLocation = locationData;
        });

        // 현재 위치에 해당하는 스테이지 찾기
        _updateCurrentStage();
      });

      // 초기 위치 가져오기
      _currentLocation = await _location.getLocation();
      if (_currentLocation != null) {
        _updateCurrentStage();
      }
    } catch (e) {
      print('위치 서비스 초기화 오류: $e');
    }
  }

  // 현재 위치에 해당하는 스테이지 찾기
  void _updateCurrentStage() {
    if (_currentLocation == null) return;

    CaminoStage? nearestStage;
    double minDistance = double.infinity;

    // 각 스테이지와 현재 위치 사이의 거리 계산
    for (final stage in _stages) {
      final distance = _calculateDistance(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        stage.startPoint,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestStage = stage;
      }
    }

    // 일정 거리 내에 있을 경우에만 현재 스테이지로 설정 (10km 이내)
    if (minDistance < 10.0) {
      setState(() {
        _currentLocationStage = nearestStage;

        // 선택된 스테이지가 없고 현재 위치 스테이지가 감지되었으면
        // 현재 위치 스테이지로 자동 선택
        if (_selectedStage == null && _currentLocationStage != null) {
          _selectedStage = _currentLocationStage;
          _onStageSelected(_selectedStage!);
        }
      });
    }

    // 마커 업데이트
    _updateMarkers();
  }

  // 두 지점 간의 거리 계산 (km 단위)
  double _calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  // 마커 업데이트 - 선택된 스테이지나 현재 위치 스테이지만 표시
  void _updateMarkers() {
    _markers = [];

    // 선택된 스테이지가 있으면 해당 스테이지 마커 표시 (파란색)
    if (_selectedStage != null) {
      _addStageMarkers(_selectedStage!, isSelected: true);
    }

    // 현재 위치의 스테이지가 있고, 선택된 스테이지와 다르면 현재 위치 스테이지 마커도 표시 (녹색)
    if (_currentLocationStage != null &&
        (_selectedStage == null ||
            _currentLocationStage!.id != _selectedStage!.id)) {
      _addStageMarkers(_currentLocationStage!, isCurrentLocation: true);
    }

    // 현재 사용자 위치 마커 추가
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          width: 40,
          height: 40,
          point:
              LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    setState(() {});
  }

  // 특정 스테이지의 마커 추가
  void _addStageMarkers(CaminoStage stage,
      {bool isSelected = false, bool isCurrentLocation = false}) {
    // 마커 색상 결정 (선택된 스테이지: 파란색, 현재 위치 스테이지: 녹색)
    final startColor = isSelected
        ? Colors.blue
        : (isCurrentLocation ? Colors.green : Colors.grey);
    final endColor = isSelected
        ? Colors.blue.shade800
        : (isCurrentLocation ? Colors.green.shade800 : Colors.red);
    final labelPrefix = isSelected ? 'S' : (isCurrentLocation ? 'C' : 'S');

    // 시작점 마커
    _markers.add(
      Marker(
        width: 60,
        height: 60,
        point: stage.startPoint,
        child: GestureDetector(
          onTap: () {
            _onStageSelected(stage);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: startColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.place,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                margin: const EdgeInsets.only(top: 2),
                child: Text(
                  '$labelPrefix${stage.dayNumber ?? '?'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 종료점 마커
    _markers.add(
      Marker(
        width: 60,
        height: 60,
        point: stage.endPoint,
        child: GestureDetector(
          onTap: () {
            _onStageSelected(stage);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: endColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.flag,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                margin: const EdgeInsets.only(top: 2),
                child: Text(
                  'E${stage.dayNumber ?? '?'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle stage selection
  void _onStageSelected(CaminoStage stage) async {
    setState(() {
      _selectedStage = stage;
      _isLoading = true;
      _errorMessage = null;
      _routePoints = [];
    });

    try {
      // Load GPX file
      final track = await _gpxService.loadGpxFromAsset(stage.assetPath);

      if (track != null) {
        setState(() {
          _track = track;
          _routePoints = track.points.map((point) => point.position).toList();
          _isLoading = false;
        });

        // 마커 업데이트
        _updateMarkers();

        // Center map on selected stage
        _centerMapOnStage(stage);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load route.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  // Center map on selected stage
  void _centerMapOnStage(CaminoStage stage) {
    if (_mapController.camera == null) {
      print('지도 컨트롤러가 아직 준비되지 않았습니다.');
      return;
    }

    // Move to center between start and end points
    final centerLat = (stage.startPoint.latitude + stage.endPoint.latitude) / 2;
    final centerLng =
        (stage.startPoint.longitude + stage.endPoint.longitude) / 2;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (_mapController.camera == null) {
          print('지도 컨트롤러가 아직 준비되지 않았습니다.');
          return;
        }
        _mapController.move(LatLng(centerLat, centerLng), 10.0);
      } catch (e) {
        print('Map center error: $e');
      }
    });
  }

  // 첫 번째 스테이지 로드
  Future<void> _loadFirstStage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _routePoints = [];
    });

    try {
      // 첫 번째 스테이지 GPX 파일 로드
      final track =
          await _gpxService.loadGpxFromAsset(_selectedStage!.assetPath);

      if (track != null) {
        setState(() {
          _track = track;
          _routePoints = track.points.map((point) => point.position).toList();
          _isLoading = false;
        });

        // 마커 업데이트
        _updateMarkers();

        // 첫 번째 스테이지로 지도 센터 이동
        _centerMapOnStage(_selectedStage!);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '경로를 로드할 수 없습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '오류: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 기본 지도 중심 위치 설정 (첫 번째 스테이지 또는 스페인 북부)
    LatLng initialCenter = LatLng(42.9, -1.8); // 기본 카미노 위치
    double initialZoom = 7.0;

    // 선택된 스테이지가 있는 경우 해당 스테이지의 중심으로 설정
    if (_selectedStage != null) {
      initialCenter = LatLng(
        (_selectedStage!.startPoint.latitude +
                _selectedStage!.endPoint.latitude) /
            2,
        (_selectedStage!.startPoint.longitude +
                _selectedStage!.endPoint.longitude) /
            2,
      );
      initialZoom = 10.0;
    }
    // 현재 위치가 있는 경우 현재 위치 근처로 설정
    else if (_currentLocation != null) {
      initialCenter =
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
      initialZoom = 12.0;
    }
    // 스테이지 목록이 있는 경우 첫 번째 스테이지로 설정
    else if (_stages.isNotEmpty) {
      initialCenter = LatLng(
        (_stages.first.startPoint.latitude + _stages.first.endPoint.latitude) /
            2,
        (_stages.first.startPoint.longitude +
                _stages.first.endPoint.longitude) /
            2,
      );
      initialZoom = 10.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedStage?.title ?? 'Camino de Santiago Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedStage != null) {
              // If a stage is selected, unselect it
              setState(() {
                _selectedStage = null;
                _routePoints = [];
              });
              _updateMarkers();

              // 첫 번째 스테이지가 있으면 다시 선택
              if (_stages.isNotEmpty) {
                _selectedStage = _stages.first;
                _loadFirstStage();
              }
            } else {
              // If no stage is selected, go back to previous screen
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              setState(() {
                _showStagesList = !_showStagesList;
              });
            },
            tooltip: 'Show/Hide Stages List',
          ),
          if (_selectedStage != null)
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () {
                // View selected stage in full screen map
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CaminoMapScreen(
                      trackId: _selectedStage!.id,
                    ),
                  ),
                );
              },
              tooltip: 'View Full Screen',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Map area
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: initialZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.my_flutter_app',
                additionalOptions: const {
                  'User-Agent': 'Camino de Santiago Pilgrim App/1.0',
                },
              ),
              // 전체 카미노 경로 (회색)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _completeRoutePoints,
                    strokeWidth: 3.0,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
              // 선택된 스테이지 경로 (파란색)
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_isLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading route...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Stages list - only visible when toggle button is pressed
          if (_showStagesList)
            Positioned(
              bottom: 70, // Space for bottom navigation bar
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Camino Frances Stages',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _showStagesList = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _stages.length,
                        itemBuilder: (context, index) {
                          final stage = _stages[index];
                          final isSelected = _selectedStage?.id == stage.id;
                          final isCurrentLocation =
                              _currentLocationStage?.id == stage.id;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            color: isSelected
                                ? Colors.blue[100]
                                : (isCurrentLocation
                                    ? Colors.green[50]
                                    : Colors.white),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? Colors.blue
                                    : (isCurrentLocation
                                        ? Colors.green
                                        : Colors.grey[700]),
                                child: Text(
                                  '${stage.dayNumber}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                stage.title,
                                style: TextStyle(
                                  fontWeight: isSelected || isCurrentLocation
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                stage.description ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isCurrentLocation)
                                    const Icon(
                                      Icons.my_location,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${stage.distance?.toStringAsFixed(1) ?? "?"} km',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.blue[800]
                                          : (isCurrentLocation
                                              ? Colors.green[800]
                                              : Colors.grey[700]),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _onStageSelected(stage),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Home',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
            ),
            _buildNavItem(
              icon: Icons.map,
              label: 'Map',
              isSelected: true,
            ),
            _buildNavItem(
              icon: Icons.people,
              label: 'Community',
              onTap: () {
                context.go('/community');
              },
            ),
            _buildNavItem(
              icon: Icons.info,
              label: 'Info',
              onTap: () {
                context.go('/info');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.black54,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
