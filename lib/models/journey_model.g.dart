// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JourneyImpl _$$JourneyImplFromJson(Map<String, dynamic> json) =>
    _$JourneyImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startLocation: json['startLocation'] as String,
      endLocation: json['endLocation'] as String,
      distance: (json['distance'] as num).toDouble(),
      estimatedTime:
          Duration(microseconds: (json['estimatedTime'] as num).toInt()),
      difficulty: (json['difficulty'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dayNumber: (json['dayNumber'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$JourneyImplToJson(_$JourneyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startLocation': instance.startLocation,
      'endLocation': instance.endLocation,
      'distance': instance.distance,
      'estimatedTime': instance.estimatedTime.inMicroseconds,
      'difficulty': instance.difficulty,
      'imageUrl': instance.imageUrl,
      'highlights': instance.highlights,
      'dayNumber': instance.dayNumber,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
