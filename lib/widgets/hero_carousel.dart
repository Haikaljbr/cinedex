import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/movie.dart';
import 'app_network_image.dart';
import 'rating_widgets.dart';

/// Carousel film yang sedang tayang (PageView + indikator halaman).
/// Bergeser otomatis setiap 5 detik.
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    super.key,
    required this.movies,
    required this.genreNamesOf,
    required this.onMovieTap,
  });

  final List<Movie> movies;
  final List<String> Function(Movie movie) genreNamesOf;
  final void Function(Movie movie) onMovieTap;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  static const _autoPlayInterval = Duration(seconds: 5);

  final _controller = PageController(
    viewportFraction: AppSizes.carouselViewport,
  );
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.movies.length < 2) return;
    _timer = Timer.periodic(_autoPlayInterval, (_) {
      if (!_controller.hasClients) return;
      final next = (_currentPage + 1) % widget.movies.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: AppSizes.carouselHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.movies.length,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
              _startAutoPlay(); // reset timer setelah geser manual
            },
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return AnimatedScale(
                scale: index == _currentPage ? 1 : 0.94,
                duration: const Duration(milliseconds: 250),
                child: _CarouselItem(
                  movie: movie,
                  genres: widget.genreNamesOf(movie),
                  onTap: () => widget.onMovieTap(movie),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _PageIndicator(count: widget.movies.length, current: _currentPage),
      ],
    );
  }
}

class _CarouselItem extends StatelessWidget {
  const _CarouselItem({
    required this.movie,
    required this.genres,
    required this.onTap,
  });

  final Movie movie;
  final List<String> genres;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: AppRadius.large,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(imageUrl: movie.backdropUrl),
              DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.imageScrim),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: AppRadius.rounded,
                      ),
                      child: Text(
                        'Sedang Tayang',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.onAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headline,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        RatingBadge(voteAverage: movie.voteAverage),
                        if (genres.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              genres.take(3).join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.textMuted,
            borderRadius: AppRadius.rounded,
          ),
        );
      }),
    );
  }
}
