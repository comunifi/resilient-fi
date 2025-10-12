import 'dart:async';

import 'package:app/models/post.dart';
import 'package:app/services/secure/secure.dart';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:dart_nostr/nostr/model/debug_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Basic Nostr service implementation
class NostrService {
  final SecureService _secureService = SecureService();
  final Nostr _nostr = Nostr(debugOptions: NostrDebugOptions(tag: 'Nostr'));

  final List<String> _relays;
  bool _isConnected = false;

  NostrService() : _relays = [dotenv.get('RELAY_URL')];

  /// Initialize connection to Nostr relays
  Future<void> initialize(Function(bool) onConnected) async {
    debugPrint(dotenv.get('RELAY_URL'));
    try {
      debugPrint('Initializing Nostr service');
      await _nostr.services.relays.init(
        relaysUrl: _relays,
        // onRelayListening: (relayUrl, relay, channel) {
        //   debugPrint('onRelayListening: $relayUrl');
        //   _isConnected = true;
        //   onConnected(true);
        // },
        onRelayConnectionError: (relayUrl, error, channel) {
          debugPrint('onRelayConnectionError $relayUrl: $error');
          onConnected(false);
        },
        onRelayConnectionDone: (relayUrl, channel) {
          debugPrint('onRelayConnectionDone: $relayUrl');
          _isConnected = false;
          onConnected(false);
        },
        retryOnError: true,
        retryOnClose: true,
        connectionTimeout: const Duration(seconds: 10),
      );

      _isConnected = true;
      onConnected(true);

      debugPrint('Nostr service initialized');
    } catch (e) {
      debugPrint('Failed to initialize Nostr service: $e');
      onConnected(false);
      rethrow;
    }
  }

  /// Get Nostr key pair from SecureService
  Future<NostrKeyPairs> _getKeyPair() async {
    final credentials = _secureService.getCredentials();

    if (credentials == null) {
      throw Exception(
        'No Nostr credentials found. Please create credentials first using SecureService.createCredentials()',
      );
    }

    final (publicKey, privateKey) = credentials;
    return _nostr.services.keys.generateKeyPairFromExistingPrivateKey(
      privateKey,
    );
  }

  /// Create and post a message (kind 1) to Nostr relays
  Future<Post> createPost(String content) async {
    if (!_isConnected) {
      throw Exception('Not connected to Nostr relays');
    }

    try {
      final keyPair = await _getKeyPair();

      debugPrint('Key pair: ${keyPair.public}');

      // Create a Nostr event with kind 1 (text note)
      final event = NostrEvent.fromPartialData(
        kind: 1,
        content: content,
        keyPairs: keyPair,
        tags: [
          ['t', DateTime.now().millisecondsSinceEpoch.toString()],
        ],
      );

      // Send the event to relays
      await _nostr.services.relays.sendEventToRelaysAsync(
        event,
        timeout: const Duration(seconds: 10),
      );

      // Convert to Post model
      final post = Post(
        id: event.id ?? '',
        userName: keyPair.public,
        userId: event.pubkey,
        content: content,
        createdAt: event.createdAt ?? DateTime.now(),
        updatedAt: event.createdAt ?? DateTime.now(),
      );

      return post;
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  /// Start listening for messages (kind 1) from Nostr relays
  Stream<Post> listenToMessages({
    List<String>? authors,
    int? limit,
    DateTime? since,
  }) {
    debugPrint('Listening to messages indefinitely');
    if (!_isConnected) {
      throw Exception('Not connected to Nostr relays');
    }

    // Create a request to listen for kind 1 events
    // Don't set a limit to ensure indefinite listening
    final request = NostrRequest(
      filters: [
        NostrFilter(
          kinds: const [1], // Text notes
          since: since,
          authors: authors,
          limit: limit, // Only apply limit if explicitly provided
        ),
      ],
    );

    // Start the subscription
    final nostrStream = _nostr.services.relays.startEventsSubscription(
      request: request,
      onEose: (eose, _) => debugPrint(
        'End of stored events received - continuing to listen for new events',
      ),
    );

    // Convert Nostr events to Post stream
    return nostrStream.stream.map((nostrEvent) {
      debugPrint('New Nostr event received: ${nostrEvent.content}');
      return Post(
        id: nostrEvent.id ?? '',
        userName: nostrEvent.pubkey,
        userId: nostrEvent.pubkey,
        content: nostrEvent.content ?? '',
        createdAt: nostrEvent.createdAt ?? DateTime.now(),
        updatedAt: nostrEvent.createdAt ?? DateTime.now(),
      );
    });
  }

  /// Listen for messages from specific authors
  Stream<Post> listenToUserMessages(List<String> authors) {
    return listenToMessages(authors: authors);
  }

  /// Listen for all public messages
  Stream<Post> listenToPublicMessages({int? limit}) {
    return listenToMessages(limit: limit);
  }

  /// Load historical messages with pagination
  Future<List<Post>> loadHistoricalMessages({
    List<String>? authors,
    int limit = 20,
    DateTime? until,
  }) async {
    if (!_isConnected) {
      throw Exception('Not connected to Nostr relays');
    }

    try {
      // Create a request for historical messages
      final request = NostrRequest(
        filters: [
          NostrFilter(
            kinds: const [1], // Text notes
            until: until, // Load messages before this timestamp
            authors: authors,
            limit: limit,
          ),
        ],
      );

      // Start the subscription for historical messages
      final events = await _nostr.services.relays.startEventsSubscriptionAsync(
        request: request,
        timeout: const Duration(seconds: 1),
        onEose: (eose, cmd) {
          print('onEose: $eose $cmd');
          // Sort posts by creation date (newest first)
          // posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          // completer.complete(posts);
          return;
        },
        shouldThrowErrorOnTimeoutWithoutEose: false,
      );

      debugPrint('Historical messages loaded: ${events.length} posts');

      final posts = events
          .map(
            (event) => Post(
              id: event.id ?? '',
              userName: event.pubkey,
              userId: event.pubkey,
              content: event.content ?? '',
              createdAt: event.createdAt ?? DateTime.now(),
              updatedAt: event.createdAt ?? DateTime.now(),
            ),
          )
          .toList();

      if (posts.isEmpty) {
        return [];
      }

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Set a timeout to prevent hanging
      return posts;
      // return completer.future.timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error loading historical messages: $e');
      rethrow;
    }
  }

  /// Load messages from specific authors with pagination
  Future<List<Post>> loadUserHistoricalMessages(
    List<String> authors, {
    int limit = 20,
    DateTime? until,
  }) async {
    return loadHistoricalMessages(authors: authors, limit: limit, until: until);
  }

  /// Get public key of current user
  String? getCurrentUserPublicKey() {
    return _secureService.getAccountAddress();
  }

  /// Check if user has credentials
  bool hasCredentials() {
    return _secureService.hasCredentials();
  }

  /// Clear user credentials
  Future<void> clearCredentials() async {
    await _secureService.clearCredentials();
  }

  /// Disconnect from relays
  Future<void> disconnect() async {
    debugPrint('Disconnecting from relays');
    await _nostr.services.relays.disconnectFromRelays();
    _isConnected = false;
  }

  /// Check if connected to relays
  bool get isConnected => _isConnected;

  /// Get connected relay URLs
  List<String> get relayUrls => _relays;
}
