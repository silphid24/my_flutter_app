import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/screens/stages_map_screen.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildDivider(),
              _buildTodaysStage(),
              _buildStageProgress(context),
              const SizedBox(height: 10),
              _buildDivider(),
              _buildRecommendedRoutes(),
              _buildPointsOfInterest(),
              _buildStageDetails(),
              const SizedBox(height: 80), // Bottom space for navigation bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: true,
            ),
            _buildNavItem(
              icon: Icons.map,
              label: 'Map',
              onTap: () {
                context.go('/map');
              },
            ),
            _buildNavItem(
              icon: Icons.people,
              label: 'Community',
              onTap: () {
                context.go('/community');
              },
            ),
            _buildNavItem(
              icon: Icons.info,
              label: 'Info',
              onTap: () {
                context.go('/info');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black.withOpacity(0.75),
            child: CircleAvatar(
              radius: 21,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 30),
              // backgroundImage: for when the actual image file is available
              // backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Pilgrim!           Day 3',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Plan your Santiago pilgrimage journey with ease',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFF979797),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildTodaysStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12, top: 10),
          child: Text(
            "Today's Stage:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      'Saint Jean',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 30),
                  const Expanded(
                    child: Text(
                      'Roncesvalles',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStageProgress(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DEF8),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.7, // 70% progress
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C7BE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Positioned(
                right: 0,
                child: Text(
                  '33.5km',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              const Positioned(
                left: 0,
                child: Text(
                  '0km',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.5 - 60,
                child: Row(
                  children: const [
                    Icon(Icons.arrow_forward, size: 16),
                    Text(
                      '24.8km',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedRoutes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Recommended Route',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildRouteCard(
                  title: 'Route 1',
                  description:
                      'Distance: 20km, Terrain: Moderate, Est. Time: 5 days',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRouteCard(
                  title: 'Route 2',
                  description:
                      'Distance: 30km, Terrain: Difficult, Est. Time: 7 days',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard({required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsOfInterest() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildDivider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: const [
                  Text(
                    'Town',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
              Column(
                children: const [
                  Text(
                    'Church',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
              Column(
                children: const [
                  Text(
                    'Town',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
              Column(
                children: const [
                  Text(
                    'Statue',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPointOfInterestMarker(isCurrentLocation: true),
              _buildPointOfInterestMarker(distance: '2.5km'),
              _buildPointOfInterestMarker(distance: '3.1km'),
              _buildPointOfInterestMarker(distance: '6.1km'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointOfInterestMarker(
      {bool isCurrentLocation = false, String? distance}) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrentLocation
                ? const Color(0xFF007AFF)
                : Colors.transparent,
            border: Border.all(
              color: isCurrentLocation ? const Color(0xFF007AFF) : Colors.black,
            ),
          ),
          child: isCurrentLocation
              ? const Icon(Icons.home, color: Colors.white, size: 17)
              : const Icon(Icons.location_on, color: Colors.black, size: 20),
        ),
        if (distance != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              distance,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStageDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  height: 170,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text('Route Image'),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black.withOpacity(0.6),
                    child: const Text(
                      '▲ 650m, Climb \n▼ 300m, Descent',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Difficulty:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '(Moderate)',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star_border),
                        Icon(Icons.star_border),
                        Icon(Icons.star_border),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text(
                      'Duration:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '7 Hours & 35 Min',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text(
                      'Terrain:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Rocky, Steep',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.black54,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
