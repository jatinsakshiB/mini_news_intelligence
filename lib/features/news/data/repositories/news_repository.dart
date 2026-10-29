import '../../../../core/errors/failures.dart';
import '../datasources/news_remote_datasource.dart';
import '../models/article_model.dart';

abstract class NewsRepository {
  Future<List<ArticleModel>> getArticlesByCategory({
    required String category,
    int page = 1,
  });

  Future<List<ArticleModel>> searchArticles({
    required String query,
    String sortBy = 'publishedAt',
    int page = 1,
  });
}

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ArticleModel>> getArticlesByCategory({
    required String category,
    int page = 1,
  }) async {
    try {
      final response = await remoteDataSource.getArticlesByCategory(
        category: category,
        page: page,
      );
      return response.articles;
    } on Failure {
      rethrow;
    } catch (_) {
      throw const GeneralFailure(
        message: 'Unable to load news articles at this time.',
      );
    }
  }

  @override
  Future<List<ArticleModel>> searchArticles({
    required String query,
    String sortBy = 'publishedAt',
    int page = 1,
  }) async {
    try {
      final response = await remoteDataSource.searchArticles(
        query: query,
        sortBy: sortBy,
        page: page,
      );
      return response.articles;
    } on Failure {
      rethrow;
    } catch (_) {
      throw const GeneralFailure(
        message: 'Search query could not be completed. Please try again.',
      );
    }
  }
}
