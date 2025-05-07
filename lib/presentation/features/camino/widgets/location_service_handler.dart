import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 위치 서비스 핸들러 프로바이더
final locationServiceProvider =
    StateNotifierProvider<LocationServiceNotifier, LocationServiceState>((ref) {
  return LocationServiceNotifier();
});

/// 위치 서비스 상태 클래스
class LocationServiceState {
  final bool isServiceEnabled;
  final bool hasPermission;
  final LocationData? currentLocation;
  final bool isTracking;

  const LocationServiceState({
    this.isServiceEnabled = false,
    this.hasPermission = false,
    this.currentLocation,
    this.isTracking = false,
  });

  LocationServiceState copyWith({
    bool? isServiceEnabled,
    bool? hasPermission,
    LocationData? currentLocation,
    bool? isTracking,
  }) {
    return LocationServiceState(
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
      hasPermission: hasPermission ?? this.hasPermission,
      currentLocation: currentLocation ?? this.currentLocation,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}

/// 위치 서비스 컨트롤러
class LocationServiceNotifier extends StateNotifier<LocationServiceState> {
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  LocationServiceNotifier() : super(const LocationServiceState()) {
    _initLocationService();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  /// 위치 서비스 초기화
  Future<void> _initLocationService() async {
    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          state = state.copyWith(isServiceEnabled: false);
          return;
        }
      }

      // 위치 권한 확인
      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          state = state.copyWith(hasPermission: false);
          return;
        }
      }

      // 상태 업데이트
      state = state.copyWith(
        isServiceEnabled: true,
        hasPermission: permissionStatus == PermissionStatus.granted,
      );

      // 위치 업데이트 구독
      startLocationUpdates();
    } catch (e) {
      debugPrint('위치 서비스 초기화 오류: $e');
    }
  }

  /// 위치 업데이트 시작
  void startLocationUpdates() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }

    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      state = state.copyWith(
        currentLocation: locationData,
      );
    });

    state = state.copyWith(isTracking: true);
  }

  /// 위치 업데이트 중지
  void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    state = state.copyWith(isTracking: false);
  }

  /// 위치 추적 토글
  void toggleLocationTracking() {
    if (state.isTracking) {
      stopLocationUpdates();
    } else {
      startLocationUpdates();
    }
  }

  /// 위치 서비스 재요청
  Future<void> requestLocationService() async {
    bool serviceEnabled = await _location.requestService();
    state = state.copyWith(isServiceEnabled: serviceEnabled);

    if (serviceEnabled) {
      await _initLocationService();
    }
  }

  /// 위치 권한 재요청
  Future<void> requestLocationPermission() async {
    final permissionStatus = await _location.requestPermission();
    state = state.copyWith(
      hasPermission: permissionStatus == PermissionStatus.granted,
    );

    if (permissionStatus == PermissionStatus.granted) {
      startLocationUpdates();
    }
  }
}

/// 위치 서비스 핸들러 위젯
class LocationServiceHandler extends HookConsumerWidget {
  final Widget child;

  const LocationServiceHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationServiceProvider);
    final locationController = ref.read(locationServiceProvider.notifier);

    // 위치 서비스가 비활성화되었을 때 표시할 위젯
    if (!locationState.isServiceEnabled) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '위치 서비스가 비활성화되었습니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '앱의 위치 기능을 사용하려면 위치 서비스를 활성화해주세요.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => locationController.requestLocationService(),
                child: const Text('위치 서비스 활성화'),
              ),
            ],
          ),
        ),
      );
    }

    // 위치 권한이 없을 때 표시할 위젯
    if (!locationState.hasPermission) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_disabled, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '위치 권한이 필요합니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '앱의 위치 기능을 사용하려면 위치 권한을 허용해주세요.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => locationController.requestLocationPermission(),
                child: const Text('위치 권한 요청'),
              ),
            ],
          ),
        ),
      );
    }

    // 모든 조건이 충족되면 자식 위젯 표시
    return child;
  }
}
