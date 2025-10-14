import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import '../../design/avatar.dart';
import '../../design/button.dart';
import '../../design/sheet.dart';

class DraggableProfileScreen extends StatefulWidget {
  const DraggableProfileScreen({super.key});

  @override
  State<DraggableProfileScreen> createState() => _DraggableProfileScreenState();
}

class _DraggableProfileScreenState extends State<DraggableProfileScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return FlySheet(
      title: 'Profile',
      initialChildSize: 0.65,
      child: _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return FlyBox(
      children: [
        // Profile header with avatar, name, and action buttons
        FlyBox(
          children: [
            // Avatar and name section
            FlyBox(
              children: [
                // Avatar
                FlyAvatar(
                  size: AvatarSize.xl,
                  shape: AvatarShape.circular,
                  children: [
                    FlyAvatarFallback(
                      fallbackText: 'JS',
                      fallbackIcon: Icons.person,
                    ),
                  ],
                ),
                // Name and handle
                FlyBox(
                  children: [
                    FlyText(
                      'John Smith',
                    ).text('xl').weight('bold').color('gray800'),
                    FlyText('@john').text('base').color('gray600'),
                  ],
                ).col().items('start').gap('s1').flex(1),
              ],
            ).row().items('start').gap('s4'),

            // Action buttons
            FlyBox(
              children: [
                FlyButton(
                  onTap: () {
                    // Handle star action
                  },
                  buttonColor: ButtonColor.secondary,
                  size: ButtonSize.small,
                  child: FlyIcon(Icons.star_border).color('gray800'),
                ),
                FlyButton(
                  onTap: () {
                    // Handle share action
                  },
                  buttonColor: ButtonColor.secondary,
                  size: ButtonSize.small,
                  child: FlyIcon(Icons.share).color('gray800'),
                ),
                FlyButton(
                  onTap: () {
                    // Handle download action
                  },
                  buttonColor: ButtonColor.secondary,
                  size: ButtonSize.small,
                  child: FlyIcon(Icons.download).color('gray800'),
                ),
              ],
            ).row().gap('s2').justify('start'),
          ],
        ).col().gap('s4').px('s6').py('s6'),

        // Bio section
        FlyBox(
          children: [
            FlyText(
              'Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae. Ex sapien vitae pellentesque sem placerat in id....',
            ).text('sm').color('gray700').leading('relaxed'),
          ],
        ).px('s6').pb('s4'),

        // Avatar row (connections/followers)
        FlyBox(
          children: List.generate(
            8,
            (index) => FlyAvatar(
              size: AvatarSize.sm,
              shape: AvatarShape.circular,
              children: [
                FlyAvatarFallback(
                  fallbackText: 'U${index + 1}',
                  fallbackIcon: Icons.person,
                ),
              ],
            ),
          ),
        ).row().gap('s1').px('s6').pb('s6'),

        // Tab navigation
        FlyBox(
          children: [
            _buildTabButton('Posts', 0),
            _buildTabButton('Replies', 1),
            _buildTabButton('Tokens', 2),
            _buildTabButton('Transactions', 3),
          ],
        ).row().gap('s1').px('s6').pb('s4').wrap(),

        // Content area (placeholder for selected tab)
        FlyBox(
          children: [FlyText(_getTabContent()).text('sm').color('gray500')],
        ).px('s6').py('s8'),
      ],
    ).col().gap('s2');
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = selectedTab == index;
    return FlyButton(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      buttonColor: isSelected ? ButtonColor.secondary : ButtonColor.secondary,
      child: FlyText(text)
          .text('sm')
          .weight(isSelected ? 'medium' : 'normal')
          .color(isSelected ? 'gray800' : 'gray500'),
    );
  }

  String _getTabContent() {
    switch (selectedTab) {
      case 0:
        return 'Posts content would go here...';
      case 1:
        return 'Replies content would go here...';
      case 2:
        return 'Tokens content would go here...';
      case 3:
        return 'Transactions content would go here...';
      default:
        return 'Content would go here...';
    }
  }
}
