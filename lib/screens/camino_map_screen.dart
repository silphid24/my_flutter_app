import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../services/gpx_service.dart';
import '../services/stage_service.dart';
import '../models/track.dart';
import '../models/track_point.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CaminoMapScreen extends StatefulWidget {
  final String? trackId;
  final bool useGoogleMaps;

  const CaminoMapScreen({super.key, this.trackId, this.useGoogleMaps = false});

  @override
  State<CaminoMapScreen> createState() => _CaminoMapScreenState();
}

class _CaminoMapScreenState extends State<CaminoMapScreen> {
  final GpxService _gpxService = GpxService();
  final Location _locationService = Location();
  final MapController _mapController = MapController();
  final Completer<gmaps.GoogleMapController> _googleMapController = Completer();
  final StageService _stageService = StageService();

  Track? _track;
  bool _isLoading = true;
  bool _isLocationEnabled = false;
  String? _loadingMessage;

  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;

  // 지도에 표시할 마커와 경로 포인트
  final List<Marker> _markers = [];
  List<latlong2.LatLng> _routePoints = [];
  List<latlong2.LatLng> _completeRoutePoints = [];

  // Google Maps 마커와 경로
  Set<gmaps.Marker> _googleMarkers = {};
  Set<gmaps.Polyline> _googlePolylines = {};
  Set<gmaps.Polyline> _googleCompleteRoutePolylines = {};

  // 지도 설정
  latlong2.LatLng _center = latlong2.LatLng(42.9, -1.8); // 산티아고 순례길 대략적 위치
  double _zoom = 8.0;

  String? _loadError;

  bool _isDisposed = false;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();

    // 전체 카미노 경로 포인트 가져오기
    _completeRoutePoints = _stageService.getAllStagesPoints();

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
    _locationSubscription?.cancel();
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
      print('위치 서비스 초기화 오류: $e');
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
        if (widget.useGoogleMaps) {
          _moveGoogleMap();
        } else {
          // 컨트롤러가 초기화되었는지 안전하게 확인
          if (_mapController.camera != null) {
            _mapController.move(
              latlong2.LatLng(
                _currentLocation!.latitude!,
                _currentLocation!.longitude!,
              ),
              _zoom,
            );
          }
        }
      } catch (e) {
        // 오류 무시 또는 로깅만 수행
        debugPrint('지도 이동 중 오류: $e');
      }
    }
  }

  // 트랙 데이터 로드
  void _startLoadingTrack() async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    // 로딩 지연 시간 표시를 위한 타이머 설정
    Future.delayed(const Duration(seconds: 5), () {
      if (_isLoading && mounted && !_isDisposed) {
        setState(() {
          _loadingMessage = '데이터 로딩 중... 잠시만 기다려주세요.';
        });
      }
    });

    Track? track;
    try {
      if (kIsWeb) {
        // 웹에서는 가장 작은 GPX 파일만 로드하여 성능 최적화
        print('웹 환경에서 가벼운 GPX 파일 로드 시도...');
        track = await GpxService().loadGpxFromAsset(
          'assets/data/Stage-1-Camino-Frances.gpx',
        );
      } else {
        // 모바일에서는 전체 트랙 로드 시도
        print('모바일 환경에서 전체 GPX 트랙 로드 시도...');
        track = await GpxService().loadCombinedGpxTracks();
      }

      if (track == null) {
        throw Exception('트랙을 로드할 수 없습니다');
      }

      if (_isDisposed) return;

      setState(() {
        _track = track;
        _isLoading = false;
        _loadingMessage = null;

        // 지도에 트랙 데이터 추가 (최적화된 방식으로)
        _setupOptimizedMapData();
      });
    } catch (e) {
      print('트랙 로드 오류: $e');
      if (_isDisposed) return;

      // 실패하면 Stage-1 기본 트랙 로드 재시도
      if (!kIsWeb) {
        try {
          print('기본 GPX 파일로 대체 시도...');
          track = await GpxService().loadGpxFromAsset(
            'assets/data/Stage-1-Camino-Frances.gpx',
          );

          if (track != null) {
            if (_isDisposed) return;

            setState(() {
              _track = track;
              _isLoading = false;
              _loadingMessage = null;

              // 지도에 트랙 데이터 추가 (최적화된 방식으로)
              _setupOptimizedMapData();
            });
            return;
          }
        } catch (fallbackError) {
          print('대체 로드도 실패: $fallbackError');
        }
      }

      setState(() {
        _loadError = '경로 데이터를 로드할 수 없습니다: $e';
        _isLoading = false;
        _loadingMessage = null;
      });
    }
  }

  // 스테이지 GPX 파일 로드
  Future<void> _loadStageGpx(String assetPath) async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = '스테이지 경로 로딩 중...';
    });

    try {
      final track = await GpxService().loadGpxFromAsset(assetPath);
      if (_isDisposed) return;

      if (track != null) {
        if (mounted) {
          setState(() {
            _track = track;
            _isLoading = false;
            _loadingMessage = null;
            _setupOptimizedMapData();
          });
        }
      } else {
        throw Exception('스테이지 경로를 로드할 수 없습니다');
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _loadError = '스테이지 경로 로드 실패: $e';
          _isLoading = false;
          _loadingMessage = null;
        });

        // 실패 시 기본 트랙 로드 시도
        _startLoadingTrack();
      }
    }
  }

  // 최적화된 지도 데이터 설정
  void _setupOptimizedMapData() {
    if (_isDisposed || _track == null || _track!.points.isEmpty) return;

    // 경로 포인트 더 적극적으로 샘플링
    final points = _track!.points;

    // 웹 환경에서는 더 적은 포인트로 최적화
    final targetPointCount = kIsWeb ? 200 : 500;

    if (points.length > targetPointCount) {
      final factor = (points.length / targetPointCount).ceil();
      final optimizedPoints = <TrackPoint>[];

      // 시작점 포함
      optimizedPoints.add(points.first);

      // 중간 포인트 샘플링
      for (int i = factor; i < points.length - factor; i += factor) {
        optimizedPoints.add(points[i]);
      }

      // 종료점 포함
      optimizedPoints.add(points.last);

      _routePoints = optimizedPoints.map((point) => point.position).toList();
      print('최적화: ${points.length}개 포인트 → ${_routePoints.length}개로 감소');
    } else {
      _routePoints = points.map((point) => point.position).toList();
    }

    // 초기 카메라 위치 설정
    _center = _track!.bounds.center;
    _zoom = 10.0;

    _addTrackMarkers();
    _addTrackPolyline();

    // 비동기로 지도 경계 조정
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted) {
          _fitBounds();
        }
      });
    }
  }

  // 지도 데이터 설정
  void _setupMapData() {
    if (_track == null || _track!.points.isEmpty) return;

    // 경로 포인트 설정 - 트랙 포인트가 너무 많을 경우 최적화
    final points = _track!.points;
    if (points.length > 500) {
      // 포인트가 500개 이상일 경우 간소화
      print('${points.length}개의 포인트 최적화 중...');
      final factor = (points.length / 500).ceil();
      final optimizedPoints = <TrackPoint>[];

      // 시작점과 종료점은 반드시 포함
      optimizedPoints.add(points.first);

      // 중간 포인트 샘플링
      for (int i = factor; i < points.length - factor; i += factor) {
        optimizedPoints.add(points[i]);
      }

      // 종료점 추가
      optimizedPoints.add(points.last);

      _routePoints = optimizedPoints.map((point) => point.position).toList();
      print('최적화 후 ${_routePoints.length}개 포인트로 감소됨');
    } else {
      _routePoints = points.map((point) => point.position).toList();
    }

    // 초기 카메라 위치 설정
    _center = _track!.bounds.center;
    _zoom = 10.0;

    if (widget.useGoogleMaps) {
      _setupGoogleMapData();
    } else {
      // 지도가 이미 초기화되었다면 이동 시도
      try {
        // 컨트롤러가 준비되었을 때만 move 호출
        _mapController.move(_center, _zoom);
      } catch (e) {
        // 지도가 아직 준비되지 않음
        print('지도 이동 실패: $e');
      }
    }

    _updateMarkers();
  }

  // Google Maps 데이터 설정
  void _setupGoogleMapData() {
    if (_track == null || _track!.points.isEmpty) return;

    // 구글맵 폴리라인 설정
    final List<gmaps.LatLng> googlePoints = _routePoints
        .map((point) => gmaps.LatLng(point.latitude, point.longitude))
        .toList();

    _googlePolylines = {
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('route'),
        points: googlePoints,
        color: Colors.blue,
        width: 4,
      ),
    };

    _updateGoogleMarkers();
  }

  // 마커 업데이트
  void _updateMarkers() {
    if (_track == null || _track!.points.isEmpty) return;

    if (widget.useGoogleMaps) {
      _updateGoogleMarkers();
    } else {
      _markers.clear();

      // 시작점 마커
      _markers.add(
        Marker(
          width: 80,
          height: 80,
          point: _track!.points.first.position,
          child: const Icon(Icons.place, color: Colors.green, size: 40),
        ),
      );

      // 종료점 마커
      _markers.add(
        Marker(
          width: 80,
          height: 80,
          point: _track!.points.last.position,
          child: const Icon(Icons.flag, color: Colors.red, size: 40),
        ),
      );

      // 현재 위치 마커 추가
      if (_currentLocation != null) {
        _markers.add(
          Marker(
            width: 80,
            height: 80,
            point: latlong2.LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        );
      }
    }

    setState(() {});
  }

  // Google 마커 업데이트
  void _updateGoogleMarkers() {
    if (_track == null || _track!.points.isEmpty) return;

    _googleMarkers = {
      // 시작점 마커
      gmaps.Marker(
        markerId: const gmaps.MarkerId('start'),
        position: gmaps.LatLng(
          _track!.points.first.position.latitude,
          _track!.points.first.position.longitude,
        ),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueGreen,
        ),
      ),

      // 종료점 마커
      gmaps.Marker(
        markerId: const gmaps.MarkerId('end'),
        position: gmaps.LatLng(
          _track!.points.last.position.latitude,
          _track!.points.last.position.longitude,
        ),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueRed,
        ),
      ),
    };

    // 현재 위치 마커 추가
    if (_currentLocation != null) {
      _googleMarkers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('currentLocation'),
          position: gmaps.LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.useGoogleMaps && widget.trackId == null
                          ? '경로 로딩 중...'
                          : _track?.name ?? '산티아고 순례길 지도',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Text(_track?.name ?? '산티아고 순례길 지도'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startLoadingTrack,
            tooltip: '경로 다시 로드하기',
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  _isLocationEnabled ? Icons.location_on : Icons.location_off,
                  color: _isLocationEnabled ? Colors.blue : null,
                ),
                if (_currentLocation == null && _isLocationEnabled)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Icon(
                        Icons.info,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              setState(() {
                _isLocationEnabled = !_isLocationEnabled;
                if (_isLocationEnabled && _currentLocation != null) {
                  if (widget.useGoogleMaps) {
                    _moveGoogleMap();
                  } else {
                    try {
                      _mapController.move(
                        latlong2.LatLng(
                          _currentLocation!.latitude!,
                          _currentLocation!.longitude!,
                        ),
                        _zoom,
                      );
                    } catch (e) {
                      // 지도가 아직 준비되지 않음
                      print('위치 이동 중 오류: $e');
                    }
                  }
                }
              });

              // 위치가 없는 경우 위치 접근 안내
              if (_isLocationEnabled && _currentLocation == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('현재 위치를 가져오는 중입니다. 잠시만 기다려주세요.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            tooltip: _isLocationEnabled ? '위치 추적 끄기' : '위치 추적 켜기',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_loadingMessage ?? '경로 데이터를 로드하는 중입니다...'),
                  const SizedBox(height: 8),
                  const Text(
                    '처음 로딩 시 시간이 걸릴 수 있습니다',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _track == null
              ? const Center(child: Text('트랙 정보를 찾을 수 없습니다.'))
              : widget.useGoogleMaps
                  ? _buildGoogleMap()
                  : _buildMap(),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: _zoom,
        onMapReady: () {
          // 지도가 준비되었을 때 실행되는 코드
          _isMapReady = true;

          // 지도가 준비되면 경로 데이터가 있을 경우 그 위치로 이동
          if (_track != null && _track!.points.isNotEmpty) {
            // 약간의 지연을 두어 안정적인 렌더링 후 실행
            Future.delayed(const Duration(milliseconds: 100), () {
              try {
                _mapController.move(_center, _zoom);
              } catch (e) {
                debugPrint('지도 초기 이동 오류: $e');
              }
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // 경고 메시지를 피하기 위해 subdomains 제거
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
    );
  }

  Widget _buildGoogleMap() {
    // 초기 카메라 위치 조정 (전체 경로 미리보기를 위해)
    double initialZoom = widget.trackId == null ? 7.0 : _zoom;

    return Stack(
      children: [
        gmaps.GoogleMap(
          initialCameraPosition: gmaps.CameraPosition(
            target: gmaps.LatLng(_center.latitude, _center.longitude),
            zoom: initialZoom,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: gmaps.MapType.normal,
          markers: _googleMarkers,
          polylines: {..._googleCompleteRoutePolylines, ..._googlePolylines},
          onMapCreated: (controller) {
            _googleMapController.complete(controller);

            // 트랙 로딩이 완료된 상태에서만 경계에 맞추기
            if (_track != null && _track!.points.isNotEmpty && !_isLoading) {
              _fitMapToBounds(controller);
            }
          },
        ),

        // 정보 버튼 (전체 경로일 때만 표시)
        if (widget.trackId == null)
          Positioned(
            bottom: 16,
            right: 16,
            child: InkWell(
              onTap: () {
                _showRouteInfo();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 경계에 맞게 지도 조정
  void _fitMapToBounds(gmaps.GoogleMapController controller) {
    if (_track == null || _track!.points.isEmpty) return;

    try {
      // 북동쪽과 남서쪽 경계 계산
      double minLat = double.infinity;
      double maxLat = -double.infinity;
      double minLng = double.infinity;
      double maxLng = -double.infinity;

      for (var point in _track!.points) {
        minLat = math.min(minLat, point.position.latitude);
        maxLat = math.max(maxLat, point.position.latitude);
        minLng = math.min(minLng, point.position.longitude);
        maxLng = math.max(maxLng, point.position.longitude);
      }

      // 약간의 패딩 추가
      final double padding = 0.05;
      minLat -= padding;
      maxLat += padding;
      minLng -= padding;
      maxLng += padding;

      // Google Maps LatLngBounds 생성
      final bounds = gmaps.LatLngBounds(
        southwest: gmaps.LatLng(minLat, minLng),
        northeast: gmaps.LatLng(maxLat, maxLng),
      );

      // 카메라 경계 설정
      controller.animateCamera(gmaps.CameraUpdate.newLatLngBounds(bounds, 50));
    } catch (e) {
      print('지도 경계 조정 오류: $e');
    }
  }

  // 경로 정보 다이얼로그 표시
  void _showRouteInfo() {
    if (_track == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_track?.name ?? '카미노 프랑세스'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('전체 포인트 수: ${_track!.points.length}개'),
            const SizedBox(height: 8),
            const Text('총 거리: 약 800km'),
            const SizedBox(height: 8),
            const Text('33개 스테이지로 구성된 전체 프랑스길 경로입니다.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _addTrackMarkers() {
    if (_track == null || _track!.points.isEmpty) return;

    _routePoints = _track!.points.map((point) => point.position).toList();
    _center = _track!.bounds.center;
    _zoom = 10.0;

    _markers.clear();
    _googleMarkers.clear();
    _googlePolylines.clear();

    _markers.add(
      Marker(
        width: 80,
        height: 80,
        point: _track!.points.first.position,
        child: const Icon(Icons.place, color: Colors.green, size: 40),
      ),
    );

    _markers.add(
      Marker(
        width: 80,
        height: 80,
        point: _track!.points.last.position,
        child: const Icon(Icons.flag, color: Colors.red, size: 40),
      ),
    );

    if (_currentLocation != null) {
      _markers.add(
        Marker(
          width: 80,
          height: 80,
          point: latlong2.LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 30),
          ),
        ),
      );
    }

    _updateGoogleMarkers();
  }

  void _addTrackPolyline() {
    if (_track == null || _track!.points.isEmpty) return;

    _routePoints = _track!.points.map((point) => point.position).toList();
    _center = _track!.bounds.center;
    _zoom = 10.0;

    _googlePolylines = {
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('route'),
        points: _routePoints
            .map((point) => gmaps.LatLng(point.latitude, point.longitude))
            .toList(),
        color: Colors.blue,
        width: 4,
      ),
    };

    _updateGoogleMarkers();
  }

  void _fitBounds() {
    if (_mapController.camera == null) {
      debugPrint('지도 컨트롤러가 아직 준비되지 않았습니다.');
      return;
    }

    if (_track == null || _track!.points.isEmpty) return;

    try {
      // 북동쪽과 남서쪽 경계 계산
      double minLat = double.infinity;
      double maxLat = -double.infinity;
      double minLng = double.infinity;
      double maxLng = -double.infinity;

      for (var point in _track!.points) {
        minLat = math.min(minLat, point.position.latitude);
        maxLat = math.max(maxLat, point.position.latitude);
        minLng = math.min(minLng, point.position.longitude);
        maxLng = math.max(maxLng, point.position.longitude);
      }

      // 약간의 패딩 추가
      final double padding = 0.05;
      minLat -= padding;
      maxLat += padding;
      minLng -= padding;
      maxLng += padding;

      // Google Maps LatLngBounds 생성
      final bounds = gmaps.LatLngBounds(
        southwest: gmaps.LatLng(minLat, minLng),
        northeast: gmaps.LatLng(maxLat, maxLng),
      );

      // 카메라 경계 설정 - 여기서 Future 처리 수정
      _googleMapController.future.then((controller) {
        controller.animateCamera(
          gmaps.CameraUpdate.newLatLngBounds(bounds, 50),
        );
      });
    } catch (e) {
      print('지도 경계 조정 오류: $e');
    }
  }

  // 안전하게 현재 위치로 이동
  void _safelyMoveToCurrentLocation() {
    if (_isDisposed || !mounted) return;

    if (_currentLocation != null) {
      try {
        if (widget.useGoogleMaps) {
          _moveGoogleMap();
        } else {
          // Flutter Map 컨트롤러 사용
          if (_mapController.camera != null) {
            _mapController.move(
              latlong2.LatLng(
                _currentLocation!.latitude!,
                _currentLocation!.longitude!,
              ),
              _zoom,
            );
          }
        }
      } catch (e) {
        // 오류 로깅만 수행
        debugPrint('지도 이동 중 오류: $e');
      }
    }
  }

  // 구글맵용 전체 경로 폴리라인 설정
  void _setupGoogleCompleteRoute() {
    final List<gmaps.LatLng> googlePoints = _completeRoutePoints
        .map((point) => gmaps.LatLng(point.latitude, point.longitude))
        .toList();

    _googleCompleteRoutePolylines = {
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('completeRoute'),
        points: googlePoints,
        color: Colors.grey.shade600,
        width: 3,
      ),
    };
  }
}
