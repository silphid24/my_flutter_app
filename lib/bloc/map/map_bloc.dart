import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class TogglePilgrimMode extends MapEvent {
  final bool enabled;

  const TogglePilgrimMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleDeviationMode extends MapEvent {
  final bool enabled;

  const ToggleDeviationMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class DismissRouteDeviationWarning extends MapEvent {
  const DismissRouteDeviationWarning();
}

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapLoaded extends MapState {
  final List<Track> tracks;
  final Track? selectedTrack;
  final LatLng currentLocation;
  final bool isLoading;
  final bool showAllTracks;
  final MapType mapType;
  final bool showPois;
  final bool isOffRoute;
  final bool pilgrimModeEnabled;
  final bool deviationModeEnabled;
  final bool warningDismissed;

  const MapLoaded({
    required this.tracks,
    this.selectedTrack,
    required this.currentLocation,
    this.isLoading = false,
    this.showAllTracks = true,
    this.mapType = MapType.normal,
    this.showPois = true,
    this.isOffRoute = false,
    this.pilgrimModeEnabled = false,
    this.deviationModeEnabled = false,
    this.warningDismissed = false,
  });

  @override
  List<Object?> get props => [
    tracks,
    selectedTrack,
    currentLocation,
    isLoading,
    showAllTracks,
    mapType,
    showPois,
    isOffRoute,
    pilgrimModeEnabled,
    deviationModeEnabled,
    warningDismissed,
  ];

  MapLoaded copyWith({
    List<Track>? tracks,
    Track? selectedTrack,
    LatLng? currentLocation,
    bool? isLoading,
    bool? showAllTracks,
    MapType? mapType,
    bool? showPois,
    bool? isOffRoute,
    bool? pilgrimModeEnabled,
    bool? deviationModeEnabled,
    bool? warningDismissed,
  }) {
    return MapLoaded(
      tracks: tracks ?? this.tracks,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      currentLocation: currentLocation ?? this.currentLocation,
      isLoading: isLoading ?? this.isLoading,
      showAllTracks: showAllTracks ?? this.showAllTracks,
      mapType: mapType ?? this.mapType,
      showPois: showPois ?? this.showPois,
      isOffRoute: isOffRoute ?? this.isOffRoute,
      pilgrimModeEnabled: pilgrimModeEnabled ?? this.pilgrimModeEnabled,
      deviationModeEnabled: deviationModeEnabled ?? this.deviationModeEnabled,
      warningDismissed: warningDismissed ?? this.warningDismissed,
    );
  }
}

class MapBloc extends Bloc<MapEvent, MapState> {
  final GPXService gpxService;
  final LocationService locationService;

  MapBloc({required this.gpxService, required this.locationService})
    : super(const MapInitial()) {
    on<TogglePilgrimMode>(_onTogglePilgrimMode);
    on<ToggleDeviationMode>(_onToggleDeviationMode);
    on<DismissRouteDeviationWarning>(_onDismissRouteDeviationWarning);
  }

  void _onTogglePilgrimMode(TogglePilgrimMode event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(
        currentState.copyWith(
          pilgrimModeEnabled: event.enabled,
          deviationModeEnabled:
              event.enabled ? currentState.deviationModeEnabled : false,
        ),
      );
    }
  }

  void _onToggleDeviationMode(
    ToggleDeviationMode event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(
        currentState.copyWith(
          deviationModeEnabled: event.enabled,
          warningDismissed: false,
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
      emit(currentState.copyWith(warningDismissed: true));
    }
  }

  void _onLocationUpdated(LocationUpdated event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      final latLng = LatLng(
        event.location.latitude!,
        event.location.longitude!,
      );

      bool isOffRoute = false;

      if (currentState.pilgrimModeEnabled &&
          currentState.deviationModeEnabled) {
        final selectedTrack = currentState.selectedTrack;
        if (selectedTrack != null && selectedTrack.points.isNotEmpty) {
          final isNearRoute = selectedTrack.points.any((point) {
            final distanceInMeters = Geolocator.distanceBetween(
              latLng.latitude,
              latLng.longitude,
              point.position.latitude,
              point.position.longitude,
            );
            return distanceInMeters <= 100;
          });

          isOffRoute = !isNearRoute && !currentState.warningDismissed;
        }
      }

      emit(
        currentState.copyWith(currentLocation: latLng, isOffRoute: isOffRoute),
      );
    }
  }
}
