import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../news/data/models/article_model.dart';
import '../../data/repositories/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repository;

  FavoritesCubit({required this.repository}) : super(const FavoritesState()) {
    loadFavorites();
  }

  void loadFavorites() {
    try {
      final list = repository.getFavorites();
      final urls = list.map((a) => a.url).toSet();
      emit(
        state.copyWith(
          status: FavoritesStatus.success,
          favorites: list,
          favoriteUrls: urls,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: FavoritesStatus.failure,
          errorMessage: 'Unable to load saved articles.',
        ),
      );
    }
  }

  Future<void> toggleFavorite(ArticleModel article) async {
    try {
      await repository.toggleFavorite(article);
      final isNowFav = !state.favoriteUrls.contains(article.url);
      final updatedUrls = Set<String>.from(state.favoriteUrls);
      final updatedList = List<ArticleModel>.from(state.favorites);

      if (isNowFav) {
        updatedUrls.add(article.url);
        // insert at top
        updatedList.insert(0, article);
      } else {
        updatedUrls.remove(article.url);
        updatedList.removeWhere((a) => a.url == article.url);
      }

      emit(state.copyWith(favorites: updatedList, favoriteUrls: updatedUrls));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not update favorites.'));
    }
  }

  Future<void> removeFavorite(String url) async {
    try {
      await repository.removeFavorite(url);
      final updatedUrls = Set<String>.from(state.favoriteUrls)..remove(url);
      final updatedList = List<ArticleModel>.from(state.favorites)
        ..removeWhere((a) => a.url == url);

      emit(state.copyWith(favorites: updatedList, favoriteUrls: updatedUrls));
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Could not remove article from favorites.',
        ),
      );
    }
  }
}
