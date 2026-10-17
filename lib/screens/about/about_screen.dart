import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/tmdb_attribution.dart';

/// Halaman Tentang: deskripsi aplikasi, sumber data, dan atribusi TMDB.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.movie_filter_rounded,
                size: AppSizes.iconLg,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(AppStrings.appName, style: AppTextStyles.headline),
          ),
          Center(child: Text('Versi 1.0.0', style: AppTextStyles.caption)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'CineDex adalah aplikasi penjelajah film. Temukan film yang sedang '
            'tayang, populer, berperingkat tinggi, dan yang akan tayang, cari '
            'film berdasarkan judul, lalu lihat detail lengkap beserta pemeran '
            'dan trailernya.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoTile(
            icon: Icons.storage_rounded,
            title: 'Sumber Data',
            subtitle: 'The Movie Database (TMDB) API v3',
          ),
          _InfoTile(
            icon: Icons.school_rounded,
            title: 'Dibuat untuk',
            subtitle: 'UTS Pemrograman Mobile (Flutter & Dart)',
          ),
          const SizedBox(height: AppSpacing.lg),
          const TmdbAttribution(),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title, style: AppTextStyles.subtitle),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
    );
  }
}
