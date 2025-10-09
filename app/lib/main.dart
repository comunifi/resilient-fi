import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import 'design/avatar.dart';
import 'design/button.dart';
import 'screens/new_post.dart';
import 'screens/profile.dart';
import 'widgets/post_card.dart';
import 'widgets/transaction_card.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Flywind(
      themeMode: ThemeMode.system,
      themeData: FlyThemeData.withDefaults(),
      appBuilder: (context) {
        return CupertinoApp(
          title: 'Comunifi',
          theme: CupertinoThemeData(
            primaryColor: const Color(0xFF7c5cbd), // Purple theme
            brightness: Brightness.light,
          ),
          home: const SocialFeedScreen(),
        );
      },
    );
  }
}

class SocialFeedScreen extends StatelessWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Comunifi'),
        backgroundColor: const Color(0xFF7c5cbd),
        brightness: Brightness.dark,
        trailing: FlyButton(
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (context) => const DraggableProfileScreen(),
            );
          },
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
            SingleChildScrollView(
              child: FlyBox(
                children: _buildFeedPosts(),
              ).col().gap('s4').px('s4'),
            ),
            // Floating action button for new post
            Positioned(
              bottom: 20,
              right: 20,
              child:
                  FlyButton(
                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) => const SimpleNewPostScreen(),
                          );
                        },
                        variant: ButtonVariant.unstyled,
                        child: FlyIcon(
                          Icons.add,
                        ).color('white').w('s6').h('s6'),
                      )
                      .w('s14')
                      .h('s14')
                      .bg('purple600')
                      .rounded('999px')
                      .items('center')
                      .justify('center'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeedPosts() {
    return [
      // Regular post
      PostCard(
        userName: 'John Smith',
        userId: '##d',
        content:
            'Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae. Ex sapien vitae pellentesque sem placer...',
        userInitials: 'JS',
        likeCount: 12,
        dislikeCount: 3,
        commentCount: 8,
        onLike: () {},
        onDislike: () {},
        onComment: () {},
        onShare: () {},
        onMore: () {},
      ),

      // Post with transaction
      PostCard(
        userName: 'John Smith',
        userId: '##d',
        content:
            'Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae. Ex sapien vitae pellentesque sem placer...',
        userInitials: 'JS',
        likeCount: 24,
        dislikeCount: 1,
        commentCount: 15,
        transaction: TransactionCard(
          senderName: 'John Smith',
          amount: '1,250 USDC',
          timeAgo: '2 days ago',
          senderInitials: 'JS',
        ),
        onLike: () {},
        onDislike: () {},
        onComment: () {},
        onShare: () {},
        onMore: () {},
      ),

      // Another regular post
      PostCard(
        userName: 'Sarah Wilson',
        userId: '##e',
        content:
            'Just finished an amazing DeFi protocol integration! The community response has been incredible. Building the future of finance one transaction at a time.',
        userInitials: 'SW',
        likeCount: 45,
        dislikeCount: 2,
        commentCount: 23,
        onLike: () {},
        onDislike: () {},
        onComment: () {},
        onShare: () {},
        onMore: () {},
      ),

      // Post with transaction
      PostCard(
        userName: 'Mike Chen',
        userId: '##f',
        content:
            'Excited to share our latest liquidity pool metrics. The numbers are looking fantastic!',
        userInitials: 'MC',
        likeCount: 18,
        dislikeCount: 0,
        commentCount: 7,
        transaction: TransactionCard(
          senderName: 'Mike Chen',
          amount: '5,750 USDC',
          timeAgo: '1 day ago',
          senderInitials: 'MC',
        ),
        onLike: () {},
        onDislike: () {},
        onComment: () {},
        onShare: () {},
        onMore: () {},
      ),

      // Another regular post
      PostCard(
        userName: 'Alex Rodriguez',
        userId: '##g',
        content:
            'The DeFi space is evolving so rapidly. What innovations are you most excited about?',
        userInitials: 'AR',
        likeCount: 32,
        dislikeCount: 1,
        commentCount: 19,
        onLike: () {},
        onDislike: () {},
        onComment: () {},
        onShare: () {},
        onMore: () {},
      ),
    ];
  }
}
