part of 'feed_cubit.dart';

abstract class FeedState {}

class FeedInitial extends FeedState {}

class FeedUpdate extends FeedState {}

class FeedLoaded extends FeedState {
  final List<FeedModel> feeds;
  FeedLoaded({required this.feeds});
}

class FeedError extends FeedState {
  final String message;
  FeedError({required this.message});
}

class FeedUpdated extends FeedState {
  FeedUpdated();
}