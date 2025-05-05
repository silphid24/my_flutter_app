import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/config/routes.dart';
import 'package:my_flutter_app/config/theme.dart';
import 'package:my_flutter_app/data/repositories/auth_repository_impl.dart';
import 'package:my_flutter_app/data/repositories/location_repository_impl.dart';
import 'package:my_flutter_app/domain/repositories/auth_repository.dart';
import 'package:my_flutter_app/domain/repositories/location_repository.dart';
import 'package:my_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:my_flutter_app/presentation/bloc/map_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/camino_map_screen.dart';
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/presentation/app.dart';
import 'package:my_flutter_app/presentation/router/app_router.dart'
    as app_router;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'screens/stages_map_screen.dart';
import 'screens/home_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/info/info_screen.dart';
// import 'package:my_flutter_app/router/router.dart';

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
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: authRepository)..add(AppStarted()),
        ),
        BlocProvider<MapBloc>(
          create: (context) => MapBloc(locationRepository: locationRepository),
        ),
      ],
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(app_router.routerProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // 앱 종료 이중 확인
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('앱 종료'),
              content: const Text('카미노 앱을 종료하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('종료'),
                ),
              ],
            );
          },
        );
        if (shouldPop == true) {
          SystemNavigator.pop();
        }
      },
      child: MaterialApp.router(
        title: 'Camino de Santiago App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
