import 'dart:async';

import 'package:app/design/button.dart';
import 'package:app/design/avatar.dart';
import 'package:app/design/avatar_blockies.dart';
import 'package:app/models/post.dart';
import 'package:app/screens/design_system.dart';
import 'package:app/screens/feed/new_post.dart';
import 'package:app/state/feed.dart';
import 'package:app/utils/address.dart';
import 'package:app/widgets/post_card.dart';
import 'package:app/widgets/transaction_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
        leading: Container(
          width: 60,
          child: FlyBox(
            children: [
              FlyIcon(LucideIcons.shield).w('s3').h('s3').color('green600'),
              FlyText('Tor').text('xs').weight('bold').color('green600'),
            ],
          ).row().items('center').gap('s1').px('s1').py('s1').bg('green50').rounded('sm').border(1).borderColor('green200'),
        ),
        trailing: FlyAvatar(
          size: AvatarSize.sm,
          shape: AvatarShape.circular,
          child: FlyAvatarBlockies(
            address: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6', // Current user's address
            size: AvatarSize.sm,
            shape: AvatarShape.circular,
            fallbackText: AddressUtils.getAddressInitials('0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6'),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Scrollable content area
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                scrollBehavior: const CupertinoScrollBehavior(),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: handleRefresh,
                  ), // the Future returned by the function is what makes the spinner go away
                  SliverToBoxAdapter(
                    child: FlyBox(
                      children: [
                        // Build all post cards
                        ...posts.map((post) => _buildPostCard(post)),
                        // Show loading indicator at the bottom if loading more
                        if (isLoadingMore) _buildLoadingIndicator(),
                      ],
                    ).col().gap('s4').px('s4').py('s4'),
                  ),
                  // Show "no posts posted" message if there are no posts at all
                  if (posts.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No posts found',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Fixed footer with balance and add button
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: FlyBox(
                children: [
                  // Balance card
                  FlyBox(
                    children: [
                      FlyText('balance').text('xs').color('gray600'),
                      FlyText('45.6 USDC').text('lg').weight('bold').color('gray900'),
                    ],
                  ).col().gap('s1').px('s3').py('s2').bg('white').rounded('lg'),
                  
                  // Add button
                  FlyButton(
                    onTap: handleCreatePost,
                    buttonColor: ButtonColor.primary,
                    variant: ButtonVariant.solid,
                    child: FlyIcon(LucideIcons.plus).color('white'),
                  ),
                ],
              ).row().items('center').justify('between').px('s4').py('s3'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return PostCard(
      key: Key(post.id),
      userAddress: post.userId, // Using userId as the user's public key/address
      userName: post.userName,
      content: post.content,
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
              status: post.transaction!.timeAgo == 'Pending' ? 'Request Pending' : 
                      post.transaction!.timeAgo == 'Complete' ? 'Request Complete' : 'Completed',
              onBackTap: () {
                // Handle back navigation
                print('Back tapped on transaction card');
              },
              onDeleteTap: () {
                // Handle delete action
                print('Delete tapped on transaction card');
              },
              onFulfillRequest: () {
                // Print callback for fulfill request
                print('Fulfill request callback triggered for ${post.transaction!.senderName}');
              },
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
