import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

part 'poi_model.freezed.dart';
part 'poi_model.g.dart';

/// POI(관심 지점) 유형 정의
enum PoiType {
  albergue, // 순례자 숙소
  hotel, // 호텔
  restaurant, // 식당
  bar, // 바
  fountain, // 식수대
  church, // 교회
  monument, // 기념비/유적지
  viewpoint, // 전망대
  medical, // 의료 시설
  shop, // 상점
  other, // 기타
}

extension PoiTypeExtension on PoiType {
  String get name {
    switch (this) {
      case PoiType.albergue:
        return '순례자 숙소';
      case PoiType.hotel:
        return '호텔';
      case PoiType.restaurant:
        return '식당';
      case PoiType.bar:
        return '바/카페';
      case PoiType.fountain:
        return '식수대';
      case PoiType.church:
        return '교회';
      case PoiType.monument:
        return '기념비/유적지';
      case PoiType.viewpoint:
        return '전망대';
      case PoiType.medical:
        return '의료 시설';
      case PoiType.shop:
        return '상점';
      case PoiType.other:
        return '기타';
    }
  }

  IconData get icon {
    switch (this) {
      case PoiType.albergue:
        return Icons.hotel;
      case PoiType.hotel:
        return Icons.apartment;
      case PoiType.restaurant:
        return Icons.restaurant;
      case PoiType.bar:
        return Icons.local_cafe;
      case PoiType.fountain:
        return Icons.local_drink;
      case PoiType.church:
        return Icons.church;
      case PoiType.monument:
        return Icons.landscape;
      case PoiType.viewpoint:
        return Icons.photo_camera;
      case PoiType.medical:
        return Icons.local_hospital;
      case PoiType.shop:
        return Icons.shopping_bag;
      case PoiType.other:
        return Icons.place;
    }
  }
}

/// 위치 기반 POI(관심 지점) 모델
class PointOfInterest {
  final String id;
  final String name;
  final PoiType type;
  final LatLng position;
  final String? description;
  final String? photoUrl;
  final Map<String, dynamic>? extraInfo;
  final int stageNumber;

  const PointOfInterest({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.description,
    this.photoUrl,
    this.extraInfo,
    required this.stageNumber,
  });

  // JSON에서 POI 객체 생성
  factory PointOfInterest.fromJson(Map<String, dynamic> json) {
    return PointOfInterest(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parsePoiType(json['type'] as String),
      position: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      description: json['description'] as String?,
      photoUrl: json['photo_url'] as String?,
      extraInfo: json['extra_info'] as Map<String, dynamic>?,
      stageNumber: json['stage_number'] as int,
    );
  }

  // POI 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'description': description,
      'photo_url': photoUrl,
      'extra_info': extraInfo,
      'stage_number': stageNumber,
    };
  }

  // 문자열에서 POI 유형 파싱
  static PoiType _parsePoiType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'albergue':
        return PoiType.albergue;
      case 'hotel':
        return PoiType.hotel;
      case 'restaurant':
        return PoiType.restaurant;
      case 'bar':
        return PoiType.bar;
      case 'fountain':
        return PoiType.fountain;
      case 'church':
        return PoiType.church;
      case 'monument':
        return PoiType.monument;
      case 'viewpoint':
        return PoiType.viewpoint;
      case 'medical':
        return PoiType.medical;
      case 'shop':
        return PoiType.shop;
      default:
        return PoiType.other;
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
