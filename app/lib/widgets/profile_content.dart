import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import 'avatar.dart';
import 'button.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.userName,
    required this.userHandle,
    required this.avatarText,
    this.bio,
    this.connectionCount = 8,
    this.onStar,
    this.onShare,
    this.onDownload,
    this.onTabChanged,
    this.selectedTab = 0,
  });

  final String userName;
  final String userHandle;
  final String avatarText;
  final String? bio;
  final int connectionCount;
  final VoidCallback? onStar;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final ValueChanged<int>? onTabChanged;
  final int selectedTab;

  @override
  Widget build(BuildContext context) {
    return FlyBox(
      children: [
        // Profile header with avatar, name, and action buttons
        FlyBox(
          children: [
            // Avatar
            FlyAvatar(
              size: AvatarSize.xl,
              shape: AvatarShape.circular,
              children: [
                FlyAvatarFallback(
                  fallbackText: avatarText,
                  fallbackIcon: Icons.person,
                ),
              ],
            ),
            // Name and handle
            FlyBox(
              children: [
                FlyText(userName).text('xl').weight('bold').color('gray800'),
                FlyText(userHandle).text('base').color('gray600'),
              ],
            ).col().items('start').gap('s1').flex(1),
            // Action buttons
            FlyBox(
              children: [
                FlyButton(
                  onTap: onStar,
                  variant: ButtonVariant.unstyled,
                  child: FlyIcon(Icons.star_border).color('gray800'),
                ).w('s10').h('s10').bg('gray100').rounded('md'),
                FlyButton(
                  onTap: onShare,
                  variant: ButtonVariant.unstyled,
                  child: FlyIcon(Icons.share).color('gray800'),
                ).w('s10').h('s10').bg('gray100').rounded('md'),
                FlyButton(
                  onTap: onDownload,
                  variant: ButtonVariant.unstyled,
                  child: FlyIcon(Icons.download).color('gray800'),
                ).w('s10').h('s10').bg('gray100').rounded('md'),
              ],
            ).row().gap('s2'),
          ],
        ).row().items('start').gap('s4').px('s6').py('s6'),

        // Bio section
        if (bio != null)
          FlyBox(
            children: [
              FlyText(bio!).text('sm').color('gray700').leading('relaxed'),
            ],
          ).px('s6').pb('s4'),

        // Avatar row (connections/followers)
        FlyBox(
          children: List.generate(
            connectionCount,
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
      onTap: () => onTabChanged?.call(index),
      variant: ButtonVariant.unstyled,
      child: FlyText(text)
          .text('sm')
          .weight(isSelected ? 'medium' : 'normal')
          .color(isSelected ? 'gray800' : 'gray500'),
    ).py('s3').px('s4').bg(isSelected ? 'gray200' : null).rounded('md');
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
