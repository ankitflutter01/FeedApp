import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String userProfileImage;
  final String text;
  final DateTime dateTime;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.text,
    required this.dateTime,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfileImage: map['userProfileImage'] ?? '',
      text: map['text'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'text': text,
      'dateTime': dateTime,
    };
  }
}
