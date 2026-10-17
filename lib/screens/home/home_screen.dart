import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/movie.dart';
import '../../providers/home_provider.dart';
import '../../providers/view_state.dart';
import '../../widgets/genre_chips.dart';
import '../../widgets/hero_carousel.dart';
import '../../widgets/movie_section.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/state_views.dart';
import '../about/about_screen.dart';
import '../detail/detail_screen.dart';

/// Halaman Beranda: carousel, chip genre, dan section film.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openDetail(BuildContext context, Movie movie, String? heroTag) {
    DetailScreen.open(context, movie, heroTag: heroTag);
  }

  Future<void> _onRefresh(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = await context.read<HomeProvider>().refresh();
    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          onRefresh: () => _onRefresh(context),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: _HomeHeader()),
              ..._buildContent(context, provider),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, HomeProvider provider) {
    switch (provider.status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const [SliverToBoxAdapter(child: HomeShimmer())];
      case LoadStatus.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(
              error: provider.error!,
              onRetry: provider.loadHome,
            ),
          ),
        ];
      case LoadStatus.success:
        return [
          SliverToBoxAdapter(
            child: HeroCarousel(
              movies: provider.carouselMovies,
              genreNamesOf: provider.genreNamesOf,
              onMovieTap: (movie) => _openDetail(context, movie, null),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverToBoxAdapter(
            child: GenreChips(
              genres: provider.genres,
              selected: provider.selectedGenre,
              onSelected: provider.selectGenre,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          if (provider.selectedGenre == null)
            ..._buildSections(context, provider)
          else
            ..._buildGenreResults(context, provider),
        ];
    }
  }

  List<Widget> _buildSections(BuildContext context, HomeProvider provider) {
    final sections = [
      ('Populer', 'popular', provider.popular),
      ('Top Rated', 'top', provider.topRated),
      ('Akan Tayang', 'upcoming', provider.upcoming),
    ];
    return [
      for (final (title, prefix, movies) in sections)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: MovieSection(
              title: title,
              movies: movies,
              heroPrefix: prefix,
              onMovieTap: (movie, tag) => _openDetail(context, movie, tag),
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildGenreResults(BuildContext context, HomeProvider provider) {
    final genre = provider.selectedGenre!;
    final header = SliverToBoxAdapter(
      child: SectionHeader(title: 'Film ${genre.name}'),
    );

    switch (provider.genreStatus) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return [header, const SliverPosterGridShimmer()];
      case LoadStatus.error:
        return [
          header,
          SliverToBoxAdapter(
            child: ErrorView(
              error: provider.genreError!,
              onRetry: provider.retryGenre,
            ),
          ),
        ];
      case LoadStatus.success:
        if (provider.genreMovies.isEmpty) {
          return [
            header,
            const SliverToBoxAdapter(
              child: MessageView(
                icon: Icons.movie_filter_outlined,
                title: 'Belum Ada Film',
                message: 'Belum ada film untuk genre ini.',
              ),
            ),
          ];
        }
        return [
          header,
          SliverMovieGrid(
            movies: provider.genreMovies,
            heroPrefix: 'genre-${genre.id}',
            onMovieTap: (movie, tag) => _openDetail(context, movie, tag),
          ),
        ];
    }
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Cine',
                    children: [
                      TextSpan(
                        text: 'Dex',
                        style: AppTextStyles.logo.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  style: AppTextStyles.logo,
                ),
                Text(AppStrings.tagline, style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Tentang',
            icon: const Icon(Icons.info_outline_rounded),
            color: AppColors.textSecondary,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
