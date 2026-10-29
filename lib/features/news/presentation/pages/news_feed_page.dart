import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../bloc/news_feed_bloc.dart';
import '../bloc/news_feed_event.dart';
import '../bloc/news_feed_state.dart';
import '../widgets/article_card.dart';
import '../widgets/category_bar.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({super.key});

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initial feed fetch if empty
    final feedBloc = context.read<NewsFeedBloc>();
    if (feedBloc.state.status == NewsFeedStatus.initial) {
      feedBloc.add(const FetchCategoryFeed());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      context.read<NewsFeedBloc>().add(const LoadMoreArticles());
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 300);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of Balaji News?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.surfaceLight,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              AppAssets.getLogo(isDark: isDark),
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                'BALAJI',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: const Text(
                'INTELLIGENCE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.brandOrange,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            tooltip: 'Search articles',
            onPressed: () => context.push('/search'),
          ),
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favState) {
              final count = favState.favorites.length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, size: 22),
                    tooltip: 'Saved articles',
                    onPressed: () => context.push('/favorites'),
                  ),
                  if (count > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.brandOrange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector Bar
          BlocBuilder<NewsFeedBloc, NewsFeedState>(
            buildWhen: (previous, current) =>
                previous.selectedCategory != current.selectedCategory,
            builder: (context, state) {
              return CategoryBar(
                selectedCategory: state.selectedCategory,
                onCategorySelected: (category) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0.0);
                  }
                  context.read<NewsFeedBloc>().add(ChangeCategory(category));
                },
              );
            },
          ),

          // Main Feed Area
          Expanded(
            child: BlocConsumer<NewsFeedBloc, NewsFeedState>(
              listener: (context, state) {
                if (state.status == NewsFeedStatus.failure &&
                    state.articles.isNotEmpty &&
                    state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == NewsFeedStatus.loading &&
                    state.articles.isEmpty) {
                  return const ArticleSkeletonList(count: 5);
                }

                if (state.status == NewsFeedStatus.failure &&
                    state.articles.isEmpty) {
                  return ErrorView(
                    message:
                        state.errorMessage ??
                        'Unable to load news feed. Please verify your connection.',
                    onRetry: () => context.read<NewsFeedBloc>().add(
                      FetchCategoryFeed(category: state.selectedCategory),
                    ),
                    onViewFavorites: () => context.push('/favorites'),
                  );
                }

                if (state.articles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 36,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No stories in this category right now.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.brandOrange,
                  onRefresh: () async {
                    context.read<NewsFeedBloc>().add(const RefreshFeed());
                    // Wait briefly for state change
                    await Future.delayed(const Duration(milliseconds: 600));
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount:
                        state.articles.length +
                        (state.isPaginating || !state.hasReachedMax ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Bottom pagination loader
                      if (index >= state.articles.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: state.isPaginating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.brandOrange,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }

                      final article = state.articles[index];
                      // Highlight top story as featured
                      final isFirst = index == 0;

                      return ArticleCard(
                        article: article,
                        isFeatured: isFirst,
                        onTap: () {
                          context.push('/article', extra: article);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
