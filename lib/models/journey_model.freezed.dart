// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journey_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Journey _$JourneyFromJson(Map<String, dynamic> json) {
  return _Journey.fromJson(json);
}

/// @nodoc
mixin _$Journey {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get startLocation => throw _privateConstructorUsedError;
  String get endLocation => throw _privateConstructorUsedError;
  double get distance => throw _privateConstructorUsedError;
  Duration get estimatedTime => throw _privateConstructorUsedError;
  int get difficulty => throw _privateConstructorUsedError; // 1-5 (쉬움-어려움)
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String> get highlights => throw _privateConstructorUsedError;
  int? get dayNumber => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Journey to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JourneyCopyWith<Journey> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JourneyCopyWith<$Res> {
  factory $JourneyCopyWith(Journey value, $Res Function(Journey) then) =
      _$JourneyCopyWithImpl<$Res, Journey>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String startLocation,
      String endLocation,
      double distance,
      Duration estimatedTime,
      int difficulty,
      String? imageUrl,
      List<String> highlights,
      int? dayNumber,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$JourneyCopyWithImpl<$Res, $Val extends Journey>
    implements $JourneyCopyWith<$Res> {
  _$JourneyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? startLocation = null,
    Object? endLocation = null,
    Object? distance = null,
    Object? estimatedTime = null,
    Object? difficulty = null,
    Object? imageUrl = freezed,
    Object? highlights = null,
    Object? dayNumber = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      startLocation: null == startLocation
          ? _value.startLocation
          : startLocation // ignore: cast_nullable_to_non_nullable
              as String,
      endLocation: null == endLocation
          ? _value.endLocation
          : endLocation // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedTime: null == estimatedTime
          ? _value.estimatedTime
          : estimatedTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      highlights: null == highlights
          ? _value.highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dayNumber: freezed == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JourneyImplCopyWith<$Res> implements $JourneyCopyWith<$Res> {
  factory _$$JourneyImplCopyWith(
          _$JourneyImpl value, $Res Function(_$JourneyImpl) then) =
      __$$JourneyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String startLocation,
      String endLocation,
      double distance,
      Duration estimatedTime,
      int difficulty,
      String? imageUrl,
      List<String> highlights,
      int? dayNumber,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$JourneyImplCopyWithImpl<$Res>
    extends _$JourneyCopyWithImpl<$Res, _$JourneyImpl>
    implements _$$JourneyImplCopyWith<$Res> {
  __$$JourneyImplCopyWithImpl(
      _$JourneyImpl _value, $Res Function(_$JourneyImpl) _then)
      : super(_value, _then);

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? startLocation = null,
    Object? endLocation = null,
    Object? distance = null,
    Object? estimatedTime = null,
    Object? difficulty = null,
    Object? imageUrl = freezed,
    Object? highlights = null,
    Object? dayNumber = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$JourneyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      startLocation: null == startLocation
          ? _value.startLocation
          : startLocation // ignore: cast_nullable_to_non_nullable
              as String,
      endLocation: null == endLocation
          ? _value.endLocation
          : endLocation // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedTime: null == estimatedTime
          ? _value.estimatedTime
          : estimatedTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      highlights: null == highlights
          ? _value._highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dayNumber: freezed == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JourneyImpl with DiagnosticableTreeMixin implements _Journey {
  const _$JourneyImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.startLocation,
      required this.endLocation,
      required this.distance,
      required this.estimatedTime,
      required this.difficulty,
      this.imageUrl,
      final List<String> highlights = const [],
      this.dayNumber,
      this.createdAt,
      this.updatedAt})
      : _highlights = highlights;

  factory _$JourneyImpl.fromJson(Map<String, dynamic> json) =>
      _$$JourneyImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String startLocation;
  @override
  final String endLocation;
  @override
  final double distance;
  @override
  final Duration estimatedTime;
  @override
  final int difficulty;
// 1-5 (쉬움-어려움)
  @override
  final String? imageUrl;
  final List<String> _highlights;
  @override
  @JsonKey()
  List<String> get highlights {
    if (_highlights is EqualUnmodifiableListView) return _highlights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_highlights);
  }

  @override
  final int? dayNumber;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Journey(id: $id, title: $title, description: $description, startLocation: $startLocation, endLocation: $endLocation, distance: $distance, estimatedTime: $estimatedTime, difficulty: $difficulty, imageUrl: $imageUrl, highlights: $highlights, dayNumber: $dayNumber, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Journey'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('startLocation', startLocation))
      ..add(DiagnosticsProperty('endLocation', endLocation))
      ..add(DiagnosticsProperty('distance', distance))
      ..add(DiagnosticsProperty('estimatedTime', estimatedTime))
      ..add(DiagnosticsProperty('difficulty', difficulty))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('highlights', highlights))
      ..add(DiagnosticsProperty('dayNumber', dayNumber))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JourneyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startLocation, startLocation) ||
                other.startLocation == startLocation) &&
            (identical(other.endLocation, endLocation) ||
                other.endLocation == endLocation) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.estimatedTime, estimatedTime) ||
                other.estimatedTime == estimatedTime) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._highlights, _highlights) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      startLocation,
      endLocation,
      distance,
      estimatedTime,
      difficulty,
      imageUrl,
      const DeepCollectionEquality().hash(_highlights),
      dayNumber,
      createdAt,
      updatedAt);

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JourneyImplCopyWith<_$JourneyImpl> get copyWith =>
      __$$JourneyImplCopyWithImpl<_$JourneyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JourneyImplToJson(
      this,
    );
  }
}

abstract class _Journey implements Journey {
  const factory _Journey(
      {required final String id,
      required final String title,
      required final String description,
      required final String startLocation,
      required final String endLocation,
      required final double distance,
      required final Duration estimatedTime,
      required final int difficulty,
      final String? imageUrl,
      final List<String> highlights,
      final int? dayNumber,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$JourneyImpl;

  factory _Journey.fromJson(Map<String, dynamic> json) = _$JourneyImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get startLocation;
  @override
  String get endLocation;
  @override
  double get distance;
  @override
  Duration get estimatedTime;
  @override
  int get difficulty; // 1-5 (쉬움-어려움)
  @override
  String? get imageUrl;
  @override
  List<String> get highlights;
  @override
  int? get dayNumber;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Journey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JourneyImplCopyWith<_$JourneyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
