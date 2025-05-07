import 'package:flutter/material.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/bottom_nav_bar.dart';

/// AppScaffold
///
/// 앱 전체에서 사용되는 공통 레이아웃 위젯입니다.
/// 네비게이션 바와 함께 일관된 화면 구조를 제공합니다.
class AppScaffold extends StatelessWidget {
  /// 표시할 화면 본문
  final Widget body;

  /// 앱바 타이틀
  final String? title;

  /// 현재 선택된 네비게이션 인덱스
  final int currentIndex;

  /// 사용자 정의 앱바
  final PreferredSizeWidget? appBar;

  /// 사용자 정의 플로팅 액션 버튼
  final Widget? floatingActionButton;

  /// 사용자 정의 바텀 시트
  final Widget? bottomSheet;

  /// 추가 액션 버튼들
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    required this.currentIndex,
    this.appBar,
    this.floatingActionButton,
    this.bottomSheet,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ??
          (title != null
              ? AppBar(
                  title: Text(title!),
                  actions: actions,
                )
              : null),
      body: body,
      bottomNavigationBar: BottomNavBar(currentIndex: currentIndex),
      floatingActionButton: floatingActionButton,
      bottomSheet: bottomSheet,
    );
  }
}
