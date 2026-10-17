import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/movie.dart';
import '../../providers/search_provider.dart';
import '../../providers/view_state.dart';
import '../../widgets/movie_section.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/state_views.dart';
import '../detail/detail_screen.dart';

/// Halaman Pencarian: kolom cari dan grid hasil.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openDetail(Movie movie, String heroTag) {
    FocusScope.of(context).unfocus();
    DetailScreen.open(context, movie, heroTag: heroTag);
  }

  void _clear(SearchProvider provider) {
    _controller.clear();
    provider.onQueryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          // Ketuk area kosong untuk menutup keyboard.
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: Text('Cari Film', style: AppTextStyles.headline),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) => TextField(
                      controller: _controller,
                      onChanged: provider.onQueryChanged,
                      textInputAction: TextInputAction.search,
                      style: AppTextStyles.subtitle,
                      cursorColor: AppColors.accent,
                      decoration: InputDecoration(
                        hintText: 'Judul film, misalnya "Inception"',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textMuted,
                        ),
                        suffixIcon: value.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Hapus',
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () => _clear(provider),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              ..._buildResults(provider),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResults(SearchProvider provider) {
    switch (provider.status) {
      case LoadStatus.initial:
        return const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: MessageView(
              icon: Icons.movie_creation_outlined,
              title: 'Mau Nonton Apa?',
              message: 'Ketik judul film untuk mulai mencari.',
            ),
          ),
        ];
      case LoadStatus.loading:
        return const [SliverPosterGridShimmer()];
      case LoadStatus.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(error: provider.error!, onRetry: provider.retry),
          ),
        ];
      case LoadStatus.success:
        if (provider.isEmptyResult) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: MessageView(
                icon: Icons.search_off_rounded,
                title: 'Film Tidak Ditemukan',
                message:
                    'Tidak ada hasil untuk "${provider.query}". '
                    'Coba kata kunci lain.',
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${provider.results.length} hasil untuk "${provider.query}"',
                style: AppTextStyles.caption,
              ),
            ),
          ),
          SliverMovieGrid(
            movies: provider.results,
            heroPrefix: 'search',
            onMovieTap: _openDetail,
          ),
        ];
    }
  }
}
