import 'dart:async';

import 'package:app/design/avatar.dart';
import 'package:app/design/button.dart';
import 'package:app/models/post.dart';
import 'package:app/screens/design_system.dart';
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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _feedState = context.read<FeedState>();
    _scrollController = ScrollController();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoad();
    });
  }

  void onLoad() {
    _feedState.init();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if we've scrolled to the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more posts when near the bottom
      _feedState.loadMorePosts();
    }
  }

  Future<void> handleRefresh() async {
    await _feedState.refreshPosts();
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

  void handleDesignSystem() {
    print('🎨 handleDesignSystem() called!'); // Enhanced debug output
    try {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => const DesignSystemScreen(),
        ),
      );
      print('✅ Navigation to DesignSystemScreen initiated');
    } catch (e) {
      print('❌ Error navigating to DesignSystemScreen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = context.watch<FeedState>();
    final posts = feedState.posts;
    final isLoadingMore = feedState.isLoadingMore;
    final hasMorePosts = feedState.hasMorePosts;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Comunifi'),
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        brightness: Brightness.dark,
        trailing: FlyButton(
          onTap: handleProfile,
          buttonColor: ButtonColor.secondary,
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
              controller: _scrollController,
              scrollBehavior: const CupertinoScrollBehavior(),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: handleRefresh,
                ), // the Future returned by the function is what makes the spinner go away
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: posts.length + (isLoadingMore ? 1 : 0),
                    (context, index) {
                      // Show loading indicator at the bottom
                      if (index == posts.length) {
                        return _buildLoadingIndicator();
                      }
                      return _buildPostCard(posts[index]);
                    },
                  ),
                ),
                // Show "no more posts" message if we've reached the end
                if (!hasMorePosts && posts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: const Center(
                        child: Text(
                          'No more posts to load',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Floating action button for new post
            Positioned(
              bottom: 20,
              right: 20,
              child: FlyButton(
                onTap: handleCreatePost,
                buttonColor: ButtonColor.secondary,
                width: 60,
                height: 60,
                flyStyle: FlyStyle(
                  rounded: '999px',
                  bg: CupertinoTheme.of(context).primaryColor,
                ),
                child: FlyIcon(Icons.add).color('white'),
              ),
            ),
            // Temporary design system button for testing
            Positioned(
              bottom: 20,
              left: 20,
              child: CupertinoButton(
                onPressed: () {
                  print('Design system button tapped from FAB!');
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const DesignSystemScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: Colors.white,
                  ),
                ),
              ),
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
      createdAt: post.createdAt,
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

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: CupertinoActivityIndicator()),
    );
  }
}
