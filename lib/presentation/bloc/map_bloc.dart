import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_app/domain/models/camino_route.dart';
import 'package:my_flutter_app/domain/models/map_marker.dart';
import 'package:my_flutter_app/domain/repositories/location_repository.dart';
import 'dart:math' as math;

// Events
abstract class MapEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMap extends MapEvent {}

class UpdateCurrentLocation extends MapEvent {
  final LatLng location;

  UpdateCurrentLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class ToggleMarkerType extends MapEvent {
  final MarkerType type;
  final bool isVisible;

  ToggleMarkerType(this.type, this.isVisible);

  @override
  List<Object?> get props => [type, isVisible];
}

class ChangeMapType extends MapEvent {
  final MapType mapType;

  ChangeMapType(this.mapType);

  @override
  List<Object?> get props => [mapType];
}

class CheckRouteDeviation extends MapEvent {
  final LatLng location;

  CheckRouteDeviation(this.location);

  @override
  List<Object?> get props => [location];
}

class DismissRouteDeviationWarning extends MapEvent {}

class UpdateSelectedLocation extends MapEvent {
  final LatLng location;
  final String locationName;

  UpdateSelectedLocation(this.location, this.locationName);

  @override
  List<Object?> get props => [location, locationName];
}

class UpdateSelectedStage extends MapEvent {
  final CaminoStage stage;

  UpdateSelectedStage(this.stage);

  @override
  List<Object?> get props => [stage];
}

class FocusOnCurrentLocation extends MapEvent {}

// 경로 이탈 감지 모드 변경 이벤트
class ToggleDeviationMode extends MapEvent {
  final bool enabled;

  ToggleDeviationMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

// 순례 모드 변경 이벤트
class TogglePilgrimMode extends MapEvent {
  final bool enabled;

  TogglePilgrimMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

// States
abstract class MapState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final CaminoRoute caminoRoute;
  final CaminoStage? currentStage;
  final CaminoStage? selectedStage;
  final LatLng? currentLocation;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final MapType mapType;
  final bool isOffRoute;
  final Map<MarkerType, bool> visibleMarkerTypes;
  final bool deviationModeEnabled; // 경로 이탈 감지 모드
  final bool pilgrimModeEnabled; // 순례 모드

  MapLoaded({
    required this.caminoRoute,
    this.currentStage,
    this.selectedStage,
    this.currentLocation,
    required this.markers,
    required this.polylines,
    this.mapType = MapType.normal,
    this.isOffRoute = false,
    required this.visibleMarkerTypes,
    this.deviationModeEnabled = false,
    this.pilgrimModeEnabled = false,
  });

  MapLoaded copyWith({
    CaminoRoute? caminoRoute,
    CaminoStage? currentStage,
    CaminoStage? selectedStage,
    LatLng? currentLocation,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    MapType? mapType,
    bool? isOffRoute,
    Map<MarkerType, bool>? visibleMarkerTypes,
    bool? deviationModeEnabled,
    bool? pilgrimModeEnabled,
  }) {
    return MapLoaded(
      caminoRoute: caminoRoute ?? this.caminoRoute,
      currentStage: currentStage ?? this.currentStage,
      selectedStage: selectedStage ?? this.selectedStage,
      currentLocation: currentLocation ?? this.currentLocation,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      mapType: mapType ?? this.mapType,
      isOffRoute: isOffRoute ?? this.isOffRoute,
      visibleMarkerTypes: visibleMarkerTypes ?? this.visibleMarkerTypes,
      deviationModeEnabled: deviationModeEnabled ?? this.deviationModeEnabled,
      pilgrimModeEnabled: pilgrimModeEnabled ?? this.pilgrimModeEnabled,
    );
  }

  @override
  List<Object?> get props => [
        caminoRoute,
        currentStage,
        selectedStage,
        currentLocation,
        markers,
        polylines,
        mapType,
        isOffRoute,
        visibleMarkerTypes,
        deviationModeEnabled,
        pilgrimModeEnabled,
      ];
}

class MapError extends MapState {
  final String message;

  MapError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationRepository _locationRepository;
  StreamSubscription<LatLng>? _locationSubscription;

  MapBloc({required LocationRepository locationRepository})
      : _locationRepository = locationRepository,
        super(MapInitial()) {
    on<LoadMap>(_onLoadMap);
    on<UpdateCurrentLocation>(_onUpdateCurrentLocation);
    on<ToggleMarkerType>(_onToggleMarkerType);
    on<ChangeMapType>(_onChangeMapType);
    on<CheckRouteDeviation>(_onCheckRouteDeviation);
    on<DismissRouteDeviationWarning>(_onDismissRouteDeviationWarning);
    on<UpdateSelectedLocation>(_onUpdateSelectedLocation);
    on<FocusOnCurrentLocation>(_onFocusOnCurrentLocation);
    on<ToggleDeviationMode>(_onToggleDeviationMode);
    on<TogglePilgrimMode>(_onTogglePilgrimMode);
    on<UpdateSelectedStage>(_onUpdateSelectedStage);
  }

  Future<void> _onLoadMap(LoadMap event, Emitter<MapState> emit) async {
    emit(MapLoading());

    try {
      // 카미노 경로 로드
      final caminoRoute = await _locationRepository.getCaminoRoute();
      final currentStage = await _locationRepository.getCurrentStage();
      final currentLocation = await _locationRepository.getCurrentLocation();

      // 맵에 표시할 마커와 경로 생성
      Map<MarkerType, bool> visibleMarkerTypes = {
        MarkerType.accommodation: true,
        MarkerType.restaurant: true,
        MarkerType.pharmacy: true,
        MarkerType.landmark: true,
      };

      Set<Marker> markers = await _createMarkers(
        currentLocation,
        visibleMarkerTypes,
      );
      Set<Polyline> polylines = await _createRoutePolylines(caminoRoute);

      // 위치 업데이트 스트림 구독
      _subscribeToLocationUpdates();

      emit(
        MapLoaded(
          caminoRoute: caminoRoute,
          currentStage: currentStage,
          selectedStage: currentStage, // 현재 스테이지를 선택 스테이지로 설정
          currentLocation: currentLocation,
          markers: markers,
          polylines: polylines,
          visibleMarkerTypes: visibleMarkerTypes,
        ),
      );
    } catch (e) {
      emit(MapError('지도 정보를 로드하는 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onUpdateCurrentLocation(
    UpdateCurrentLocation event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;

      // 현재 위치에 가장 가까운 스테이지 찾기
      CaminoStage? closestStage = await _locationRepository.getCurrentStage();

      // 현재 위치 마커 업데이트
      Set<Marker> updatedMarkers = await _updateCurrentLocationMarker(
        currentState.markers,
        event.location,
      );

      // 사용자 경로 이탈 확인
      bool isOffRoute = await _locationRepository.isOffRoute(
        event.location,
        100, // 임계값: 100m
      );

      // 가장 가까운 스테이지가 변경된 경우 폴리라인 업데이트
      Set<Polyline> updatedPolylines = currentState.polylines;
      if (closestStage != null &&
          (currentState.currentStage == null ||
              closestStage.id != currentState.currentStage!.id)) {
        updatedPolylines = await _updateStagePolylines(
          currentState.caminoRoute,
          closestStage,
        );
      }

      emit(
        currentState.copyWith(
          currentLocation: event.location,
          markers: updatedMarkers,
          isOffRoute: isOffRoute,
          currentStage: closestStage,
          polylines: updatedPolylines,
        ),
      );
    }
  }

  Future<void> _onToggleMarkerType(
    ToggleMarkerType event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;

      // 표시할 마커 타입 업데이트
      Map<MarkerType, bool> updatedVisibleMarkerTypes = Map.from(
        currentState.visibleMarkerTypes,
      );
      updatedVisibleMarkerTypes[event.type] = event.isVisible;

      // 마커 업데이트
      Set<Marker> updatedMarkers = await _createMarkers(
        currentState.currentLocation,
        updatedVisibleMarkerTypes,
      );

      emit(
        currentState.copyWith(
          markers: updatedMarkers,
          visibleMarkerTypes: updatedVisibleMarkerTypes,
        ),
      );
    }
  }

  void _onChangeMapType(ChangeMapType event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(mapType: event.mapType));
    }
  }

  Future<void> _onCheckRouteDeviation(
    CheckRouteDeviation event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;

      // 경로 이탈 감지 모드가 활성화된 경우에만 처리
      if (currentState.deviationModeEnabled &&
          currentState.pilgrimModeEnabled) {
        bool isOffRoute = await _locationRepository.isOffRoute(
          event.location,
          100, // 임계값: 100m
        );

        if (isOffRoute != currentState.isOffRoute) {
          emit(currentState.copyWith(isOffRoute: isOffRoute));
        }
      } else if (currentState.isOffRoute) {
        // 모드가 비활성화된 경우 이탈 경고 끄기
        emit(currentState.copyWith(isOffRoute: false));
      }
    }
  }

  // 경로 이탈 감지 모드 변경 처리
  void _onToggleDeviationMode(
    ToggleDeviationMode event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(
        currentState.copyWith(
          deviationModeEnabled: event.enabled,
          // 이탈 감지 모드가 꺼지면 경고도 끄기
          isOffRoute: event.enabled ? currentState.isOffRoute : false,
        ),
      );
    }
  }

  // 순례 모드 변경 처리
  void _onTogglePilgrimMode(TogglePilgrimMode event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(
        currentState.copyWith(
          pilgrimModeEnabled: event.enabled,
          // 순례 모드가 꺼지면 경고도 끄기
          isOffRoute: event.enabled ? currentState.isOffRoute : false,
        ),
      );
    }
  }

  void _onDismissRouteDeviationWarning(
    DismissRouteDeviationWarning event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(isOffRoute: false));
    }
  }

  Future<void> _onUpdateSelectedLocation(
    UpdateSelectedLocation event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;

      // 선택된 위치에 마커 추가
      Set<Marker> updatedMarkers = Set.from(currentState.markers);

      // 위치 마커 ID
      final markerId = MarkerId('selected_location_${event.locationName}');

      // 기존에 선택 위치 마커가 있으면 제거
      updatedMarkers.removeWhere(
        (marker) => marker.markerId.value.startsWith('selected_location_'),
      );

      // 새 마커 추가
      updatedMarkers.add(
        Marker(
          markerId: markerId,
          position: event.location,
          infoWindow: InfoWindow(title: event.locationName, snippet: '선택한 위치'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      );

      emit(currentState.copyWith(markers: updatedMarkers));
    }
  }

  void _onFocusOnCurrentLocation(
    FocusOnCurrentLocation event,
    Emitter<MapState> emit,
  ) {
    // 현재 위치로 이동하는 로직은 이미 UI 레벨에서 처리되므로
    // 여기서는 추가 작업 없이 스테이트를 그대로 유지
    // 필요하다면 나중에 여기에 추가 로직을 구현할 수 있습니다
  }

  void _subscribeToLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = _locationRepository.getLocationUpdates().listen((
      location,
    ) {
      add(UpdateCurrentLocation(location));
      add(CheckRouteDeviation(location));
    });
  }

  Future<Set<Marker>> _createMarkers(
    LatLng? currentLocation,
    Map<MarkerType, bool> visibleMarkerTypes,
  ) async {
    Set<Marker> markers = {};

    // 주변 마커 가져오기
    List<MarkerType> visibleTypes = visibleMarkerTypes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // 현재 위치가 없는 경우 기본 위치 설정
    LatLng center = currentLocation ?? const LatLng(42.7806, -7.4149); // Sarria

    // 모든 타입의 마커 가져오기
    final nearbyMarkers = await _locationRepository.getNearbyMarkers(
      center,
      5, // 반경 5km 내 마커
      visibleTypes,
    );

    // 마커 생성
    for (var marker in nearbyMarkers) {
      final icon = await _locationRepository.getMarkerIcon(marker.type);

      markers.add(
        Marker(
          markerId: MarkerId(marker.id),
          position: marker.position,
          icon: icon,
          infoWindow: InfoWindow(
            title: marker.title,
            snippet: marker.description,
          ),
        ),
      );
    }

    // 현재 위치 마커 추가
    if (currentLocation != null) {
      final currentLocationIcon = await _locationRepository.getMarkerIcon(
        MarkerType.currentLocation,
      );

      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLocation,
          icon: currentLocationIcon,
          zIndex: 2, // 다른 마커 위에 표시
          infoWindow: const InfoWindow(title: '현재 위치', snippet: '실시간 위치 정보'),
        ),
      );
    }

    return markers;
  }

  Future<Set<Marker>> _updateCurrentLocationMarker(
    Set<Marker> existingMarkers,
    LatLng newLocation,
  ) async {
    // 기존 마커 세트에서 현재 위치 마커만 제거
    Set<Marker> updatedMarkers = existingMarkers
        .where((marker) => marker.markerId.value != 'current_location')
        .toSet();

    // 새로운 현재 위치 마커 추가
    final currentLocationIcon = await _locationRepository.getMarkerIcon(
      MarkerType.currentLocation,
    );

    updatedMarkers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: newLocation,
        icon: currentLocationIcon,
        zIndex: 2, // 다른 마커 위에 표시
        infoWindow: const InfoWindow(title: '현재 위치', snippet: '실시간 위치 정보'),
      ),
    );

    return updatedMarkers;
  }

  Future<Set<Polyline>> _createRoutePolylines(CaminoRoute route) async {
    Set<Polyline> polylines = {};

    // 현재 위치를 가져옴
    LatLng? currentLocation = await _locationRepository.getCurrentLocation();

    // 현재 위치와 가장 가까운 스테이지 찾기
    CaminoStage? nearestStage;
    int nearestStageIndex = 0;

    if (currentLocation != null) {
      double minDistance = double.infinity;

      for (int i = 0; i < route.stages.length; i++) {
        var stage = route.stages[i];
        for (var point in stage.path) {
          double distance = _calculateDistance(currentLocation, point);
          if (distance < minDistance) {
            minDistance = distance;
            nearestStage = stage;
            nearestStageIndex = i;
          }
        }
      }
    }

    // 위치 기반 추적이 안되면 기본적으로 스테이지 1과 2를 표시
    if (nearestStage == null) {
      // 스테이지가 최소 2개 이상 있는지 확인
      if (route.stages.length >= 2) {
        // 스테이지 1 (첫 번째 스테이지) 추가
        polylines.add(
          Polyline(
            polylineId: PolylineId(route.stages[0].id),
            points: route.stages[0].path,
            color: route.stages[0].color,
            width: 5,
          ),
        );

        // 스테이지 2 (두 번째 스테이지) 추가
        polylines.add(
          Polyline(
            polylineId: PolylineId(route.stages[1].id),
            points: route.stages[1].path,
            color: route.stages[1].color.withOpacity(0.7),
            width: 3,
            patterns: [PatternItem.dash(10), PatternItem.gap(5)],
          ),
        );
      } else if (route.stages.isNotEmpty) {
        // 스테이지가 하나만 있으면 그 하나만 표시
        polylines.add(
          Polyline(
            polylineId: PolylineId(route.stages[0].id),
            points: route.stages[0].path,
            color: route.stages[0].color,
            width: 5,
          ),
        );
      }
    } else {
      // 현재 스테이지 추가
      polylines.add(
        Polyline(
          polylineId: PolylineId(nearestStage.id),
          points: nearestStage.path,
          color: nearestStage.color,
          width: 5,
        ),
      );

      // 다음 스테이지가 있으면 추가 (총 33개 스테이지가 있다고 가정)
      if (nearestStageIndex < route.stages.length - 1) {
        CaminoStage nextStage = route.stages[nearestStageIndex + 1];
        polylines.add(
          Polyline(
            polylineId: PolylineId(nextStage.id),
            points: nextStage.path,
            color: nextStage.color.withOpacity(0.7),
            width: 3,
            patterns: [PatternItem.dash(10), PatternItem.gap(5)],
          ),
        );
      }
    }

    return polylines;
  }

  // 두 위치 간의 거리 계산 (이미 있는 함수 사용 또는 아래 함수 추가)
  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371000; // 지구 반경 (미터)
    final double lat1Rad = pos1.latitude * (math.pi / 180);
    final double lat2Rad = pos2.latitude * (math.pi / 180);
    final double deltaLatRad =
        (pos2.latitude - pos1.latitude) * (math.pi / 180);
    final double deltaLngRad =
        (pos2.longitude - pos1.longitude) * (math.pi / 180);

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  Future<Set<Polyline>> _updateStagePolylines(
    CaminoRoute route,
    CaminoStage currentStage, {
    bool isSelected = false,
  }) async {
    Set<Polyline> polylines = {};

    // 모든 스테이지의 경로를 추가
    for (var stage in route.stages) {
      if (stage.path.isNotEmpty) {
        // 경로 색상 결정: 현재 선택된 스테이지는 다른 색상으로 표시
        Color polylineColor = stage.color;

        if (stage.id == currentStage.id) {
          // 선택된 스테이지는 빨간색(또는 원하는 강조 색상)으로 표시
          polylineColor = isSelected ? Colors.red : Colors.deepPurple;
        } else {
          // 다른 스테이지들은 기본 색상(파란색) 유지
          polylineColor = Colors.blue.withOpacity(0.7);
        }

        polylines.add(
          Polyline(
            polylineId: PolylineId('stage_${stage.id}'),
            points: stage.path,
            color: polylineColor,
            width: stage.id == currentStage.id ? 5 : 3, // 선택된 스테이지는 더 굵게
          ),
        );
      }
    }

    return polylines;
  }

  // 선택된 스테이지 업데이트 처리
  Future<void> _onUpdateSelectedStage(
    UpdateSelectedStage event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;

      Set<Polyline> updatedPolylines = {};

      // 선택한 스테이지 찾기
      int selectedIndex = -1;
      for (int i = 0; i < currentState.caminoRoute.stages.length; i++) {
        if (currentState.caminoRoute.stages[i].id == event.stage.id) {
          selectedIndex = i;
          break;
        }
      }

      if (selectedIndex >= 0) {
        // 선택한 스테이지 추가
        updatedPolylines.add(
          Polyline(
            polylineId: PolylineId('stage_${event.stage.id}'),
            points: event.stage.path,
            color: Colors.red, // 선택된 스테이지는 빨간색
            width: 5,
          ),
        );

        // 다음 스테이지가 있으면 추가
        if (selectedIndex < currentState.caminoRoute.stages.length - 1) {
          CaminoStage nextStage =
              currentState.caminoRoute.stages[selectedIndex + 1];
          updatedPolylines.add(
            Polyline(
              polylineId: PolylineId('stage_${nextStage.id}'),
              points: nextStage.path,
              color: Colors.blue.withOpacity(0.7), // 다음 스테이지는 파란색 (흐림)
              width: 3,
              patterns: [PatternItem.dash(10), PatternItem.gap(5)],
            ),
          );
        }
      }

      // 스테이지 시작 위치에 마커 추가
      Set<Marker> updatedMarkers = Set.from(currentState.markers);

      // 기존에 선택 위치 마커가 있으면 제거
      updatedMarkers.removeWhere(
        (marker) => marker.markerId.value.startsWith('selected_location_'),
      );

      // 스테이지 시작점에 마커 추가
      if (event.stage.path.isNotEmpty) {
        final startPoint = event.stage.path.first;
        final endPoint = event.stage.path.last;
        final stageName = event.stage.name;

        // 시작점 마커 추가
        updatedMarkers.add(
          Marker(
            markerId: const MarkerId('selected_location_start'),
            position: startPoint,
            infoWindow: InfoWindow(
              title: stageName.split('→').first.trim(),
              snippet: '스테이지 시작점',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );

        // 종점 마커 추가
        updatedMarkers.add(
          Marker(
            markerId: const MarkerId('selected_location_end'),
            position: endPoint,
            infoWindow: InfoWindow(
              title: stageName.split('→').last.trim(),
              snippet: '스테이지 종점',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      }

      emit(
        currentState.copyWith(
          selectedStage: event.stage,
          polylines: updatedPolylines,
          markers: updatedMarkers,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
