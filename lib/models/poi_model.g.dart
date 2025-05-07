// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poi_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PoiImpl _$$PoiImplFromJson(Map<String, dynamic> json) => _$PoiImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: $enumDecode(_$PoiTypeEnumMap, json['type']),
      description: json['description'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      facilities: (json['facilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PoiImplToJson(_$PoiImpl instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'type': _$PoiTypeEnumMap[instance.type]!,
      'description': instance.description,
      'address': instance.address,
      'phone': instance.phone,
      'website': instance.website,
      'rating': instance.rating,
      'isFavorite': instance.isFavorite,
      'imageUrl': instance.imageUrl,
      'facilities': instance.facilities,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PoiTypeEnumMap = {
  PoiType.albergue: 'albergue',
  PoiType.hotel: 'hotel',
  PoiType.restaurant: 'restaurant',
  PoiType.bar: 'bar',
  PoiType.fountain: 'fountain',
  PoiType.church: 'church',
  PoiType.monument: 'monument',
  PoiType.viewpoint: 'viewpoint',
  PoiType.medical: 'medical',
  PoiType.shop: 'shop',
  PoiType.other: 'other',
};
