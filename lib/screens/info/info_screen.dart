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
      title: 'Camino Frances Introduction',
      icon: Icons.hiking,
      description:
          'The French Way (Camino Francés) is the most popular Camino de Santiago route.',
      items: [
        InfoItem(
          title: 'What is Camino Frances?',
          content:
              'The Camino Frances is an approximately 800km pilgrimage route starting in France and crossing northern Spain to Santiago de Compostela. Each year, tens of thousands of pilgrims walk this route for various reasons.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?camino,pilgrimage',
        ),
        InfoItem(
          title: 'History',
          content:
              'The history of this pilgrimage route dates back to the 9th century with the discovery of the tomb of St. James, and it became an important Christian pilgrimage site. In the Middle Ages, it was one of the most important Christian pilgrimage destinations along with Jerusalem and Rome.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?history,medieval',
        ),
        InfoItem(
          title: 'Major Cities',
          content:
              'The route passes through historic cities such as Saint-Jean-Pied-de-Port, Pamplona, Logroño, Burgos, León, Ponferrada, and Santiago de Compostela.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?santiago,spain',
        ),
      ],
    ),
    InfoCategory(
      title: 'Pilgrim Credential',
      icon: Icons.bookmark,
      description:
          'The pilgrim passport is an essential document for receiving official certification during your Camino journey.',
      items: [
        InfoItem(
          title: 'What is a Credential?',
          content:
              'The pilgrim passport (Credencial del Peregrino) is an official document that proves your identity as a pilgrim and records your journey. It qualifies you to stay in albergues (pilgrim hostels).',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?passport,travel',
        ),
        InfoItem(
          title: 'Collecting Stamps',
          content:
              'You can collect stamps from albergues, churches, cafés, and other places you visit during your pilgrimage. Upon arrival in Santiago, you can show your stamps proving at least 100km (on foot) or 200km (by bicycle) of the journey to receive a Compostela certificate.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?stamp,collection',
        ),
      ],
    ),
    InfoCategory(
      title: 'Albergue Information',
      icon: Icons.hotel,
      description: 'Albergues are special accommodation systems for pilgrims.',
      items: [
        InfoItem(
          title: 'Types of Albergues',
          content:
              'Municipal: The most affordable but offering basic facilities.\nPrivate: Slightly more expensive but providing better facilities and services.\nDonativo: Accommodation run on donations.\nParochial: Accommodation operated by churches or monasteries.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?hostel,accommodation',
        ),
        InfoItem(
          title: 'How to Use',
          content:
              'Most albergues are first-come, first-served, with check-in available from 1-2 pm. Show your pilgrim passport and pay the fee to be assigned a bed. Generally, you can only stay for one night and must check out by 8-9 am the next morning.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?hostel,bedroom',
        ),
      ],
    ),
    InfoCategory(
      title: 'Gear and Equipment',
      icon: Icons.backpack,
      description:
          'Traveling light is important. Your backpack weight should not exceed 10% of your body weight.',
      items: [
        InfoItem(
          title: 'Essential Equipment',
          content:
              'Comfortable hiking shoes or trail running shoes, lightweight backpack (30-40L), weather-appropriate clothing (waterproof jacket, quick-dry shirts, hiking pants, etc.), sleeping bag, toiletries, basic first aid kit, water bottle, sunscreen, hat, etc.',
          imageUrl: 'https://source.unsplash.com/random/800x600/?hiking,gear',
        ),
        InfoItem(
          title: 'Recommended Apps',
          content:
              'Apps like Camino Ninja, Buen Camino, and Wise Pilgrim provide useful features such as route information, albergue details, distance calculations, etc.',
          imageUrl:
              'https://source.unsplash.com/random/800x600/?smartphone,app',
        ),
      ],
    ),
    InfoCategory(
      title: 'Health and Safety',
      icon: Icons.healing,
      description:
          'Maintaining your health during the long journey is important.',
      items: [
        InfoItem(
          title: 'Blister Management',
          content:
              'Blisters are the most common problem. Wear comfortable shoes and quality socks to prevent them. If blisters do form, disinfect them and use special blister patches (like Compeed).',
          imageUrl: 'https://source.unsplash.com/random/800x600/?blister,foot',
        ),
        InfoItem(
          title: 'Weather Preparation',
          content:
              'Weather can vary greatly depending on the season. Prepare appropriate clothing for heat, cold, and rain. In summer, it\'s good to start early in the morning to avoid the midday heat.',
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
        title: const Text('Camino Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Search feature is under development')),
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

          // 선택된 카테고리 설명
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _selectedCategoryIndex < _categories.length
                  ? _categories[_selectedCategoryIndex].description
                  : '',
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
                    child: Text('Please select a category'),
                  ),
          ),
        ],
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
                            'Failed to load image',
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
