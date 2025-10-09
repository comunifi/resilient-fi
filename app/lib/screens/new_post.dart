import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import '../design/button.dart';
import '../design/sheet.dart';
import '../widgets/send_receive_widget.dart';

class SimpleNewPostScreen extends StatefulWidget {
  const SimpleNewPostScreen({super.key});

  @override
  State<SimpleNewPostScreen> createState() => _SimpleNewPostScreenState();
}

class _SimpleNewPostScreenState extends State<SimpleNewPostScreen> {
  final TextEditingController _postController = TextEditingController();
  String selectedCommunity = 'ComuniFi';

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlySheet(
      title: 'New Post',
      initialChildSize: 0.7,
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
                    variant: ButtonVariant.unstyled,
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
                  )
                  .bg('white')
                  .border(1)
                  .borderColor('gray200')
                  .rounded('md')
                  .px('s3')
                  .py('s2'),
            ],
          ).px('s4').py('s2').mb('s4'),

          // Text input area
          FlyBox(
                child: CupertinoTextField(
                  controller: _postController,
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
          const SendReceiveWidget(),
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
            child: FlyText('ComuniFi').color('blue600'),
            onPressed: () {
              setState(() {
                selectedCommunity = 'ComuniFi';
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: FlyText('TechFi').color('blue600'),
            onPressed: () {
              setState(() {
                selectedCommunity = 'TechFi';
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: FlyText('DeFi').color('blue600'),
            onPressed: () {
              setState(() {
                selectedCommunity = 'DeFi';
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: FlyText('TradFi').color('blue600'),
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
