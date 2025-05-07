import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:my_flutter_app/models/track.dart';
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/home_header.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/stage_progress.dart';
import 'package:my_flutter_app/presentation/features/home/widgets/today_stage_card.dart';
import 'package:my_flutter_app/presentation/features/shared/widgets/ui_divider.dart';
import 'package:my_flutter_app/presentation/router/app_router.dart';

/// 홈 페이지 콘텐츠
///
/// 홈 화면의 주요 콘텐츠를 표시하는 위젯입니다.
/// 현재 경로 정보, 진행 상황 등을 보여줍니다.
class HomePageContent extends HookConsumerWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrack = useState<Track?>(null);

    // 초기화 시 현재 트랙 로드
    useEffect(() {
      _loadCurrentTrack(currentTrack);
      return null;
    }, []);

    // 시작점과 도착점 위치 정의
    const startLocation =
        latlong2.LatLng(43.1634, -1.2374); // Saint Jean Pied de Port
    const endLocation = latlong2.LatLng(43.0096, -1.3195); // Roncesvalles

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildDivider(),
            _buildTodaysStage(context, startLocation, endLocation),
            _buildStageProgress(context),
            const SizedBox(height: 10),
            _buildDivider(),
            _buildRecommendedRoutes(),
            _buildPointsOfInterest(),
            _buildStageDetails(),
            _buildLandmarks(context),
            _buildElevationCard(context),
            const SizedBox(height: 80), // Bottom space for navigation bar
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

  Widget _buildTodaysStage(BuildContext context, latlong2.LatLng startLocation,
      latlong2.LatLng endLocation) {
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
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToLocation(
                          context, startLocation, 'Saint Jean'),
                      child: const Text(
                        'Saint Jean',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
                      onTap: () => _navigateToLocation(
                          context, endLocation, 'Roncesvalles'),
                      child: const Text(
                        'Roncesvalles',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '27km',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Distance',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  const Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '8h',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  const Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Hard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Difficulty',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Will navigate to the stages map screen focused on this stage
                        context.push('/full_camino_map', extra: {
                          'location': startLocation,
                          'name': 'Saint Jean Pied de Port'
                        });
                      },
                      icon: const Icon(Icons.map, size: 16),
                      label: const Text('Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // 상세 경로 정보 페이지로 이동
                        context.push('/routes/stage1');
                      },
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
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
    // 전체 스테이지 데이터
    final totalStages = 33; // 프랑스 길 기준
    final completedStages = 2; // 사용자가 완료한 스테이지
    final currentStage = 3; // 현재 스테이지
    final progressPercentage = (completedStages / totalStages) * 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Progress:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${progressPercentage.toStringAsFixed(1)}% complete',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completedStages / totalStages,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 14),
              children: [
                const TextSpan(text: 'You are on Stage '),
                TextSpan(
                  text: '$currentStage',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                TextSpan(text: ' of $totalStages'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: List.generate(
              5,
              (index) => Chip(
                backgroundColor: index < completedStages
                    ? Colors.green[100]
                    : Colors.grey[300],
                label: Text(
                  'Stage ${index + 1}',
                  style: TextStyle(
                    color: index < completedStages
                        ? Colors.green[800]
                        : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                avatar: index < completedStages
                    ? const Icon(Icons.check_circle,
                        color: Colors.green, size: 16)
                    : index == completedStages
                        ? const Icon(Icons.directions_walk,
                            color: Colors.blue, size: 16)
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedRoutes() {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Routes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                4,
                (index) => _buildRouteCard(
                  'Camino Francés',
                  '800km - Most Popular',
                  'assets/images/camino_frances.jpg',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(String title, String subtitle, String imagePath) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Container(
              height: 100,
              color: Colors.blue.withOpacity(0.2), // placeholder
              alignment: Alignment.center,
              child: const Icon(Icons.photo, size: 40, color: Colors.blue),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsOfInterest() {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Points of Interest Nearby',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPOICard(
                  'Santiago Cathedral',
                  'Famous landmark',
                  Icons.church,
                ),
                _buildPOICard(
                  'Albergue San Marcos',
                  'Hostel',
                  Icons.hotel,
                ),
                _buildPOICard(
                  'Restaurant El Peregrino',
                  'Food',
                  Icons.restaurant,
                ),
                _buildPOICard(
                  'Pilgrim Statue',
                  'Monument',
                  Icons.emoji_nature,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPOICard(String title, String category, IconData icon) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '2.3 km away',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageDetails() {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Stage Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.directions_walk, color: Colors.blue),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Saint-Jean-Pied-de-Port to Roncesvalles',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is one of the most challenging stages of the entire Camino Frances. The route crosses the Pyrenees from France into Spain, with spectacular views and significant elevation change.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailItem(Icons.terrain, '1,400m', 'Elevation'),
                    _buildDetailItem(Icons.water_drop, '6', 'Water Sources'),
                    _buildDetailItem(Icons.hotel, '1', 'Albergues'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[700], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLandmarks(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Landmarks',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildLandmarkItem(
                  'Virgin of Orisson',
                  '8km from start',
                  'Statue',
                ),
                const Divider(height: 1),
                _buildLandmarkItem(
                  'Roland\'s Cross',
                  '20km from start',
                  'Monument',
                ),
                const Divider(height: 1),
                _buildLandmarkItem(
                  'Roncesvalles Monastery',
                  '27km from start',
                  'Historic Site',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandmarkItem(String name, String distance, String type) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.place, color: Colors.blue, size: 20),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        '$type • $distance',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      dense: true,
    );
  }

  Widget _buildElevationCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Elevation Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Container(
                  height: 100,
                  color: Colors.grey[100],
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width - 48, 100),
                    painter: ElevationPainter(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(
                        'St. Jean (600m)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        'Col de Lepoeder (1,430m)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Text(
                        'Roncesvalles (900m)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
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

  void _navigateToLocation(
      BuildContext context, latlong2.LatLng location, String name) {
    // Map 화면으로 이동하고 location과 name을 추가 데이터로 전달
    context.push('/map', extra: {'location': location, 'name': name});
  }

  // 현재 트랙 로드 함수
  Future<void> _loadCurrentTrack(ValueNotifier<Track?> currentTrack) async {
    final gpxService = GpxService();
    try {
      final track = await gpxService
          .loadGpxFromAsset('assets/data/Stage-1-Camino-Frances.gpx');
      currentTrack.value = track;
    } catch (e) {
      debugPrint('트랙 로드 중 오류: $e');
    }
  }
}

// 고도 프로필을 그리는 커스텀 페인터
class ElevationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 경로 정의
    final path = Path();

    // 시작점 (좌측 하단에서 시작)
    path.moveTo(0, size.height * 0.7);

    // 중간 지점 (피레네 산맥 봉우리)
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.2, // 첫 번째 제어점
      size.width * 0.45, size.height * 0.1, // 첫 번째 종료점 (봉우리)
    );

    // 하강
    path.quadraticBezierTo(
      size.width * 0.6, size.height * 0.3, // 두 번째 제어점
      size.width * 0.7, size.height * 0.4, // 두 번째 종료점
    );

    // 마지막 상승-하강
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.3, // 세 번째 제어점
      size.width * 0.9, size.height * 0.5, // 세 번째 종료점
    );

    // 끝점
    path.quadraticBezierTo(
      size.width * 0.95, size.height * 0.55, // 네 번째 제어점
      size.width, size.height * 0.5, // 네 번째 종료점
    );

    // 영역을 채우기 위해 하단으로 확장
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // 채우기 그라데이션
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.blue.shade300,
        Colors.blue.shade100.withOpacity(0.3),
      ],
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    // 경로 채우기
    canvas.drawPath(path, paint);

    // 윤곽선 그리기
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue.shade500
      ..strokeWidth = 2;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
