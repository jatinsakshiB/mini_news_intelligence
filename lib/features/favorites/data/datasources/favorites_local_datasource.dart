import 'package:hive/hive.dart';
import '../../../../core/errors/failures.dart';
import '../../../news/data/models/article_model.dart';

abstract class FavoritesLocalDataSource {
  List<ArticleModel> getFavorites();
  Future<void> saveFavorite(ArticleModel article);
  Future<void> removeFavorite(String articleUrl);
  bool isFavorite(String articleUrl);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  static const String boxName = 'favorites_box';
  final Box<Map> favoritesBox;

  FavoritesLocalDataSourceImpl({required this.favoritesBox});

  @override
  List<ArticleModel> getFavorites() {
    try {
      final List<ArticleModel> list = [];
      for (final value in favoritesBox.values) {
        try {
          list.add(ArticleModel.fromMap(value));
        } catch (_) {}
      }
      // Sort newest first by publishedAt
      list.sort((a, b) {
        final dateA = a.publishedAt ?? '';
        final dateB = b.publishedAt ?? '';
        return dateB.compareTo(dateA);
      });
      return list;
    } catch (_) {
      throw const CacheFailure(
        message: 'Unable to read saved articles from storage.',
      );
    }
  }

  @override
  Future<void> saveFavorite(ArticleModel article) async {
    try {
      await favoritesBox.put(article.url, article.toMap());
    } catch (_) {
      throw const CacheFailure(
        message: 'Unable to save article to offline storage.',
      );
    }
  }

  @override
  Future<void> removeFavorite(String articleUrl) async {
    try {
      await favoritesBox.delete(articleUrl);
    } catch (_) {
      throw const CacheFailure(
        message: 'Unable to remove article from offline storage.',
      );
    }
  }

  @override
  bool isFavorite(String articleUrl) {
    return favoritesBox.containsKey(articleUrl);
  }
}
