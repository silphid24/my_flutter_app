import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_app/domain/models/camino_route.dart';
import 'package:my_flutter_app/models/stage_model.dart' as stage_model;
import 'package:flutter/material.dart';

class StageConverter {
  // stage_model.CaminoStage를 domain.CaminoStage로 변환
  static CaminoStage convertToMapStage(stage_model.CaminoStage modelStage) {
    try {
      debugPrint('StageConverter: 스테이지 변환 시작 - ID: ${modelStage.id}');

      // 시작점과 끝점을 통한 경로 생성
      final List<LatLng> path = [
        // 시작점
        LatLng(
          modelStage.startPoint.latitude,
          modelStage.startPoint.longitude,
        ),
        // 끝점
        LatLng(
          modelStage.endPoint.latitude,
          modelStage.endPoint.longitude,
        ),
      ];
      debugPrint('StageConverter: 경로 생성 완료');

      // 거리를 기준으로 난이도 계산
      String difficulty = 'Moderate';
      if (modelStage.distance != null) {
        if (modelStage.distance! > 25) {
          difficulty = 'Hard';
        } else if (modelStage.distance! < 20) {
          difficulty = 'Easy';
        }
      }
      debugPrint('StageConverter: 난이도 계산 완료 - $difficulty');

      // 시간 계산 (4km/h 기준)
      Duration estimatedTime = const Duration(hours: 5);
      if (modelStage.distance != null) {
        int minutes = (modelStage.distance! * 60 / 4).round();
        estimatedTime = Duration(minutes: minutes);
      }
      debugPrint('StageConverter: 예상 시간 계산 완료 - ${estimatedTime.inMinutes}분');

      debugPrint('StageConverter: CaminoStage 객체 생성');
      return CaminoStage(
        id: modelStage.id,
        name: modelStage.title,
        description: modelStage.description ?? modelStage.title,
        distanceKm: modelStage.distance ?? 20.0,
        elevationGainM: 500, // 기본값
        path: path,
        estimatedTime: estimatedTime,
        difficulty: difficulty,
        color: Colors.blue,
      );
    } catch (e, stackTrace) {
      debugPrint('StageConverter 오류 (스테이지 ID: ${modelStage.id}): $e');
      debugPrint('스택 트레이스: $stackTrace');

      // 문제가 발생해도 기본 객체를 반환하여 앱이 크래시되지 않도록 함
      return CaminoStage(
        id: modelStage.id,
        name: modelStage.title,
        description: '데이터 변환 오류',
        distanceKm: 0.0,
        elevationGainM: 0,
        path: [], // 빈 경로
        estimatedTime: const Duration(hours: 0),
        difficulty: 'Unknown',
        color: Colors.grey,
      );
    }
  }
}
