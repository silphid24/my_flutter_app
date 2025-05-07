import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong2;

/// 오늘의 스테이지 정보를 표시하는 위젯
///
/// 출발지와 목적지 정보, 거리, 예상 소요시간을 표시합니다.
class TodayStageCard extends StatelessWidget {
  final String fromLocation;
  final String toLocation;
  final latlong2.LatLng startCoordinates;
  final latlong2.LatLng endCoordinates;
  final double distance;
  final int estimatedHours;
  final VoidCallback? onTapStart;
  final VoidCallback? onTapEnd;

  const TodayStageCard({
    super.key,
    required this.fromLocation,
    required this.toLocation,
    required this.startCoordinates,
    required this.endCoordinates,
    this.distance = 25.0,
    this.estimatedHours = 6,
    this.onTapStart,
    this.onTapEnd,
  });

  @override
  Widget build(BuildContext context) {
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
              _buildLocationRow(),
              const SizedBox(height: 12),
              _buildDetailRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTapStart,
            child: Text(
              fromLocation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const Icon(Icons.arrow_forward, size: 30),
        Expanded(
          child: GestureDetector(
            onTap: onTapEnd,
            child: Text(
              toLocation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDetailItem(
          icon: Icons.straighten,
          label: '거리',
          value: '$distance km',
        ),
        const SizedBox(width: 20),
        _buildDetailItem(
          icon: Icons.access_time,
          label: '예상 소요 시간',
          value: '$estimatedHours 시간',
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.blue[800]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
