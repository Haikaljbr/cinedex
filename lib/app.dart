import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/movie_repository.dart';
import 'data/services/tmdb_service.dart';
import 'providers/home_provider.dart';
import 'screens/main_screen.dart';

/// Root widget: mendaftarkan repository dan provider, lalu tema aplikasi.
class CineDexApp extends StatelessWidget {
  const CineDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MovieRepository>(
          create: (_) => MovieRepository(TmdbService()),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (context) =>
              HomeProvider(context.read<MovieRepository>())..loadHome(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const MainScreen(),
      ),
    );
  }
}
