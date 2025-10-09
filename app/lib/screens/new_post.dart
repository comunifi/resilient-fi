import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import '../design/button.dart';
import '../design/sheet.dart';

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
      showCloseButton: true,
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

          // Action buttons
          FlyBox(
                children: [
                  // Add attachment button
                  FlyButton(
                        onTap: () {
                          // TODO: Handle add attachment
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: FlyText('Add Attachment').color('gray900'),
                              content: FlyText(
                                'Attachment feature coming soon!',
                              ).color('gray700'),
                              actions: [
                                CupertinoDialogAction(
                                  child: FlyText('OK').color('blue600'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        },
                        variant: ButtonVariant.unstyled,
                        child: FlyIcon(
                          Icons.add,
                        ).color('purple600').w('s6').h('s6'),
                      )
                      .w('s12')
                      .h('s12')
                      .bg('purple100')
                      .rounded('999px')
                      .items('center')
                      .justify('center'),

                  // Send button
                  FlyButton(
                    onTap: () => _handleSendPost(),
                    variant: ButtonVariant.unstyled,
                    child: FlyText(
                      'Send',
                    ).text('sm').weight('medium').color('purple600'),
                  ).bg('purple100').rounded('999px').px('s4').py('s2'),

                  // Request button
                  FlyButton(
                    onTap: () => _handleRequestPost(),
                    variant: ButtonVariant.unstyled,
                    child: FlyText(
                      'Request',
                    ).text('sm').weight('medium').color('purple600'),
                  ).bg('purple100').rounded('999px').px('s4').py('s2'),

                  // Send post button (primary action)
                  FlyButton(
                        onTap: () => _handleSendPost(),
                        variant: ButtonVariant.unstyled,
                        child: FlyIcon(
                          Icons.send,
                        ).color('white').w('s5').h('s5'),
                      )
                      .w('s12')
                      .h('s12')
                      .bg('purple600')
                      .rounded('999px')
                      .items('center')
                      .justify('center'),
                ],
              )
              .row()
              .items('center')
              .gap('s3')
              .justify('space-between')
              .px('s4')
              .py('s3')
              .mb('s4'),
        ],
      ).col().px('s4'),
    );
  }

  void _handleSendPost() {
    if (_postController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: FlyText('Error').color('red600').text('lg').weight('bold'),
          content: FlyText(
            'Please enter some text for your post',
          ).color('gray700'),
          actions: [
            CupertinoDialogAction(
              child: FlyText('OK').color('blue600'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    print('Sending post: ${_postController.text}');
    print('Community: $selectedCommunity');

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: FlyText('Success').color('green600').text('lg').weight('bold'),
        content: FlyText('Post sent successfully!').color('gray700'),
        actions: [
          CupertinoDialogAction(
            child: FlyText('OK').color('blue600'),
            onPressed: () {
              Navigator.pop(context);
              _postController.clear();
            },
          ),
        ],
      ),
    );
  }

  void _handleRequestPost() {
    if (_postController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: FlyText('Error').color('red600').text('lg').weight('bold'),
          content: FlyText(
            'Please enter some text for your request',
          ).color('gray700'),
          actions: [
            CupertinoDialogAction(
              child: FlyText('OK').color('blue600'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    print('Sending request: ${_postController.text}');
    print('Community: $selectedCommunity');

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: FlyText('Success').color('green600').text('lg').weight('bold'),
        content: FlyText('Request posted successfully!').color('gray700'),
        actions: [
          CupertinoDialogAction(
            child: FlyText('OK').color('blue600'),
            onPressed: () {
              Navigator.pop(context);
              _postController.clear();
            },
          ),
        ],
      ),
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
