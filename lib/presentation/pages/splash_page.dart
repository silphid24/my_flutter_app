import 'package:flutter/material.dart';
import 'package:my_flutter_app/presentation/router/app_router.dart';
import 'package:my_flutter_app/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    try {
      // 실제 앱에서는 여기서 초기화 작업을 수행 (데이터 로드, 인증 상태 확인 등)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // 현재 사용자 확인
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;

      if (authState is Authenticated) {
        // 로그인된 사용자가 있으면 홈 화면으로 이동
        if (mounted) {
          debugPrint('이미 로그인된 사용자가 있습니다: ${authState.user.email}');
          context.go(AppRoutes.home);
        }
      } else {
        // 로그인된 사용자가 없으면 로그인 화면으로 이동
        if (mounted) {
          debugPrint('로그인 화면으로 이동합니다');
          context.go(AppRoutes.login);
        }
      }
    } catch (e) {
      debugPrint('스플래시 화면 오류: $e');
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 이미지 (실제 이미지 파일이 없으므로 아이콘으로 대체)
            const Icon(Icons.hiking, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'Camino de Santiago',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Ultimate Pilgrim Companion',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
