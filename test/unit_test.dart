import 'package:flutter_test/flutter_test.dart';
import 'package:mini_news_intelligence/core/utils/date_formatter.dart';
import 'package:mini_news_intelligence/core/utils/password_hasher.dart';
import 'package:mini_news_intelligence/features/news/data/models/article_model.dart';
import 'package:mini_news_intelligence/features/news/data/models/news_response_model.dart';

void main() {
  group('PasswordHasher', () {
    test('hashes password consistently and verifies correctly', () {
      const password = 'mySecretPassword123';
      final hash1 = PasswordHasher.hashPassword(password);
      final hash2 = PasswordHasher.hashPassword(password);

      expect(hash1, equals(hash2));
      expect(PasswordHasher.verify(password, hash1), isTrue);
      expect(PasswordHasher.verify('wrongPassword', hash1), isFalse);
    });
  });

  group('DateFormatter', () {
    test('formats relative dates accurately', () {
      final now = DateTime.now();
      final oneHourAgo = now
          .subtract(const Duration(hours: 1))
          .toIso8601String();
      final relative = DateFormatter.formatRelative(oneHourAgo);

      expect(relative.contains('hour'), isTrue);
    });

    test('handles empty or null gracefully', () {
      expect(DateFormatter.formatRelative(null), equals(''));
      expect(DateFormatter.formatRelative(''), equals(''));
      expect(DateFormatter.formatFull(null), equals(''));
    });

    test('estimates reading time reasonably', () {
      final readTime = DateFormatter.estimateReadTime(
        'Some long content here',
        'Description',
      );
      expect(readTime.contains('min read'), isTrue);
    });
  });

  group('ArticleModel', () {
    test('parses json correctly and handles nulls safely', () {
      final json = {
        'source': {'id': 'bloomberg', 'name': 'Bloomberg'},
        'author': 'Jane Doe',
        'title': 'Tech Stocks Rally on Q3 Earnings',
        'description': 'Markets saw strong gains across tech sector.',
        'url': 'https://example.com/article1',
        'urlToImage': 'https://example.com/image1.jpg',
        'publishedAt': '2026-10-29T10:00:00Z',
        'content': 'Stocks rose on Thursday...',
      };

      final article = ArticleModel.fromJson(json, category: 'Markets');

      expect(article.sourceName, equals('Bloomberg'));
      expect(article.title, equals('Tech Stocks Rally on Q3 Earnings'));
      expect(article.category, equals('Markets'));

      // Test map serialization for Hive
      final map = article.toMap();
      final fromMapArticle = ArticleModel.fromMap(map);

      expect(fromMapArticle.url, equals(article.url));
      expect(fromMapArticle.title, equals(article.title));
    });

    test('NewsResponseModel filters out removed articles', () {
      final json = {
        'status': 'ok',
        'totalResults': 2,
        'articles': [
          {
            'source': {'name': 'Reuters'},
            'title': '[Removed]',
            'url': 'https://example.com/removed',
          },
          {
            'source': {'name': 'WSJ'},
            'title': 'Federal Reserve Holds Rates Steady',
            'url': 'https://example.com/valid',
          },
        ],
      };

      final response = NewsResponseModel.fromJson(json);
      expect(response.articles.length, equals(1));
      expect(
        response.articles.first.title,
        equals('Federal Reserve Holds Rates Steady'),
      );
    });
  });
}
