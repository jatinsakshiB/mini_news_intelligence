import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/news_response_model.dart';

abstract class NewsRemoteDataSource {
  Future<NewsResponseModel> getArticlesByCategory({
    required String category,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  });

  Future<NewsResponseModel> searchArticles({
    required String query,
    String sortBy = 'publishedAt',
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final DioClient dioClient;

  NewsRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<NewsResponseModel> getArticlesByCategory({
    required String category,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    try {
      final normalizedCategory = category.toLowerCase().trim();

      if (normalizedCategory == 'general' || normalizedCategory == 'all') {
        final response = await dioClient.dio.get(
          ApiConstants.topHeadlines,
          queryParameters: {
            'category': 'business',
            'language': 'en',
            'page': page,
            'pageSize': pageSize,
          },
        );
        return NewsResponseModel.fromJson(
          response.data as Map<String, dynamic>,
          category: 'Business',
        );
      } else if (normalizedCategory == 'technology') {
        final response = await dioClient.dio.get(
          ApiConstants.topHeadlines,
          queryParameters: {
            'category': 'technology',
            'language': 'en',
            'page': page,
            'pageSize': pageSize,
          },
        );
        return NewsResponseModel.fromJson(
          response.data as Map<String, dynamic>,
          category: 'Technology',
        );
      } else {
        // Topic-specific queries under everything for rich business intelligence
        final response = await dioClient.dio.get(
          ApiConstants.everything,
          queryParameters: {
            'q': normalizedCategory,
            'language': 'en',
            'sortBy': 'publishedAt',
            'page': page,
            'pageSize': pageSize,
          },
        );
        return NewsResponseModel.fromJson(
          response.data as Map<String, dynamic>,
          category: category,
        );
      }
    } catch (e) {
      throw DioClient.mapDioErrorToFailure(e);
    }
  }

  @override
  Future<NewsResponseModel> searchArticles({
    required String query,
    String sortBy = 'publishedAt',
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    try {
      final cleanQuery = query.trim();
      final response = await dioClient.dio.get(
        ApiConstants.everything,
        queryParameters: {
          'q': cleanQuery.isEmpty ? 'business' : cleanQuery,
          'language': 'en',
          'sortBy': sortBy,
          'page': page,
          'pageSize': pageSize,
        },
      );

      return NewsResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.mapDioErrorToFailure(e);
    }
  }
}
