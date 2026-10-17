import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/cast_member.dart';
import 'app_network_image.dart';

/// Daftar pemeran horizontal: foto bulat, nama, dan nama karakter.
class CastList extends StatelessWidget {
  const CastList({super.key, required this.cast});

  final List<CastMember> cast;

  static const double _itemWidth = 84;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.castAvatar + 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: cast.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final member = cast[index];
          return SizedBox(
            width: _itemWidth,
            child: Column(
              children: [
                SizedBox.square(
                  dimension: AppSizes.castAvatar,
                  child: AppNetworkImage(
                    imageUrl: member.profileUrl,
                    borderRadius: AppRadius.rounded,
                    fallbackIcon: Icons.person_rounded,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  member.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (member.character.isNotEmpty)
                  Text(
                    member.character,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
