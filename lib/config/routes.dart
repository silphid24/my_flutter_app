import 'package:flutter/material.dart';
import 'package:my_flutter_app/login_screen.dart';
import 'package:my_flutter_app/presentation/pages/auth/signup_page.dart';
import 'package:my_flutter_app/presentation/pages/home/home_page.dart';
import 'package:my_flutter_app/presentation/pages/map/map_page.dart'
    as mapModule;
import 'package:my_flutter_app/presentation/pages/community/community_page.dart'
    as communityModule;
import 'package:my_flutter_app/presentation/pages/info/info_page.dart'
    as infoModule;
import 'package:my_flutter_app/presentation/pages/profile/profile_page.dart';
import 'package:my_flutter_app/presentation/pages/routes/route_list_page.dart';
import 'package:my_flutter_app/presentation/pages/splash_page.dart';
import 'package:my_flutter_app/screens/route_list_screen.dart';
import 'package:my_flutter_app/screens/track_map_screen.dart';
import 'package:my_flutter_app/screens/gpx_loader_screen.dart';
import 'package:my_flutter_app/screens/camino_map_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String map = '/map';
  static const String community = '/community';
  static const String info = '/info';
  static const String profile = '/profile';
  static const String routes = '/routes';
  static const String trackMap = '/track_map';
  static const String gpxLoader = '/gpx_loader';
  static const String caminoMap = '/camino_map';
  static const String fullCaminoMap = '/full_camino_map';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case map:
        return MaterialPageRoute(builder: (_) => const mapModule.MapPage());
      case community:
        return MaterialPageRoute(
          builder: (_) => const communityModule.CommunityPage(),
        );
      case info:
        return MaterialPageRoute(builder: (_) => const infoModule.InfoPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case routes:
        return MaterialPageRoute(builder: (_) => const RouteListScreen());
      case trackMap:
        String? trackId;
        if (settings.arguments != null) {
          trackId =
              (settings.arguments as Map<String, dynamic>)['trackId']
                  as String?;
        }
        return MaterialPageRoute(
          builder: (_) => TrackMapScreen(trackId: trackId),
        );
      case gpxLoader:
        return MaterialPageRoute(builder: (_) => const GpxLoaderScreen());
      case caminoMap:
        return MaterialPageRoute(builder: (_) => const CaminoMapScreen());
      case fullCaminoMap:
        return MaterialPageRoute(
          builder: (_) => const CaminoMapScreen(useGoogleMaps: true),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
