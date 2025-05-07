import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:location/location.dart';
import 'package:my_flutter_app/models/journey_model.dart';
import 'package:my_flutter_app/models/poi_model.dart';
import 'package:my_flutter_app/services/journey_service.dart';
import 'package:my_flutter_app/services/poi_service.dart';

// 위치 정보 Provider
final currentLocationProvider = StreamProvider<LocationData?>((ref) {
  final location = Location();
  location.requestPermission();
  location.requestService();

  return location.onLocationChanged;
});

// 현재 위치 기반 주변 POI Provider
final nearbyPoisProvider =
    FutureProvider.autoDispose<Map<PoiType, List<Poi>>>((ref) async {
  final locationData = await ref.watch(currentLocationProvider.future);

  if (locationData == null ||
      locationData.latitude == null ||
      locationData.longitude == null) {
    // 위치 정보가 없는 경우 빈 결과 반환
    return {};
  }

  return PoiService().getNearbyPois(
    latitude: locationData.latitude!,
    longitude: locationData.longitude!,
    radiusKm: 5.0,
  );
});

// 추천 여행 경로 Provider
final recommendedJourneysProvider =
    FutureProvider.autoDispose<List<Journey>>((ref) async {
  return JourneyService().getRecommendedJourneys();
});

// 선택된 POI Provider
final selectedPoiProvider = StateProvider<Poi?>((ref) => null);

// 모든 POI 타입을 반환하는 Provider
final poiTypesProvider = Provider<List<PoiType>>((ref) {
  return PoiType.values.toList();
});
