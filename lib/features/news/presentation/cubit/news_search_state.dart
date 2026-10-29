import 'package:equatable/equatable.dart';
import '../../data/models/article_model.dart';

enum NewsSearchStatus { initial, loading, success, empty, failure }

class NewsSearchState extends Equatable {
  final NewsSearchStatus status;
  final List<ArticleModel> results;
  final String query;
  final String sortBy;
  final String? errorMessage;

  const NewsSearchState({
    this.status = NewsSearchStatus.initial,
    this.results = const [],
    this.query = '',
    this.sortBy = 'publishedAt',
    this.errorMessage,
  });

  NewsSearchState copyWith({
    NewsSearchStatus? status,
    List<ArticleModel>? results,
    String? query,
    String? sortBy,
    String? errorMessage,
  }) {
    return NewsSearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      query: query ?? this.query,
      sortBy: sortBy ?? this.sortBy,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, results, query, sortBy, errorMessage];
}
