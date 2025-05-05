import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/config/routes.dart';
import 'package:my_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:my_flutter_app/presentation/pages/map/map_page.dart';
import 'package:my_flutter_app/presentation/pages/community/community_page.dart';
import 'package:my_flutter_app/presentation/pages/info/info_page.dart';
import 'package:my_flutter_app/domain/repositories/location_repository.dart';
import 'package:my_flutter_app/services/gpx_service.dart';
import 'package:my_flutter_app/models/track.dart';
import 'package:my_flutter_app/presentation/bloc/map_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_app/screens/camino_map_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Track? _currentTrack;
  final double _progressValue = 0.72; // 진행률 예시 (0.0 ~ 1.0 사이)
  final int _currentDay = 3; // 현재 날짜 예시

  // 시작점과 도착점 위치 정의
  final LatLng _startLocation = const LatLng(
    43.1634,
    -1.2374,
  ); // Saint Jean Pied de Port
  final LatLng _endLocation = const LatLng(43.0096, -1.3195); // Roncesvalles

  @override
  void initState() {
    super.initState();
    _loadCurrentTrack();
  }

  Future<void> _loadCurrentTrack() async {
    try {
      final gpxService = GpxService();
      final track = await gpxService.loadGpxFromAsset(
        'assets/data/Stage-1-Camino-Frances.gpx',
      );

      if (mounted) {
        setState(() {
          _currentTrack = track;
        });
      }
    } catch (e) {
      print('트랙 로드 오류: $e');
    }
  }

  // 특정 위치로 맵 이동 후 지도 화면으로 전환하는 메서드
  void _navigateToLocation(LatLng location, String locationName) {
    // 맵 블록에 위치 업데이트 이벤트 전송
    context.read<MapBloc>().add(UpdateSelectedLocation(location, locationName));

    // 지도 화면으로 전환
    setState(() {
      _selectedIndex = 1;
    });
  }

  // 현재 위치로 이동하는 메서드
  void _navigateToCurrentLocation() {
    // 맵 블록에 현재 위치로 이동 이벤트 전송
    context.read<MapBloc>().add(FocusOnCurrentLocation());

    // 지도 화면으로 전환
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Camino de Santiago'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LoggedOut());
              },
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: _selectedIndex == 0 ? _buildHomeContent() : _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Text('🏠', style: TextStyle(fontSize: 20)),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Text('🗺️', style: TextStyle(fontSize: 20)),
              label: '지도',
            ),
            BottomNavigationBarItem(
              icon: Text('👥', style: TextStyle(fontSize: 20)),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Text('ℹ️', style: TextStyle(fontSize: 20)),
              label: '더보기',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black.withOpacity(0.5),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Camino de Santiago',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('순례길 지도'),
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('순례자 프로필'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.route),
            title: const Text('순례길 목록'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(AppRoutes.routes);
            },
          ),
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('GPX 경로 지도'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(AppRoutes.gpxLoader);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('카미노 지도 (GPS 트래킹)'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(AppRoutes.caminoMap);
            },
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('프랑스길 전체 지도'),
            subtitle: const Text('Saint-Jean → Santiago'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(AppRoutes.fullCaminoMap);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('앱 정보'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 20),
            _buildTodayStage(),
            const SizedBox(height: 20),
            _buildProgressBar(),
            const SizedBox(height: 30),
            _buildRecommendedRoutes(),
            const SizedBox(height: 20),
            _buildLandmarks(),
            const SizedBox(height: 20),
            _buildStageDetails(),
            const SizedBox(height: 20),
            _buildElevationCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.black.withOpacity(0.75),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: const NetworkImage('https://picsum.photos/200'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '환영합니다, 순례자님!           Day $_currentDay',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '산티아고 순례길을 쉽게 계획하세요',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 구간:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => _navigateToLocation(_startLocation, 'Saint Jean'),
                child: const Text(
                  'Saint Jean',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => _navigateToLocation(_endLocation, 'Roncesvalles'),
                child: const Text(
                  'Roncesvalles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _navigateToCurrentLocation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progressValue,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8DEF8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00C7BE),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '0km',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '24.8km',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '33.5km',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendedRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '모든 스테이지',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.fullCaminoMap);
              },
              child: const Text('전체 지도 보기'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(height: 180, child: _buildStagesList()),
      ],
    );
  }

  Widget _buildStagesList() {
    final List<Map<String, dynamic>> stages = [
      {
        'number': 1,
        'start': 'Saint-Jean-Pied-de-Port',
        'end': 'Roncesvalles',
        'distance': 25,
        'difficulty': '어려움',
        'filename': 'Stage-1-Camino-Frances.gpx',
      },
      {
        'number': 2,
        'start': 'Roncesvalles',
        'end': 'Zubiri',
        'distance': 22,
        'difficulty': '보통',
        'filename': 'Stage-2.-Camino-Frances.gpx',
      },
      {
        'number': 3,
        'start': 'Zubiri',
        'end': 'Pamplona',
        'distance': 21,
        'difficulty': '쉬움',
      },
      {
        'number': 4,
        'start': 'Pamplona',
        'end': 'Puente la Reina',
        'distance': 24,
        'difficulty': '보통',
      },
      {
        'number': 5,
        'start': 'Puente la Reina',
        'end': 'Estella',
        'distance': 22,
        'difficulty': '보통',
      },
      {
        'number': 6,
        'start': 'Estella',
        'end': 'Los Arcos',
        'distance': 21,
        'difficulty': '보통',
      },
      {
        'number': 7,
        'start': 'Los Arcos',
        'end': 'Logroño',
        'distance': 28,
        'difficulty': '보통',
      },
      {
        'number': 8,
        'start': 'Logroño',
        'end': 'Nájera',
        'distance': 29,
        'difficulty': '보통',
      },
      {
        'number': 9,
        'start': 'Nájera',
        'end': 'Santo Domingo de la Calzada',
        'distance': 21,
        'difficulty': '쉬움',
      },
      {
        'number': 10,
        'start': 'Santo Domingo de la Calzada',
        'end': 'Belorado',
        'distance': 23,
        'difficulty': '쉬움',
      },
      {
        'number': 11,
        'start': 'Belorado',
        'end': 'San Juan de Ortega',
        'distance': 24,
        'difficulty': '어려움',
      },
      {
        'number': 12,
        'start': 'San Juan de Ortega',
        'end': 'Burgos',
        'distance': 26,
        'difficulty': '보통',
      },
      {
        'number': 13,
        'start': 'Burgos',
        'end': 'Hontanas',
        'distance': 32,
        'difficulty': '보통',
      },
      {
        'number': 14,
        'start': 'Hontanas',
        'end': 'Boadilla del Camino',
        'distance': 28,
        'difficulty': '보통',
      },
      {
        'number': 15,
        'start': 'Boadilla del Camino',
        'end': 'Carrión de los Condes',
        'distance': 25,
        'difficulty': '쉬움',
      },
      {
        'number': 16,
        'start': 'Carrión de los Condes',
        'end': 'Terradillos de los Templarios',
        'distance': 27,
        'difficulty': '보통',
      },
      {
        'number': 17,
        'start': 'Terradillos de los Templarios',
        'end': 'El Burgo Ranero',
        'distance': 31,
        'difficulty': '보통',
      },
      {
        'number': 18,
        'start': 'El Burgo Ranero',
        'end': 'León',
        'distance': 37,
        'difficulty': '보통',
      },
      {
        'number': 19,
        'start': 'León',
        'end': 'San Martín del Camino',
        'distance': 25,
        'difficulty': '쉬움',
      },
      {
        'number': 20,
        'start': 'San Martín del Camino',
        'end': 'Astorga',
        'distance': 24,
        'difficulty': '쉬움',
      },
      {
        'number': 21,
        'start': 'Astorga',
        'end': 'Rabanal del Camino',
        'distance': 21,
        'difficulty': '보통',
      },
      {
        'number': 22,
        'start': 'Rabanal del Camino',
        'end': 'Ponferrada',
        'distance': 32,
        'difficulty': '어려움',
      },
      {
        'number': 23,
        'start': 'Ponferrada',
        'end': 'Villafranca del Bierzo',
        'distance': 24,
        'difficulty': '쉬움',
      },
      {
        'number': 24,
        'start': 'Villafranca del Bierzo',
        'end': 'O Cebreiro',
        'distance': 30,
        'difficulty': '매우 어려움',
      },
      {
        'number': 25,
        'start': 'O Cebreiro',
        'end': 'Triacastela',
        'distance': 21,
        'difficulty': '보통',
      },
      {
        'number': 26,
        'start': 'Triacastela',
        'end': 'Sarria',
        'distance': 18,
        'difficulty': '쉬움',
      },
      {
        'number': 27,
        'start': 'Sarria',
        'end': 'Portomarín',
        'distance': 23,
        'difficulty': '쉬움',
      },
      {
        'number': 28,
        'start': 'Portomarín',
        'end': 'Palas de Rei',
        'distance': 25,
        'difficulty': '보통',
      },
      {
        'number': 29,
        'start': 'Palas de Rei',
        'end': 'Arzúa',
        'distance': 29,
        'difficulty': '보통',
      },
      {
        'number': 30,
        'start': 'Arzúa',
        'end': 'O Pedrouzo',
        'distance': 19,
        'difficulty': '쉬움',
      },
      {
        'number': 31,
        'start': 'O Pedrouzo',
        'end': 'Santiago de Compostela',
        'distance': 20,
        'difficulty': '쉬움',
      },
      {
        'number': 32,
        'start': 'Santiago de Compostela',
        'end': 'Negreira',
        'distance': 21,
        'difficulty': '보통',
      },
      {
        'number': 33,
        'start': 'Negreira',
        'end': 'Olveiroa',
        'distance': 33,
        'difficulty': '보통',
      },
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: stages.length,
      itemBuilder: (context, index) {
        final stage = stages[index];
        // 파일 경로 생성 (번호에 따라)
        String gpxFilename = '';
        if (index + 1 == 27 || index + 1 == 28) {
          gpxFilename = 'Stages-27-28.-Camino-Frances.gpx';
        } else if (index + 1 == 1) {
          gpxFilename = 'Stage-1-Camino-Frances.gpx';
        } else {
          gpxFilename = 'Stage-${index + 1}.-Camino-Frances.gpx';
        }

        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {
              // 스테이지 카드 터치 시 해당 스테이지 지도로 이동
              _navigateToStageMap(gpxFilename);
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '스테이지 ${stage['number']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stage['start']} →',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${stage['end']}',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '거리: ${stage['distance']}km',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '난이도: ${stage['difficulty']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getDifficultyColor(stage['difficulty']),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.map_outlined,
                        size: 16,
                        color: Colors.blue[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '쉬움':
        return Colors.green;
      case '보통':
        return Colors.orange;
      case '어려움':
        return Colors.red;
      case '매우 어려움':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  Widget _buildLandmarks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 39,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 3),
                    ),
                    child: Center(
                      child: Container(
                        width: 23,
                        height: 23,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Town',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(width: 25),
              Text('2.5km'),
              const SizedBox(width: 25),
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2),
                    ),
                  ),
                  const Text(
                    'Church',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(width: 25),
              Text('3.1km'),
              const SizedBox(width: 25),
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2),
                    ),
                  ),
                  const Text(
                    'Town',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(width: 25),
              Text('6.1km'),
              const SizedBox(width: 10),
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2),
                    ),
                  ),
                  const Text(
                    'Statue',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStageDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text(
                    '난이도:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Text('(보통)', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        color: index < 3 ? Colors.amber : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  Text(
                    '소요 시간:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Text('7시간 35분', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  Text(
                    '지형:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Text('바위, 가파름', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevationCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Image.network(
              'https://picsum.photos/344/168',
              height: 168,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  Text(
                    '▲ 650m, 오르막',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '▼ 300m, 내리막',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 스테이지 지도로 이동하는 메서드
  void _navigateToStageMap(String gpxFilename) async {
    // 데이터베이스에서 트랙 데이터 생성 또는 획득을 위한 gpxService 인스턴스
    final gpxService = GpxService();

    // 에셋 경로
    final assetPath = 'assets/data/$gpxFilename';

    try {
      // 미리 로드하고 저장하여 트랙 ID 획득
      final track = await gpxService.loadGpxFromAsset(assetPath);

      if (track != null) {
        // 이 트랙 ID로 CaminoMapScreen으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CaminoMapScreen(
                  trackId: track.id,
                  useGoogleMaps: true, // Google Maps 사용
                ),
          ),
        );
      } else {
        // 트랙 로드 실패 시 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('스테이지 데이터를 불러올 수 없습니다.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('스테이지 로드 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('스테이지 데이터 로드 중 오류가 발생했습니다.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const MapPage();
      case 2:
        return const CommunityPage();
      case 3:
        return const InfoPage();
      case 0:
      default:
        return _buildHomeContent();
    }
  }
}
