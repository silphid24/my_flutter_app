import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class MapCacheService {
  // 싱글톤 패턴
  static final MapCacheService _instance = MapCacheService._internal();
  factory MapCacheService() => _instance;
  MapCacheService._internal();

  static const String _tileTable = 'map_tiles';
  static const String _prefKey = 'cached_regions';

  Database? _database;
  bool _isWebMode = false;

  // 데이터베이스 초기화
  Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      if (kIsWeb) {
        throw Exception('웹 환경에서는 SQLite 캐싱이 지원되지 않습니다');
      }
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      _isWebMode = true;
      print('지도 캐시 데이터베이스 초기화 실패: $e');
      throw Exception('지도 캐시 초기화 실패: $e');
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = path.join(await getDatabasesPath(), 'map_cache.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tileTable(
            id TEXT PRIMARY KEY,
            zoom INTEGER,
            x INTEGER, 
            y INTEGER,
            data BLOB,
            timestamp INTEGER
          )
        ''');
      },
    );
  }

  // 특정 지역의 지도 타일 다운로드 및 캐싱
  Future<bool> cacheRegion({
    required LatLng southWest,
    required LatLng northEast,
    required int minZoom,
    required int maxZoom,
    String tileProvider = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    Function(double)? progressCallback,
  }) async {
    if (_isWebMode) {
      print('웹 환경에서는 지도 캐싱이 지원되지 않습니다');
      return false;
    }

    try {
      // 캐싱할 타일 개수 계산
      int totalTiles = 0;
      int processedTiles = 0;

      for (int zoom = minZoom; zoom <= maxZoom; zoom++) {
        final swTile = _latLngToTile(southWest, zoom);
        final neTile = _latLngToTile(northEast, zoom);

        final xMin = swTile[0];
        final xMax = neTile[0];
        final yMin = neTile[1];
        final yMax = swTile[1];

        for (int x = xMin; x <= xMax; x++) {
          for (int y = yMin; y <= yMax; y++) {
            totalTiles++;
          }
        }
      }

      print('캐싱할 타일 수: $totalTiles');

      // 타일 다운로드 및 캐싱
      for (int zoom = minZoom; zoom <= maxZoom; zoom++) {
        final swTile = _latLngToTile(southWest, zoom);
        final neTile = _latLngToTile(northEast, zoom);

        final xMin = swTile[0];
        final xMax = neTile[0];
        final yMin = neTile[1];
        final yMax = swTile[1];

        for (int x = xMin; x <= xMax; x++) {
          for (int y = yMin; y <= yMax; y++) {
            final tileId = '${zoom}_${x}_${y}';

            // 이미 캐싱된 타일인지 확인
            final cachedTile = await _getTile(tileId);
            if (cachedTile == null) {
              // 서버에서 타일 다운로드
              final url = tileProvider
                  .replaceAll('{z}', zoom.toString())
                  .replaceAll('{x}', x.toString())
                  .replaceAll('{y}', y.toString());

              try {
                final response = await http.get(Uri.parse(url));
                if (response.statusCode == 200) {
                  await _saveTile(tileId, zoom, x, y, response.bodyBytes);
                }
              } catch (e) {
                print('타일 다운로드 오류 ($url): $e');
              }
            }

            processedTiles++;
            if (progressCallback != null) {
              progressCallback(processedTiles / totalTiles);
            }
          }
        }
      }

      // 캐싱된 지역 정보 저장
      await _saveCachedRegion(
        southWest: southWest,
        northEast: northEast,
        minZoom: minZoom,
        maxZoom: maxZoom,
      );

      return true;
    } catch (e) {
      print('지역 캐싱 오류: $e');
      return false;
    }
  }

  // 캐싱된 타일 가져오기
  Future<Uint8List?> getCachedTile(int zoom, int x, int y) async {
    if (_isWebMode) return null;

    try {
      final tileId = '${zoom}_${x}_${y}';
      final tile = await _getTile(tileId);
      return tile;
    } catch (e) {
      print('캐시된 타일 조회 오류: $e');
      return null;
    }
  }

  // 데이터베이스에서 타일 가져오기
  Future<Uint8List?> _getTile(String tileId) async {
    try {
      final db = await database;
      final result = await db.query(
        _tileTable,
        columns: ['data'],
        where: 'id = ?',
        whereArgs: [tileId],
      );

      if (result.isNotEmpty) {
        return result.first['data'] as Uint8List;
      }
      return null;
    } catch (e) {
      print('타일 조회 오류: $e');
      return null;
    }
  }

  // 데이터베이스에 타일 저장
  Future<void> _saveTile(
    String tileId,
    int zoom,
    int x,
    int y,
    Uint8List data,
  ) async {
    try {
      final db = await database;
      await db.insert(
        _tileTable,
        {
          'id': tileId,
          'zoom': zoom,
          'x': x,
          'y': y,
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('타일 저장 오류: $e');
    }
  }

  // 위도/경도를 타일 좌표로 변환
  List<int> _latLngToTile(LatLng latLng, int zoom) {
    final lat = latLng.latitude;
    final lng = latLng.longitude;

    final n = 1 << zoom;
    final xtile = ((lng + 180) / 360 * n).floor();
    final ytile = ((1 -
                (math.log(math.tan(lat * math.pi / 180) +
                        1 / math.cos(lat * math.pi / 180)) /
                    math.pi)) /
            2 *
            n)
        .floor();

    return [xtile, ytile];
  }

  // 캐싱된 지역 정보 저장
  Future<void> _saveCachedRegion({
    required LatLng southWest,
    required LatLng northEast,
    required int minZoom,
    required int maxZoom,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedRegions = prefs.getStringList(_prefKey) ?? [];

      final regionInfo = {
        'southWestLat': southWest.latitude,
        'southWestLng': southWest.longitude,
        'northEastLat': northEast.latitude,
        'northEastLng': northEast.longitude,
        'minZoom': minZoom,
        'maxZoom': maxZoom,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      cachedRegions.add(regionInfo.toString());
      await prefs.setStringList(_prefKey, cachedRegions);
    } catch (e) {
      print('캐싱된 지역 정보 저장 오류: $e');
    }
  }

  // 캐시 크기 계산
  Future<int> getCacheSize() async {
    if (_isWebMode) return 0;

    try {
      final db = await database;
      final result = await db
          .rawQuery('SELECT SUM(LENGTH(data)) as size FROM $_tileTable');
      return (result.first['size'] as int?) ?? 0;
    } catch (e) {
      print('캐시 크기 계산 오류: $e');
      return 0;
    }
  }

  // 오래된 캐시 정리
  Future<void> clearOldCache({int maxAgeInDays = 30}) async {
    if (_isWebMode) return;

    try {
      final db = await database;
      final cutoffTime = DateTime.now()
          .subtract(Duration(days: maxAgeInDays))
          .millisecondsSinceEpoch;

      await db.delete(
        _tileTable,
        where: 'timestamp < ?',
        whereArgs: [cutoffTime],
      );
    } catch (e) {
      print('오래된 캐시 정리 오류: $e');
    }
  }

  // 모든 캐시 정리
  Future<void> clearAllCache() async {
    if (_isWebMode) return;

    try {
      final db = await database;
      await db.delete(_tileTable);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKey);
    } catch (e) {
      print('캐시 정리 오류: $e');
    }
  }
}
