import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:my_flutter_app/presentation/features/home/widgets/bottom_nav_bar.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/home_header.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/stage_progress.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/today_stage_card.dart';
import 'package:my_flutter_app/presentation/features/shared/widgets/ui_divider.dart';
import 'package:my_flutter_app/presentation/router/app_router.dart';

/// Home Screen
///
/// The main screen of the app, displaying recent route information and progress.
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Define start and end point locations
    const startLocation =
        latlong2.LatLng(43.1634, -1.2374); // Saint Jean Pied de Port
    const endLocation = latlong2.LatLng(43.0096, -1.3195); // Roncesvalles

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header (profile information)
              const HomeHeader(
                username: 'Pilgrim',
                currentDay: 3,
                welcomeMessage:
                    'Plan your Santiago pilgrimage journey with ease',
              ),

              // Divider
              const UiDivider(),

              // Today's stage information
              TodayStageCard(
                fromLocation: 'Saint Jean',
                toLocation: 'Roncesvalles',
                startCoordinates: startLocation,
                endCoordinates: endLocation,
                distance: 25.0,
                estimatedHours: 6,
                onTapStart: () =>
                    _navigateToLocation(context, startLocation, 'Saint Jean'),
                onTapEnd: () =>
                    _navigateToLocation(context, endLocation, 'Roncesvalles'),
              ),

              // Progress status
              const StageProgress(
                progressPercentage: 38.5,
                stageTitle: "Stage 1: Saint Jean to Roncesvalles",
                currentKm: 9,
                totalKm: 25,
              ),

              const SizedBox(height: 10),
              const UiDivider(),

              // Additional information sections
              _buildRecommendedRoutes(),
              _buildPointsOfInterest(),
              _buildStageDetails(),
              _buildLandmarks(context),
              _buildElevationCard(context),

              const SizedBox(height: 80), // Bottom space for navigation bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildRecommendedRoutes() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recommended Routes",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Camino Frances (French Way): The most popular route, approximately 780km from Saint Jean to Santiago",
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Camino Portugues (Portuguese Way): Approximately 610km from Lisbon or Porto to Santiago",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsOfInterest() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Points of Interest",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPoiCard(
                "Cathedrals",
                Icons.church,
                "2 within 3km",
                Colors.amber[100]!,
              ),
              const SizedBox(width: 10),
              _buildPoiCard(
                "Accommodations",
                Icons.hotel,
                "3 within 5km",
                Colors.blue[100]!,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPoiCard(
                "Water Fountains",
                Icons.water_drop_outlined,
                "1 within 2km",
                Colors.cyan[100]!,
              ),
              const SizedBox(width: 10),
              _buildPoiCard(
                "Rest Areas",
                Icons.restaurant,
                "2 within 7km",
                Colors.green[100]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoiCard(
      String title, IconData icon, String description, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              description,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageDetails() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Stage Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Difficulty: Hard",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Terrain: Mountainous, crossing the Pyrenees",
                ),
                SizedBox(height: 4),
                Text(
                  "Elevation Change: +1,250m / -450m",
                ),
                SizedBox(height: 4),
                Text(
                  "Recommended Schedule: 1 day (start before sunrise)",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandmarks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Key Landmarks",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildLandmarkCard(
                  "Virgin of Biakorri",
                  "Statue at 8km",
                  const Color(0xFFE3F2FD),
                ),
                _buildLandmarkCard(
                  "Orisson",
                  "Albergue at 8km",
                  const Color(0xFFE8F5E9),
                ),
                _buildLandmarkCard(
                  "Roland's Fountain",
                  "Water at 15km",
                  const Color(0xFFF3E5F5),
                ),
                _buildLandmarkCard(
                  "Roncesvalles Monastery",
                  "Accommodation at 25km",
                  const Color(0xFFFFEBEE),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandmarkCard(String title, String description, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElevationCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Elevation Profile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Image.network(
              'https://via.placeholder.com/350x60?text=Elevation+Chart',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text('Elevation chart not available'),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saint Jean Pied de Port (640m)',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Text(
                'Roncesvalles (960m)',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToLocation(
      BuildContext context, latlong2.LatLng coords, String name) {
    context.go(AppRoutes.map);
    // TODO: Implement map location selection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to $name')),
    );
  }
}
