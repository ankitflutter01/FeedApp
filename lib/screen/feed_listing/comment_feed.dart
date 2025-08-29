import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/comment_model.dart';
import '../../untils/app_string.dart';
import '../../untils/common_widget.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String feedId;

  const CommentsBottomSheet({super.key, required this.feedId});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('feeds')
                        .doc(widget.feedId)
                        .collection('comments')
                        .orderBy('dateTime', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child:  CommonAppText(text:
                            AppStrings.noCommentYet,
                            color:  Colors.grey,
                          ),
                        );
                      }

                      final comments = snapshot.data!.docs.map((doc) {
                        return CommentModel.fromMap(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        );
                      }).toList();

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: comment.userProfileImage.isNotEmpty
                                  ? MemoryImage(base64Decode(comment.userProfileImage))
                                  : null,
                              child: comment.userProfileImage.isEmpty
                                  ? CommonAppText(text:comment.userName.isNotEmpty
                                  ? comment.userName[0].toUpperCase()
                                  : "?")
                                  : null,
                            ),
                            title: CommonAppText(text:comment.userName,
                                fontWeight: FontWeight.w600,
                                ),
                            subtitle:  CommonAppText(text:comment.text),
                            trailing: CommonAppText(text:
                              "${comment.dateTime.hour}:${comment.dateTime.minute.toString().padLeft(2, '0')}",
                              color:Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: AppStrings.addComment,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _postComment,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

        },
      ),
    );
  }

  Future<void> _postComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || user == null) return;

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userData = userDoc.data()!;
    _controller.clear();
    final comment = CommentModel(
      id: '',
      userId: userId,
      userName: userData['name'] ?? "User",
      userProfileImage: userData['profilePic'],
      text: text,
      dateTime: DateTime.now(),
    );
    final feedRef = FirebaseFirestore.instance.collection('feeds').doc(widget.feedId);

    final commentDocRef = await feedRef.collection('comments').add(comment.toMap());

    await feedRef.update({
      'comments': FieldValue.arrayUnion([
        {
          'id': commentDocRef.id,
          'text': comment.text,
          'userName': comment.userName,
          'userProfileImage': comment.userProfileImage,
          'dateTime': Timestamp.fromDate(comment.dateTime),
        }
      ])
    });
  }

}
