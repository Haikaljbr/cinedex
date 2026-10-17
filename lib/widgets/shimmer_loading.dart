import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';

/// Pembungkus efek shimmer dengan warna tema.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: child,
    );
  }
}

/// Kotak abu-abu sebagai kerangka (skeleton) konten.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = AppRadius.sm,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Skeleton satu kartu poster (poster + judul + rating).
class PosterCardSkeleton extends StatelessWidget {
  const PosterCardSkeleton({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          AspectRatio(
            aspectRatio: AppSizes.posterAspectRatio,
            child: SkeletonBox(radius: AppRadius.md),
          ),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(height: 12, width: 90),
          SizedBox(height: AppSpacing.xxs),
          SkeletonBox(height: 10, width: 48),
        ],
      ),
    );
  }
}

/// Skeleton satu section horizontal di Beranda.
class SectionSkeleton extends StatelessWidget {
  const SectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SkeletonBox(height: 18, width: 140),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: AppSizes.posterHeight + 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, _) =>
                const PosterCardSkeleton(width: AppSizes.posterWidth),
          ),
        ),
      ],
    );
  }
}

/// Skeleton seluruh Beranda saat pertama kali dimuat.
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SkeletonBox(
              height: AppSizes.carouselHeight,
              radius: AppRadius.lg,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: AppSizes.genreChipHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (_, _) =>
                  const SkeletonBox(width: 80, radius: AppRadius.pill),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionSkeleton(),
          const SizedBox(height: AppSpacing.lg),
          const SectionSkeleton(),
        ],
      ),
    );
  }
}

/// Grid skeleton (sliver) untuk hasil pencarian dan filter genre.
class SliverPosterGridShimmer extends StatelessWidget {
  const SliverPosterGridShimmer({super.key, this.itemCount = 9});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: AppSizes.posterGridDelegate,
        delegate: SliverChildBuilderDelegate(
          (_, _) => const AppShimmer(child: PosterCardSkeleton()),
          childCount: itemCount,
        ),
      ),
    );
  }
}
