import 'package:flutter/cupertino.dart';

import '../widgets/draggable_sheet.dart';
import '../widgets/profile_content.dart';

class DraggableProfileScreen extends StatefulWidget {
  const DraggableProfileScreen({super.key});

  @override
  State<DraggableProfileScreen> createState() => _DraggableProfileScreenState();
}

class _DraggableProfileScreenState extends State<DraggableProfileScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return DraggableSheet(
      title: 'Profile',
      child: ProfileContent(
        userName: 'John Smith',
        userHandle: '@john',
        avatarText: 'JS',
        bio:
            'Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae. Ex sapien vitae pellentesque sem placerat in id....',
        connectionCount: 8,
        selectedTab: selectedTab,
        onStar: () {
          // Handle star action
        },
        onShare: () {
          // Handle share action
        },
        onDownload: () {
          // Handle download action
        },
        onTabChanged: (index) {
          setState(() {
            selectedTab = index;
          });
        },
      ),
    );
  }
}
