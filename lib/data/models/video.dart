import '../../core/constants/api_constants.dart';

/// Video film (trailer, teaser, dll) dari endpoint `/movie/{id}/videos`.
class Video {
  const Video({
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
  });

  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      key: (json['key'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      site: (json['site'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      official: (json['official'] as bool?) ?? false,
    );
  }

  bool get isYouTube => site == 'YouTube' && key.isNotEmpty;

  String get youtubeUrl => ApiConstants.youtubeUrl(key);
}
