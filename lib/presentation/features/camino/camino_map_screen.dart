import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:my_flutter_app/services/stage_service.dart';
import 'package:my_flutter_app/models/track.dart';
import 'package:my_flutter_app/models/stage_model.dart' as stage_model;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/presentation/features/camino/widgets/google_map_component.dart';
import 'package:my_flutter_app/presentation/features/camino/utils/map_utils.dart';
import 'package:my_flutter_app/presentation/features/shared/layout/app_scaffold.dart';

/// Camino Map Screen
///
/// 카미노 데 산티아고 경로의 상세 지도를 표시하는 화면입니다.
/// OpenStreetMap과 Google Maps를 모두 지원합니다.
class CaminoMapScreen extends ConsumerStatefulWidget {
  final String? trackId;

  const CaminoMapScreen({super.key, this.trackId});

  @override
  ConsumerState<CaminoMapScreen> createState() => _CaminoMapScreenState();
}

class _CaminoMapScreenState extends ConsumerState<CaminoMapScreen> {
  final GpxService _gpxService = GpxService();
  final Location _locationService = Location();
  final Completer<gmaps.GoogleMapController> _googleMapController = Completer();
  final StageService _stageService = StageService();

  Track? _track;
  bool _isLoading = true;
  bool _isLocationEnabled = false;
  String? _statusMessage; // 로딩 및 상태 메시지

  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;

  // 지도에 표시할 경로 포인트
  List<latlong2.LatLng> _routePoints = [];
  List<latlong2.LatLng> _completeRoutePoints = [];

  // Google Maps 마커와 경로
  Set<gmaps.Marker> _googleMarkers = {};
  Set<gmaps.Polyline> _googlePolylines = {};
  Set<gmaps.Polyline> _googleCompleteRoutePolylines = {};

  // 지도 설정
  latlong2.LatLng _center =
      const latlong2.LatLng(42.9, -1.8); // 산티아고 순례길 대략적 위치
  double _zoom = 8.0;

  bool _isDisposed = false;

  gmaps.MapType _currentMapType = gmaps.MapType.normal;

  @override
  void initState() {
    super.initState();

    // 전체 카미노 경로 포인트 가져오기 (Google Maps LatLng -> latlong2.LatLng로 변환)
    _completeRoutePoints = MapUtils.convertListFromGoogleLatLng(
        _stageService.getAllStagesPoints());

    _initLocationService();

    // 특정 스테이지 ID가 있는 경우 해당 스테이지 GPX 파일 로드
    if (widget.trackId != null && widget.trackId!.startsWith('stage')) {
      // 스테이지 서비스를 통해 스테이지 정보 조회
      final stageService = StageService();
      final stage = stageService.getStageById(widget.trackId!);

      if (stage != null) {
        // 스테이지가 있는 경우 해당 GPX 파일 로드
        _loadStageGpx(stage.assetPath);
      } else {
        // 그렇지 않은 경우 기본 트랙 로드
        _startLoadingTrack();
      }
    } else {
      // 스테이지 ID가 없는 경우 기본 트랙 로드
      _startLoadingTrack();
    }

    // 구글맵용 전체 경로 폴리라인 설정
    _setupGoogleCompleteRoute();
  }

  @override
  void dispose() {
    _isDisposed = true;
    // 위치 구독 취소
    _locationSubscription?.cancel();

    // GPX 로드 작업 취소
    _gpxService.cancelLoading();

    // Google 맵 컨트롤러가 초기화된 경우 리소스 정리
    if (_googleMapController.isCompleted) {
      _googleMapController.future.then((controller) {
        controller.dispose();
      }).catchError((e) {
        // 컨트롤러 해제 중 오류가 발생하더라도 무시
        debugPrint('Google Maps 컨트롤러 해제 중 오류: $e');
      });
    }

    // 트랙 참조 명시적으로 해제
    _track = null;
    _routePoints = [];
    _completeRoutePoints = [];
    _googleMarkers = {};
    _googlePolylines = {};
    _googleCompleteRoutePolylines = {};

    super.dispose();
  }

  // 위치 서비스 초기화
  Future<void> _initLocationService() async {
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

      // 위치 업데이트 구독
      _locationSubscription = _locationService.onLocationChanged
          .listen((LocationData locationData) {
        setState(() {
          _currentLocation = locationData;
          _updateMarkers();
        });

        // 위치 추적이 활성화되었을 때만 카메라 이동
        if (_isLocationEnabled && _currentLocation != null) {
          _safelyMoveToCurrentLocation();
        }
      });

      setState(() {
        _isLocationEnabled = true;
      });
    } catch (e) {
      debugPrint('위치 서비스 초기화 오류: $e');
    }
  }

  // Google Maps 카메라 이동
  void _moveGoogleMap() async {
    if (_currentLocation != null && _googleMapController.isCompleted) {
      try {
        final controller = await _googleMapController.future;
        controller.animateCamera(
          gmaps.CameraUpdate.newCameraPosition(
            gmaps.CameraPosition(
              target: gmaps.LatLng(
                _currentLocation!.latitude!,
                _currentLocation!.longitude!,
              ),
              zoom: _zoom,
            ),
          ),
        );
      } catch (e) {
        debugPrint('Google Maps 이동 중 오류: $e');
      }
    }
  }

  // 다른 지도 컨트롤러 이동 관련 부분 수정
  void _moveMap() {
    if (_currentLocation != null) {
      try {
        _moveGoogleMap();
      } catch (e) {
        // 오류 무시 또는 로깅만 수행
        debugPrint('지도 이동 중 오류: $e');
      }
    }
  }

  // 현재 위치로 안전하게 이동
  void _safelyMoveToCurrentLocation() {
    try {
      _moveMap();
    } catch (e) {
      debugPrint("지도 이동 중 오류: $e");
    }
  }

  // 트랙 데이터 로드
  void _startLoadingTrack() async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    // 로딩 지연 시간 표시를 위한 타이머 설정
    Future.delayed(const Duration(seconds: 5), () {
      if (_isLoading && mounted && !_isDisposed) {
        setState(() {
          _statusMessage = 'Loading data, please wait...';
        });
      }
    });

    try {
      await _loadDefaultTrack();
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error loading data: $e';
        });
      }
    }
  }

  // 스테이지 GPX 파일 로드
  Future<void> _loadStageGpx(String assetPath) async {
    if (_isDisposed) return;

    try {
      if (!mounted || _isDisposed) return; // 추가 검사

      setState(() {
        _statusMessage = 'Loading stage GPX data...';
      });

      // 비동기 작업 시작 전 마운트 상태 저장
      bool wasDisposedBeforeLoad = _isDisposed;

      final track = await _gpxService.loadGpxFromAsset(assetPath);

      // 화면이 이미 언마운트되었거나, 객체가 dispose 되었으면 중단
      if (!mounted || _isDisposed || wasDisposedBeforeLoad) {
        debugPrint('Screen is already unmounted or disposed.');
        return;
      }

      if (track != null) {
        try {
          setState(() {
            _track = track;
            _routePoints = track.points.map((p) => p.position).toList();
            _center = _calculateCenter(_routePoints);
            _updateMarkers();
            _isLoading = false;
          });
        } catch (stateError) {
          debugPrint('setState error: $stateError');
          // setState 오류를 무시하고 진행
        }
      } else if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Unable to load track';
        });
      }
    } catch (e) {
      // 오류 처리 전에 마운트 상태 재확인
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error loading GPX data: $e';
        });
      }
    }
  }

  // 기본 트랙 로드
  Future<void> _loadDefaultTrack() async {
    if (_isDisposed) return;

    try {
      if (!mounted || _isDisposed) return; // 추가 검사

      setState(() {
        _statusMessage = 'Loading default track...';
      });

      // 비동기 작업 시작 전 마운트 상태 저장
      bool wasDisposedBeforeLoad = _isDisposed;

      final track = await _gpxService
          .loadGpxFromAsset('assets/data/Stage-1-Camino-Frances.gpx');

      // 화면이 이미 언마운트되었거나, 객체가 dispose 되었으면 중단
      if (!mounted || _isDisposed || wasDisposedBeforeLoad) {
        debugPrint('Screen is already unmounted or disposed.');
        return;
      }

      if (track != null) {
        try {
          if (!mounted || _isDisposed) return; // 마지막 검사

          setState(() {
            _track = track;
            _routePoints = track.points.map((p) => p.position).toList();
            _center = _calculateCenter(_routePoints);
            _updateMarkers();
            _isLoading = false;
          });
        } catch (stateError) {
          debugPrint('setState error: $stateError');
          // setState 오류를 무시하고 진행
        }
      } else if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Failed to load track data';
        });
      }
    } catch (e) {
      debugPrint('Error loading track: $e');
      // 오류 처리 전에 마운트 상태 재확인
      if (mounted && !_isDisposed) {
        try {
          setState(() {
            _isLoading = false;
            _statusMessage = 'Error loading track: $e';
          });
        } catch (stateError) {
          debugPrint('setState error: $stateError');
        }
      }
    }
  }

  // 경로의 중심점 계산
  latlong2.LatLng _calculateCenter(List<latlong2.LatLng> points) {
    if (points.isEmpty) {
      return const latlong2.LatLng(42.9, -1.8); // 기본 위치 (산티아고 대략적 위치)
    }

    double latSum = 0, lngSum = 0;
    for (var point in points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }

    return latlong2.LatLng(
      latSum / points.length,
      lngSum / points.length,
    );
  }

  // 마커 업데이트
  void _updateMarkers() {
    if (_track == null || _isDisposed || !mounted) return;

    // Google Maps 마커 업데이트
    _updateGoogleMapMarkers();
  }

  // Google Maps 마커 업데이트
  void _updateGoogleMapMarkers() {
    _googleMarkers = {};
    _googlePolylines = {};

    // 트랙 경로 폴리라인 추가
    if (_routePoints.isNotEmpty) {
      _googlePolylines.add(_createGoogleMapPolyline(
        points: _convertToGoogleLatLngList(_routePoints),
        id: 'route',
        color: Colors.blue,
        width: 4,
      ));
    }

    // 시작 지점 마커
    if (_track != null && _track!.startPoint != null) {
      _googleMarkers.add(_createGoogleMapMarker(
        position: _convertToGoogleLatLng(_track!.startPoint!),
        id: 'start',
        title: 'Start',
      ));
    }

    // 종료 지점 마커
    if (_track != null && _track!.endPoint != null) {
      _googleMarkers.add(_createGoogleMapMarker(
        position: _convertToGoogleLatLng(_track!.endPoint!),
        id: 'end',
        title: 'End',
      ));
    }

    // 현재 위치 마커
    if (_currentLocation != null) {
      _googleMarkers.add(_createGoogleMapMarker(
        position: gmaps.LatLng(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        ),
        id: 'current_location',
        title: 'Current Location',
      ));
    }
  }

  // Google Maps 전체 경로 설정
  void _setupGoogleCompleteRoute() {
    _googleCompleteRoutePolylines = {
      _createGoogleMapPolyline(
        points: _convertToGoogleLatLngList(_completeRoutePoints),
        id: 'complete_route',
        color: Colors.grey.shade600,
        width: 3,
      ),
    };
  }

  // Flutter 좌표를 Google 좌표로 변환
  gmaps.LatLng _convertToGoogleLatLng(latlong2.LatLng point) {
    return gmaps.LatLng(point.latitude, point.longitude);
  }

  // Flutter 좌표 리스트를 Google 좌표 리스트로 변환
  List<gmaps.LatLng> _convertToGoogleLatLngList(List<latlong2.LatLng> points) {
    return points
        .map((point) => gmaps.LatLng(point.latitude, point.longitude))
        .toList();
  }

  // Google Maps 폴리라인 생성
  gmaps.Polyline _createGoogleMapPolyline({
    required List<gmaps.LatLng> points,
    required String id,
    required Color color,
    double width = 3.0,
  }) {
    return gmaps.Polyline(
      polylineId: gmaps.PolylineId(id),
      points: points,
      color: color,
      width: width.toInt(),
    );
  }

  // Google Maps 마커 생성
  gmaps.Marker _createGoogleMapMarker({
    required gmaps.LatLng position,
    required String id,
    String? title,
  }) {
    return gmaps.Marker(
      markerId: gmaps.MarkerId(id),
      position: position,
      infoWindow: title != null
          ? gmaps.InfoWindow(title: title)
          : const gmaps.InfoWindow(title: ''), // 기본값 제공
      // 마커 클릭 시 Google Maps 경로 찾기가 자동으로 활성화되도록 설정
      onTap: null, // 마커 클릭 시 기본 작동 사용
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.trackId != null
          ? 'Camino de Santiago Map'
          : 'Camino de Santiago Map',
      currentIndex: 1, // Map screen is index 1
      actions: [
        // Map settings button
        IconButton(
          icon: const Icon(Icons.layers),
          onPressed: () {
            _showMapTypeOptions(context);
          },
          tooltip: 'Change Map Type',
        ),
        // Stage selection button
        IconButton(
          icon: const Icon(Icons.map),
          onPressed: () {
            _showStageSelection(context);
          },
          tooltip: 'Select Stage',
        ),
      ],
      body: Stack(
        children: [
          // Map widget
          _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      if (_statusMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _statusMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                )
              : _buildGoogleMap(),

          // Map info display
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                widget.trackId != null
                    ? 'Stage: ${_getStageNameById(widget.trackId!)}'
                    : 'Camino Frances Full Map',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),

          // Current location and zoom control buttons
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current location button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    heroTag: 'location',
                    onPressed: () {
                      setState(() {
                        _isLocationEnabled = !_isLocationEnabled;
                      });
                      _moveToCurrentLocation();
                    },
                    backgroundColor: _isLocationEnabled
                        ? Colors.blue
                        : Theme.of(context).primaryColor,
                    child: Icon(
                      _isLocationEnabled
                          ? Icons.gps_fixed
                          : Icons.gps_not_fixed,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Zoom in button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    onPressed: () {
                      setState(() {
                        _zoom = math.min(_zoom + 1, 18.0);
                      });
                      _zoomMap(_zoom);
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),

                // Zoom out button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    onPressed: () {
                      setState(() {
                        _zoom = math.max(_zoom - 1, 5.0);
                      });
                      _zoomMap(_zoom);
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMapComponent(
      controller: _googleMapController,
      center: MapUtils.convertToGoogleLatLng(_center),
      zoom: _zoom,
      markers: _googleMarkers,
      polylines: {..._googleCompleteRoutePolylines, ..._googlePolylines},
      onTap: null,
      mapType: _currentMapType,
    );
  }

  // 스테이지 ID로 스테이지 이름 가져오기
  String _getStageNameById(String stageId) {
    final stage = _stageService.getStageById(stageId);
    return stage != null
        ? 'Stage ${stage.stageNumber}: ${stage.title}'
        : 'Unknown Stage';
  }

  // 지도 유형 선택 다이얼로그 표시
  void _showMapTypeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Default Map'),
                onTap: () {
                  setState(() {
                    _currentMapType = gmaps.MapType.normal;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.satellite),
                title: const Text('Satellite Map'),
                onTap: () {
                  setState(() {
                    _currentMapType = gmaps.MapType.satellite;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.terrain),
                title: const Text('Terrain Map'),
                onTap: () {
                  setState(() {
                    _currentMapType = gmaps.MapType.terrain;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.layers),
                title: const Text('Hybrid Map'),
                onTap: () {
                  setState(() {
                    _currentMapType = gmaps.MapType.hybrid;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 스테이지 선택 다이얼로그 표시
  void _showStageSelection(BuildContext context) {
    final allStages = _stageService.getAllStages();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Camino Frances Stage Selection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: allStages.length,
                    itemBuilder: (context, index) {
                      final stage = allStages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              '${stage.stageNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            stage.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: stage.description != null
                              ? Text(stage.description!)
                              : null,
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // 선택한 스테이지 GPX 파일 로드
                            _loadStageGpx(stage.assetPath);

                            // 선택한 스테이지 위치로 지도 이동
                            _moveToStage(stage);

                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 선택한 스테이지 위치로 지도 이동
  void _moveToStage(stage_model.CaminoStage stage) {
    final startPoint = MapUtils.convertToGoogleLatLng(
        latlong2.LatLng(stage.startPoint.latitude, stage.startPoint.longitude));

    _googleMapController.future.then((controller) {
      controller.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(startPoint, 12.0),
      );
    });
  }

  // 현재 위치로 지도 이동
  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      _googleMapController.future.then((controller) {
        controller.animateCamera(
          gmaps.CameraUpdate.newLatLngZoom(
            gmaps.LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
            15.0,
          ),
        );
      }).catchError((e) {
        debugPrint('지도 이동 중 오류: $e');
        // 사용자에게 오류 알림
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to move to current location.'),
            ),
          );
        }
      });
    } else {
      // 위치 서비스 다시 초기화 시도
      _initLocationService().then((_) {
        if (_currentLocation != null) {
          _moveToCurrentLocation();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Unable to get your current location. Please check your location settings.'),
            ),
          );
        }
      });
    }
  }

  // 특정 줌 레벨로 지도 확대/축소
  void _zoomMap(double zoom) {
    if (_googleMapController.isCompleted) {
      _googleMapController.future.then((controller) {
        controller.animateCamera(
          gmaps.CameraUpdate.zoomTo(zoom),
        );
      }).catchError((e) {
        debugPrint('줌 변경 중 오류: $e');
      });
    }
  }
}
