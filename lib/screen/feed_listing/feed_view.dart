import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practical_task/untils/app_color.dart';
import 'package:shimmer/shimmer.dart';
import '../../model/feed_model.dart';
import '../../untils/app_string.dart';
import '../../untils/common_widget.dart';
import 'comment_feed.dart';
import 'feed_cubit.dart';

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedCubit()..fetchFeeds(),
      child: Scaffold(
        appBar: AppBar(
          title: const CommonAppText(
            text: AppStrings.feedLabel,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          backgroundColor: AppColors.whiteColorShade,
          foregroundColor: AppColors.blackColorShade2,
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: AppColors.greyColorShade100,
        body: BlocConsumer<FeedCubit, FeedState>(
          listener: (context, state) {
            if(state is FeedError){
              commonToast(state.message);
            }
          },
          builder: (context, state) {
            final cubit = BlocProvider.of<FeedCubit>(context);
            // return cubit.isLoadingComplete
            //     ? _buildShimmer()
            //     : cubit.feeds.isEmpty
            //     ? _buildEmptyState()
            //     : RefreshIndicator(
            //       onRefresh: () async {
            //         cubit.fetchFeeds();
            //       },
            //       child: listViewData(cubit)
            //     );

            if (cubit.isLoadingComplete) {
              return _buildShimmer();
            }

            if (cubit.isLoadingComplete == false) {
              final feeds = cubit.feeds;
              if (feeds.isEmpty) return _buildEmptyState();

              return RefreshIndicator(
                onRefresh: () async {
                  cubit.fetchFeeds();
                },
                // child: ListView.builder(
                //   itemCount: feeds.length,
                //   itemBuilder: (context, index) {
                //     final feed = feeds[index];
                //     final isLiked = feed.likes.contains(currentUser!.uid);
                //
                //     return _buildFeedItem(
                //       key: ValueKey(feed.id),
                //       feed: feed,
                //       isLiked: isLiked,
                //       cubit: context.read<FeedCubit>(),
                //     );
                //   },
                // ),
                child: listViewData(cubit)
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }


  Widget listViewData(FeedCubit cubit){
    return  ListView.builder(
      key: const PageStorageKey('main_feed_list'),
      itemCount: cubit.feeds.length,
      primary: false,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final feed = cubit.feeds[index];
        final isLiked = feed.likes.contains(currentUser!.uid);

        return _buildFeedItem(
          key: ValueKey(feed.id),
          feed: feed,
          isLiked: isLiked,
          cubit: context.read<FeedCubit>(),
        );
      },
    );
  }

  Widget _buildFeedItem({
    Key? key,
    required FeedModel feed,
    required bool isLiked,
    required FeedCubit cubit,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.whiteColorShade,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  feed.userProfileImage.isNotEmpty
                      ? MemoryImage(base64Decode(feed.userProfileImage))
                      : null,
              child:
                  feed.userProfileImage.isEmpty
                      ? CommonAppText(
                        text:
                            feed.userName.isNotEmpty
                                ? feed.userName[0].toUpperCase()
                                : "?",
                      )
                      : null,
            ),
            title: CommonAppText(
              text: feed.userName,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            subtitle: CommonAppText(
              text: DateFormat('dd MMM yyyy • hh:mm a').format(feed.dateTime),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (feed.image.isNotEmpty)
            Image.memory(
              base64Decode(feed.image),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color:
                        isLiked
                            ? AppColors.redColorShade
                            : AppColors.blackColorShade,
                  ),
                  onPressed: () async {
                    cubit.toggleLike(feed.id, currentUser!.uid);
                  },
                ),
                CommonAppText(text: "${feed.likes.length}"),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () => _openComments(feed.id, cubit),
                ),
                CommonAppText(text: "${feed.comments.length}"),
              ],
            ),
          ),
          if (feed.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CommonAppText(text: feed.caption, fontSize: 14),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _openComments(String feedId, FeedCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteColorShade,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CommentsBottomSheet(feedId: feedId),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_album_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          const CommonAppText(
            text: AppStrings.noPostAvailable,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
          const SizedBox(height: 8),
          CommonAppText(
            text: AppStrings.followMessage,
            color: AppColors.greyColorShade,
            fontSize: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder:
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: AppColors.greyColorShade100,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.whiteColorShade,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
    );
  }
}
