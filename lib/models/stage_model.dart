import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class CaminoStage {
  final String id;
  final String name;
  final String assetPath;
  final String title;
  final String? description;
  final gmaps.LatLng startPoint;
  final gmaps.LatLng endPoint;
  final double? distance;
  final int? dayNumber;

  // 추가된 속성들
  final int stageNumber;
  final String startName;
  final String endName;
  final int difficulty;

  const CaminoStage({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.title,
    this.description,
    required this.startPoint,
    required this.endPoint,
    this.distance,
    this.dayNumber,
    required this.stageNumber,
    required this.startName,
    required this.endName,
    required this.difficulty,
  });

  // stageNumber를 id에서 파싱하는 편의 생성자
  factory CaminoStage.fromStageId({
    required String id,
    required String name,
    required String assetPath,
    required String title,
    String? description,
    required gmaps.LatLng startPoint,
    required gmaps.LatLng endPoint,
    double? distance,
    int? dayNumber,
    required String startName,
    required String endName,
    required int difficulty,
  }) {
    // 'stage1', 'stage2'와 같은 형식에서 번호 추출
    final regExp = RegExp(r'stage(\d+)');
    final match = regExp.firstMatch(id);
    final stageNumber = match != null ? int.parse(match.group(1)!) : 0;

    return CaminoStage(
      id: id,
      name: name,
      assetPath: assetPath,
      title: title,
      description: description,
      startPoint: startPoint,
      endPoint: endPoint,
      distance: distance,
      dayNumber: dayNumber,
      stageNumber: stageNumber,
      startName: startName,
      endName: endName,
      difficulty: difficulty,
    );
  }
}
