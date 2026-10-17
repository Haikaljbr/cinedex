import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/movie.dart';
import '../../data/models/movie_detail.dart';
import '../../data/models/video.dart';
import '../../data/repositories/movie_repository.dart';
import '../../providers/movie_detail_provider.dart';
import '../../providers/view_state.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/cast_list.dart';
import '../../widgets/expandable_text.dart';
import '../../widgets/movie_section.dart';
import '../../widgets/rating_widgets.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/state_views.dart';
import '../../widgets/tmdb_attribution.dart';

/// Halaman Detail Film. Data ringkas dari [movie] langsung ditampilkan
/// (judul, poster, rating) sambil menunggu detail lengkap dari API.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.movie, this.heroTag});

  final Movie movie;
  final String? heroTag;

  static Future<void> open(
    BuildContext context,
    Movie movie, {
    String? heroTag,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(movie: movie, heroTag: heroTag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MovieDetailProvider(context.read<MovieRepository>(), movie.id)
            ..load(),
      child: _DetailView(movie: movie, heroTag: heroTag),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.movie, this.heroTag});

  final Movie movie;
  final String? heroTag;

  static const double _expandedHeight = AppSizes.backdropHeight + 80;

  Future<void> _openTrailer(BuildContext context, Video trailer) async {
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(trailer.youtubeUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka trailer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieDetailProvider>();
    final detail = provider.detail;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _expandedHeight,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: const _CircleBackButton(),
            flexibleSpace: _DetailHeader(
              movie: movie,
              detail: detail,
              heroTag: heroTag,
            ),
          ),
          ..._buildBody(context, provider),
        ],
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context, MovieDetailProvider provider) {
    switch (provider.status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const [SliverToBoxAdapter(child: _DetailShimmer())];
      case LoadStatus.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(error: provider.error!, onRetry: provider.load),
          ),
        ];
      case LoadStatus.success:
        final detail = provider.detail!;
        final trailer = provider.trailer;
        return [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList.list(
              children: [
                const SizedBox(height: AppSpacing.md),
                _InfoRow(detail: detail),
                const SizedBox(height: AppSpacing.md),
                _GenreWrap(genres: detail.genres.map((g) => g.name).toList()),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: trailer == null
                        ? null
                        : () => _openTrailer(context, trailer),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      trailer == null
                          ? 'Trailer Tidak Tersedia'
                          : 'Tonton Trailer',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Sinopsis', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                ExpandableText(
                  text: detail.overview.isEmpty
                      ? 'Sinopsis belum tersedia untuk film ini.'
                      : detail.overview,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
          if (provider.cast.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SectionHeader(title: 'Pemeran')),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            SliverToBoxAdapter(child: CastList(cast: provider.cast)),
          ],
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            sliver: SliverToBoxAdapter(child: TmdbAttribution()),
          ),
        ];
    }
  }
}

/// Header yang bisa mengecil: backdrop, poster (Hero), judul, rating.
/// Saat header tertutup penuh, judul muncul di app bar.
class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.movie,
    required this.detail,
    this.heroTag,
  });

  final Movie movie;
  final MovieDetail? detail;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final title = detail?.title ?? movie.title;
    final tagline = detail?.tagline ?? '';
    final voteAverage = detail?.voteAverage ?? movie.voteAverage;
    final voteCount = detail?.voteCount ?? movie.voteCount;

    final poster = AppNetworkImage(
      imageUrl: movie.posterUrl ?? detail?.posterUrl,
      borderRadius: AppRadius.card,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final collapsed =
            constraints.maxHeight <= kToolbarHeight + topPadding + 24;

        return Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(imageUrl: detail?.backdropUrl ?? movie.backdropUrl),
            DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.imageScrim),
            ),
            if (collapsed)
              ColoredBox(
                color: AppColors.background,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: topPadding,
                    left: 64,
                    right: AppSpacing.md,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: AppSizes.detailPosterWidth,
                      height: AppSizes.detailPosterHeight,
                      child: heroTag == null
                          ? poster
                          : Hero(tag: heroTag!, child: poster),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.headline,
                          ),
                          if (tagline.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              tagline,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              StarRating(
                                voteAverage: voteAverage,
                                size: AppSizes.iconSm + 2,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                Formatters.formatStarRating(voteAverage),
                                style: AppTextStyles.label,
                              ),
                            ],
                          ),
                          Text(
                            '${Formatters.formatVoteCount(voteCount)} vote',
                            style: AppTextStyles.small,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          tooltip: 'Kembali',
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

/// Durasi dan tanggal rilis.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        _InfoItem(
          icon: Icons.schedule_rounded,
          text: Formatters.formatRuntime(detail.runtime),
        ),
        _InfoItem(
          icon: Icons.calendar_today_rounded,
          text: Formatters.formatReleaseDate(detail.releaseDate),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconSm, color: AppColors.accent),
        const SizedBox(width: AppSpacing.xxs),
        Text(text, style: AppTextStyles.caption),
      ],
    );
  }
}

class _GenreWrap extends StatelessWidget {
  const _GenreWrap({required this.genres});

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final genre in genres)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.rounded,
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(genre, style: AppTextStyles.caption),
          ),
      ],
    );
  }
}

/// Skeleton isi halaman Detail saat memuat.
class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 14, width: 200),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                SkeletonBox(height: 26, width: 70, radius: AppRadius.pill),
                SizedBox(width: AppSpacing.xs),
                SkeletonBox(height: 26, width: 90, radius: AppRadius.pill),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            SkeletonBox(height: 50, radius: AppRadius.md),
            SizedBox(height: AppSpacing.lg),
            SkeletonBox(height: 18, width: 100),
            SizedBox(height: AppSpacing.sm),
            SkeletonBox(height: 12),
            SizedBox(height: AppSpacing.xs),
            SkeletonBox(height: 12),
            SizedBox(height: AppSpacing.xs),
            SkeletonBox(height: 12, width: 220),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                SkeletonBox(width: 72, height: 72, radius: AppRadius.pill),
                SizedBox(width: AppSpacing.sm),
                SkeletonBox(width: 72, height: 72, radius: AppRadius.pill),
                SizedBox(width: AppSpacing.sm),
                SkeletonBox(width: 72, height: 72, radius: AppRadius.pill),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
