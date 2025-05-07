import 'dart:io';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show debugPrint;

import '../models/track.dart';
import '../models/track_point.dart';
import '../services/stage_service.dart';

class GpxService {
  static final GpxService _instance = GpxService._internal();
  static const String _trackTable = 'tracks';
  static const String _pointTable = 'track_points';

  Database? _database;
  final _uuid = Uuid();
  bool _dbInitialized = false;
  bool _isWebMode = false;

  // 진행 중인 비동기 로드 작업을 추적하기 위한 변수
  bool _isCancelled = false;

  factory GpxService() {
    return _instance;
  }

  GpxService._internal() {
    _isWebMode = kIsWeb;
  }

  // 데이터베이스 초기화 메소드 (외부에서 명시적으로 호출 가능)
  Future<void> initializeDatabase() async {
    if (_dbInitialized) return;

    try {
      if (_database == null) {
        await database;
        _dbInitialized = true;
        print('데이터베이스 초기화 완료');
      }
    } catch (e) {
      _dbInitialized = false;
      _isWebMode = true; // 오류 발생 시 웹 모드로 전환
      print('데이터베이스 초기화 오류: $e - 웹 모드로 작동합니다.');
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      _isWebMode = true;
      throw Exception('데이터베이스 초기화 실패: $e');
    }
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'camino_tracks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 트랙 테이블 생성
        await db.execute('''
          CREATE TABLE $_trackTable(
            id TEXT PRIMARY KEY,
            name TEXT,
            type TEXT,
            created_at TEXT
          )
        ''');

        // 트랙 포인트 테이블 생성
        await db.execute('''
          CREATE TABLE $_pointTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            track_id TEXT,
            latitude REAL,
            longitude REAL,
            elevation REAL,
            timestamp TEXT,
            FOREIGN KEY (track_id) REFERENCES $_trackTable(id)
          )
        ''');
      },
    );
  }

  void cancelLoading() {
    _isCancelled = true;
    debugPrint('GPX 로드 작업이 취소되었습니다.');
  }

  Future<Track?> loadGpxFromAsset(String assetPath) async {
    // 이전 로드가 취소되었다면 초기화
    _isCancelled = false;

    try {
      final data = await rootBundle.loadString(assetPath);
      // 로드가 취소되었으면 중단
      if (_isCancelled) {
        debugPrint('GPX 로드가 취소되었습니다: $assetPath');
        return null;
      }

      final document = XmlDocument.parse(data);

      // GPX 파싱 (네임스페이스 처리 간소화)
      String nsPrefix = '';

      // 메타데이터 추출
      final metadataNodes = document.findAllElements('metadata');
      if (metadataNodes.isEmpty) {
        throw Exception('메타데이터 요소를 찾을 수 없습니다');
      }

      // 로드가 취소되었는지 확인
      if (_isCancelled) {
        debugPrint('메타데이터 추출 중 로드가 취소되었습니다.');
        return null;
      }

      final metadata = metadataNodes.first;
      final timeNodes = metadata.findElements('time');
      DateTime createdAt;

      if (timeNodes.isNotEmpty) {
        final timeNode = timeNodes.first;
        createdAt = DateTime.parse(timeNode.innerText);
      } else {
        // 시간 정보가 없는 경우 현재 시간 사용
        createdAt = DateTime.now();
      }

      // 로드가 취소되었는지 확인
      if (_isCancelled) {
        debugPrint('시간 정보 추출 중 로드가 취소되었습니다.');
        return null;
      }

      // 트랙 정보 추출
      final trkNodes = document.findAllElements('trk');
      if (trkNodes.isEmpty) {
        throw Exception('트랙 요소를 찾을 수 없습니다');
      }

      final trkNode = trkNodes.first;
      String name = '카미노 프랑세스';
      String type = '순례길';

      final nameNodes = trkNode.findElements('name');
      if (nameNodes.isNotEmpty) {
        name = nameNodes.first.innerText;
      }

      final typeNodes = trkNode.findElements('type');
      if (typeNodes.isNotEmpty) {
        type = typeNodes.first.innerText;
      }

      // 로드가 취소되었는지 확인
      if (_isCancelled) {
        debugPrint('트랙 정보 추출 중 로드가 취소되었습니다.');
        return null;
      }

      // 트랙 포인트 추출
      final points = <TrackPoint>[];
      final trkSegNodes = trkNode.findElements('trkseg');

      if (trkSegNodes.isEmpty) {
        throw Exception('트랙 세그먼트를 찾을 수 없습니다');
      }

      // 로드가 취소되었는지 확인
      if (_isCancelled) {
        debugPrint('GPX 로드가 취소되었습니다: $assetPath');
        return null;
      }

      for (final trkSegNode in trkSegNodes) {
        final trkptNodes = trkSegNode.findElements('trkpt').toList();

        // 로드가 취소되었는지 확인
        if (_isCancelled) {
          debugPrint('GPX 포인트 처리 중 로드가 취소되었습니다: $assetPath');
          return null;
        }

        // 최적화: 모든 포인트의 절반만 사용 (첫 포인트와 마지막 포인트는 항상 포함)
        List<XmlElement> optimizedNodes = [];
        if (trkptNodes.length > 2) {
          // 첫 번째 포인트는 항상 포함
          optimizedNodes.add(trkptNodes.first);

          // 중간 포인트는 2개마다 하나씩만 선택 (50% 감소)
          for (int i = 1; i < trkptNodes.length - 1; i += 2) {
            optimizedNodes.add(trkptNodes[i]);

            // 주기적으로 취소 확인 (매 50개 포인트마다)
            if (i % 50 == 0 && _isCancelled) {
              debugPrint('포인트 최적화 중 로드가 취소되었습니다.');
              return null;
            }
          }

          // 마지막 포인트는 항상 포함 (홀수 개일 경우)
          if (trkptNodes.length > 1) {
            optimizedNodes.add(trkptNodes.last);
          }
        } else {
          // 포인트가 2개 이하면 그대로 사용
          optimizedNodes = trkptNodes;
        }

        for (final trkptNode in optimizedNodes) {
          final lat = double.parse(trkptNode.getAttribute('lat') ?? '0');
          final lon = double.parse(trkptNode.getAttribute('lon') ?? '0');

          double elevation = 0;
          DateTime time = DateTime.now();

          final eleNodes = trkptNode.findElements('ele');
          if (eleNodes.isNotEmpty) {
            try {
              elevation = double.parse(eleNodes.first.innerText);
            } catch (e) {
              print('고도 파싱 오류: ${eleNodes.first.innerText}');
            }
          }

          final timeNodes = trkptNode.findElements('time');
          if (timeNodes.isNotEmpty) {
            try {
              time = DateTime.parse(timeNodes.first.innerText);
            } catch (e) {
              print('시간 파싱 오류: ${timeNodes.first.innerText}');
            }
          }

          // 취소 확인
          if (_isCancelled) {
            debugPrint('포인트 생성 중 로드가 취소되었습니다.');
            return null;
          }

          try {
            points.add(
              TrackPoint(
                position: LatLng(lat, lon),
                elevation: elevation,
                time: time,
              ),
            );
            print('TrackPoint 생성 성공: lat=$lat, lon=$lon');
          } catch (e) {
            print('TrackPoint 생성 오류: $e');
            // 오류를 무시하지만 기록
            debugPrint('TrackPoint 생성 실패: $e');
          }
        }
      }

      if (points.isEmpty) {
        throw Exception('트랙 포인트를 찾을 수 없습니다');
      }

      print('최적화: 원본 포인트 대비 ${points.length}개 포인트 로드됨');

      // 최종 취소 확인
      if (_isCancelled) {
        debugPrint('트랙 생성 전 로드가 취소되었습니다.');
        return null;
      }

      // 트랙 ID 생성
      final trackId = _uuid.v4();

      // 트랙 객체 생성
      final track = Track(
        id: trackId,
        name: name,
        type: type,
        points: points,
        createdAt: createdAt,
      );

      // 웹 모드가 아닐 때만 데이터베이스에 저장 시도
      if (!_isWebMode) {
        try {
          // 마지막 취소 확인
          if (_isCancelled) {
            debugPrint('데이터베이스 저장 전 로드가 취소되었습니다.');
            return null;
          }

          await saveTrack(track);
          print('트랙 저장 성공: ${track.name}, 포인트 수: ${track.points.length}');
        } catch (e) {
          print('트랙 저장 실패: $e');
        }
      } else {
        print(
          '웹 모드: 트랙 메모리에만 로드됨 (${track.name}, 포인트 수: ${track.points.length})',
        );
      }

      return track;
    } catch (e) {
      print('GPX 파싱 오류: $e');
      return null;
    }
  }

  Future<void> saveTrack(Track track) async {
    final db = await database;

    // 트랜잭션 내에서 트랙과 트랙 포인트 저장
    await db.transaction((txn) async {
      // 트랙 정보 저장
      await txn.insert(
        _trackTable,
        track.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 트랙 포인트 저장
      for (final point in track.points) {
        await txn.insert(
            _pointTable,
            {
              'track_id': track.id,
              ...point.toMap(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<Track>> getTracks() async {
    List<Track> tracks = [];

    if (_isWebMode) {
      print('웹 모드에서는 기본 Stage-1 트랙만 로드합니다.');
      final track = await loadGpxFromAsset(
        'assets/data/Stage-1-Camino-Frances.gpx',
      );
      if (track != null) {
        tracks.add(track);
      }
      return tracks;
    }

    try {
      final db = await database;
      final trackMaps = await db.query(_trackTable);

      for (final trackMap in trackMaps) {
        final trackId = trackMap['id'] as String;
        final pointMaps = await db.query(
          _pointTable,
          where: 'track_id = ?',
          whereArgs: [trackId],
          orderBy: 'timestamp ASC',
        );

        final points = pointMaps.map((map) => TrackPoint.fromMap(map)).toList();
        tracks.add(Track.fromMap(trackMap, points));
      }
    } catch (e) {
      print('트랙 목록 로드 오류: $e');
      // 오류 발생 시 기본 파일 로드
      final track = await loadGpxFromAsset(
        'assets/data/Stage-1-Camino-Frances.gpx',
      );
      if (track != null) {
        tracks.add(track);
      }
    }

    return tracks;
  }

  Future<Track?> getTrack(String trackId) async {
    if (_isWebMode) {
      print('웹 모드에서는 기본 Stage-1 트랙을 로드합니다.');
      return loadGpxFromAsset('assets/data/Stage-1-Camino-Frances.gpx');
    }

    try {
      final db = await database;
      final trackMaps = await db.query(
        _trackTable,
        where: 'id = ?',
        whereArgs: [trackId],
      );

      if (trackMaps.isEmpty) return null;

      final pointMaps = await db.query(
        _pointTable,
        where: 'track_id = ?',
        whereArgs: [trackId],
        orderBy: 'timestamp ASC',
      );

      final points = pointMaps.map((map) => TrackPoint.fromMap(map)).toList();
      return Track.fromMap(trackMaps.first, points);
    } catch (e) {
      print('트랙 로드 오류: $e');
      return loadGpxFromAsset('assets/data/Stage-1-Camino-Frances.gpx');
    }
  }

  // 여러 GPX 파일을 하나로 결합하여 전체 경로를 생성
  Future<Track?> loadCombinedGpxTracks() async {
    print('전체 프랑스길 경로 결합 중...');

    // 경로를 결합할 모든 파일 목록 (순서대로)
    List<String> stageFiles = [];

    // Stage 1부터 33까지 순서대로 파일 경로 생성
    for (int i = 1; i <= 33; i++) {
      if (i == 27 || i == 28) {
        // 27-28은 합쳐진 파일
        if (!stageFiles.contains(
          'assets/data/Stages-27-28.-Camino-Frances.gpx',
        )) {
          stageFiles.add('assets/data/Stages-27-28.-Camino-Frances.gpx');
        }
      } else if (i == 1) {
        stageFiles.add('assets/data/Stage-1-Camino-Frances.gpx');
      } else {
        stageFiles.add('assets/data/Stage-$i.-Camino-Frances.gpx');
      }
    }

    // 웹 모드에서는 첫 번째 스테이지 하나만 처리 (성능 이슈 방지)
    if (_isWebMode) {
      print('웹 모드에서는 첫 번째 스테이지만 로드합니다.');
      return loadGpxFromAsset('assets/data/Stage-1-Camino-Frances.gpx');
    }

    // 결합된 포인트를 저장할 리스트
    List<TrackPoint> combinedPoints = [];
    DateTime createdAt = DateTime.now();

    try {
      // 각 파일에서 트랙 포인트를 추출하여 결합
      for (String filePath in stageFiles) {
        print('파일 처리 중: $filePath');
        Track? stageTrack;

        try {
          stageTrack = await loadGpxFromAsset(filePath);
        } catch (e) {
          print('파일 로드 실패: $filePath - $e');
          continue; // 이 파일을 건너뜁니다
        }

        if (stageTrack != null && stageTrack.points.isNotEmpty) {
          // 생성 시간은 가장 첫 번째 트랙의 시간으로 설정
          if (combinedPoints.isEmpty) {
            createdAt = stageTrack.createdAt;
          }

          // 포인트 추가 (중복 제거하지 않고 모두 추가)
          combinedPoints.addAll(stageTrack.points);
          print(
            '${stageTrack.points.length}개 포인트 추가됨 (현재 총 ${combinedPoints.length}개)',
          );
        }
      }

      if (combinedPoints.isEmpty) {
        print('결합된 포인트가 없습니다. 기본 파일 로드');
        return loadGpxFromAsset('assets/data/Stage-1-Camino-Frances.gpx');
      }

      // 결합된 트랙 생성
      final combinedTrack = Track(
        id: _uuid.v4(),
        name: '카미노 프랑세스 - 전체 경로',
        type: '순례길',
        points: combinedPoints,
        createdAt: createdAt,
      );

      // 웹 모드가 아닐 때만 저장 시도
      if (!_isWebMode) {
        try {
          // 데이터베이스에 저장
          await saveTrack(combinedTrack);
          print('전체 경로 저장 성공: ${combinedTrack.points.length}개 포인트');
        } catch (e) {
          print('전체 경로 저장 실패: $e');
        }
      } else {
        print('웹 모드: 전체 경로 메모리에만 로드됨 (${combinedTrack.points.length}개 포인트)');
      }

      return combinedTrack;
    } catch (e) {
      print('경로 결합 오류: $e');
      return loadGpxFromAsset('assets/data/Stage-1-Camino-Frances.gpx');
    }
  }

  Future<Track?> loadTrack(String trackId) async {
    // 이전 로드가 취소되었다면 초기화
    _isCancelled = false;

    try {
      // 주기적으로 취소 여부 확인
      if (_isCancelled) {
        debugPrint('트랙 로드가 취소되었습니다: $trackId');
        return null;
      }

      // 데이터베이스에서 트랙 조회 시도
      if (!_isWebMode) {
        try {
          // 취소 여부 재확인
          if (_isCancelled) return null;

          final track = await getTrack(trackId);
          if (track != null) {
            return track;
          }
        } catch (e) {
          print('데이터베이스에서 트랙 로드 실패: $e');
          // 작업이 취소되었는지 확인
          if (_isCancelled) return null;
        }
      }

      // 취소 여부 재확인
      if (_isCancelled) return null;

      // 데이터베이스에서 트랙을 찾지 못한 경우 스테이지 서비스를 통해 GPX 파일 로드 시도
      try {
        final stageService = StageService();
        final stage = stageService.getStageById(trackId);

        if (stage != null && stage.assetPath.isNotEmpty) {
          // 취소 여부 재확인
          if (_isCancelled) return null;

          return await loadGpxFromAsset(stage.assetPath);
        }
      } catch (e) {
        print('스테이지에서 트랙 로드 실패: $e');
        // 작업이 취소되었는지 확인
        if (_isCancelled) return null;
      }

      // 모든 방법이 실패한 경우 null, 혹은 취소된 경우 null 반환
      return null;
    } catch (e) {
      print('트랙 로드 중 예외 발생: $e');
      return null;
    }
  }
}
