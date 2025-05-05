import 'package:flutter/material.dart';
import 'package:my_flutter_app/screens/home_screen.dart';
import 'package:my_flutter_app/screens/stages_map_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<PostItem> _posts = [
    PostItem(
      username: 'pilgrim_john',
      location: 'Roncesvalles',
      timeAgo: '2시간 전',
      content: '첫 번째 스테이지를 끝마쳤습니다! 피레네 산맥을 건너는 것은 힘들었지만 아름다운 경험이었어요.',
      likes: 24,
      comments: 5,
      imageUrl: 'https://source.unsplash.com/random/800x600/?hiking,camino',
    ),
    PostItem(
      username: 'camino_maria',
      location: 'Pamplona',
      timeAgo: '어제',
      content: '팜플로나에서의 아름다운 석양. 내일은 푸엔테 라 레이나로 출발합니다. 누구 같이 걸을 사람?',
      likes: 36,
      comments: 8,
      imageUrl: 'https://source.unsplash.com/random/800x600/?sunset,spain',
    ),
    PostItem(
      username: 'hiking_peter',
      location: 'León',
      timeAgo: '3일 전',
      content: '레온 대성당은 반드시 방문해야 할 곳입니다. 스테인드글라스의 아름다움은 정말 놀랍습니다.',
      likes: 42,
      comments: 7,
      imageUrl: 'https://source.unsplash.com/random/800x600/?cathedral,spain',
    ),
    PostItem(
      username: 'buen_camino',
      location: 'O Cebreiro',
      timeAgo: '1주일 전',
      content: '오 세브레이로에 눈이 내렸습니다! 겨울에 카미노를 걷는 것은 또 다른 경험이네요.',
      likes: 51,
      comments: 12,
      imageUrl: 'https://source.unsplash.com/random/800x600/?snow,mountains',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카미노 커뮤니티'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('검색 기능은 개발 중입니다.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알림 기능은 개발 중입니다.')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('새 게시물 작성 기능은 개발 중입니다.')),
          );
        },
        child: const Icon(Icons.add),
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
              isSelected: true,
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

  Widget _buildPostCard(PostItem post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 사용자 정보 및 메뉴
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade300,
              child: Text(
                post.username.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              post.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${post.location} • ${post.timeAgo}'),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ),
          // 게시물 내용
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(post.content),
          ),
          // 이미지
          if (post.imageUrl.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: const CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '이미지를 불러올 수 없습니다',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          // 좋아요 및 댓글 버튼
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                Text('${post.likes}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () {},
                ),
                Text('${post.comments}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
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

class PostItem {
  final String username;
  final String location;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;
  final String imageUrl;

  PostItem({
    required this.username,
    required this.location,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
    required this.imageUrl,
  });
}
