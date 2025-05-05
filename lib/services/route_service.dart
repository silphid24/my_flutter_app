import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/route_model.dart';

class RouteService {
  static final RouteService _instance = RouteService._internal();
  static const String _tableName = 'pilgrim_routes';

  Database? _database;
  List<PilgrimRoute>? _cachedRoutes;

  factory RouteService() {
    return _instance;
  }

  RouteService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'pilgrim_routes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            id TEXT PRIMARY KEY,
            title TEXT,
            towns TEXT,
            mapped INTEGER
          )
          ''');
      },
    );
  }

  Future<List<PilgrimRoute>> loadRoutes() async {
    if (_cachedRoutes != null) return _cachedRoutes!;

    try {
      // 내부 데이터베이스에서 먼저 확인
      final routes = await _loadRoutesFromDatabase();
      if (routes.isNotEmpty) {
        _cachedRoutes = routes;
        return routes;
      }

      // 데이터베이스에 없으면 CSV 파일에서 로드
      final csvRoutes = await _loadRoutesFromCsv();
      // 데이터베이스에 저장
      await _saveRoutesToDatabase(csvRoutes);

      _cachedRoutes = csvRoutes;
      return csvRoutes;
    } catch (e) {
      print('경로 로드 중 오류 발생: $e');
      return [];
    }
  }

  Future<List<PilgrimRoute>> _loadRoutesFromCsv() async {
    final rawData = await rootBundle.loadString('assets/data/routes_data.csv');
    final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
      rawData,
    );

    // 헤더 행 제거
    if (csvTable.isNotEmpty) {
      csvTable.removeAt(0);
    }

    return csvTable.map((row) {
      final csvRow = row.map((item) => item.toString()).toList();
      return PilgrimRoute.fromCsv(csvRow);
    }).toList();
  }

  Future<List<PilgrimRoute>> _loadRoutesFromDatabase() async {
    final db = await database;
    final maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return PilgrimRoute.fromMap(maps[i]);
    });
  }

  Future<void> _saveRoutesToDatabase(List<PilgrimRoute> routes) async {
    final db = await database;
    final batch = db.batch();

    for (var route in routes) {
      batch.insert(
        _tableName,
        route.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<PilgrimRoute>> searchRoutes(String query) async {
    if (query.isEmpty) return loadRoutes();

    final allRoutes = await loadRoutes();
    final lowercaseQuery = query.toLowerCase();

    return allRoutes.where((route) {
      return route.title.toLowerCase().contains(lowercaseQuery) ||
          route.id.toLowerCase().contains(lowercaseQuery) ||
          route.towns.any(
            (town) => town.toLowerCase().contains(lowercaseQuery),
          );
    }).toList();
  }

  Future<List<PilgrimRoute>> getMappedRoutes() async {
    final allRoutes = await loadRoutes();
    return allRoutes.where((route) => route.mapped).toList();
  }
}
