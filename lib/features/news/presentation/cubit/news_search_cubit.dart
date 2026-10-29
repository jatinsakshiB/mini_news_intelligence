import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/news_repository.dart';
import 'news_search_state.dart';

class NewsSearchCubit extends Cubit<NewsSearchState> {
  final NewsRepository newsRepository;

  NewsSearchCubit({required this.newsRepository})
    : super(const NewsSearchState());

  void onSortByChanged(String sortBy) {
    if (state.sortBy == sortBy) return;
    if (state.query.trim().isNotEmpty) {
      search(query: state.query, sortBy: sortBy);
    } else {
      emit(state.copyWith(sortBy: sortBy));
    }
  }

  Future<void> search({required String query, String? sortBy}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      clearSearch();
      return;
    }

    final sort = sortBy ?? state.sortBy;
    emit(
      state.copyWith(
        status: NewsSearchStatus.loading,
        query: cleanQuery,
        sortBy: sort,
        errorMessage: null,
      ),
    );

    try {
      final results = await newsRepository.searchArticles(
        query: cleanQuery,
        sortBy: sort,
      );

      if (results.isEmpty) {
        emit(
          state.copyWith(
            status: NewsSearchStatus.empty,
            results: const [],
            query: cleanQuery,
            sortBy: sort,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: NewsSearchStatus.success,
            results: results,
            query: cleanQuery,
            sortBy: sort,
          ),
        );
      }
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: NewsSearchStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: NewsSearchStatus.failure,
          errorMessage:
              'Unable to perform search. Please check your connection.',
        ),
      );
    }
  }

  void clearSearch() {
    emit(const NewsSearchState());
  }
}
