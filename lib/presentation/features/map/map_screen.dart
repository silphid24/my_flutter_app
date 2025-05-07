import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/screens/stages_map_screen.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/bottom_nav_bar.dart';

/// 지도 스크린 컨테이너
///
/// 지도 화면의 메인 컨테이너입니다.
/// 기존 StagesMapScreen을 래핑하고 하단 네비게이션 바를 제공합니다.
class MapScreen extends HookConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: StagesMapScreen(),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }
}
