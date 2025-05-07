import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 커뮤니티 스크린 콘텐츠
///
/// 카미노 드 산티아고 사용자들의 커뮤니티 게시글을 표시하는 화면입니다.
class CommunityScreenContent extends StatefulWidget {
  const CommunityScreenContent({super.key});

  @override
  State<CommunityScreenContent> createState() => _CommunityScreenContentState();
}

class _CommunityScreenContentState extends State<CommunityScreenContent> {
  final List<PostItem> _posts = [
    PostItem(
      username: 'pilgrim_john',
      location: 'Roncesvalles',
      timeAgo: '2 hours ago',
      content:
          'Completed the first stage! Crossing the Pyrenees was challenging but a beautiful experience.',
      likes: 24,
      comments: 5,
      imageUrl: 'https://source.unsplash.com/random/800x600/?hiking,camino',
    ),
    PostItem(
      username: 'camino_maria',
      location: 'Pamplona',
      timeAgo: 'Yesterday',
      content:
          'Beautiful sunset in Pamplona. Heading to Puente la Reina tomorrow. Anyone walking together?',
      likes: 36,
      comments: 8,
      imageUrl: 'https://source.unsplash.com/random/800x600/?sunset,spain',
    ),
    PostItem(
      username: 'hiking_peter',
      location: 'León',
      timeAgo: '3 days ago',
      content:
          'León Cathedral is a must-visit place. The beauty of the stained glass is truly remarkable.',
      likes: 42,
      comments: 7,
      imageUrl: 'https://source.unsplash.com/random/800x600/?cathedral,spain',
    ),
    PostItem(
      username: 'buen_camino',
      location: 'O Cebreiro',
      timeAgo: '1 week ago',
      content:
          'It\'s snowing in O Cebreiro! Walking the Camino in winter is a completely different experience.',
      likes: 51,
      comments: 12,
      imageUrl: 'https://source.unsplash.com/random/800x600/?snow,mountains',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camino Community'),
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
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notification feature is under development')),
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
            const SnackBar(
                content: Text('New post feature is under development')),
          );
        },
        child: const Icon(Icons.add),
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
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
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
                          'Failed to load image',
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
          // 댓글 입력 필드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 게시물 데이터 클래스
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
