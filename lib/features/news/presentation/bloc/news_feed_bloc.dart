import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/article_model.dart';
import '../../data/repositories/news_repository.dart';
import 'news_feed_event.dart';
import 'news_feed_state.dart';

class NewsFeedBloc extends Bloc<NewsFeedEvent, NewsFeedState> {
  final NewsRepository newsRepository;

  NewsFeedBloc({required this.newsRepository}) : super(const NewsFeedState()) {
    on<FetchCategoryFeed>(_onFetchCategoryFeed);
    on<RefreshFeed>(_onRefreshFeed);
    on<LoadMoreArticles>(_onLoadMoreArticles);
    on<ChangeCategory>(_onChangeCategory);
  }

  Future<void> _onFetchCategoryFeed(
    FetchCategoryFeed event,
    Emitter<NewsFeedState> emit,
  ) async {
    emit(
      state.copyWith(
        status: NewsFeedStatus.loading,
        selectedCategory: event.category,
        articles: const [],
        currentPage: 1,
        hasReachedMax: false,
        errorMessage: null,
      ),
    );

    try {
      final articles = await newsRepository.getArticlesByCategory(
        category: event.category,
        page: 1,
      );

      emit(
        state.copyWith(
          status: NewsFeedStatus.success,
          articles: articles,
          currentPage: 1,
          hasReachedMax: articles.length < ApiConstants.defaultPageSize,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(status: NewsFeedStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: NewsFeedStatus.failure,
          errorMessage: 'Unable to load news feed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onRefreshFeed(
    RefreshFeed event,
    Emitter<NewsFeedState> emit,
  ) async {
    try {
      final articles = await newsRepository.getArticlesByCategory(
        category: state.selectedCategory,
        page: 1,
      );

      emit(
        state.copyWith(
          status: NewsFeedStatus.success,
          articles: articles,
          currentPage: 1,
          hasReachedMax: articles.length < ApiConstants.defaultPageSize,
          errorMessage: null,
        ),
      );
    } on Failure catch (e) {
      // If refresh fails but we already have articles, don't wipe them, just show snackbar/message
      if (state.articles.isEmpty) {
        emit(
          state.copyWith(
            status: NewsFeedStatus.failure,
            errorMessage: e.message,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _onChangeCategory(
    ChangeCategory event,
    Emitter<NewsFeedState> emit,
  ) async {
    if (event.category == state.selectedCategory &&
        state.status == NewsFeedStatus.success) {
      return;
    }
    add(FetchCategoryFeed(category: event.category));
  }

  Future<void> _onLoadMoreArticles(
    LoadMoreArticles event,
    Emitter<NewsFeedState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.isPaginating ||
        state.status != NewsFeedStatus.success) {
      return;
    }

    emit(state.copyWith(isPaginating: true));

    try {
      final nextPage = state.currentPage + 1;
      final newArticles = await newsRepository.getArticlesByCategory(
        category: state.selectedCategory,
        page: nextPage,
      );

      if (newArticles.isEmpty) {
        emit(state.copyWith(isPaginating: false, hasReachedMax: true));
        return;
      }

      // Deduplicate articles against existing list by URL
      final existingUrls = state.articles.map((a) => a.url).toSet();
      final List<ArticleModel> deduplicated = [];
      for (final article in newArticles) {
        if (!existingUrls.contains(article.url) &&
            article.url.isNotEmpty &&
            article.title.isNotEmpty) {
          deduplicated.add(article);
          existingUrls.add(article.url);
        }
      }

      emit(
        state.copyWith(
          isPaginating: false,
          articles: [...state.articles, ...deduplicated],
          currentPage: nextPage,
          hasReachedMax: newArticles.length < ApiConstants.defaultPageSize,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isPaginating: false));
    }
  }
}
