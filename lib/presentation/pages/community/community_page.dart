import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              '카미노 커뮤니티',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // 최신 게시물 섹션
            _buildSectionTitle('최신 게시물'),
            const SizedBox(height: 12),
            _buildPostCard(
              title: '산티아고 순례 첫 날 후기',
              author: '순례자김철수',
              date: '오늘',
              likes: 15,
              comments: 3,
              snippet: '오늘 산티아고 데 콤포스텔라를 향한 첫 걸음을 내딛었습니다. 처음 걷는 순례길에 설레면서도...',
            ),
            const SizedBox(height: 12),
            _buildPostCard(
              title: '샘플링한 현지 음식 추천',
              author: '순례자이영희',
              date: '어제',
              likes: 32,
              comments: 7,
              snippet: '스페인 현지 음식 중에 꼭 먹어봐야 할 것들을 정리해 봤습니다. 먼저 첫번째는...',
            ),
            const SizedBox(height: 12),
            _buildPostCard(
              title: '도중에 알베르게 찾기 꿀팁',
              author: '베테랑순례자',
              date: '2일 전',
              likes: 42,
              comments: 12,
              snippet: '예약 없이도 좋은 알베르게를 찾는 방법을 알려드립니다.',
            ),

            const SizedBox(height: 24),

            // 인기 주제 섹션
            _buildSectionTitle('인기 주제'),
            const SizedBox(height: 12),
            _buildTopicChips(),

            const SizedBox(height: 24),

            // 같이 걸을 동행 찾기
            _buildSectionTitle('같이 걸을 동행 찾기'),
            const SizedBox(height: 12),
            _buildCompanionSection(),

            const SizedBox(height: 30),
            Center(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('게시물 작성하기'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('커뮤니티 기능은 준비 중입니다.')));
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPostCard({
    required String title,
    required String author,
    required String date,
    required int likes,
    required int comments,
    required String snippet,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              snippet,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  author,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.thumb_up, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$likes', style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.comment, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$comments', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChips() {
    final topics = [
      '준비물',
      '알베르게',
      '식당',
      '동행 구하기',
      '길 찾기',
      '현지 언어',
      '배낭',
      '날씨',
      '응급처치',
      '문화',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          topics
              .map(
                (topic) => Chip(
                  label: Text(topic),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
              )
              .toList(),
    );
  }

  Widget _buildCompanionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '현재 동행을 찾고 있는 순례자: 15명',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            '산티아고 순례길을 함께 걸을 동행을 찾고 계신가요? 위치, 날짜, 걷는 속도 등을 공유하고 함께 할 순례자를 찾아보세요.',
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(onPressed: () {}, child: const Text('동행 찾기')),
          ),
        ],
      ),
    );
  }
}
