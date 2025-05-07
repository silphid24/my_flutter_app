class PilgrimRoute {
  final String id;
  final String title;
  final List<String> towns;
  final bool mapped;
  final double? distance; // 거리 (km)
  final int difficulty; // 난이도 (1-5)
  final String season; // 추천 시즌
  final String? description; // 설명
  final String? notes; // 메모 및 기타 정보

  PilgrimRoute({
    required this.id,
    required this.title,
    required this.towns,
    required this.mapped,
    this.distance,
    this.difficulty = 1,
    this.season = 'All year',
    this.description,
    this.notes,
  });

  factory PilgrimRoute.fromCsv(List<String> row) {
    // CSV 포맷: ID, Title, Towns, Mapped, Distance, Difficulty, Season, Description, Notes
    if (row.length < 4) {
      throw Exception('CSV data is invalid: $row');
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
      distance:
          row.length > 4 && row[4].isNotEmpty ? double.tryParse(row[4]) : null,
      difficulty:
          row.length > 5 && row[5].isNotEmpty ? int.tryParse(row[5]) ?? 1 : 1,
      season: row.length > 6 ? row[6] : 'All year',
      description: row.length > 7 ? row[7] : null,
      notes: row.length > 8 ? row[8] : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'towns': towns.join(','),
      'mapped': mapped ? 1 : 0,
      'distance': distance,
      'difficulty': difficulty,
      'season': season,
      'description': description,
      'notes': notes,
    };
  }

  factory PilgrimRoute.fromMap(Map<String, dynamic> map) {
    return PilgrimRoute(
      id: map['id'] as String,
      title: map['title'] as String,
      towns: (map['towns'] as String).split(','),
      mapped: map['mapped'] == 1,
      distance:
          map['distance'] != null ? (map['distance'] as num).toDouble() : null,
      difficulty: map['difficulty'] != null ? map['difficulty'] as int : 1,
      season: map['season'] as String? ?? 'All year',
      description: map['description'] as String?,
      notes: map['notes'] as String?,
    );
  }
}
