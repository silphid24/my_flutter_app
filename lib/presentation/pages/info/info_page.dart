import 'package:flutter/material.dart';
import 'package:my_flutter_app/config/theme.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

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
              '카미노 정보',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // 카미노 소개
            _buildInfoSection(
              title: '카미노 데 산티아고란?',
              icon: Icons.info_outline,
              content:
                  '카미노 데 산티아고(Camino de Santiago)는 스페인 산티아고 데 콤포스텔라에 있는 산티아고 대성당으로 향하는 순례길을 의미합니다. 성 야고보의 유해가 모셔진 이 성당은 수세기 동안 기독교 순례의 중요한 목적지였습니다. 오늘날에는 종교적 이유뿐만 아니라 문화적, 자연적 경험을 위해서도 많은 사람들이 이 길을 걷고 있습니다.',
            ),

            const SizedBox(height: 20),

            // 주요 루트
            _buildInfoSection(
              title: '주요 루트',
              icon: Icons.route,
              content: '카미노는 여러 개의 다른 루트로 이루어져 있습니다:',
              bulletPoints: [
                '프랑스 길 (Camino Francés): 가장 인기 있는 루트로, 프랑스 국경에서부터 시작',
                '포르투갈 길 (Camino Português): 리스본이나 포르투에서 시작',
                '북쪽 길 (Camino del Norte): 스페인 북부 해안을 따라 이어지는 루트',
                '원래 길 (Camino Primitivo): 가장 오래된 순례 루트',
                '영국 길 (Camino Inglés): 영국 순례자들이 배를 타고 도착했던 북부 항구에서 시작',
              ],
            ),

            const SizedBox(height: 20),

            // 준비물
            _buildInfoSection(
              title: '필수 준비물',
              icon: Icons.backpack,
              content: '카미노를 걷기 위한 필수 준비물:',
              bulletPoints: [
                '편안한 등산화 또는 워킹화',
                '가벼운 배낭 (30-40L 추천)',
                '통풍이 잘 되는 옷 (여러 겹으로 입을 수 있게)',
                '비옷 및 방수 커버',
                '모자와 선글라스',
                '개인 식별용 순례자 여권 (credential)',
                '물통 (최소 1L)',
                '기본 구급약품',
              ],
            ),

            const SizedBox(height: 20),

            // 알베르게
            _buildInfoSection(
              title: '알베르게 (숙소)',
              icon: Icons.hotel,
              content: '알베르게는 순례자들을 위한 특별한 숙소입니다. 종류:',
              bulletPoints: [
                '공립 알베르게: 가장 저렴하며 보통 5-10유로',
                '사립 알베르게: 10-15유로 정도이며 조금 더 편안함',
                '수도원 알베르게: 종교 단체에서 운영하는 숙소',
                '호스텔 및 호텔: 좀 더 비싸지만 개인 공간을 원하는 경우 선택',
              ],
            ),

            const SizedBox(height: 20),

            // 날씨
            _buildInfoSection(
              title: '날씨 및 최적 시기',
              icon: Icons.wb_sunny,
              content: '시기별 날씨 정보:',
              bulletPoints: [
                '봄 (4-6월): 온화하고 좋은 날씨, 꽃이 만발하지만 비가 올 수 있음',
                '여름 (7-8월): 가장 붐비는 시즌, 더운 날씨 (특히 메세타 지역)',
                '가을 (9-10월): 온화한 날씨와 아름다운 풍경, 붐비지 않음',
                '겨울 (11-3월): 추운 날씨, 일부 알베르게 폐쇄, 눈이 내릴 수 있음',
              ],
            ),

            const SizedBox(height: 20),

            // 증명서
            _buildInfoSection(
              title: '콤포스텔라 증명서',
              icon: Icons.card_membership,
              content:
                  '콤포스텔라(Compostela)는 산티아고 대성당 순례사무소에서 발급하는 공식 증명서입니다. 이를 받기 위해서는:',
              bulletPoints: [
                '순례자 여권(credential)에 도장을 모아야 함',
                '최소 100km를 걸어서 완주하거나 자전거로 200km 이상 완주해야 함',
                '종교적 또는 정신적 이유로 순례했음을 명시해야 함',
              ],
            ),

            const SizedBox(height: 20),

            // 팁
            _buildInfoSection(
              title: '유용한 팁',
              icon: Icons.lightbulb_outline,
              content: '순례길을 위한 유용한 팁:',
              bulletPoints: [
                '배낭은 가능한 가볍게 (전체 체중의 10% 이하 권장)',
                '물집 예방을 위해 발 관리에 신경쓰기',
                '첫 주는 천천히 걸으며 몸을 적응시키기',
                '출발 전 충분한 체력 훈련하기',
                '지역 음식과 문화를 즐기기',
                '다양한 국적의 순례자들과 교류하기',
              ],
            ),

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
                child: const Text('더 많은 정보 보기'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required String content,
    List<String>? bulletPoints,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 14)),
            if (bulletPoints != null) ...[
              const SizedBox(height: 8),
              ...bulletPoints.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
