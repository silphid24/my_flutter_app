import 'package:flutter/material.dart';

/// 홈 화면 상단의 헤더 위젯
///
/// 프로필 아바타, 환영 메시지, 현재 일차를 표시합니다.
class HomeHeader extends StatelessWidget {
  final String username;
  final int currentDay;
  final String welcomeMessage;

  const HomeHeader({
    super.key,
    this.username = 'Pilgrim',
    this.currentDay = 1,
    this.welcomeMessage = 'Plan your Santiago pilgrimage journey with ease',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $username!           Day $currentDay',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  welcomeMessage,
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

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.black.withOpacity(0.75),
      child: CircleAvatar(
        radius: 21,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, size: 30),
        // 프로필 이미지가 있을 경우 사용할 코드
        // backgroundImage: AssetImage('assets/images/profile.jpg'),
      ),
    );
  }
}
