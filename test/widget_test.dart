// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:my_flutter_app/domain/repositories/auth_repository.dart';
import 'package:my_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/today_stage_card.dart';
import 'package:my_flutter_app/presentation/router/app_router.dart';

class MockAuthRepository extends AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // 테스트에 필요한 메소드만 모킹
    return super.noSuchMethod(invocation);
  }
}

void main() {
  testWidgets('TodayStageCard 렌더링 테스트', (WidgetTester tester) async {
    // 기본 위젯 테스트를 위한 TodayStageCard 렌더링
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TodayStageCard(
              fromLocation: 'Saint Jean',
              toLocation: 'Roncesvalles',
              startCoordinates: latlong2.LatLng(43.1634, -1.2374),
              endCoordinates: latlong2.LatLng(43.0096, -1.3195),
              distance: 25.0,
              estimatedHours: 6,
            ),
          ),
        ),
      ),
    );

    // 위젯에 출발지와 도착지 표시가 있는지 확인
    expect(find.text('Saint Jean'), findsOneWidget);
    expect(find.text('Roncesvalles'), findsOneWidget);

    // 거리 확인 (올바른 형식으로 표시되는지 확인)
    expect(find.text('25.0 km'), findsOneWidget);

    // 예상 소요 시간 확인
    expect(find.text('6 시간'), findsOneWidget);
  });
}
