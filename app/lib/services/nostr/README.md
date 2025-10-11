# Nostr Service

This service provides a basic Nostr client implementation using the `dart_nostr` package. It supports posting messages (kind 1) and listening for messages from Nostr relays.

## Features

- **Key Management**: Automatic generation and secure storage of Nostr key pairs
- **Message Posting**: Create and post text messages (kind 1) to Nostr relays
- **Message Listening**: Listen to messages from specific authors or all public messages
- **Relay Connection**: Connect to and manage connections to Nostr relays
- **Error Handling**: Comprehensive error handling and connection management

## Usage

### 1. Create Credentials (if needed)

```dart
final secureService = SecureService();
if (!secureService.hasCredentials()) {
  final (publicKey, privateKey) = secureService.createCredentials();
  print('Created new credentials: $publicKey');
}
```

### 2. Initialize the Service

```dart
final nostrService = NostrService('user123', 'username');
await nostrService.initialize();
```

### 3. Post a Message

```dart
try {
  final post = await nostrService.createPost('Hello, Nostr!');
  print('Message posted: ${post.id}');
} catch (e) {
  print('Failed to post message: $e');
}
```

### 4. Listen to Messages

```dart
// Listen to all public messages
final messageStream = nostrService.listenToPublicMessages(limit: 10);
messageStream.listen((Post post) {
  print('Received: ${post.content}');
});

// Listen to messages from specific users
final userStream = nostrService.listenToUserMessages(['pubkey1', 'pubkey2']);
userStream.listen((Post post) {
  print('Message from ${post.userName}: ${post.content}');
});
```

### 5. Check Connection Status

```dart
if (nostrService.isConnected) {
  print('Connected to relays: ${nostrService.relayUrls}');
} else {
  print('Not connected to any relays');
}
```

### 6. Get User Information

```dart
final publicKey = nostrService.getCurrentUserPublicKey();
if (publicKey != null) {
  print('Your public key: $publicKey');
}
```

### 7. Cleanup

```dart
await nostrService.disconnect();
```

## Configuration

The service uses environment variables for configuration:

- `RELAY_URL`: The Nostr relay URL to connect to (e.g., `wss://relay.damus.io`)

Make sure to set this in your `.env` file:

```
RELAY_URL=wss://relay.damus.io
```

## Key Management

The service uses the existing `SecureService` for key management:

- Credentials must be created first using `SecureService.createCredentials()`
- Private keys are securely stored using the `SecureService`
- Public keys can be retrieved for sharing with other users
- The NostrService will throw an exception if no credentials are found

## Error Handling

The service includes comprehensive error handling:

- Connection errors are logged and can be retried
- Message posting failures are caught and rethrown
- Invalid relay URLs or network issues are handled gracefully

## Dependencies

- `dart_nostr: ^9.2.2` - Core Nostr functionality
- `flutter_dotenv: ^6.0.0` - Environment variable management
- `shared_preferences: ^2.5.3` - Secure key storage

## Notes

- The service uses kind 1 events (text notes) for messaging
- All timestamps are converted from Unix timestamps to Dart DateTime objects
- The service automatically handles event signing and verification
- Connection status is tracked and can be monitored
