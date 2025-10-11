import 'package:app/models/post.dart';
import 'package:app/utils/delay.dart';

class NostrService {
  String userId;
  String username;

  NostrService(this.userId, this.username);

  Future<Post> createPost(String content) async {
    // TODO: Implement create post

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await delay(const Duration(seconds: 1));

    // create a new post
    final post = Post(
      id: id,
      userName: username,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      content: content,
    );

    return post;
  }
}
