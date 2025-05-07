import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/presentation/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // 앱 종료 이중 확인
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return AlertDialog(
              title: Text(l10n.exitConfirm),
              content: Text(l10n.exitConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.exit),
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
        // Localization 설정
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English - 기본
          Locale('es', ''), // Spanish
          Locale('de', ''), // German
          Locale('ko', ''), // Korean
          Locale('zh', ''), // Chinese
          Locale('ja', ''), // Japanese
        ],
        // 영어를 기본 언어로 설정
        locale: const Locale('en'),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}
