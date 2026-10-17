import '../../core/constants/api_constants.dart';

/// Pemeran film dari endpoint `/movie/{id}/credits` (array `cast`).
class CastMember {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.order,
    this.profilePath,
  });

  final int id;
  final String name;
  final String character;
  final String? profilePath;

  /// Urutan tampil di kredit (0 = pemeran utama).
  final int order;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '-',
      character: (json['character'] as String?)?.trim() ?? '',
      profilePath: json['profile_path'] as String?,
      // Nilai besar agar data tanpa `order` berada di akhir saat diurutkan.
      order: (json['order'] as num?)?.toInt() ?? 9999,
    );
  }

  String? get profileUrl =>
      ApiConstants.imageUrl(profilePath, ApiConstants.profileSize);
}
