import 'dart:async';

import 'package:app/models/post.dart';
import 'package:app/models/transaction.dart';
import 'package:app/services/nostr/nostr.dart';
import 'package:app/utils/delay.dart';
import 'package:flutter/cupertino.dart';

class FeedState extends ChangeNotifier {
  // instantiate services here - local storage, db, api, etc.
  final NostrService _nostrService;

  // private variables here - things that the UI doesn't need
  final String _userId;

  // constructor here - you could pass a user id to the constructor and use it to trigger all methods with that user id
  FeedState(this._userId) : _nostrService = NostrService();

  void init() {
    print('FeedState initialized');
    _nostrService.initialize((isConnected) {
      print('isConnected: $isConnected');
      if (!this.isConnected && isConnected) {
        startListening();
      }

      this.isConnected = isConnected;
      safeNotifyListeners();
    });
  }

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
    _messageSubscription?.cancel();
    _nostrService.disconnect();
    super.dispose();
  }

  // state variables here - things that are observable by the UI
  final List<Post> posts = [];
  bool isLoading = false;
  bool isConnected = false;
  StreamSubscription<Post>? _messageSubscription;

  Future<void> startListening() async {
    if (_messageSubscription != null) {
      await _messageSubscription!.cancel();
    }

    _messageSubscription = _nostrService.listenToMessages().listen(
      (post) {
        // Add new posts to the beginning of the list
        posts.insert(0, post);
        safeNotifyListeners();
      },
      onError: (error) {
        print('Error listening to messages: $error');
      },
    );
  }

  Future<void> loadPosts() async {
    isLoading = true;

    safeNotifyListeners(); // call this to tell the UI to update

    posts.clear();
    posts.addAll(mockPosts);
    safeNotifyListeners(); // call this to tell the UI to update

    // just for fake loading since provider will optimize the updates, you won't see true/false loading unless there's a fake delay while we test things
    await delay(const Duration(seconds: 1));

    isLoading = false;
    safeNotifyListeners(); // call this to tell the UI to update
  }

  Future<void> createPost(String content) async {
    isLoading = true;
    safeNotifyListeners();

    final post = await _nostrService.createPost(content);

    posts.insert(0, post);

    isLoading = false;
    safeNotifyListeners();
  }
}

// just for the example until we hook up nostr
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
