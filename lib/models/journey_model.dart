import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'journey_model.freezed.dart';
part 'journey_model.g.dart';

@freezed
class Journey with _$Journey {
  const factory Journey({
    required String id,
    required String title,
    required String description,
    required String startLocation,
    required String endLocation,
    required double distance,
    required Duration estimatedTime,
    required int difficulty, // 1-5 (쉬움-어려움)
    String? imageUrl,
    @Default([]) List<String> highlights,
    int? dayNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Journey;

  factory Journey.fromJson(Map<String, dynamic> json) =>
      _$JourneyFromJson(json);
}
