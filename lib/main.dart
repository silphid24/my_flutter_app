import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/data/repositories/auth_repository_impl.dart';
import 'package:my_flutter_app/data/repositories/location_repository_impl.dart';
import 'package:my_flutter_app/domain/repositories/auth_repository.dart';
import 'package:my_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:my_flutter_app/presentation/bloc/map_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/presentation/app.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart' as provider;

// 웹용 임포트 - 조건부 임포트로 처리
import 'web_imports.dart' if (dart.library.io) 'mobile_imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 앱 시작 시간 기록 (성능 추적용)
  final startTime = DateTime.now();

  // 플랫폼에 맞는 초기화 수행
  if (kIsWeb) {
    try {
      // 웹 환경 초기화 (오류 처리 강화)
      print(
        '웹 환경 초기화 시작: ${DateTime.now().difference(startTime).inMilliseconds}ms',
      );

      // Google Maps 초기화
      initializeGoogleMapsForWeb();

      // 데이터베이스 초기화
      initializeDatabaseForWeb();

      print(
        '웹 환경 초기화 완료: ${DateTime.now().difference(startTime).inMilliseconds}ms',
      );
    } catch (e) {
      print('웹 초기화 중 오류 발생: $e');
    }
  } else {
    try {
      // 모바일 환경 초기화
      print('모바일 환경 초기화 시작');
      initializeDatabaseForMobile();
      print('모바일 환경 초기화 완료');
    } catch (e) {
      print('모바일 초기화 중 오류 발생: $e');
    }
  }

  // GPX 서비스 초기화 - 웹에서는 지연시간 감소
  try {
    if (kIsWeb) {
      // 웹에서는 메인 스레드 차단을 피하기 위해 비동기 초기화
      Future.microtask(() async {
        try {
          await GpxService().initializeDatabase();
          print(
            'GPX 데이터베이스 초기화 완료: ${DateTime.now().difference(startTime).inMilliseconds}ms',
          );
        } catch (e) {
          print('GPX 데이터베이스 초기화 중 오류 발생: $e');
        }
      });
    } else {
      // 모바일에서는 동기 초기화
      await GpxService().initializeDatabase();
      print('GPX 데이터베이스 초기화 완료');
    }
  } catch (e) {
    print('GPX 데이터베이스 초기화 중 오류 발생: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  print('앱 시작 준비 완료: ${DateTime.now().difference(startTime).inMilliseconds}ms');

  // Firebase 초기화
  try {
    await Firebase.initializeApp();
    print('Firebase 초기화 완료');
  } catch (e) {
    print('Firebase 초기화 오류: $e');
  }

  final authRepository = AuthRepositoryImpl();
  final locationRepository = LocationRepositoryImpl();

  // 자동 로그인 확인 및 시도
  final isAutoLoginEnabled = await authRepository.isAutoLoginEnabled();
  if (isAutoLoginEnabled) {
    try {
      await authRepository.loadSavedUser();
    } catch (e) {
      debugPrint('자동 로그인 실패: $e');
    }
  }

  runApp(
    // 먼저 Provider 레벨에서 Repository를 제공
    provider.MultiProvider(
      providers: [
        provider.Provider<AuthRepository>(
          create: (context) => authRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: authRepository)..add(AppStarted()),
          ),
          BlocProvider<MapBloc>(
            create: (context) =>
                MapBloc(locationRepository: locationRepository),
          ),
        ],
        child: const ProviderScope(child: MyApp()),
      ),
    ),
  );
}
