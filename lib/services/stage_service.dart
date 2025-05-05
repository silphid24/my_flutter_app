import 'package:latlong2/latlong.dart';
import 'package:my_flutter_app/models/stage_model.dart';

class StageService {
  // 싱글톤 패턴 적용
  static final StageService _instance = StageService._internal();
  factory StageService() => _instance;
  StageService._internal();

  // 카미노 프랑세스 스테이지 목록
  final List<CaminoStage> _caminoStages = [
    CaminoStage(
      id: 'stage1',
      name: 'Stage 1',
      assetPath: 'assets/data/Stage-1-Camino-Frances.gpx',
      title: 'Saint Jean Pied de Port → Roncesvalles',
      description: 'First stage crossing the Pyrenees.',
      startPoint:
          LatLng(43.163232, -1.237514), // Saint Jean Pied de Port (정확한 좌표)
      endPoint: LatLng(43.009158, -1.319721), // Roncesvalles (정확한 좌표)
      distance: 25.1,
      dayNumber: 1,
    ),
    CaminoStage(
      id: 'stage2',
      name: 'Stage 2',
      assetPath: 'assets/data/Stage-2.-Camino-Frances.gpx',
      title: 'Roncesvalles → Zubiri',
      description: 'Peaceful passage through forests and rural areas.',
      startPoint: LatLng(43.009158, -1.319721), // Roncesvalles (정확한 좌표)
      endPoint: LatLng(42.933156, -1.504384), // Zubiri (정확한 좌표)
      distance: 21.4,
      dayNumber: 2,
    ),
    CaminoStage(
      id: 'stage3',
      name: 'Stage 3',
      assetPath: 'assets/data/Stage-3.-Camino-Frances.gpx',
      title: 'Zubiri → Pamplona',
      description: 'Path to the capital of Navarra.',
      startPoint: LatLng(42.933156, -1.504384), // Zubiri (정확한 좌표)
      endPoint: LatLng(42.811956, -1.637954), // Pamplona (정확한 좌표)
      distance: 19.8,
      dayNumber: 3,
    ),
    CaminoStage(
      id: 'stage4',
      name: 'Stage 4',
      assetPath: 'assets/data/Stage-4.-Camino-Frances.gpx',
      title: 'Pamplona → Puente la Reina',
      description:
          'Through Navarra countryside to the town with the pilgrim bridge.',
      startPoint: LatLng(42.811956, -1.637954), // Pamplona (정확한 좌표)
      endPoint: LatLng(42.672409, -1.815055), // Puente la Reina (정확한 좌표)
      distance: 23.5,
      dayNumber: 4,
    ),
    CaminoStage(
      id: 'stage5',
      name: 'Stage 5',
      assetPath: 'assets/data/Stage-5.-Camino-Frances.gpx',
      title: 'Puente la Reina → Estella',
      description: 'Through wine regions to the historic city of Estella.',
      startPoint: LatLng(42.672409, -1.815055), // Puente la Reina (정확한 좌표)
      endPoint: LatLng(42.671284, -2.030892), // Estella (정확한 좌표)
      distance: 21.6,
      dayNumber: 5,
    ),
    CaminoStage(
      id: 'stage6',
      name: 'Stage 6',
      assetPath: 'assets/data/Stage-6.-Camino-Frances.gpx',
      title: 'Estella → Los Arcos',
      description: 'Passing vineyards and the famous wine fountain village.',
      startPoint: LatLng(42.671284, -2.030892), // Estella (정확한 좌표)
      endPoint: LatLng(42.568837, -2.191831), // Los Arcos (정확한 좌표)
      distance: 20.3,
      dayNumber: 6,
    ),
    CaminoStage(
      id: 'stage7',
      name: 'Stage 7',
      assetPath: 'assets/data/Stage-7.-Camino-Frances.gpx',
      title: 'Los Arcos → Logroño',
      description: 'Crossing from Navarra to La Rioja region.',
      startPoint: LatLng(42.568837, -2.191831), // Los Arcos (정확한 좌표)
      endPoint: LatLng(42.466271, -2.444983), // Logroño (정확한 좌표)
      distance: 27.8,
      dayNumber: 7,
    ),
    CaminoStage(
      id: 'stage8',
      name: 'Stage 8',
      assetPath: 'assets/data/Stage-8.-Camino-Frances.gpx',
      title: 'Logroño → Nájera',
      description: 'Flat path through wine regions.',
      startPoint: LatLng(42.466271, -2.444983), // Logroño (정확한 좌표)
      endPoint: LatLng(42.416668, -2.733333), // Nájera (정확한 좌표)
      distance: 28.5,
      dayNumber: 8,
    ),
    // 위치 정보가 틀린 s9부터 수정
    CaminoStage(
      id: 'stage9',
      name: 'Stage 9',
      assetPath: 'assets/data/Stage-9.-Camino-Frances.gpx',
      title: 'Nájera → Santo Domingo de la Calzada',
      description: 'Path to a historic Christian city.',
      startPoint: LatLng(42.416668, -2.733333), // Nájera (정확한 좌표)
      endPoint: LatLng(42.442778, -2.955278), // Santo Domingo (정확한 좌표)
      distance: 21.2,
      dayNumber: 9,
    ),
    CaminoStage(
      id: 'stage10',
      name: 'Stage 10',
      assetPath: 'assets/data/Stage-10.-Camino-Frances.gpx',
      title: 'Santo Domingo de la Calzada → Belorado',
      description: 'Long stage across plateau region.',
      startPoint: LatLng(42.442778, -2.955278), // Santo Domingo (정확한 좌표)
      endPoint: LatLng(42.420278, -3.185833), // Belorado (정확한 좌표)
      distance: 22.7,
      dayNumber: 10,
    ),
    CaminoStage(
      id: 'stage11',
      name: 'Stage 11',
      assetPath: 'assets/data/Stage-11.-Camino-Frances.gpx',
      title: 'Belorado → Agés',
      description: 'Challenging morning mountain crossing.',
      startPoint: LatLng(42.420278, -3.185833), // Belorado (정확한 좌표)
      endPoint: LatLng(42.368889, -3.478333), // Agés (정확한 좌표)
      distance: 23.8,
      dayNumber: 11,
    ),
    CaminoStage(
      id: 'stage12',
      name: 'Stage 12',
      assetPath: 'assets/data/Stage-12.-Camino-Frances.gpx',
      title: 'Agés → Burgos',
      description: 'Path to the beautiful cathedral of Burgos.',
      startPoint: LatLng(42.368889, -3.478333), // Agés (정확한 좌표)
      endPoint: LatLng(42.343889, -3.696944), // Burgos (정확한 좌표)
      distance: 16.3,
      dayNumber: 12,
    ),
    CaminoStage(
      id: 'stage13',
      name: 'Stage 13',
      assetPath: 'assets/data/Stage-13.-Camino-Frances.gpx',
      title: 'Burgos → Hornillos del Camino',
      description: 'Start of the meseta (plateau) crossing.',
      startPoint: LatLng(42.343889, -3.696944), // Burgos (정확한 좌표)
      endPoint: LatLng(42.338333, -3.908889), // Hornillos (정확한 좌표)
      distance: 20.5,
      dayNumber: 13,
    ),
    CaminoStage(
      id: 'stage14',
      name: 'Stage 14',
      assetPath: 'assets/data/Stage-14.-Camino-Frances.gpx',
      title: 'Hornillos del Camino → Castrojeriz',
      description: 'Flat crossing through the meseta.',
      startPoint: LatLng(42.338333, -3.908889), // Hornillos (정확한 좌표)
      endPoint: LatLng(42.288889, -4.139444), // Castrojeriz (정확한 좌표)
      distance: 19.2,
      dayNumber: 14,
    ),
    // 누락된 스테이지 15-33 추가
    CaminoStage(
      id: 'stage15',
      name: 'Stage 15',
      assetPath: 'assets/data/Stage-15.-Camino-Frances.gpx',
      title: 'Castrojeriz → Frómista',
      description: 'Crossing Castilla plateau and Pisuerga river valley.',
      startPoint: LatLng(42.288889, -4.139444), // Castrojeriz (정확한 좌표)
      endPoint: LatLng(42.268333, -4.405556), // Frómista (정확한 좌표)
      distance: 24.8,
      dayNumber: 15,
    ),
    CaminoStage(
      id: 'stage16',
      name: 'Stage 16',
      assetPath: 'assets/data/Stage-16.-Camino-Frances.gpx',
      title: 'Frómista → Carrión de los Condes',
      description: 'Follows the ancient Roman road Aquitania.',
      startPoint: LatLng(42.268333, -4.405556), // Frómista (정확한 좌표)
      endPoint: LatLng(42.338056, -4.601944), // Carrión de los Condes (정확한 좌표)
      distance: 19.4,
      dayNumber: 16,
    ),
    CaminoStage(
      id: 'stage17',
      name: 'Stage 17',
      assetPath: 'assets/data/Stage-17.-Camino-Frances.gpx',
      title: 'Carrión de los Condes → Terradillos de los Templarios',
      description: 'The meseta\'s longest stretch without services.',
      startPoint: LatLng(42.338056, -4.601944), // Carrión (정확한 좌표)
      endPoint: LatLng(42.366667, -4.818056), // Terradillos (정확한 좌표)
      distance: 26.8,
      dayNumber: 17,
    ),
    CaminoStage(
      id: 'stage18',
      name: 'Stage 18',
      assetPath: 'assets/data/Stage-18.-Camino-Frances.gpx',
      title: 'Terradillos de los Templarios → Bercianos del Real Camino',
      description: 'Rural path with few services.',
      startPoint: LatLng(42.366667, -4.818056), // Terradillos (정확한 좌표)
      endPoint: LatLng(42.413056, -5.021111), // Bercianos (정확한 좌표)
      distance: 22.7,
      dayNumber: 18,
    ),
    CaminoStage(
      id: 'stage19',
      name: 'Stage 19',
      assetPath: 'assets/data/Stage-19.-Camino-Frances.gpx',
      title: 'Bercianos del Real Camino → León',
      description: 'Approaching the city of León.',
      startPoint: LatLng(42.413056, -5.021111), // Bercianos (정확한 좌표)
      endPoint: LatLng(42.598333, -5.570000), // León (정확한 좌표)
      distance: 26.5,
      dayNumber: 19,
    ),
    CaminoStage(
      id: 'stage20',
      name: 'Stage 20',
      assetPath: 'assets/data/Stage-20.-Camino-Frances.gpx',
      title: 'León → Villadangos del Páramo',
      description: 'Leaving the city through industrial areas.',
      startPoint: LatLng(42.598333, -5.570000), // León (정확한 좌표)
      endPoint: LatLng(42.526111, -5.769444), // Villadangos (정확한 좌표)
      distance: 21.3,
      dayNumber: 20,
    ),
    CaminoStage(
      id: 'stage21',
      name: 'Stage 21',
      assetPath: 'assets/data/Stage-21.-Camino-Frances.gpx',
      title: 'Villadangos del Páramo → Astorga',
      description: 'Walking through small villages to Astorga.',
      startPoint: LatLng(42.526111, -5.769444), // Villadangos (정확한 좌표)
      endPoint: LatLng(42.455278, -6.052778), // Astorga (정확한 좌표)
      distance: 27.2,
      dayNumber: 21,
    ),
    CaminoStage(
      id: 'stage22',
      name: 'Stage 22',
      assetPath: 'assets/data/Stage-22.-Camino-Frances.gpx',
      title: 'Astorga → Rabanal del Camino',
      description: 'Beginning of the ascent to Cruz de Ferro.',
      startPoint: LatLng(42.455278, -6.052778), // Astorga (정확한 좌표)
      endPoint: LatLng(42.480278, -6.292778), // Rabanal (정확한 좌표)
      distance: 20.6,
      dayNumber: 22,
    ),
    CaminoStage(
      id: 'stage23',
      name: 'Stage 23',
      assetPath: 'assets/data/Stage-23.-Camino-Frances.gpx',
      title: 'Rabanal del Camino → Ponferrada',
      description: 'Famous for Cruz de Ferro, the highest point of the Camino.',
      startPoint: LatLng(42.480278, -6.292778), // Rabanal (정확한 좌표)
      endPoint: LatLng(42.548056, -6.598056), // Ponferrada (정확한 좌표)
      distance: 32.5,
      dayNumber: 23,
    ),
    CaminoStage(
      id: 'stage24',
      name: 'Stage 24',
      assetPath: 'assets/data/Stage-24.-Camino-Frances.gpx',
      title: 'Ponferrada → Villafranca del Bierzo',
      description: 'Through beautiful wine region of El Bierzo.',
      startPoint: LatLng(42.548056, -6.598056), // Ponferrada (정확한 좌표)
      endPoint: LatLng(42.608333, -6.810833), // Villafranca (정확한 좌표)
      distance: 24.2,
      dayNumber: 24,
    ),
    CaminoStage(
      id: 'stage25',
      name: 'Stage 25',
      assetPath: 'assets/data/Stage-25.-Camino-Frances.gpx',
      title: 'Villafranca del Bierzo → O Cebreiro',
      description: 'Steep climb to Galicia through beautiful mountains.',
      startPoint: LatLng(42.608333, -6.810833), // Villafranca (정확한 좌표)
      endPoint: LatLng(42.706944, -7.042778), // O Cebreiro (정확한 좌표)
      distance: 28.4,
      dayNumber: 25,
    ),
    CaminoStage(
      id: 'stage26',
      name: 'Stage 26',
      assetPath: 'assets/data/Stage-26.-Camino-Frances.gpx',
      title: 'O Cebreiro → Triacastela',
      description: 'Descending from the mountains into Galicia.',
      startPoint: LatLng(42.706944, -7.042778), // O Cebreiro (정확한 좌표)
      endPoint: LatLng(42.756111, -7.241111), // Triacastela (정확한 좌표)
      distance: 20.8,
      dayNumber: 26,
    ),
    CaminoStage(
      id: 'stage27',
      name: 'Stage 27',
      assetPath: 'assets/data/Stage-27.-Camino-Frances.gpx',
      title: 'Triacastela → Sarria',
      description: 'Path through small Galician villages.',
      startPoint: LatLng(42.756111, -7.241111), // Triacastela (정확한 좌표)
      endPoint: LatLng(42.780278, -7.413889), // Sarria (정확한 좌표)
      distance: 18.4,
      dayNumber: 27,
    ),
    CaminoStage(
      id: 'stage28',
      name: 'Stage 28',
      assetPath: 'assets/data/Stage-28.-Camino-Frances.gpx',
      title: 'Sarria → Portomarín',
      description: 'Popular starting point for many pilgrims (last 100km).',
      startPoint: LatLng(42.780278, -7.413889), // Sarria (정확한 좌표)
      endPoint: LatLng(42.808056, -7.616111), // Portomarín (정확한 좌표)
      distance: 22.2,
      dayNumber: 28,
    ),
    CaminoStage(
      id: 'stage29',
      name: 'Stage 29',
      assetPath: 'assets/data/Stage-29.-Camino-Frances.gpx',
      title: 'Portomarín → Palas de Rei',
      description: 'Beautiful Galician countryside trails.',
      startPoint: LatLng(42.808056, -7.616111), // Portomarín (정확한 좌표)
      endPoint: LatLng(42.873333, -7.868889), // Palas de Rei (정확한 좌표)
      distance: 24.8,
      dayNumber: 29,
    ),
    CaminoStage(
      id: 'stage30',
      name: 'Stage 30',
      assetPath: 'assets/data/Stage-30.-Camino-Frances.gpx',
      title: 'Palas de Rei → Arzúa',
      description: 'Rolling hills and many small rivers.',
      startPoint: LatLng(42.873333, -7.868889), // Palas de Rei (정확한 좌표)
      endPoint: LatLng(42.930278, -8.161111), // Arzúa (정확한 좌표)
      distance: 28.5,
      dayNumber: 30,
    ),
    CaminoStage(
      id: 'stage31',
      name: 'Stage 31',
      assetPath: 'assets/data/Stage-31.-Camino-Frances.gpx',
      title: 'Arzúa → O Pedrouzo',
      description: 'Getting closer to Santiago.',
      startPoint: LatLng(42.930278, -8.161111), // Arzúa (정확한 좌표)
      endPoint: LatLng(42.902778, -8.390833), // O Pedrouzo (정확한 좌표)
      distance: 19.3,
      dayNumber: 31,
    ),
    CaminoStage(
      id: 'stage32',
      name: 'Stage 32',
      assetPath: 'assets/data/Stage-32.-Camino-Frances.gpx',
      title: 'O Pedrouzo → Monte do Gozo',
      description: 'Last stretch before Santiago, first glimpse of the city.',
      startPoint: LatLng(42.902778, -8.390833), // O Pedrouzo (정확한 좌표)
      endPoint: LatLng(42.879722, -8.505556), // Monte do Gozo (정확한 좌표)
      distance: 15.8,
      dayNumber: 32,
    ),
    CaminoStage(
      id: 'stage33',
      name: 'Stage 33',
      assetPath: 'assets/data/Stage-33.-Camino-Frances.gpx',
      title: 'Monte do Gozo → Santiago de Compostela',
      description: 'Final stretch, arriving at the cathedral.',
      startPoint: LatLng(42.879722, -8.505556), // Monte do Gozo (정확한 좌표)
      endPoint: LatLng(42.880556, -8.544444), // Santiago Cathedral (정확한 좌표)
      distance: 4.5,
      dayNumber: 33,
    ),
  ];

  // 모든 스테이지 가져오기
  List<CaminoStage> getAllStages() {
    return _caminoStages;
  }

  // 스테이지 ID로 스테이지 정보 가져오기
  CaminoStage? getStageById(String id) {
    try {
      return _caminoStages.firstWhere((stage) => stage.id == id);
    } catch (e) {
      return null;
    }
  }

  // 일차별로 스테이지 가져오기
  CaminoStage? getStageByDay(int day) {
    try {
      return _caminoStages.firstWhere((stage) => stage.dayNumber == day);
    } catch (e) {
      return null;
    }
  }

  // 모든 스테이지의 경로 포인트를 결합한 리스트 가져오기 (전체 경로용)
  List<LatLng> getAllStagesPoints() {
    final List<LatLng> allPoints = [];

    for (final stage in _caminoStages) {
      // 스테이지 시작점 추가 (첫 번째 스테이지이거나 이전 스테이지의 끝점과 다른 경우만)
      if (allPoints.isEmpty || allPoints.last != stage.startPoint) {
        allPoints.add(stage.startPoint);
      }

      // 스테이지 끝점 추가
      allPoints.add(stage.endPoint);
    }

    return allPoints;
  }
}
