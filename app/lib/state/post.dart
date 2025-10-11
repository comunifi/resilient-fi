import 'dart:async';

import 'package:app/models/post.dart';
import 'package:app/models/transaction.dart';
import 'package:app/utils/delay.dart';
import 'package:flutter/cupertino.dart';

class PostState extends ChangeNotifier {
  // instantiate services here - local storage, db, api, etc.

  // private variables here - things that the UI doesn't need
  final String postId;

  // constructor here - you could pass a user id to the constructor and use it to trigger all methods with that user id
  PostState(this.postId);

  // life cycle methods here
  bool _mounted = true;
  void safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  // state variables here - things that are observable by the UI
  Post? post;
  final List<Post> replies = [];
  bool isLoading = false;
  bool isLoadingReplies = false;

  Future<void> loadPost() async {
    isLoading = true;
    safeNotifyListeners();

    // Find the post by ID from mock data
    post = mockPosts.firstWhere(
      (p) => p.id == postId,
      orElse: () => throw Exception('Post not found'),
    );

    safeNotifyListeners();

    // Simulate loading delay
    await delay(const Duration(milliseconds: 500));

    isLoading = false;
    safeNotifyListeners();
  }

  Future<void> loadReplies() async {
    isLoadingReplies = true;
    safeNotifyListeners();

    // Clear existing replies
    replies.clear();

    // Add mock replies
    replies.addAll(mockReplies);

    safeNotifyListeners();

    // Simulate loading delay
    await delay(const Duration(milliseconds: 800));

    isLoadingReplies = false;
    safeNotifyListeners();
  }

  Future<void> refreshPost() async {
    await Future.wait([loadPost(), loadReplies()]);
  }
}

// Mock replies data for testing
final List<Post> mockReplies = [
  Post(
    id: 'reply_1',
    userName: 'Alice Johnson',
    userId: '##a',
    content:
        'Great insights! I completely agree with your perspective on this topic.',
    userInitials: 'AJ',
    likeCount: 5,
    dislikeCount: 0,
    commentCount: 2,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  Post(
    id: 'reply_2',
    userName: 'Bob Wilson',
    userId: '##b',
    content:
        'This is exactly what I was thinking. The implementation details you mentioned are spot on.',
    userInitials: 'BW',
    likeCount: 8,
    dislikeCount: 1,
    commentCount: 0,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Post(
    id: 'reply_3',
    userName: 'Carol Davis',
    userId: '##c',
    content:
        'Interesting take! Have you considered the scalability implications?',
    userInitials: 'CD',
    likeCount: 3,
    dislikeCount: 0,
    commentCount: 1,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  Post(
    id: 'reply_4',
    userName: 'David Brown',
    userId: '##d',
    content:
        'Thanks for sharing this. It really helped clarify some concepts I was struggling with.',
    userInitials: 'DB',
    likeCount: 12,
    dislikeCount: 0,
    commentCount: 0,
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  Post(
    id: 'reply_5',
    userName: 'Eva Martinez',
    userId: '##e',
    content:
        'I\'ve been working on something similar. Would love to collaborate on this!',
    userInitials: 'EM',
    likeCount: 7,
    dislikeCount: 0,
    commentCount: 3,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
];

// Import mock posts from feed state
final List<Post> mockPosts = [
  // Regular post
  Post(
    id: 'post_1',
    userName: 'John Smith',
    userId: '##d',
    content:
        'Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae. Ex sapien vitae pellentesque sem placer...',
    userInitials: 'JS',
    likeCount: 12,
    dislikeCount: 3,
    commentCount: 8,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),

  // Post with transaction
  Post(
    id: 'post_2',
    userName: 'John Smith',
    userId: '##d',
    content:
        '2Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae. Ex sapien vitae pellentesque sem placer...',
    userInitials: 'JS',
    likeCount: 24,
    dislikeCount: 1,
    commentCount: 15,
    transaction: const Transaction(
      senderName: 'John Smith',
      amount: '1,250 USDC',
      timeAgo: '2 days ago',
      senderInitials: 'JS',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),

  // Another regular post
  Post(
    id: 'post_3',
    userName: 'Sarah Wilson',
    userId: '##e',
    content:
        'Just finished an amazing DeFi protocol integration! The community response has been incredible. Building the future of finance one transaction at a time.',
    userInitials: 'SW',
    likeCount: 45,
    dislikeCount: 2,
    commentCount: 23,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),

  // Post with transaction
  Post(
    id: 'post_4',
    userName: 'Mike Chen',
    userId: '##f',
    content:
        'Excited to share our latest liquidity pool metrics. The numbers are looking fantastic!',
    userInitials: 'MC',
    likeCount: 18,
    dislikeCount: 0,
    commentCount: 7,
    transaction: const Transaction(
      senderName: 'Mike Chen',
      amount: '5,750 USDC',
      timeAgo: '1 day ago',
      senderInitials: 'MC',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),

  // Another regular post
  Post(
    id: 'post_5',
    userName: 'Alex Rodriguez',
    userId: '##g',
    content:
        'The DeFi space is evolving so rapidly. What innovations are you most excited about?',
    userInitials: 'AR',
    likeCount: 32,
    dislikeCount: 1,
    commentCount: 19,
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
  ),
];
