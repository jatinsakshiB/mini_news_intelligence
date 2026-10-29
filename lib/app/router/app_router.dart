import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/news/data/models/article_model.dart';
import '../../features/news/presentation/pages/article_detail_page.dart';
import '../../features/news/presentation/pages/news_feed_page.dart';
import '../../features/news/presentation/pages/search_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const NewsFeedPage(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/article',
        name: 'article_detail',
        builder: (context, state) {
          final article = state.extra as ArticleModel?;
          if (article == null) {
            return const Scaffold(
              body: Center(child: Text('Article not found')),
            );
          }
          return ArticleDetailPage(article: article);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.toString()}')),
    ),
  );
}
