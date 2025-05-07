import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/screens/community/community_screen.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/bottom_nav_bar.dart';

/// 커뮤니티 스크린 컨테이너
///
/// 커뮤니티 화면의 메인 컨테이너입니다.
/// 기존 CommunityScreen을 래핑하고 하단 네비게이션 바를 제공합니다.
class CommunityScreenContainer extends HookConsumerWidget {
  const CommunityScreenContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: CommunityScreen(),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}
