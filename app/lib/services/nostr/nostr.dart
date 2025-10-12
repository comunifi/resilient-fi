import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app/models/nostr_event.dart';
import 'package:app/services/secure/secure.dart';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket-based Nostr service implementation
class NostrService {
  final SecureService _secureService = SecureService();

  final String _relayUrl;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  final Map<String, StreamController<NostrEventModel>> _subscriptions = {};
  final Map<String, VoidCallback> _eoseCompleters = {};
  final Random _random = Random();

  NostrService(this._relayUrl);

  /// Connect to the Nostr relay
  Future<void> connect(Function(bool) onConnected) async {
    if (_isConnected) {
      debugPrint('Already connected to relay');
      return;
    }

    try {
      debugPrint('Connecting to relay: $_relayUrl');
      _channel = WebSocketChannel.connect(Uri.parse(_relayUrl));

      // Listen for incoming messages
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _isConnected = false;
          onConnected(false);
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _isConnected = false;
          onConnected(false);
        },
      );

      _isConnected = true;
      debugPrint('Connected to relay successfully');
      onConnected(true);
    } catch (e) {
      debugPrint('Failed to connect to relay: $e');
      _isConnected = false;
      onConnected(false);
      rethrow;
    }
  }

  /// Disconnect from the relay
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;

    // Close all subscriptions
    for (final controller in _subscriptions.values) {
      controller.close();
    }
    _subscriptions.clear();

    // Clear EOSE completers
    _eoseCompleters.clear();

    debugPrint('Disconnected from relay');
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final List<dynamic> data = jsonDecode(message);
      final String messageType = data[0];

      switch (messageType) {
        case 'EVENT':
          _handleEventMessage(data);
          break;
        case 'EOSE':
          _handleEoseMessage(data);
          break;
        case 'NOTICE':
          _handleNoticeMessage(data);
          break;
        case 'OK':
          _handleOkMessage(data);
          break;
        default:
          debugPrint('Unknown message type: $messageType');
      }
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  /// Handle EVENT messages
  void _handleEventMessage(List<dynamic> data) {
    if (data.length < 3) return;

    final String subscriptionId = data[1];
    final Map<String, dynamic> eventData = data[2];

    try {
      final event = NostrEventModel.fromJson(eventData);

      // Emit event to the appropriate subscription
      final controller = _subscriptions[subscriptionId];
      if (controller != null && !controller.isClosed) {
        debugPrint('adding event to controller: $subscriptionId');
        controller.add(event);
      }
    } catch (e, s) {
      debugPrint('Error parsing event: $e');
      debugPrint('Stack trace: $s');
    }
  }

  /// Handle EOSE (End of Stored Events) messages
  void _handleEoseMessage(List<dynamic> data) {
    if (data.length < 2) return;
    final String subscriptionId = data[1];
    debugPrint('EOSE received for subscription: $subscriptionId');

    // Call the EOSE completer if it exists
    final completer = _eoseCompleters[subscriptionId];
    if (completer != null) {
      completer();
    }
  }

  /// Handle NOTICE messages
  void _handleNoticeMessage(List<dynamic> data) {
    if (data.length < 2) return;
    final String notice = data[1];
    debugPrint('Relay notice: $notice');
  }

  /// Handle OK messages
  void _handleOkMessage(List<dynamic> data) {
    if (data.length < 4) return;
    final String eventId = data[1];
    final bool success = data[2];
    final String message = data[3];
    debugPrint('Event $eventId ${success ? 'accepted' : 'rejected'}: $message');
  }

  /// Generate a random subscription ID
  String _generateSubscriptionId() {
    return 'sub_${_random.nextInt(1000000)}';
  }

  /// Send a message to the relay
  void _sendMessage(List<dynamic> message) {
    if (!_isConnected || _channel == null) {
      throw Exception('Not connected to relay');
    }

    final String jsonMessage = jsonEncode(message);
    _channel!.sink.add(jsonMessage);
    debugPrint('Sent message: $jsonMessage');
  }

  /// Listen to events of a specific kind
  Stream<NostrEventModel> listenToEvents({
    required int kind,
    List<String>? authors,
    List<String>? tags,
    DateTime? since,
    DateTime? until,
    int? limit,
  }) {
    if (!_isConnected) {
      throw Exception('Not connected to relay. Call connect() first.');
    }

    final String subscriptionId = _generateSubscriptionId();
    final StreamController<NostrEventModel> controller =
        StreamController<NostrEventModel>();

    debugPrint('listening to events: $subscriptionId');

    // Store the controller for this subscription
    _subscriptions[subscriptionId] = controller;

    // Build the filter
    final Map<String, dynamic> filter = {
      'kinds': [kind],
    };

    if (authors != null && authors.isNotEmpty) {
      filter['authors'] = authors;
    }

    if (tags != null && tags.isNotEmpty) {
      // For now, we'll handle simple tag filters
      // In a full implementation, you'd want to support more complex tag queries
      filter['#t'] = tags;
    }

    if (since != null) {
      filter['since'] = (since.millisecondsSinceEpoch / 1000).floor();
    }

    if (until != null) {
      filter['until'] = (until.millisecondsSinceEpoch / 1000).floor();
    }

    if (limit != null) {
      filter['limit'] = limit;
    }

    // Send the REQ message
    final List<dynamic> request = ['REQ', subscriptionId, filter];
    _sendMessage(request);

    // Clean up when the stream is cancelled
    controller.onCancel = () {
      print('onCancel: $subscriptionId');
      _unsubscribe(subscriptionId);
    };

    return controller.stream;
  }

  /// Request past events and return them as a Future that completes when EOSE is received
  /// Perfect for pagination by requesting chunks of events
  Future<List<NostrEventModel>> requestPastEvents({
    required int kind,
    List<String>? authors,
    List<String>? tags,
    DateTime? since,
    DateTime? until,
    int? limit,
  }) async {
    if (!_isConnected) {
      throw Exception('Not connected to relay. Call connect() first.');
    }

    final String subscriptionId = _generateSubscriptionId();
    final List<NostrEventModel> events = [];
    final Completer<List<NostrEventModel>> completer =
        Completer<List<NostrEventModel>>();
    bool eoseReceived = false;

    // Create a temporary controller to handle events for this request
    final StreamController<NostrEventModel> controller =
        StreamController<NostrEventModel>();

    // Store the controller temporarily
    _subscriptions[subscriptionId] = controller;

    // Listen to events and collect them
    controller.stream.listen(
      (event) {
        events.add(event);
      },
      onDone: () {
        debugPrint('stream listener done for: $subscriptionId');
        // If EOSE was received and stream is done, complete the future
        if (eoseReceived && !completer.isCompleted) {
          completer.complete(events);
        }
      },
      onError: (error) {
        debugPrint('Error in past events request: $error');
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );

    // Build the filter
    final Map<String, dynamic> filter = {
      'kinds': [kind],
    };

    if (authors != null && authors.isNotEmpty) {
      filter['authors'] = authors;
    }

    if (tags != null && tags.isNotEmpty) {
      filter['#t'] = tags;
    }

    if (since != null) {
      filter['since'] = (since.millisecondsSinceEpoch / 1000).floor();
    }

    if (until != null) {
      filter['until'] = (until.millisecondsSinceEpoch / 1000).floor();
    }

    if (limit != null) {
      filter['limit'] = limit;
    }

    // Send the REQ message
    final List<dynamic> request = ['REQ', subscriptionId, filter];
    _sendMessage(request);

    // Set up EOSE handling
    _eoseCompleters[subscriptionId] = () {
      debugPrint('eose completer: $subscriptionId');
      eoseReceived = true;

      // Close the controller to trigger onDone
      controller.close();
      _subscriptions.remove(subscriptionId);
      _eoseCompleters.remove(subscriptionId);
    };

    return completer.future.timeout(const Duration(seconds: 10));
  }

  /// Unsubscribe from a subscription
  void _unsubscribe(String subscriptionId) {
    // Send CLOSE message
    _sendMessage(['CLOSE', subscriptionId]);

    // Close and remove the controller
    final controller = _subscriptions[subscriptionId];
    if (controller != null) {
      controller.close();
      _subscriptions.remove(subscriptionId);
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

    final (_, privateKey) = credentials;
    final nostr = Nostr();
    return nostr.services.keys.generateKeyPairFromExistingPrivateKey(
      privateKey,
    );
  }

  /// Publish an event to the relay
  Future<NostrEventModel> publishEvent(NostrEventModel event) async {
    if (!_isConnected) {
      throw Exception('Not connected to relay. Call connect() first.');
    }

    // Get the key pair for signing
    final keyPair = await _getKeyPair();

    // Create a NostrEvent using dart_nostr which handles ID generation and signing
    final nostrEvent = NostrEvent.fromPartialData(
      kind: event.kind,
      content: event.content,
      keyPairs: keyPair,
      tags: addClientIdTag(event.tags),
      createdAt: event.createdAt,
    );

    // Convert back to our model format
    final completeEvent = NostrEventModel.fromNostrEvent(nostrEvent);

    // Send the EVENT message
    final List<dynamic> message = ['EVENT', completeEvent.toJson()];
    _sendMessage(message);

    return completeEvent;
  }

  /// Check if connected to the relay
  bool get isConnected => _isConnected;

  /// Get the relay URL
  String get relayUrl => _relayUrl;

  /// Get active subscription count
  int get activeSubscriptions => _subscriptions.length;
}
