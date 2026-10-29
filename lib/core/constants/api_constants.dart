class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://newsapi.org/v2';

  // Provided NewsAPI key
  static const String apiKey = '42b8effdc37a42449be0d893b83b033e';

  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';

  static const int defaultPageSize = 20;

  static const List<String> businessCategories = [
    'General',
    'Technology',
    'Markets',
    'Economy',
    'Startups',
    'Finance',
  ];
}
