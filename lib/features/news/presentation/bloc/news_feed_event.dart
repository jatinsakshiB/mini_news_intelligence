import 'package:equatable/equatable.dart';

abstract class NewsFeedEvent extends Equatable {
  const NewsFeedEvent();

  @override
  List<Object?> get props => [];
}

class FetchCategoryFeed extends NewsFeedEvent {
  final String category;

  const FetchCategoryFeed({this.category = 'General'});

  @override
  List<Object?> get props => [category];
}

class RefreshFeed extends NewsFeedEvent {
  const RefreshFeed();
}

class LoadMoreArticles extends NewsFeedEvent {
  const LoadMoreArticles();
}

class ChangeCategory extends NewsFeedEvent {
  final String category;

  const ChangeCategory(this.category);

  @override
  List<Object?> get props => [category];
}
