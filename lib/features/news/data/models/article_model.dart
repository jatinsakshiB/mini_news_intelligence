import 'package:equatable/equatable.dart';

class ArticleSource extends Equatable {
  final String? id;
  final String name;

  const ArticleSource({this.id, required this.name});

  factory ArticleSource.fromJson(Map<String, dynamic> json) {
    return ArticleSource(
      id: json['id'] as String?,
      name: (json['name'] as String?)?.trim() ?? 'Unknown Source',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

class ArticleModel extends Equatable {
  final String? sourceName;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final String? category;

  const ArticleModel({
    this.sourceName,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.category,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json, {String? category}) {
    final sourceObj = json['source'];
    String? source;
    if (sourceObj is Map<String, dynamic>) {
      source = sourceObj['name'] as String?;
    } else if (sourceObj is String) {
      source = sourceObj;
    }

    return ArticleModel(
      sourceName: source ?? 'News',
      author: json['author'] as String?,
      title: (json['title'] as String?)?.trim() ?? 'Untitled',
      description: json['description'] as String?,
      url: (json['url'] as String?) ?? '',
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String?,
      content: json['content'] as String?,
      category: category ?? json['category'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'sourceName': sourceName,
    'author': author,
    'title': title,
    'description': description,
    'url': url,
    'urlToImage': urlToImage,
    'publishedAt': publishedAt,
    'content': content,
    'category': category,
  };

  factory ArticleModel.fromMap(Map<dynamic, dynamic> map) {
    return ArticleModel(
      sourceName: map['sourceName'] as String?,
      author: map['author'] as String?,
      title: (map['title'] as String?) ?? 'Untitled',
      description: map['description'] as String?,
      url: (map['url'] as String?) ?? '',
      urlToImage: map['urlToImage'] as String?,
      publishedAt: map['publishedAt'] as String?,
      content: map['content'] as String?,
      category: map['category'] as String?,
    );
  }

  ArticleModel copyWith({
    String? sourceName,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
    String? category,
  }) {
    return ArticleModel(
      sourceName: sourceName ?? this.sourceName,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [url, title, sourceName, publishedAt, urlToImage];
}
