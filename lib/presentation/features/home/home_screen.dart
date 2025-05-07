import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/presentation/features/home/home_page.dart';

/// Home Screen
///
/// A container that wraps the Home Page component, simply rendering the home page.
/// This separation allows us to separate screen logic from UI logic.
class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const HomePage();
  }
}
