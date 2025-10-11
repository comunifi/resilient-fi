import 'package:app/design/avatar.dart';
import 'package:app/design/button.dart';
import 'package:app/models/post.dart';
import 'package:app/screens/feed/new_post.dart';
import 'package:app/screens/feed/profile.dart';
import 'package:app/state/feed.dart';
import 'package:app/widgets/post_card.dart';
import 'package:app/widgets/transaction_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  late FeedState _feedState;

  @override
  void initState() {
    super.initState();

    _feedState = context.read<FeedState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoad();
    });
  }

  void onLoad() {
    _feedState.loadPosts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> handleRefresh() async {
    await _feedState.loadPosts();
  }

  Future<void> handleProfile() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => const DraggableProfileScreen(),
    );
  }

  Future<void> handleCreatePost() async {
    // modals and navigation in general can be awaited and return a value
    // when inside SimpleNewPostScreen and navigator.pop(value) is called, value is returned
    final content = await showCupertinoModalPopup<String?>(
      context: context,
      builder: (context) => const SimpleNewPostScreen(),
    );

    if (content == null || content.isEmpty) {
      return;
    }

    await _feedState.createPost(content);
  }

  @override
  Widget build(BuildContext context) {
    final posts = context
        .watch<FeedState>()
        .posts; // this is how you watch a specific part of the state

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Comunifi'),
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        brightness: Brightness.dark,
        trailing: FlyButton(
          onTap: handleProfile,
          variant: ButtonVariant.unstyled,
          child: FlyAvatar(
            size: AvatarSize.xs,
            shape: AvatarShape.circular,
            children: [
              FlyAvatarFallback(fallbackText: 'JS', fallbackIcon: Icons.person),
            ],
          ),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              scrollBehavior: const CupertinoScrollBehavior(),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: handleRefresh,
                ), // the Future returned by the function is what makes the spinner go away
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: posts.length,
                    (context, index) => _buildPostCard(posts[index]),
                  ),
                ),
              ],
            ),
            // Floating action button for new post
            Positioned(
              bottom: 20,
              right: 20,
              child:
                  FlyButton(
                        onTap: handleCreatePost,
                        variant: ButtonVariant.unstyled,
                        child: FlyIcon(Icons.add).color('white'),
                      )
                      .w(60)
                      .h(60)
                      .rounded('999px')
                      .bg(CupertinoTheme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return PostCard(
      key: Key(post.id),
      userName: post.userName,
      userId: post.userId,
      content: post.content,
      userInitials: post.userInitials,
      likeCount: post.likeCount,
      dislikeCount: post.dislikeCount,
      commentCount: post.commentCount,
      transaction: post.transaction != null
          ? TransactionCard(
              senderName: post.transaction!.senderName,
              amount: post.transaction!.amount,
              timeAgo: post.transaction!.timeAgo,
              senderInitials: post.transaction!.senderInitials,
            )
          : null,
      onLike: () {
        // TODO: Implement like functionality
      },
      onDislike: () {
        // TODO: Implement dislike functionality
      },
      onComment: () {
        // Navigate to post details page
        context.push('/user123/posts/${post.id}');
      },
      onShare: () {
        // TODO: Implement share functionality
      },
      onMore: () {
        // TODO: Implement more options functionality
      },
    );
  }
}
