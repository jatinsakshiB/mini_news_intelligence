import 'package:equatable/equatable.dart';
import '../../../news/data/models/article_model.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<ArticleModel> favorites;
  final Set<String> favoriteUrls;
  final String? errorMessage;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.favoriteUrls = const {},
    this.errorMessage,
  });

  bool isFavorite(String url) => favoriteUrls.contains(url);

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<ArticleModel>? favorites,
    Set<String>? favoriteUrls,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      favoriteUrls: favoriteUrls ?? this.favoriteUrls,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, favorites, favoriteUrls, errorMessage];
}
