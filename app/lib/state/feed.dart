import 'dart:async';

import 'package:app/models/post.dart';
import 'package:app/services/nostr/nostr.dart';
import 'package:flutter/cupertino.dart';

class FeedState extends ChangeNotifier {
  // instantiate services here - local storage, db, api, etc.
  final NostrService _nostrService;

  // constructor here - you could pass a user id to the constructor and use it to trigger all methods with that user id
  FeedState() : _nostrService = NostrService();

  void init() {
    _nostrService.initialize((isConnected) {
      if (!this.isConnected && isConnected) {
        _lastLoadedAt = DateTime.now();
        startListening();
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
  StreamSubscription<Post>? _messageSubscription;

  DateTime? _now;
  DateTime? _lastLoadedAt;

  Future<void> startListening() async {
    if (_messageSubscription != null) {
      await _messageSubscription!.cancel();
    }

    _messageSubscription = _nostrService
        .listenToMessages(since: _now)
        .listen(
          (post) {
            // Check if post already exists to avoid duplicates
            final existingPost = posts.any(
              (existingPost) => existingPost.id == post.id,
            );

            if (!existingPost) {
              // Add new posts to the beginning of the list
              posts.insert(0, post);
              safeNotifyListeners();
            }
          },
          onError: (error) {
            print('Error listening to messages: $error');
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
      final historicalPosts = await _nostrService.loadHistoricalMessages(
        limit: limit,
        until: _lastLoadedAt,
      );

      posts.clear();
      upsertPosts(historicalPosts);

      // If we got less than 20 posts, we've reached the end
      if (historicalPosts.length < limit) {
        hasMorePosts = false;
      }

      safeNotifyListeners(); // call this to tell the UI to update
    } catch (e) {
      print('Error loading posts: $e');
      // Fallback to mock posts for development
      posts.clear();
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
    _now = DateTime.now();
    _lastLoadedAt = DateTime.now();

    try {
      // Load the latest 20 posts from Nostr (most recent posts)
      final historicalPosts = await _nostrService.loadHistoricalMessages(
        limit: limit,
        until: _lastLoadedAt,
      );

      upsertPosts(historicalPosts);

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
      print('Error refreshing posts: $e');
      // Fallback to mock posts for development
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
      final morePosts = await _nostrService.loadHistoricalMessages(
        limit: limit,
        until: until,
      );

      if (morePosts.isNotEmpty) {
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
      print('Error loading more posts: $e');
    }

    isLoadingMore = false;
    safeNotifyListeners();
  }

  Future<void> createPost(String content) async {
    isLoading = true;
    safeNotifyListeners();

    final post = await _nostrService.createPost(content);

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
  }
}
