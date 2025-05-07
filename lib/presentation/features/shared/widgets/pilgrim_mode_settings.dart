import 'package:flutter/material.dart';

/// 순례 모드 설정을 위한 위젯
class PilgrimModeSettings extends StatelessWidget {
  final bool pilgrimModeEnabled;
  final Function(bool) onTogglePilgrimMode;

  const PilgrimModeSettings({
    Key? key,
    required this.pilgrimModeEnabled,
    required this.onTogglePilgrimMode,
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
              '순례 모드',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              '순례 모드를 활성화하면 더 정확한 위치 추적과 경로 안내를 제공합니다. 배터리 소모가 증가할 수 있습니다.',
              style: TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text('순례 모드'),
              subtitle: Text(
                pilgrimModeEnabled ? '활성화됨' : '비활성화됨',
                style: TextStyle(
                  color: pilgrimModeEnabled
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                ),
              ),
              value: pilgrimModeEnabled,
              onChanged: onTogglePilgrimMode,
              activeColor: Colors.blue,
              secondary: Icon(
                pilgrimModeEnabled ? Icons.directions_walk : Icons.hotel,
                color: pilgrimModeEnabled ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(height: 8.0),
            if (pilgrimModeEnabled) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '더 정확한 추적을 위해 GPS 위치 정확도를 높게 설정했습니다. 배터리 소모에 주의하세요.',
                  style: TextStyle(color: Colors.blue, fontSize: 12.0),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
