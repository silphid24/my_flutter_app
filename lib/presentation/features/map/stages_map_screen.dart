import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_flutter_app/models/stage_model.dart';
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:my_flutter_app/services/stage_service.dart';
import 'package:my_flutter_app/models/track.dart';
import 'package:my_flutter_app/presentation/features/camino/camino_map_screen.dart';
import 'package:location/location.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stages Map Screen
///
/// 카미노 데 산티아고의 스테이지(구간)들을 지도에 표시하는 화면입니다.
/// 사용자는 스테이지를 선택하여 상세 정보를 볼 수 있습니다.
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

    // GoRouter의 extra에서 위치 정보를 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = this.context;
      final routeState = GoRouterState.of(context);

      if (routeState.extra != null && routeState.extra is Map) {
        final extra = routeState.extra as Map;
        if (extra.containsKey('location') && extra.containsKey('name')) {
          final location = extra['location'] as LatLng;
          final name = extra['name'] as String;

          // 특정 위치로 지도 이동
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              if (_mapController.camera != null) {
                _mapController.move(location, 13.0);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name 위치로 이동했습니다')),
                );
              }
            } catch (e) {
              debugPrint('지도 이동 중 오류: $e');
            }
          });
        }
      }
    });
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
        if (mounted) {
          setState(() {
            _currentLocation = locationData;
          });

          // 현재 위치에 해당하는 스테이지 찾기
          _updateCurrentStage();
        }
      });

      // 초기 위치 가져오기
      _currentLocation = await _location.getLocation();
      if (_currentLocation != null && mounted) {
        _updateCurrentStage();
      }
    } catch (e) {
      debugPrint('위치 서비스 초기화 오류: $e');
    }
  }

  // 현재 위치에 해당하는 스테이지 찾기
  void _updateCurrentStage() {
    if (_currentLocation == null || !mounted) return;

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
    if (minDistance < 10.0 && mounted) {
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
          point: LatLng(
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
        ),
      );
    }

    // UI 업데이트
    setState(() {});
  }

  // 스테이지 마커 추가
  void _addStageMarkers(CaminoStage stage,
      {bool isSelected = false, bool isCurrentLocation = false}) {
    // 시작점 마커
    _markers.add(
      Marker(
        point: stage.startPoint,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue
                : isCurrentLocation
                    ? Colors.green
                    : Colors.orange,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.pin_drop,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );

    // 도착점 마커
    _markers.add(
      Marker(
        point: stage.endPoint,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue
                : isCurrentLocation
                    ? Colors.green
                    : Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.flag,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  // 첫 번째 스테이지 로드
  Future<void> _loadFirstStage() async {
    if (_stages.isEmpty || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _loadStageGpx(_stages.first.assetPath);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '스테이지 GPX 로드 중 오류: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 스테이지 GPX 파일 로드
  Future<void> _loadStageGpx(String assetPath) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final track = await _gpxService.loadGpxFromAsset(assetPath);
      if (track != null && mounted) {
        setState(() {
          _track = track;
          _routePoints = track.points.map((p) => p.position).toList();

          // 경로 중심으로 맵 이동
          _moveMapToCenter();
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = 'GPX 로드 실패: 파일이 유효하지 않습니다';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'GPX 로드 중 오류: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 맵을 현재 로드된 경로의 중심으로 이동
  void _moveMapToCenter() {
    if (_routePoints.isEmpty) return;

    try {
      // 경로의 모든 좌표로부터 중심점 계산
      double latSum = 0, lngSum = 0;
      for (var point in _routePoints) {
        latSum += point.latitude;
        lngSum += point.longitude;
      }

      final centerLat = latSum / _routePoints.length;
      final centerLng = lngSum / _routePoints.length;
      final center = LatLng(centerLat, centerLng);

      // 지도 이동
      if (_mapController.camera != null) {
        _mapController.move(center, 11.0);
      }
    } catch (e) {
      debugPrint('지도 이동 중 오류: $e');
    }
  }

  // 현재 위치로 이동
  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      try {
        final targetLocation = LatLng(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        );
        _mapController.move(targetLocation, 15.0);
      } catch (e) {
        debugPrint('지도 이동 중 오류: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 위치를 확인할 수 없습니다')),
      );
    }
  }

  // 특정 스테이지 선택
  void _onStageSelected(CaminoStage stage) {
    if (!mounted) return;

    setState(() {
      _selectedStage = stage;
      _showStagesList = false;
    });

    _loadStageGpx(stage.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카미노 경로 지도'),
        actions: [
          // 위치 버튼
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _moveToCurrentLocation,
          ),
          // 스테이지 목록 버튼
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () {
              setState(() {
                _showStagesList = !_showStagesList;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 지도
          _buildMap(),

          // 로딩 인디케이터
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // 오류 메시지
          if (_errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadFirstStage,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),

          // 스테이지 목록
          if (_showStagesList) _buildStagesList(),

          // 선택된 스테이지 정보
          if (_selectedStage != null && !_showStagesList)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildStageInfo(_selectedStage!),
            ),
        ],
      ),
    );
  }

  // 지도 위젯 구성
  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(42.9, -1.8), // 카미노 대략적 위치
        initialZoom: 7,
        maxZoom: 18,
        minZoom: 4,
      ),
      children: [
        // 기본 타일 레이어
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.my_flutter_app',
        ),

        // 전체 카미노 경로 표시
        PolylineLayer(
          polylines: [
            Polyline(
              points: _completeRoutePoints,
              color: Colors.grey.withAlpha(127),
              strokeWidth: 3.0,
            ),
          ],
        ),

        // 현재 선택된 경로 표시
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: Colors.blue,
                strokeWidth: 5.0,
              ),
            ],
          ),

        // 마커 표시
        MarkerLayer(markers: _markers),
      ],
    );
  }

  // 스테이지 목록 위젯
  Widget _buildStagesList() {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      width: MediaQuery.of(context).size.width * 0.7,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              color: Colors.blue,
              child: const Row(
                children: [
                  Icon(Icons.map, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    '스테이지 목록',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _stages.length,
                itemBuilder: (context, index) {
                  final stage = _stages[index];
                  final isSelected =
                      _selectedStage != null && _selectedStage!.id == stage.id;
                  final isCurrentLocation = _currentLocationStage != null &&
                      _currentLocationStage!.id == stage.id;

                  return ListTile(
                    title: Text(
                      '${stage.stageNumber}. ${stage.name}',
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text('${stage.distance}km'),
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : isCurrentLocation
                                ? Colors.green
                                : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${stage.stageNumber}',
                          style: TextStyle(
                            color: isSelected || isCurrentLocation
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _onStageSelected(stage),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 선택된 스테이지 정보 위젯
  Widget _buildStageInfo(CaminoStage stage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '스테이지 ${stage.stageNumber}: ${stage.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedStage = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place, size: 16, color: Colors.blue),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  stage.startName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 16),
              ),
              const Icon(Icons.flag, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  stage.endName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.straighten, size: 16),
              const SizedBox(width: 4),
              Text('${stage.distance} km'),
              const SizedBox(width: 16),
              const Icon(Icons.hiking, size: 16),
              const SizedBox(width: 4),
              Text('난이도: ${_getDifficultyText(stage.difficulty)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  stage.description ?? '이 스테이지에 대한 정보가 없습니다',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // 스테이지 상세 정보 페이지로 이동 (미구현)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${stage.name} 상세 정보 페이지는 개발 중입니다'),
                    ),
                  );
                },
                icon: const Icon(Icons.info),
                label: const Text('상세 정보'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final fullMapRoute = '/full_camino_map';
                  context.go(fullMapRoute);
                },
                icon: const Icon(Icons.map),
                label: const Text('전체 지도'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 난이도 텍스트 변환
  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return '쉬움';
      case 2:
        return '보통';
      case 3:
        return '중간';
      case 4:
        return '어려움';
      case 5:
        return '매우 어려움';
      default:
        return '알 수 없음';
    }
  }
}
