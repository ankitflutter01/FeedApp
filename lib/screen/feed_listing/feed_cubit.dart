import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/feed_model.dart';
part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit() : super(FeedInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<FeedModel> feeds = [];
  bool isLoadingComplete = true;
  bool isError = false;
  String error = "";

  // Fetch feed data
  Future<void> fetchFeeds() async {
    isLoadingComplete = true;
    emit(FeedInitial());
    try {
      feeds.clear();
      final snapshot = await _firestore
          .collection('feeds')
          .orderBy('dateTime', descending: true)
          .get();

      List<FeedModel> feedsData = snapshot.docs
          .map((doc) =>
          FeedModel.fromMap(doc.data(), doc.id))
          .toList();
      feeds.addAll(feedsData);
      isLoadingComplete = false;
      emit(FeedLoaded(feeds: feeds));
    } catch (e) {
      isError = true;
      error = e.toString();
      emit(FeedError(message: e.toString()));
    }
  }

  void updateData(){
    emit(FeedUpdate());
  }

  Future<void> toggleLike(String feedId, String userId) async {
    final index = feeds.indexWhere((f) => f.id == feedId);
    if (index == -1) return;

    final isLiked = feeds[index].likes.contains(userId);

    if (isLiked) {
      feeds[index].likes.remove(userId);
    } else {
      feeds[index].likes.add(userId);
    }

    // Update Firestore without re-fetching entire list
    await _firestore.collection('feeds').doc(feedId).update({
      'likes': isLiked
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId])
    });

    emit(FeedUpdated());
  }
}
