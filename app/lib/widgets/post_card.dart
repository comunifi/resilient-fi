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

        // User name and ID
        FlyBox(
          children: [
            FlyText(userName).text('base').weight('semibold').color('gray800'),
            FlyText(userId).text('sm').color('gray500'),
          ],
        ).col().items('start').gap('s1').flex(1),

        // Action buttons
        FlyBox(
          children: [
            FlyButton(
              onTap: onShare,
              variant: ButtonVariant.unstyled,
              size: ButtonSize.small,
              child: FlyIcon(Icons.share).color('gray500'),
            ),
            FlyButton(
              onTap: onMore,
              variant: ButtonVariant.unstyled,
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
        // Like button
        FlyButton(
          onTap: onLike,
          variant: ButtonVariant.unstyled,
          size: ButtonSize.small,
          children: [
            FlyIcon(Icons.favorite).color('#ef4444'),
            FlyText(
              likeCount.toString(),
            ).text('sm').weight('medium').color('gray600'),
          ],
        ).row().items('center').gap('s1').bg('#f3f4f6').rounded('md').p('s2'),

        // Dislike button
        FlyButton(
          onTap: onDislike,
          variant: ButtonVariant.unstyled,
          size: ButtonSize.small,
          children: [
            FlyIcon(Icons.close).color('#6b7280'),
            FlyText(
              dislikeCount.toString(),
            ).text('sm').weight('medium').color('gray600'),
          ],
        ).row().items('center').gap('s1').bg('#f3f4f6').rounded('md').p('s2'),

        // Comment button
        FlyButton(
          onTap: onComment,
          variant: ButtonVariant.unstyled,
          size: ButtonSize.small,
          children: [
            FlyIcon(Icons.chat_bubble_outline).color('#6b7280'),
            FlyText(
              commentCount.toString(),
            ).text('sm').weight('medium').color('gray600'),
          ],
        ).row().items('center').gap('s1').bg('#f3f4f6').rounded('md').p('s2'),
      ],
    ).row().items('center').gap('s3');
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
      onLike: onLike,
      onDislike: onDislike,
      onComment: onComment,
      onShare: onShare,
      onMore: onMore,
      children: children,
    );
  };
}
