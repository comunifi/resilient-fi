import 'post.dart';
import 'transaction.dart';

/// Example usage of Post and Transaction classes with JSON serialization
class ExampleUsage {
  static void demonstrateJsonSerialization() {
    // Create a transaction
    final transaction = Transaction(
      senderName: 'John Smith',
      amount: '1,250 USDC',
      timeAgo: '2 days ago',
      senderInitials: 'JS',
    );

    // Create a post with transaction
    final post = Post(
      id: 'post_123',
      userName: 'John Smith',
      userId: '##d',
      content: 'Lorem ipsum dolor sit amet consectetur adipiscing elit...',
      userInitials: 'JS',
      likeCount: 12,
      dislikeCount: 3,
      commentCount: 8,
      transaction: transaction,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    );

    // Convert to JSON
    final postJson = post.toJson();
    print('Post as JSON: $postJson');

    // Parse from JSON
    final parsedPost = Post.fromJson(postJson);
    print('Parsed post: $parsedPost');

    // Create a post without transaction
    final simplePost = Post(
      id: 'post_456',
      userName: 'Sarah Wilson',
      userId: '##e',
      content: 'Just finished an amazing DeFi protocol integration!',
      userInitials: 'SW',
      likeCount: 45,
      dislikeCount: 2,
      commentCount: 23,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now(),
    );

    final simplePostJson = simplePost.toJson();
    print('Simple post as JSON: $simplePostJson');

    // Parse from JSON
    final parsedSimplePost = Post.fromJson(simplePostJson);
    print('Parsed simple post: $parsedSimplePost');
  }

  /// Example of parsing from API response
  static Post parseFromApiResponse(Map<String, dynamic> apiResponse) {
    return Post.fromJson(apiResponse);
  }

  /// Example of converting to API request
  static Map<String, dynamic> convertToApiRequest(Post post) {
    return post.toJson();
  }
}
