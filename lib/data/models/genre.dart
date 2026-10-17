/// Genre film dari endpoint `/genre/movie/list` dan `/movie/{id}`.
class Genre {
  const Genre({required this.id, required this.name});

  final int id;
  final String name;

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
    );
  }

  @override
  bool operator ==(Object other) => other is Genre && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
