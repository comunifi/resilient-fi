import 'dart:async';

import 'package:app/models/nostr_event.dart';
import 'package:app/models/post.dart';
import 'package:app/services/nostr/nostr.dart';
import 'package:app/services/tor/tor_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FeedState extends ChangeNotifier {
  // instantiate services here - local storage, db, api, etc.
  NostrService _nostrService;
  final TorService _torService = TorService();

  // constructor here - you could pass a user id to the constructor and use it to trigger all methods with that user id
  FeedState() : _nostrService = NostrService(dotenv.get('RELAY_URL'));

  // Tor-related fields
  bool _useTor = false;
  String? _torConnectionStatus;
  String? _torIpAddress;
  bool _isReconnecting = false;

  void init() {
    if (!isConnected) {
      _nostrService.connect((isConnected) async {
        if (!this.isConnected && isConnected && !_isReconnecting) {
          _lastLoadedAt = DateTime.now();
          await startListening();
          loadPosts();
          
          // If using Tor, verify connection and get IP address
          if (_useTor) {
            _verifyTorConnectionAsync();
          }
        }

        this.isConnected = isConnected;
        _updateConnectionStatus();
        safeNotifyListeners();
      });
    }
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

  // Tor-related getters
  bool get useTor => _useTor;
  String? get torConnectionStatus => _torConnectionStatus;
  bool get isReconnecting => _isReconnecting;

  Future<void> startListening() async {
    if (_messageSubscription != null) {
      await _messageSubscription!.cancel();
    }

    try {
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
    } catch (e) {
      debugPrint('Failed to start listening: $e');
      rethrow;
    }
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
      // Only start listening if we're not in the middle of a reconnection
      if (isConnected && !_isReconnecting) {
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

  /// Update connection status based on current state
  void _updateConnectionStatus() {
    if (isConnected) {
      _torConnectionStatus = _useTor ? 'Connected via Tor' : 'Connected';
    } else {
      _torConnectionStatus = _useTor ? 'Tor connection failed' : 'Disconnected';
    }
  }

  /// Toggle Tor connection
  Future<void> toggleTor() async {
    if (_useTor) {
      // Switch from Tor to regular connection
      await reconnect(useTor: false);
    } else {
      // Switch from regular to Tor connection
      await reconnect(useTor: true);
    }
  }

  /// Reconnect with new settings
  Future<void> reconnect({bool? useTor}) async {
    try {
      _isReconnecting = true;
      
      // Update Tor setting
      if (useTor != null) {
        _useTor = useTor;
      }

      // Cancel existing subscription before disconnecting
      if (_messageSubscription != null) {
        try {
          if (_nostrService.isConnected) {
            await _messageSubscription!.cancel();
          }
        } catch (e) {
          debugPrint('Error cancelling subscription: $e');
        }
        _messageSubscription = null;
      }

      // Disconnect current connection
      await _nostrService.disconnect();

      // Create new service with updated settings
      final relayUrl = dotenv.get('RELAY_URL');
      _nostrService = NostrService(relayUrl, useTor: _useTor);

      // Wait for connection to complete
      final completer = Completer<void>();
      
      // Reconnect
      try {
        await _nostrService.connect((isConnected) async {
          this.isConnected = isConnected;
          _updateConnectionStatus();
          safeNotifyListeners();
          
          if (isConnected && !completer.isCompleted) {
            completer.complete();
          } else if (!isConnected && !completer.isCompleted) {
            completer.completeError(Exception('Connection failed'));
          }
        });
      } catch (e) {
        debugPrint('Exception during connect(): $e');
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
        rethrow;
      }
      
      // Wait for connection to be established with timeout
      await completer.future.timeout(const Duration(seconds: 5));
      
      // Start listening and load posts after connection is established
      if (isConnected) {
        _lastLoadedAt = DateTime.now();
        await startListening();
      }
      
    } catch (e) {
      debugPrint('Error reconnecting: $e');
      _updateConnectionStatus();
      safeNotifyListeners();
      rethrow;
    } finally {
      _isReconnecting = false;
    }
  }

  /// Check if Tor is available
  Future<bool> isTorAvailable() async {
    return await _torService.isTorRunning();
  }

  /// Get Tor error message
  String getTorErrorMessage() {
    return _torService.getTorErrorMessage();
  }

  /// Get the current Tor IP address
  String? get torIpAddress => _torIpAddress;

  /// Verify Tor connection and get IP address
  Future<String> verifyTorConnection() async {
    try {
      // Check if we're connecting to localhost
      final uri = Uri.parse(_nostrService.relayUrl);
      if (_torService.isLocalhost(uri.host)) {
        final ip = await _torService.verifyLocalhostConnection();
        _torIpAddress = ip;
        _torConnectionStatus = 'Connected to localhost';
        safeNotifyListeners();
        return ip;
      } else {
        final ip = await _torService.verifyTorConnection();
        _torIpAddress = ip;
        _torConnectionStatus = 'Connected via Tor (IP: $ip)';
        safeNotifyListeners();
        return ip;
      }
    } catch (e) {
      debugPrint('Tor verification failed: $e');
      _torConnectionStatus = 'Tor verification failed: $e';
      safeNotifyListeners();
      rethrow;
    }
  }

  /// Verify Tor connection asynchronously (non-blocking)
  void _verifyTorConnectionAsync() {
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        // Check if we're connecting to localhost
        final uri = Uri.parse(_nostrService.relayUrl);
        if (_torService.isLocalhost(uri.host)) {
          final ip = await _torService.verifyLocalhostConnection();
          _torIpAddress = ip;
          _torConnectionStatus = 'Connected to localhost';
        } else {
          final ip = await _torService.verifyTorConnection();
          _torIpAddress = ip;
          _torConnectionStatus = 'Connected via Tor (IP: $ip)';
        }
        safeNotifyListeners();
      } catch (e) {
        debugPrint('Tor verification failed: $e');
        // Keep showing "Tor: Verifying..." - don't show error to user
        // The connection is still working, just IP verification failed
      }
    });
  }

}
