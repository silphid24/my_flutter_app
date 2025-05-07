import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'poi_model.freezed.dart';
part 'poi_model.g.dart';

enum PoiType {
  @JsonValue(0)
  accommodation,

  @JsonValue(1)
  restaurant,

  @JsonValue(2)
  pharmacy,

  @JsonValue(3)
  landmark,

  @JsonValue(4)
  service,
}

extension PoiTypeExtension on PoiType {
  String get name {
    switch (this) {
      case PoiType.accommodation:
        return '숙소';
      case PoiType.restaurant:
        return '식당';
      case PoiType.pharmacy:
        return '약국';
      case PoiType.landmark:
        return '명소';
      case PoiType.service:
        return '서비스';
    }
  }

  IconData get icon {
    switch (this) {
      case PoiType.accommodation:
        return Icons.hotel;
      case PoiType.restaurant:
        return Icons.restaurant;
      case PoiType.pharmacy:
        return Icons.local_pharmacy;
      case PoiType.landmark:
        return Icons.landscape;
      case PoiType.service:
        return Icons.miscellaneous_services;
    }
  }
}

@freezed
class Poi with _$Poi {
  const factory Poi({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required PoiType type,
    String? description,
    String? address,
    String? phone,
    String? website,
    double? rating,
    @Default(false) bool isFavorite,
    String? imageUrl,
    @Default([]) List<String> facilities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Poi;

  factory Poi.fromJson(Map<String, dynamic> json) => _$PoiFromJson(json);
}
