import 'package:flutter/material.dart';

/// 경로 이탈 감지 설정을 관리하는 위젯
class RouteDeviationSettings extends StatelessWidget {
  final bool deviationModeEnabled;
  final Function(bool) onToggleDeviationMode;
  final bool isPilgrimMode;

  const RouteDeviationSettings({
    Key? key,
    required this.deviationModeEnabled,
    required this.onToggleDeviationMode,
    required this.isPilgrimMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '경로 이탈 감지',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              '카미노 경로에서 100m 이상 벗어나면 알림을 표시합니다.',
              style: TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text('경로 이탈 감지'),
              subtitle: Text(
                deviationModeEnabled ? '활성화됨' : '비활성화됨',
                style: TextStyle(
                  color: deviationModeEnabled
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                ),
              ),
              value: deviationModeEnabled,
              onChanged: isPilgrimMode
                  ? onToggleDeviationMode
                  : (value) {
                      // 순례 모드가 꺼져 있으면 경고 메시지 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('순례 모드가 켜져 있을 때만 경로 이탈 감지를 활성화할 수 있습니다.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
              activeColor: Colors.blue,
              secondary: Icon(
                deviationModeEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: deviationModeEnabled ? Colors.blue : Colors.grey,
              ),
            ),
            if (!isPilgrimMode) ...[
              const SizedBox(height: 8.0),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '경로 이탈 감지를 활성화하려면 먼저 순례 모드를 켜야 합니다.',
                  style: TextStyle(color: Colors.red, fontSize: 12.0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
