import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/domain/models/camino_route.dart';
import 'package:my_flutter_app/domain/models/map_marker.dart';
import 'package:my_flutter_app/domain/repositories/location_repository.dart';
import 'package:my_flutter_app/presentation/bloc/map_bloc.dart';
import 'package:my_flutter_app/presentation/features/shared/layout/app_scaffold.dart';
import 'package:my_flutter_app/presentation/features/shared/widgets/pilgrim_mode_settings.dart';
import 'package:my_flutter_app/presentation/features/shared/widgets/route_deviation_alert.dart';
import 'package:my_flutter_app/presentation/features/shared/widgets/route_deviation_settings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_app/data/repositories/location_repository_impl.dart';
import 'package:my_flutter_app/presentation/features/camino/camino_map_screen.dart';

/// 지도 스크린 컨테이너
///
/// 지도 화면의 메인 컨테이너입니다.
/// 홈 화면의 맵 버튼과 동일한 기능을 제공하도록 CaminoMapScreen을 사용합니다.
class MapScreen extends StatelessWidget {
  final String? stageId;

  const MapScreen({
    Key? key,
    this.stageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // CaminoMapScreen을 사용하여 일관성 있는 지도 인터페이스 제공
    return CaminoMapScreen(trackId: stageId);
  }
}
