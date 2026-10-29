import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../cubit/news_search_cubit.dart';
import '../cubit/news_search_state.dart';
import '../widgets/article_card.dart';
import '../widgets/search_filter_sheet.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier<bool>(false);
  final FocusNode _focusNode = FocusNode();

  static const List<String> _quickTopics = [
    'AI & Chips',
    'Federal Reserve',
    'Wall Street',
    'Crypto',
    'Clean Energy',
    'Startups',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final hasText = _searchController.text.trim().isNotEmpty;
      if (_hasTextNotifier.value != hasText) {
        _hasTextNotifier.value = hasText;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _hasTextNotifier.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    _focusNode.unfocus();
    final cleanQuery = query.trim();
    if (cleanQuery.isNotEmpty) {
      context.read<NewsSearchCubit>().search(query: cleanQuery);
    }
  }

  void _onQuickTopicSelected(String topic) {
    _searchController.text = topic;
    _performSearch(topic);
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
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
          style: TextStyle(
            fontSize: 15,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'Search business news, tickers...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            suffixIcon: ValueListenableBuilder<bool>(
              valueListenable: _hasTextNotifier,
              builder: (context, hasText, _) {
                if (!hasText) return const SizedBox.shrink();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      tooltip: 'Clear query',
                      onPressed: () {
                        _searchController.clear();
                        context.read<NewsSearchCubit>().clearSearch();
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.brandOrange,
                      ),
                      tooltip: 'Search',
                      onPressed: () => _performSearch(_searchController.text),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        actions: [
          BlocBuilder<NewsSearchCubit, NewsSearchState>(
            buildWhen: (prev, curr) => prev.sortBy != curr.sortBy,
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.tune_outlined),
                tooltip: 'Sort options',
                onPressed: () {
                  _focusNode.unfocus();
                  SearchFilterSheet.show(
                    context,
                    currentSortBy: state.sortBy,
                    onSortByChanged: (sort) {
                      context.read<NewsSearchCubit>().onSortByChanged(sort);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NewsSearchCubit, NewsSearchState>(
        builder: (context, state) {
          if (state.status == NewsSearchStatus.loading) {
            return const ArticleSkeletonList(count: 6);
          }

          if (state.status == NewsSearchStatus.failure) {
            return ErrorView(
              message:
                  state.errorMessage ??
                  'Search request failed. Please check connection and try again.',
              onRetry: () => _performSearch(_searchController.text),
              onViewFavorites: () => context.push('/favorites'),
            );
          }

          if (state.status == NewsSearchStatus.empty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_outlined,
                      size: 40,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No articles found for "${state.query}"',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Try searching for broader keywords like "tech", "earnings", or "markets".',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
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

          if (state.status == NewsSearchStatus.success) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${state.results.length} results',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Sorted by: ${state.sortBy == 'publishedAt'
                            ? 'Latest'
                            : state.sortBy == 'popularity'
                            ? 'Popularity'
                            : 'Relevancy'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      final article = state.results[index];
                      return ArticleCard(
                        article: article,
                        onTap: () {
                          context.push('/article', extra: article);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Initial suggestion state
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular Business Topics',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickTopics.map((topic) {
                    return ActionChip(
                      label: Text(
                        topic,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      backgroundColor: isDark
                          ? AppColors.cardDark
                          : const Color(0xFFF3F4F6),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onPressed: () => _onQuickTopicSelected(topic),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
