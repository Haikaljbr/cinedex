import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/movie.dart';
import 'movie_card.dart';

/// Judul section dengan garis aksen di kiri.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: AppRadius.rounded,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(title, style: AppTextStyles.title)),
        ],
      ),
    );
  }
}

/// Section film horizontal (Populer, Top Rated, Akan Tayang).
class MovieSection extends StatelessWidget {
  const MovieSection({
    super.key,
    required this.title,
    required this.movies,
    required this.onMovieTap,
    required this.heroPrefix,
  });

  final String title;
  final List<Movie> movies;
  final void Function(Movie movie, String heroTag) onMovieTap;

  /// Awalan tag Hero agar unik antar-section.
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: AppSizes.sectionListHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: movies.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final movie = movies[index];
              final tag = '$heroPrefix-${movie.id}';
              return MovieCard(
                movie: movie,
                heroTag: tag,
                width: AppSizes.posterWidth,
                onTap: () => onMovieTap(movie, tag),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Grid poster 3 kolom (sliver) untuk hasil pencarian dan filter genre.
class SliverMovieGrid extends StatelessWidget {
  const SliverMovieGrid({
    super.key,
    required this.movies,
    required this.onMovieTap,
    required this.heroPrefix,
  });

  final List<Movie> movies;
  final void Function(Movie movie, String heroTag) onMovieTap;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: AppSizes.posterGridDelegate,
        delegate: SliverChildBuilderDelegate((context, index) {
          final movie = movies[index];
          final tag = '$heroPrefix-${movie.id}';
          return MovieCard(
            movie: movie,
            heroTag: tag,
            onTap: () => onMovieTap(movie, tag),
          );
        }, childCount: movies.length),
      ),
    );
  }
}
