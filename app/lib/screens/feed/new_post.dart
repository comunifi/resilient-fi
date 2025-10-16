import 'package:flutter/cupertino.dart';
import 'package:flywind/flywind.dart';
import 'package:go_router/go_router.dart';

import '../../design/sheet.dart';
import '../../widgets/send_receive_widget.dart';

class SimpleNewPostScreen extends StatefulWidget {
  const SimpleNewPostScreen({super.key});

  @override
  State<SimpleNewPostScreen> createState() => _SimpleNewPostScreenState();
}

class _SimpleNewPostScreenState extends State<SimpleNewPostScreen> {
  final TextEditingController _postController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the text input when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handlePost() {
    GoRouter.of(context).pop(
      _postController.text,
    ); // here, when pop is called, the value is returned
  }

  @override
  Widget build(BuildContext context) {
    return FlySheet(
      title: 'New Post',
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      showCloseButton: false,
      showBackButton: true,
      showDragHandle: true,
      child: FlyBox(
        children: [
          // Text input area
          FlyBox(
            child: CupertinoTextField(
              controller: _postController,
              focusNode: _focusNode,
              maxLines: 5,
              textAlignVertical: TextAlignVertical.top,
              placeholder: 'share with your community...',
              style: const TextStyle(fontSize: 16, height: 1.5),
              padding: const EdgeInsets.all(16),
            ),
          ).mb('s4'),

          // Send and Receive mechanism
          SendReceiveWidget(onPost: _handlePost),
        ],
      ).col().px('s4'),
    );
  }
}
