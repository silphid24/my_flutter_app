import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/models/route_model.dart';
import 'package:my_flutter_app/presentation/features/shared/layout/app_scaffold.dart';

/// Route Detail Screen
///
/// Displays detailed information for a selected pilgrim route.
class RouteDetailScreen extends ConsumerWidget {
  final PilgrimRoute route;

  const RouteDetailScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      currentIndex: 0,
      appBar: AppBar(title: Text(route.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Route ID:', route.id),
                    _buildInfoRow('Distance:', '${route.distance} km'),
                    _buildInfoRow(
                        'Difficulty:', _getDifficultyText(route.difficulty)),
                    _buildInfoRow('Season:', route.season),
                    _buildInfoRow(
                        'Status:', route.mapped ? 'Mapped' : 'Not mapped'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Towns and Cities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: route.towns.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text('${index + 1}. '),
                              Text(route.towns[index]),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(route.description ?? 'No description available.'),
                  ],
                ),
              ),
            ),
            if (route.notes != null && route.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(route.notes!),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Moderate';
      case 3:
        return 'Challenging';
      case 4:
        return 'Difficult';
      case 5:
        return 'Very Difficult';
      default:
        return 'Unknown';
    }
  }
}
