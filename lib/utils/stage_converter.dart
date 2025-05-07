import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:my_flutter_app/domain/models/camino_route.dart';
import 'package:my_flutter_app/models/stage_model.dart' as stage_model;
import 'package:flutter/material.dart';

class StageConverter {
  // stage_model.CaminoStage를 domain.CaminoStage로 변환
  static CaminoStage convertToMapStage(stage_model.CaminoStage modelStage) {
    // latlong2.LatLng 목록을 google_maps_flutter.LatLng 목록으로 변환
    final List<gmaps.LatLng> path = [
      // 시작점
      gmaps.LatLng(
        modelStage.startPoint.latitude,
        modelStage.startPoint.longitude,
      ),
      // 끝점
      gmaps.LatLng(
        modelStage.endPoint.latitude,
        modelStage.endPoint.longitude,
      ),
    ];

    // 거리를 기준으로 난이도 계산
    String difficulty = 'Moderate';
    if (modelStage.distance != null) {
      if (modelStage.distance! > 25) {
        difficulty = 'Hard';
      } else if (modelStage.distance! < 20) {
        difficulty = 'Easy';
      }
    }

    // 시간 계산 (4km/h 기준)
    Duration estimatedTime = const Duration(hours: 5);
    if (modelStage.distance != null) {
      int minutes = (modelStage.distance! * 60 / 4).round();
      estimatedTime = Duration(minutes: minutes);
    }

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
  }
}
