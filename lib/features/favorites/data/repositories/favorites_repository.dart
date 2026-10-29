import '../../../news/data/models/article_model.dart';
import '../datasources/favorites_local_datasource.dart';

abstract class FavoritesRepository {
  List<ArticleModel> getFavorites();
  Future<void> toggleFavorite(ArticleModel article);
  bool isFavorite(String articleUrl);
  Future<void> removeFavorite(String articleUrl);
}

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  FavoritesRepositoryImpl({required this.localDataSource});

  @override
  List<ArticleModel> getFavorites() {
    return localDataSource.getFavorites();
  }

  @override
  Future<void> toggleFavorite(ArticleModel article) async {
    if (localDataSource.isFavorite(article.url)) {
      await localDataSource.removeFavorite(article.url);
    } else {
      await localDataSource.saveFavorite(article);
    }
  }

  @override
  bool isFavorite(String articleUrl) {
    return localDataSource.isFavorite(articleUrl);
  }

  @override
  Future<void> removeFavorite(String articleUrl) async {
    await localDataSource.removeFavorite(articleUrl);
  }
}
