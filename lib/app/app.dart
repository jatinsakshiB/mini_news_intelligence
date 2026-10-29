import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/favorites/data/repositories/favorites_repository.dart';
import '../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../features/news/data/repositories/news_repository.dart';
import '../features/news/presentation/bloc/news_feed_bloc.dart';
import '../features/news/presentation/cubit/news_search_cubit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class MiniNewsApp extends StatelessWidget {
  final AuthRepository authRepository;
  final NewsRepository newsRepository;
  final FavoritesRepository favoritesRepository;

  const MiniNewsApp({
    super.key,
    required this.authRepository,
    required this.newsRepository,
    required this.favoritesRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authRepository: authRepository),
        ),
        BlocProvider<FavoritesCubit>(
          create: (_) => FavoritesCubit(repository: favoritesRepository),
        ),
        BlocProvider<NewsFeedBloc>(
          create: (_) => NewsFeedBloc(newsRepository: newsRepository),
        ),
        BlocProvider<NewsSearchCubit>(
          create: (_) => NewsSearchCubit(newsRepository: newsRepository),
        ),
      ],
      child: MaterialApp.router(
        title: 'Balaji News',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
