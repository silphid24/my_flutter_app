class PilgrimRoute {
  final String id;
  final String title;
  final List<String> towns;
  final bool mapped;

  PilgrimRoute({
    required this.id,
    required this.title,
    required this.towns,
    required this.mapped,
  });

  factory PilgrimRoute.fromCsv(List<String> row) {
    // CSV 포맷: ID, Title, Towns, Mapped
    if (row.length < 4) {
      throw Exception('CSV 행 데이터가 올바르지 않습니다: $row');
    }

    List<String> townsList = [];
    if (row[2].isNotEmpty) {
      // 세미콜론(;)으로 분리된 서브 경로를 분할
      List<String> subRoutes = row[2].split(';');
      for (var subRoute in subRoutes) {
        // 각 서브 경로에서 쉼표로 분리된 마을들을 추가
        townsList.addAll(subRoute.split(',').map((town) => town.trim()));
      }
    }

    return PilgrimRoute(
      id: row[0],
      title: row[1],
      towns: townsList,
      mapped: row[3].toLowerCase() == 'yes',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'towns': towns.join(','),
      'mapped': mapped ? 1 : 0,
    };
  }

  factory PilgrimRoute.fromMap(Map<String, dynamic> map) {
    return PilgrimRoute(
      id: map['id'] as String,
      title: map['title'] as String,
      towns: (map['towns'] as String).split(','),
      mapped: map['mapped'] == 1,
    );
  }
}
