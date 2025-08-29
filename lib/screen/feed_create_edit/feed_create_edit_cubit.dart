import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/feed_model.dart';
import 'feed_create_edit_state.dart';

class FeedCreateEditCubit extends Cubit<FeedState> {
  FeedCreateEditCubit() : super(FeedInitial());

  String? _base64Image;

  // Image picker
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      _base64Image = base64Encode(bytes);
      emit(FeedImageSelected(_base64Image!));
    }
  }

  // Create feed
  Future<void> createFeed({
    required String caption,
  }) async {
    if (_base64Image == null) {
      emit(FeedError("Please select an image"));
      return;
    }

    emit(FeedLoading());

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        emit(FeedError("User profile not found"));
        return;
      }

      final userData = userDoc.data()!;
      final String userName = userData['name'] ?? 'Unknown User';
      final String userProfileImage = userData['profilePic'] ?? '';

      final feed = FeedModel(
        id: "",
        userId: userId,
        userName: userName, // Added
        userProfileImage: userProfileImage, // Added
        image: _base64Image!,
        caption: caption,
        dateTime: DateTime.now(),
        likes: [],
        comments: [],
      );

      await FirebaseFirestore.instance.collection('feeds').add(feed.toMap());

      emit(FeedSuccess("Feed created successfully"));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  // Edit feed
  Future<void> editFeed({
    required String feedId,
    required String caption,
  }) async {
    emit(FeedLoading());
    try {
      await FirebaseFirestore.instance.collection('feeds').doc(feedId).update({
        'caption': caption,
        if (_base64Image != null) 'image': _base64Image,
      });
      emit(FeedSuccess("Feed updated successfully"));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }
}
