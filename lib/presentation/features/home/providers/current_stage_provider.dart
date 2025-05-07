import 'package:latlong2/latlong.dart' as latlong2;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_flutter_app/models/track.dart';
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:geolocator/geolocator.dart';

part 'current_stage_provider.g.dart';

/// 현재 스테이지 모델 클래스
class CurrentStage {
  final String fromLocation;
  final String toLocation;
  final latlong2.LatLng startCoordinates;
  final latlong2.LatLng endCoordinates;
  final double distance;
  final int estimatedHours;
  final double progressPercentage;
  final int completedKm;
  final int totalKm;
  final String title;
  final Track? track;

  const CurrentStage({
    required this.fromLocation,
    required this.toLocation,
    required this.startCoordinates,
    required this.endCoordinates,
    required this.distance,
    required this.estimatedHours,
    required this.progressPercentage,
    required this.completedKm,
    required this.totalKm,
    required this.title,
    this.track,
  });
}

/// 현재 스테이지 정보를 제공하는 Provider
@riverpod
class CurrentStageNotifier extends _$CurrentStageNotifier {
  final _gpxService = GpxService();

  @override
  Future<CurrentStage> build() async {
    // 기본값 설정
    final defaultStage = CurrentStage(
      fromLocation: 'Saint Jean',
      toLocation: 'Roncesvalles',
      startCoordinates: const latlong2.LatLng(43.1634, -1.2374),
      endCoordinates: const latlong2.LatLng(43.0096, -1.3195),
      distance: 25.0,
      estimatedHours: 6,
      progressPercentage: 38.5,
      completedKm: 9,
      totalKm: 25,
      title: 'Stage 1: Saint Jean to Roncesvalles',
    );

    try {
      // 트랙 ID를 사용하여 GPX 데이터 로드
      final trackId = "stage1"; // 예시 ID
      final track = await _gpxService.loadTrack(trackId);

      if (track != null) {
        // 트랙 데이터가 있으면 실제 정보로 업데이트
        return _createCurrentStageFromTrack(track);
      }
    } catch (e) {
      // 오류 발생 시 기본값 사용
      print('트랙 로드 중 오류: $e');
    }

    return defaultStage;
  }

  // 트랙 정보에서 현재 스테이지 정보 생성
  CurrentStage _createCurrentStageFromTrack(Track track) {
    // Track 클래스의 실제 구조에 맞게 수정
    final startPoint = track.startPoint;
    final endPoint = track.endPoint;

    // Track 클래스에서 총 거리 계산
    final double totalDistance = _calculateTrackDistance(track);

    return CurrentStage(
      fromLocation: track.name.split(' to ').first,
      toLocation: track.name.split(' to ').last,
      startCoordinates: startPoint != null
          ? latlong2.LatLng(startPoint.latitude, startPoint.longitude)
          : const latlong2.LatLng(43.1634, -1.2374),
      endCoordinates: endPoint != null
          ? latlong2.LatLng(endPoint.latitude, endPoint.longitude)
          : const latlong2.LatLng(43.0096, -1.3195),
      distance: totalDistance / 1000, // 미터에서 킬로미터로 변환
      estimatedHours: (totalDistance / 1000 / 4).round(), // 시속 4km 가정
      progressPercentage: 38.5, // 실제 구현에서는 사용자의 진행 상황 계산
      completedKm: 9, // 실제 구현에서는 사용자의 진행 상황 계산
      totalKm: (totalDistance / 1000).round(),
      title: track.name,
      track: track,
    );
  }

  // 트랙의 총 거리 계산
  double _calculateTrackDistance(Track track) {
    if (track.points.isEmpty) return 0;

    double totalDistance = 0;
    for (int i = 0; i < track.points.length - 1; i++) {
      final current = track.points[i].position;
      final next = track.points[i + 1].position;

      // latlong2 패키지의 Distance 클래스 사용
      final distance = latlong2.Distance();
      totalDistance += distance.as(
        latlong2.LengthUnit.Meter,
        latlong2.LatLng(current.latitude, current.longitude),
        latlong2.LatLng(next.latitude, next.longitude),
      );
    }

    return totalDistance;
  }

  // 트랙 수동 업데이트 메서드
  Future<void> updateTrack(String trackId) async {
    // state 변수 접근을 위해 AsyncNotifierProvider로 수정 필요
    state = const AsyncValue.loading();

    try {
      final track = await _gpxService.loadTrack(trackId);
      if (track != null) {
        state = AsyncValue.data(_createCurrentStageFromTrack(track));
      } else {
        state = AsyncValue.error(
          '트랙을 찾을 수 없습니다',
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
