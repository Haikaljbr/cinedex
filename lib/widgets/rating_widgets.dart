import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';

/// Rating ringkas "★ 4.2" (skala 0-5).
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.voteAverage, this.style});

  final double voteAverage;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star_rounded,
          color: AppColors.accent,
          size: AppSizes.iconSm,
        ),
        const SizedBox(width: 2),
        Text(
          Formatters.formatStarRating(voteAverage),
          style: style ?? AppTextStyles.caption,
        ),
      ],
    );
  }
}

/// Lima ikon bintang (penuh, setengah, kosong) sesuai skala 0-5.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.voteAverage,
    this.size = AppSizes.iconMd,
  });

  final double voteAverage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final stars = Formatters.toStarScale(voteAverage);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final IconData icon;
        if (stars >= i + 0.75) {
          icon = Icons.star_rounded;
        } else if (stars >= i + 0.25) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, color: AppColors.accent, size: size);
      }),
    );
  }
}
