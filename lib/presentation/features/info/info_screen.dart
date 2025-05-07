import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/screens/info/info_screen.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/bottom_nav_bar.dart';

/// 정보 스크린 컨테이너
///
/// 정보 화면의 메인 컨테이너입니다.
/// 기존 InfoScreen을 래핑하고 하단 네비게이션 바를 제공합니다.
class InfoScreenContainer extends HookConsumerWidget {
  const InfoScreenContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: InfoScreen(),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
    );
  }
}
