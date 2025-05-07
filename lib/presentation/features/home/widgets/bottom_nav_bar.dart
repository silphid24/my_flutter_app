import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/presentation/router/app_router.dart';

/// 앱의 하단 네비게이션 바 위젯
///
/// 홈, 지도, 커뮤니티, 정보 탭을 제공합니다.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            context: context,
            icon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => _navigateTo(context, AppRoutes.home),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.map,
            label: 'Map',
            isSelected: currentIndex == 1,
            onTap: () => _navigateTo(context, AppRoutes.map),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.people,
            label: 'Community',
            isSelected: currentIndex == 2,
            onTap: () => _navigateTo(context, AppRoutes.community),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.info,
            label: 'Info',
            isSelected: currentIndex == 3,
            onTap: () => _navigateTo(context, AppRoutes.info),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    if (route == AppRoutes.home && currentIndex == 0) return;
    context.go(route);
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
