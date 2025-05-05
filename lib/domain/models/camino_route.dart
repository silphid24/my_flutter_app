import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class CaminoStage extends Equatable {
  final String id;
  final String name;
  final String description;
  final double distanceKm;
  final double elevationGainM;
  final List<LatLng> path;
  final Duration estimatedTime;
  final String difficulty;
  final Color color;

  const CaminoStage({
    required this.id,
    required this.name,
    required this.description,
    required this.distanceKm,
    required this.elevationGainM,
    required this.path,
    required this.estimatedTime,
    required this.difficulty,
    this.color = Colors.blue,
  });

  @override
  List<Object> get props => [id, name, path];
}

class CaminoRoute extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<CaminoStage> stages;

  const CaminoRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.stages,
  });

  List<LatLng> get fullPath {
    return stages.expand((stage) => stage.path).toList();
  }

  @override
  List<Object> get props => [id, name, stages];
}
