import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/presentation/features/info/info_screen_content.dart';
import 'package:my_flutter_app/presentation/features/shared/layout/app_scaffold.dart';

/// 정보 스크린 컨테이너
///
/// 정보 화면의 메인 컨테이너입니다.
/// InfoScreenContent를 래핑하고 AppScaffold를 사용해 일관된 레이아웃을 제공합니다.
class InfoScreenContainer extends HookConsumerWidget {
  const InfoScreenContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AppScaffold(
      currentIndex: 3,
      body: InfoScreenContent(),
    );
  }
}
