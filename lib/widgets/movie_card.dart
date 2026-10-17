import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../data/models/movie.dart';
import 'app_network_image.dart';
import 'rating_widgets.dart';

/// Kartu poster film: poster bersudut membulat (dengan animasi Hero),
/// judul, tahun rilis, dan rating.
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.heroTag,
    this.width,
    this.onTap,
  });

  final Movie movie;

  /// Tag unik per kartu, karena film yang sama bisa muncul di beberapa section.
  final String heroTag;
  final double? width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: AppSizes.posterAspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: AppNetworkImage(
                      imageUrl: movie.posterUrl,
                      borderRadius: AppRadius.card,
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.75),
                        borderRadius: AppRadius.rounded,
                      ),
                      child: RatingBadge(
                        voteAverage: movie.voteAverage,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.releaseYear(movie.releaseDate),
              style: AppTextStyles.small,
            ),
          ],
        ),
      ),
    );
  }
}
