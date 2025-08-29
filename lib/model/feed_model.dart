import 'comment_model.dart';

class FeedModel {
  final String id; // Firestore document ID
  final String userId;
  final String userName; // NEW
  final String userProfileImage; // NEW
  final String image; // base64 string
  final String caption;
  final DateTime dateTime;
  final List<String> likes;
  final List<dynamic> comments;

  FeedModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.image,
    required this.caption,
    required this.dateTime,
    required this.likes,
    required this.comments,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName, // NEW
      'userProfileImage': userProfileImage, // NEW
      'image': image,
      'caption': caption,
      'dateTime': dateTime.toIso8601String(),
      'likes': likes,
      'comments': comments.map((c) => c.toMap()).toList(),
    };
  }

  factory FeedModel.fromMap(Map<String, dynamic> map, String docId) {
    return FeedModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',
      userProfileImage: map['userProfileImage'] ?? '',
      image: map['image'] ?? '',
      caption: map['caption'] ?? '',
      dateTime: DateTime.tryParse(map['dateTime'] ?? '') ?? DateTime.now(),
      likes: List<String>.from(map['likes'] ?? []),
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((c) => c)
          .toList(),
    );
  }
}
