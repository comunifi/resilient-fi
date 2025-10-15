import 'package:app/design/button.dart';
import 'package:app/models/post.dart';
import 'package:app/state/post.dart';
import 'package:app/widgets/post_card.dart';
import 'package:app/widgets/transaction_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flywind/flywind.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  late PostState _postState;

  @override
  void initState() {
    super.initState();
    _postState = PostState(widget.postId);
    _loadData();
  }

  Future<void> _loadData() async {
    await _postState.loadPost();
    await _postState.loadReplies();
  }

  @override
  void dispose() {
    _postState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _postState,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Post'),
          backgroundColor: CupertinoTheme.of(context).primaryColor,
          brightness: Brightness.dark,
          leading: FlyButton(
            onTap: () => GoRouter.of(context).pop(),
            buttonColor: ButtonColor.secondary,
            child: FlyIcon(
              CupertinoIcons.back,
            ).color(FlyColorToken.defaultColor().purple400),
          ),
        ),
        child: SafeArea(
          child: Consumer<PostState>(
            builder: (context, postState, child) {
              return CustomScrollView(
                scrollBehavior: const CupertinoScrollBehavior(),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: _postState.refreshPost,
                  ),

                  // Main post at the top
                  if (postState.isLoading)
                    SliverToBoxAdapter(child: _buildPostSkeleton())
                  else if (postState.post == null)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: FlyText(
                            'Post not found',
                          ).text('lg').color('gray500'),
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(child: _buildMainPost(postState.post!)),

                  // Replies section
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FlyText(
                            'Replies',
                          ).text('lg').weight('semibold').color('gray800'),
                          FlyText(
                            postState.isLoading
                                ? 'Loading replies...'
                                : '${postState.replies.length} replies',
                          ).text('sm').color('gray500'),
                        ],
                      ),
                    ),
                  ),

                  // Replies list
                  if (postState.isLoadingReplies)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildReplySkeleton(),
                        childCount: 3, // Show 3 skeleton replies
                      ),
                    )
                  else if (postState.replies.isEmpty && !postState.isLoading)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: FlyText(
                            'No replies yet',
                          ).text('base').color('gray500'),
                        ),
                      ),
                    )
                  else if (postState.replies.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final reply = postState.replies[index];
                        return _buildReplyCard(reply);
                      }, childCount: postState.replies.length),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainPost(Post post) {
    final postCard = PostCard(
      userAddress: post.userId, // Using userId as the user's public key/address
      userName: post.userName,
      content: post.content,
      userAvatarUrl: post.userAvatarUrl,
      userInitials: post.userInitials,
      likeCount: post.likeCount,
      dislikeCount: post.dislikeCount,
      commentCount: post.commentCount,
      transaction: post.transaction != null
          ? TransactionCard(
              senderName: post.transaction!.senderName,
              senderAddress: post.userId, // Use the post author's address as sender address
              amount: post.transaction!.amount,
              timeAgo: post.transaction!.timeAgo,
              senderInitials: post.transaction!.senderInitials,
            )
          : null,
      createdAt: post.createdAt,
      onLike: () {
        // TODO: Implement like functionality
      },
      onDislike: () {
        // TODO: Implement dislike functionality
      },
      onComment: () {
        // TODO: Implement comment functionality
      },
      onShare: () {
        // TODO: Implement share functionality
      },
      onMore: () {
        // TODO: Implement more options
      },
    );
    return Padding(padding: const EdgeInsets.all(16.0), child: postCard);
  }

  Widget _buildReplyCard(Post reply) {
    final replyCard = PostCard(
      userAddress: reply.userId, // Using userId as the user's public key/address
      userName: reply.userName,
      content: reply.content,
      userAvatarUrl: reply.userAvatarUrl,
      userInitials: reply.userInitials,
      likeCount: reply.likeCount,
      dislikeCount: reply.dislikeCount,
      commentCount: reply.commentCount,
      transaction: reply.transaction != null
          ? TransactionCard(
              senderName: reply.transaction!.senderName,
              senderAddress: reply.userId, // Use the reply author's address as sender address
              amount: reply.transaction!.amount,
              timeAgo: reply.transaction!.timeAgo,
              senderInitials: reply.transaction!.senderInitials,
            )
          : null,
      createdAt: reply.createdAt,
      onLike: () {
        // TODO: Implement like functionality for replies
      },
      onDislike: () {
        // TODO: Implement dislike functionality for replies
      },
      onComment: () {
        // TODO: Implement comment functionality for replies
      },
      onShare: () {
        // TODO: Implement share functionality for replies
      },
      onMore: () {
        // TODO: Implement more options for replies
      },
    );
    return Padding(padding: const EdgeInsets.all(16.0), child: replyCard);
  }

  Widget _buildPostSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              // Avatar skeleton
              _buildShimmerContainer(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
              ),
              const SizedBox(width: 12),
              // Name and ID skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerContainer(
                      height: 16,
                      width: 120,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    _buildShimmerContainer(
                      height: 12,
                      width: 80,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content skeleton
          _buildShimmerContainer(
            height: 16,
            width: double.infinity,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          _buildShimmerContainer(
            height: 16,
            width: 250,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          _buildShimmerContainer(
            height: 16,
            width: 180,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          // Action buttons skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildShimmerContainer(
                    height: 20,
                    width: 60,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(width: 20),
                  _buildShimmerContainer(
                    height: 20,
                    width: 60,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              _buildShimmerContainer(
                height: 20,
                width: 60,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplySkeleton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              // Avatar skeleton
              _buildShimmerContainer(
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(width: 12),
              // Name and ID skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerContainer(
                      height: 14,
                      width: 100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    _buildShimmerContainer(
                      height: 10,
                      width: 60,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Content skeleton
          _buildShimmerContainer(
            height: 14,
            width: double.infinity,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          _buildShimmerContainer(
            height: 14,
            width: 200,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          // Action buttons skeleton
          Row(
            children: [
              _buildShimmerContainer(
                height: 18,
                width: 50,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 16),
              _buildShimmerContainer(
                height: 18,
                width: 50,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer({
    required double? width,
    required double? height,
    required BorderRadius borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: borderRadius,
      ),
    );
  }
}
