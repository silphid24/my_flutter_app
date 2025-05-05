import 'package:flutter/material.dart';
import 'package:my_flutter_app/screens/home_screen.dart';
import 'package:my_flutter_app/screens/stages_map_screen.dart';
import 'package:my_flutter_app/screens/community/community_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final List<InfoCategory> _categories = [
    InfoCategory(
      title: '카미노 프랑세스 소개',
      icon: Icons.hiking,
      description: '프랑스 길(Camino Francés)은 가장 인기있는 카미노 데 산티아고 경로입니다.',
      items: [
        InfoItem(
          title: '카미노 프랑세스란?',
          content:
              '카미노 프랑세스는 프랑스에서 시작하여 스페인 북부를 가로질러 산티아고 데 콤포스텔라까지 이어지는 약 800km의 순례길입니다. 매년 수만 명의 순례자들이 다양한 이유로 이 길을 걷습니다.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?camino,pilgrimage',
        ),
        InfoItem(
          title: '역사',
          content:
              '이 순례길의 역사는 9세기로 거슬러 올라가며, 성 야고보의 무덤이 발견된 이후 크리스천들의 중요한 순례지가 되었습니다. 중세 시대에는 예루살렘, 로마와 함께 가장 중요한 크리스천 순례지 중 하나였습니다.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?history,medieval',
        ),
        InfoItem(
          title: '주요 도시',
          content:
              '생 장 피에 드 포르, 팜플로나, 로그로뇨, 부르고스, 레온, 폰페라다, 산티아고 데 콤포스텔라 등 역사적인 도시들을 통과합니다.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?santiago,spain',
        ),
      ],
    ),
    InfoCategory(
      title: '순례자 여권 (Credential)',
      icon: Icons.bookmark,
      description: '순례자 여권은 카미노를 걷는 동안 공식 인증을 받기 위한 필수 문서입니다.',
      items: [
        InfoItem(
          title: '크레덴셜이란?',
          content:
              '순례자 여권(Credencial del Peregrino)은 순례자의 신분을 증명하고 순례 여정을 기록하는 공식 문서입니다. 이를 통해 알베르게(순례자 숙소)에 묵을 수 있는 자격을 얻습니다.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?passport,travel',
        ),
        InfoItem(
          title: '스탬프 수집',
          content:
              '순례 중 방문하는 알베르게, 성당, 카페 등에서 스탬프를 모을 수 있습니다. 산티아고에 도착하면 최소 100km(도보) 또는 200km(자전거)의 여정을 증명하는 스탬프를 보여주고 콤포스텔라(Compostela)를 발급받을 수 있습니다.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?stamp,collection',
        ),
      ],
    ),
    InfoCategory(
      title: '알베르게 정보',
      icon: Icons.hotel,
      description: '알베르게는 순례자들을 위한 특별한 숙소 시스템입니다.',
      items: [
        InfoItem(
          title: '알베르게 종류',
          content:
              '공립(Municipal): 가장 저렴하지만 기본적인 시설을 제공합니다.\n사립(Private): 조금 더 높은 가격이지만 더 좋은 시설과 서비스를 제공합니다.\n기부제(Donativo): 기부금으로 운영되는 숙소입니다.\n교회/수도원(Parroquial): 교회나 수도원에서 운영하는 숙소입니다.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?hostel,accommodation',
        ),
        InfoItem(
          title: '이용 방법',
          content:
              '대부분의 알베르게는 선착순이며, 오후 1-2시부터 체크인이 가능합니다. 순례자 여권을 보여주고 요금을 지불하면 침대가 배정됩니다. 일반적으로 1박만 가능하며, 다음날 아침에는 8-9시까지 퇴실해야 합니다.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?hostel,bedroom',
        ),
      ],
    ),
    InfoCategory(
      title: '준비물과 장비',
      icon: Icons.backpack,
      description: '가볍게 가는 것이 중요합니다. 배낭 무게는 체중의 10%를 넘지 않는 것이 좋습니다.',
      items: [
        InfoItem(
          title: '필수 장비',
          content:
              '편안한 하이킹 신발 또는 트레일 러닝화, 가벼운 배낭(30-40L), 날씨에 적합한 의류(방수 자켓, 퀵드라이 셔츠, 하이킹 바지 등), 침낭, 세면도구, 기본 응급 처치 키트, 물병, 선크림, 모자 등.',
          imageUrl: 'https://source.unsplash.com/random/800x600/?hiking,gear',
        ),
        InfoItem(
          title: '추천 앱',
          content:
              'Camino Ninja, Buen Camino, Wise Pilgrim 등의 앱은 경로, 알베르게 정보, 거리 계산 등 유용한 기능을 제공합니다.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?smartphone,app',
        ),
      ],
    ),
    InfoCategory(
      title: '건강과 안전',
      icon: Icons.healing,
      description: '긴 여정 동안 건강을 유지하는 것이 중요합니다.',
      items: [
        InfoItem(
          title: '물집 관리',
          content:
              '물집은 가장 흔한 문제입니다. 예방을 위해 편안한 신발과 양질의 양말을 착용하세요. 물집이 생기면 소독하고 특수 물집 패치(Compeed 등)를 사용하세요.',
          imageUrl: 'https://source.unsplash.com/random/800x600/?blister,foot',
        ),
        InfoItem(
          title: '날씨 대비',
          content:
              '계절에 따라 날씨가 크게 달라질 수 있습니다. 더위, 추위, 비 등에 대비하여 적절한 의류를 준비하세요. 여름에는 아침 일찍 출발하여 한낮의 더위를 피하는 것이 좋습니다.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?weather,hiking',
        ),
      ],
    ),
  ];

  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카미노 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('검색 기능은 개발 중입니다.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 카테고리 선택 영역
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = index == _selectedCategoryIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category.icon,
                          color:
                              isSelected ? Colors.blue : Colors.grey.shade700,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.blue.shade800
                                : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 카테고리 설명
          if (_selectedCategoryIndex < _categories.length)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _categories[_selectedCategoryIndex].description,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),

          // 선택된 카테고리의 정보 항목 목록
          Expanded(
            child: _selectedCategoryIndex < _categories.length
                ? ListView.builder(
                    itemCount: _categories[_selectedCategoryIndex].items.length,
                    itemBuilder: (context, index) {
                      final item =
                          _categories[_selectedCategoryIndex].items[index];
                      return _buildInfoCard(item);
                    },
                  )
                : const Center(
                    child: Text('카테고리를 선택해주세요.'),
                  ),
          ),
        ],
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
              onTap: () {
                context.go('/');
              },
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
              isSelected: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(InfoItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 150,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: const CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '이미지를 불러올 수 없습니다',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.content,
                  style: const TextStyle(fontSize: 14),
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

class InfoCategory {
  final String title;
  final IconData icon;
  final String description;
  final List<InfoItem> items;

  InfoCategory({
    required this.title,
    required this.icon,
    required this.description,
    required this.items,
  });
}

class InfoItem {
  final String title;
  final String content;
  final String imageUrl;

  InfoItem({
    required this.title,
    required this.content,
    required this.imageUrl,
  });
}
