abstract class FeedState {}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedSuccess extends FeedState {
  final String message;
  FeedSuccess(this.message);
}

class FeedError extends FeedState {
  final String error;
  FeedError(this.error);
}

class FeedImageSelected extends FeedState {
  final String base64Image;
  FeedImageSelected(this.base64Image);
}
