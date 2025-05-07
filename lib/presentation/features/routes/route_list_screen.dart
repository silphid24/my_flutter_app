import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/models/route_model.dart';
import 'package:my_flutter_app/services/route_service.dart';
import 'package:my_flutter_app/presentation/features/routes/route_detail_screen.dart';
import 'package:my_flutter_app/presentation/features/shared/layout/app_scaffold.dart';

/// Route List Screen
///
/// Displays a list of pilgrim routes with search functionality.
class RouteListScreen extends ConsumerStatefulWidget {
  const RouteListScreen({super.key});

  @override
  ConsumerState<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends ConsumerState<RouteListScreen> {
  final RouteService _routeService = RouteService();
  List<PilgrimRoute> _routes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final routes = await _routeService.loadRoutes();
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading routes: $e');
    }
  }

  Future<void> _searchRoutes(String query) async {
    if (query == _searchQuery) return;

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final routes = await _routeService.searchRoutes(query);
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error searching routes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 0,
      title: 'Pilgrim Routes',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRoutes),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search routes or cities',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchRoutes('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                _searchRoutes(value);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _routes.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No routes available.'
                              : 'No results found for \'$_searchQuery\'.',
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _routes.length,
                        itemBuilder: (context, index) {
                          final route = _routes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                route.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Route ID: ${route.id}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Cities: ${route.towns.take(3).join(', ')}${route.towns.length > 3 ? ' and ${route.towns.length - 3} more' : ''}',
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (route.distance != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Distance: ${route.distance!.toStringAsFixed(1)} km',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: route.mapped
                                  ? const Icon(Icons.map, color: Colors.green)
                                  : null,
                              onTap: () {
                                // Navigate to detail page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RouteDetailScreen(route: route),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
