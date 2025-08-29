import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../untils/app_color.dart';
import '../../untils/app_string.dart';
import '../../untils/common_widget.dart';
import '../feed_create_edit/feed_create_edit_view.dart';

class MyFeedsScreen extends StatefulWidget {
  const MyFeedsScreen({super.key});

  @override
  State<MyFeedsScreen> createState() => _MyFeedsScreenState();
}

class _MyFeedsScreenState extends State<MyFeedsScreen> {
  bool _showShimmer = true;

  @override
  void initState() {
    super.initState();
    // Delay to show shimmer effect for at least 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.whiteColorShade,
        foregroundColor: AppColors.blackColorShade2,
        title: const  CommonAppText(
          text: AppStrings.myFeedsTitle,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.greyColorShade100,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('feeds')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (_showShimmer || snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState(context);
            }

            final feeds = snapshot.data!.docs;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: feeds.length,
              itemBuilder: (context, index) {
                final feed = feeds[index].data() as Map<String, dynamic>;
                final feedId = feeds[index].id;
                final imageBase64 = feed['image'];
                final caption = feed['caption'] ?? "";

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.whiteColorShade,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.memory(
                            base64Decode(imageBase64),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            width: double.infinity,
                            color: Colors.black.withOpacity(0.4),
                            child: CommonAppText(
                              text: caption.isEmpty ? AppStrings.noCaption : caption,
                              color: AppColors.whiteColorShade,
                              fontSize: 12,
                              textOverflow: TextOverflow.ellipsis,
                              maxLine: 1,
                              textAlignment: TextAlign.center,
                            ),
                          ),
                        ),
                        // Edit Button
                        Positioned(
                          top: 8,
                          right: 48,
                          child: _actionButton(
                            icon: Icons.edit,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FeedCreateEditScreen(
                                    feedId: feedId,
                                    existingCaption: caption,
                                    existingImage: imageBase64,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Delete Button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _actionButton(
                            icon: Icons.delete,
                            onTap: () async {
                              final confirm = await _showDeleteDialog(context);
                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('feeds')
                                    .doc(feedId)
                                    .delete();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.blackColorShade2,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FeedCreateEditScreen(),
            ),
          );
        },
        label: const  CommonAppText(text:
          AppStrings.createFeed,
          color: AppColors.whiteColorShade,
        ),
        icon: const Icon(Icons.add, color: AppColors.whiteColorShade),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            color: AppColors.whiteColorShade,
            size: 18,
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const  CommonAppText(text:AppStrings.deleteFeedTitle),
        content: const  CommonAppText(text:AppStrings.deleteFeedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const  CommonAppText(text:AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const  CommonAppText(text:AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColorShade,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_album_outlined,
              size: 80, color: Colors.grey.withOpacity(0.6)),
          const SizedBox(height: 16),
          CommonAppText(
            text: AppStrings.noFeedsYet,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            maxLine: 1,
            textAlignment: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CommonAppText(
            text: AppStrings.startCreatingFirstFeed,
            fontSize: 14,
            color: AppColors.greyColorShade,
            maxLine: 2,
            textAlignment: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blackColorShade2,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.add, color: AppColors.whiteColorShade),
            label: const  CommonAppText(text:
              AppStrings.createFeed,
              color: AppColors.whiteColorShade,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FeedCreateEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
