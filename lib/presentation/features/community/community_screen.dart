import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/presentation/features/community/community_screen_content.dart';
import 'package:my_flutter_app/presentation/features/shared/layout/app_scaffold.dart';

/// 커뮤니티 스크린 컨테이너
///
/// 커뮤니티 화면의 메인 컨테이너입니다.
/// CommunityScreenContent를 래핑하고 AppScaffold를 사용해 일관된 레이아웃을 제공합니다.
class CommunityScreenContainer extends HookConsumerWidget {
  const CommunityScreenContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AppScaffold(
      currentIndex: 2,
      body: CommunityScreenContent(),
    );
  }
}
