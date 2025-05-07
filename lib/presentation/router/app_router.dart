import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_flutter_app/presentation/features/home/home_screen.dart';
import 'package:my_flutter_app/presentation/features/map/map_screen.dart';
import 'package:my_flutter_app/presentation/features/community/community_screen.dart';
import 'package:my_flutter_app/presentation/features/info/info_screen.dart';
import 'package:my_flutter_app/presentation/features/routes/route_list_screen.dart';
import 'package:my_flutter_app/presentation/features/tracks/track_map_screen.dart';
import 'package:my_flutter_app/presentation/features/tracks/gpx_loader_screen.dart';
import 'package:my_flutter_app/presentation/features/camino/camino_map_screen.dart';
import 'package:my_flutter_app/login_screen.dart';
import 'package:my_flutter_app/presentation/pages/auth/signup_page.dart';
import 'package:my_flutter_app/presentation/pages/profile/profile_page.dart';
import 'package:my_flutter_app/presentation/pages/splash_page.dart';

part 'app_router.g.dart';

/// 앱 라우트 상수 정의
///
/// 앱의 모든 라우트 경로를 중앙에서 관리합니다.
/// 이렇게 하면 경로 문자열을 하드코딩하지 않고 일관되게 참조할 수 있습니다.
class AppRoutes {
  // 인증 관련 경로
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  // 메인 탭 화면 경로
  static const String home = '/home';
  static const String map = '/map';
  static const String community = '/community';
  static const String info = '/info';

  // 기타 화면 경로
  static const String profile = '/profile';
  static const String routes = '/routes';
  static const String trackMap = '/track_map';
  static const String gpxLoader = '/gpx_loader';
  static const String caminoMap = '/camino_map';
  static const String fullCaminoMap = '/full_camino_map';
}

/// 앱 라우터 프로바이더
///
/// Riverpod 프로바이더 주석을 사용하여 자동 코드 생성합니다.
/// 이 프로바이더는 전체 앱의 라우팅 설정을 제공합니다.
@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // 인증 관련 라우트
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupPage(),
      ),

      // 메인 탭 화면 라우트
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: AppRoutes.community,
        builder: (context, state) => const CommunityScreenContainer(),
      ),
      GoRoute(
        path: AppRoutes.info,
        builder: (context, state) => const InfoScreenContainer(),
      ),

      // 기타 화면 라우트
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.caminoMap,
        builder: (context, state) => const CaminoMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.fullCaminoMap,
        builder: (context, state) => const CaminoMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.routes,
        builder: (context, state) => const RouteListScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.trackMap}/:trackId',
        builder: (context, state) {
          final trackId = state.pathParameters['trackId'];
          return TrackMapScreen(trackId: trackId);
        },
      ),
      GoRoute(
        path: AppRoutes.gpxLoader,
        builder: (context, state) => const GpxLoaderScreen(),
      ),
    ],
  );
}
