import 'package:equatable/equatable.dart';
import '../../data/models/article_model.dart';

enum NewsFeedStatus { initial, loading, success, failure }

class NewsFeedState extends Equatable {
  final NewsFeedStatus status;
  final List<ArticleModel> articles;
  final String selectedCategory;
  final int currentPage;
  final bool hasReachedMax;
  final bool isPaginating;
  final String? errorMessage;

  const NewsFeedState({
    this.status = NewsFeedStatus.initial,
    this.articles = const [],
    this.selectedCategory = 'General',
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isPaginating = false,
    this.errorMessage,
  });

  NewsFeedState copyWith({
    NewsFeedStatus? status,
    List<ArticleModel>? articles,
    String? selectedCategory,
    int? currentPage,
    bool? hasReachedMax,
    bool? isPaginating,
    String? errorMessage,
  }) {
    return NewsFeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isPaginating: isPaginating ?? this.isPaginating,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    articles,
    selectedCategory,
    currentPage,
    hasReachedMax,
    isPaginating,
    errorMessage,
  ];
}
