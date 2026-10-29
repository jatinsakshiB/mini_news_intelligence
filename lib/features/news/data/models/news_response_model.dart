import 'article_model.dart';

class NewsResponseModel {
  final String status;
  final int totalResults;
  final List<ArticleModel> articles;

  const NewsResponseModel({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponseModel.fromJson(
    Map<String, dynamic> json, {
    String? category,
  }) {
    final rawArticles = json['articles'] as List<dynamic>? ?? [];
    final List<ArticleModel> list = [];

    for (final item in rawArticles) {
      if (item is Map<String, dynamic>) {
        final title = item['title'] as String?;
        // Ignore removed / invalid articles
        if (title != null &&
            !title.contains('[Removed]') &&
            title.trim().isNotEmpty) {
          list.add(ArticleModel.fromJson(item, category: category));
        }
      }
    }

    return NewsResponseModel(
      status: (json['status'] as String?) ?? 'ok',
      totalResults: (json['totalResults'] as int?) ?? list.length,
      articles: list,
    );
  }
}
