import 'dart:async';

import 'package:app/models/nostr_event.dart';
import 'package:app/models/post.dart';
import 'package:app/models/transaction.dart';
import 'package:app/services/nostr/nostr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FeedState extends ChangeNotifier {
  // instantiate services here - local storage, db, api, etc.
  final NostrService _nostrService;

  // constructor here - you could pass a user id to the constructor and use it to trigger all methods with that user id
  FeedState() : _nostrService = NostrService(dotenv.get('RELAY_URL'));

  void init() {
    _nostrService.connect((isConnected) async {
      if (!this.isConnected && isConnected) {
        _lastLoadedAt = DateTime.now();
        await startListening();
        loadPosts();
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
  bool isLoadingMore = false;
  bool isConnected = false;
  bool hasMorePosts = true;
  StreamSubscription<NostrEventModel>? _messageSubscription;

  DateTime? _lastLoadedAt;

  Future<void> startListening() async {
    if (_messageSubscription != null) {
      await _messageSubscription!.cancel();
    }

    _messageSubscription = _nostrService
        .listenToEvents(kind: 1, since: _lastLoadedAt)
        .listen(
          (event) {
            // Check if post already exists to avoid duplicates
            final existingPostIndex = posts.indexWhere(
              (existingPost) => existingPost.id == event.id,
            );

            if (existingPostIndex == -1) {
              // Add new posts to the beginning of the list
              posts.insert(
                0,
                Post(
                  id: event.id,
                  userName: event.pubkey,
                  userId: event.pubkey,
                  content: event.content,
                  createdAt: event.createdAt,
                  updatedAt: event.createdAt,
                ),
              );
              safeNotifyListeners();
            } else {
              posts[existingPostIndex] = Post(
                id: event.id,
                userName: event.pubkey,
                userId: event.pubkey,
                content: event.content,
                createdAt: event.createdAt,
                updatedAt: event.createdAt,
              );
              safeNotifyListeners();
            }
          },
          onError: (error) {
            debugPrint('Error listening to messages: $error');
          },
        );
  }

  Future<void> loadPosts() async {
    isLoading = true;
    hasMorePosts = true;
    safeNotifyListeners(); // call this to tell the UI to update

    try {
      final limit = 10;

      // Load initial limit posts from Nostr (most recent posts)
      final historicalEvents = await _nostrService.requestPastEvents(
        kind: 1,
        limit: limit,
        until: _lastLoadedAt,
      );

      final historicalPosts = historicalEvents
          .map(
            (event) => Post(
              id: event.id,
              userName: event.pubkey,
              userId: event.pubkey,
              content: event.content,
              createdAt: event.createdAt,
              updatedAt: event.createdAt,
            ),
          )
          .toList();

      posts.clear();
      upsertPosts(historicalPosts);

      // Add some mock posts with transactions for testing
      // _addMockPostsWithTransactions();

      // If we got less than 20 posts, we've reached the end
      if (historicalPosts.length < limit) {
        hasMorePosts = false;
      }

      safeNotifyListeners(); // call this to tell the UI to update
    } catch (e) {
      debugPrint('Error loading posts: $e');
      // Fallback to mock posts for development
      posts.clear();
      // _addMockPostsWithTransactions();
      safeNotifyListeners();
    }

    isLoading = false;
    safeNotifyListeners(); // call this to tell the UI to update
  }

  Future<void> refreshPosts() async {
    // Clear existing posts and reset pagination state
    posts.clear();
    hasMorePosts = true;
    safeNotifyListeners();

    // Cancel existing message subscription to restart fresh
    if (_messageSubscription != null) {
      await _messageSubscription!.cancel();
      _messageSubscription = null;
    }

    final limit = 10;
    _lastLoadedAt = DateTime.now();

    try {
      // Load the latest 20 posts from Nostr (most recent posts)
      final historicalEvents = await _nostrService.requestPastEvents(
        kind: 1,
        limit: limit,
        until: _lastLoadedAt,
      );

      final historicalPosts = historicalEvents
          .map(
            (event) => Post(
              id: event.id,
              userName: event.pubkey,
              userId: event.pubkey,
              content: event.content,
              createdAt: event.createdAt,
              updatedAt: event.createdAt,
            ),
          )
          .toList();

      upsertPosts(historicalPosts);

      // Add some mock posts with transactions for testing
      // _addMockPostsWithTransactions();

      // If we got less than limit posts, we've reached the end
      if (historicalPosts.length < limit) {
        hasMorePosts = false;
      }

      safeNotifyListeners();

      // Start listening for new messages after loading historical posts
      if (isConnected) {
        startListening();
      }
    } catch (e) {
      debugPrint('Error refreshing posts: $e');
      // Fallback to mock posts for development
      // _addMockPostsWithTransactions();
      safeNotifyListeners();
    }
  }

  Future<void> loadMorePosts() async {
    if (isLoadingMore || !hasMorePosts || posts.isEmpty) {
      return;
    }

    final limit = 10;

    isLoadingMore = true;
    safeNotifyListeners();

    try {
      // Get the timestamp of the oldest post to load messages before it
      final oldestPost = posts.last;
      final until = oldestPost.createdAt;

      // Load next 20 posts
      final moreEvents = await _nostrService.requestPastEvents(
        kind: 1,
        limit: limit,
        until: until,
      );

      if (moreEvents.isNotEmpty) {
        final morePosts = moreEvents
            .map(
              (event) => Post(
                id: event.id,
                userName: event.pubkey,
                userId: event.pubkey,
                content: event.content,
                createdAt: event.createdAt,
                updatedAt: event.createdAt,
              ),
            )
            .toList();

        upsertPosts(morePosts);

        // If we got less than limit posts, we've reached the end
        if (morePosts.length < limit) {
          hasMorePosts = false;
        }
      } else {
        hasMorePosts = false;
      }

      safeNotifyListeners();
    } catch (e) {
      debugPrint('Error loading more posts: $e');
    }

    isLoadingMore = false;
    safeNotifyListeners();
  }

  Future<void> createPost(String content) async {
    isLoading = true;
    safeNotifyListeners();

    final event = await _nostrService.publishEvent(
      NostrEventModel.fromPartialData(kind: 1, content: content),
    );

    final post = Post(
      id: event.id,
      userName: event.pubkey,
      userId: event.pubkey,
      content: event.content,
      createdAt: event.createdAt,
      updatedAt: event.createdAt,
    );

    posts.insert(0, post);

    isLoading = false;
    safeNotifyListeners();
  }

  void upsertPosts(List<Post> posts) {
    for (var post in posts) {
      final existingPostIndex = this.posts.indexWhere((p) => p.id == post.id);
      if (existingPostIndex != -1) {
        this.posts[existingPostIndex] = post;
      } else {
        this.posts.add(post);
      }
    }
    
    // Sort posts by creation date (most recent first)
    this.posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Add mock posts with transactions for testing the new TransactionCard design
  void _addMockPostsWithTransactions() {
    final now = DateTime.now();
    
    // Mock post 1: Request Pending with action button
    final pendingRequestPost = Post(
      id: 'mock_pending_${now.millisecondsSinceEpoch}',
      userName: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      userId: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      content: 'Requesting \$299 for software license refund. Community admin please review.',
      userInitials: '0x74',
      likeCount: 5,
      dislikeCount: 0,
      commentCount: 3,
      transaction: Transaction(
        senderName: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
        amount: '299.00 USDC',
        timeAgo: 'Pending',
        senderInitials: '0x74',
      ),
      createdAt: now.subtract(const Duration(minutes: 30)),
      updatedAt: now.subtract(const Duration(minutes: 30)),
    );

    // Add mock posts to the list
    posts.addAll([
      pendingRequestPost,
    ]);
    
    // Sort posts by creation date (most recent first)
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
