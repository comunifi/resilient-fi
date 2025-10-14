import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';
import 'package:go_router/go_router.dart';

import '../../design/button.dart';
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
  String selectedCommunity = 'ComuniFi';

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
          // Header with community dropdown
          FlyBox(
            children: [
              FlyButton(
                onTap: () {
                  _showCommunitySelection();
                },
                buttonColor: ButtonColor.secondary,
                child: FlyBox(
                  children: [
                    FlyText(
                      selectedCommunity,
                    ).text('base').weight('medium').color('gray900'),
                    FlyIcon(
                      Icons.keyboard_arrow_down,
                    ).color('gray600').w('s4').h('s4'),
                  ],
                ).row().items('center').gap('s1'),
              ),
            ],
          ).px('s4').py('s2').mb('s4'),

          // Text input area
          FlyBox(
                child: CupertinoTextField(
                  controller: _postController,
                  focusNode: _focusNode,
                  maxLines: 5,
                  textAlignVertical: TextAlignVertical.top,
                  placeholder: 'What\'s on your mind?',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  padding: const EdgeInsets.all(16),
                ),
              )
              .bg('purple50')
              .rounded('lg')
              .border(1)
              .borderColor('purple200')
              .px('s4')
              .py('s3')
              .mb('s4'),

          // Send and Receive mechanism
          SendReceiveWidget(onPost: _handlePost),
        ],
      ).col().px('s4'),
    );
  }

  void _showCommunitySelection() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: FlyText(
          'Select Community',
        ).text('lg').weight('bold').color('gray900'),
        actions: [
          CupertinoActionSheetAction(
            child: FlyText('ComuniFi').color('purple600'),
            onPressed: () {
              setState(() {
                selectedCommunity = 'ComuniFi';
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: FlyText('TechFi').color('purple600'),
            onPressed: () {
              setState(() {
                selectedCommunity = 'TechFi';
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: FlyText('DeFi').color('purple600'),
            onPressed: () {
              setState(() {
                selectedCommunity = 'DeFi';
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: FlyText('TradFi').color('purple600'),
            onPressed: () {
              setState(() {
                selectedCommunity = 'TradFi';
              });
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: FlyText('Cancel').color('red600'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
