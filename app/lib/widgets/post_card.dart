import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import '../design/avatar.dart';
import '../design/button.dart';
import '../design/card.dart';
import 'transaction_card.dart';

class PostCard extends FlyCard {
  PostCard({
    super.key,
    super.children,
    super.alignment,
    super.padding,
    super.margin,
    super.decoration,
    super.foregroundDecoration,
    super.width,
    super.height,
    super.constraints,
    super.transform,
    super.transformAlignment,
    super.clipBehavior,
    super.flyStyle,
    required this.userName,
    required this.userId,
    required this.content,
    this.userAvatarUrl,
    this.userInitials,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
    this.transaction,
    this.createdAt,
    this.onLike,
    this.onDislike,
    this.onComment,
    this.onShare,
    this.onMore,
  }) : super(variant: CardVariant.outlined, size: CardSize.medium);

  final String userName;
  final String userId;
  final String content;
  final String? userAvatarUrl;
  final String? userInitials;
  final int likeCount;
  final int dislikeCount;
  final int commentCount;
  final TransactionCard? transaction;
  final DateTime? createdAt;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return FlyCard(
      key: key,
      variant: CardVariant.outlined,
      size: CardSize.medium,
      alignment: alignment,
      padding: padding,
      margin: margin,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      flyStyle: flyStyle,
      children: [
        // Header
        _buildHeader(),

        // Content
        _buildContent(),

        // Transaction (optional)
        if (transaction != null) transaction!,

        // Footer with action buttons
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return FlyBox(
      children: [
        // User avatar
        FlyAvatar(
          size: AvatarSize.md,
          shape: AvatarShape.circular,
          children: [
            if (userAvatarUrl != null)
              FlyAvatarImage(
                imageUrl: userAvatarUrl!,
                child: FlyAvatarFallback(
                  fallbackText:
                      userInitials ?? userName.substring(0, 1).toUpperCase(),
                ),
              )
            else
              FlyAvatarFallback(
                fallbackText:
                    userInitials ?? userName.substring(0, 1).toUpperCase(),
              ),
          ],
        ),

        // User name, ID, and timestamp
        FlyBox(
          children: [
            FlyText(userName).text('base').weight('semibold').color('gray800'),
            FlyText(userId).text('sm').color('gray500'),
            if (createdAt != null)
              FlyText(_formatTimestamp(createdAt!)).text('xs').color('gray400'),
          ],
        ).col().items('start').gap('s1').flex(1),

        // Action buttons
        FlyBox(
          children: [
            FlyButton(
              onTap: onShare,
              buttonColor: ButtonColor.secondary,
              size: ButtonSize.small,
              child: FlyIcon(Icons.share).color('gray500'),
            ),
            FlyButton(
              onTap: onMore,
              buttonColor: ButtonColor.secondary,
              size: ButtonSize.small,
              child: FlyIcon(Icons.more_vert).color('gray500'),
            ),
          ],
        ).row().items('center').gap('s2'),
      ],
    ).row().items('center').gap('s3');
  }

  Widget _buildContent() {
    return FlyText(content).text('sm').color('gray700').leading('relaxed');
  }

  Widget _buildFooter() {
    return FlyBox(
          children: [
            // Left side: Like and Dislike buttons
            FlyBox(
              children: [
                // Like button
                FlyButton(
                  onTap: onLike,
                  buttonColor: ButtonColor.secondary,
                  size: ButtonSize.small,
                  children: [
                    FlyIcon(Icons.favorite).color('#ef4444'),
                    FlyText(
                      likeCount.toString(),
                    ).text('sm').weight('medium').color('gray600'),
                  ],
                ).row().items('center').gap('s1'),

                // Dislike button
                FlyButton(
                  onTap: onDislike,
                  buttonColor: ButtonColor.secondary,
                  size: ButtonSize.small,
                  children: [
                    FlyIcon(Icons.close).color('#6b7280'),
                    FlyText(
                      dislikeCount.toString(),
                    ).text('sm').weight('medium').color('gray600'),
                  ],
                ).row().items('center').gap('s1'),
              ],
            ).row(),

            // Right side: Comment button
            FlyBox(
              children: [
                FlyButton(
                  onTap: onComment,
                  buttonColor: ButtonColor.secondary,
                  size: ButtonSize.small,
                  children: [
                    FlyIcon(Icons.chat_bubble_outline).color('#6b7280'),
                    FlyText(
                      commentCount.toString(),
                    ).text('sm').weight('medium').color('gray600'),
                  ],
                ),
              ],
            ).row(),
          ],
        )
        // TODO figure out why .jusify(space-between) doesn't work
        .row(mainAxisAlignment: MainAxisAlignment.spaceBetween)
        .justify('space-between')
        .gap('s4');
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  @override
  PostCard Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return PostCard(
      key: key,
      alignment: alignment,
      padding: padding,
      margin: margin,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      flyStyle: newStyle,
      userName: userName,
      userId: userId,
      content: content,
      userAvatarUrl: userAvatarUrl,
      userInitials: userInitials,
      likeCount: likeCount,
      dislikeCount: dislikeCount,
      commentCount: commentCount,
      transaction: transaction,
      createdAt: createdAt,
      onLike: onLike,
      onDislike: onDislike,
      onComment: onComment,
      onShare: onShare,
      onMore: onMore,
      children: children,
    );
  };
}
