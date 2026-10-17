import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'shimmer_loading.dart';

/// Gambar dari internet dengan cache, shimmer saat memuat,
/// dan gambar cadangan bila URL kosong atau gagal dimuat.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.borderRadius = BorderRadius.zero,
    this.fallbackIcon = Icons.movie_outlined,
  });

  final String? imageUrl;
  final BorderRadius borderRadius;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: borderRadius,
      child: url == null
          ? _Fallback(icon: fallbackIcon)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, _) => const AppShimmer(child: SkeletonBox()),
              errorWidget: (_, _, _) => _Fallback(icon: fallbackIcon),
            ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.textMuted, size: 32),
    );
  }
}
