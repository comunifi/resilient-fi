import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import '../design/avatar.dart';

class TransactionCard extends FlyBox {
  TransactionCard({
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
    required this.senderName,
    required this.amount,
    required this.timeAgo,
    this.senderAvatarUrl,
    this.senderInitials,
  });

  final String senderName;
  final String amount;
  final String timeAgo;
  final String? senderAvatarUrl;
  final String? senderInitials;

  bool get hasDefaultStyle => true;

  @override
  FlyStyle getDefaultStyle(FlyStyle incomingStyle) {
    return incomingStyle.copyWith(
      bg: '#e8d5ff', // Light purple background
      rounded: 'md',
      p: 's3',
      layoutType: 'row',
      items: 'center',
      gap: 's3',
    );
  }

  @override
  Widget build(BuildContext context) {
    final mergedStyle = getDefaultStyle(flyStyle);

    return FlyBox(
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
      flyStyle: mergedStyle,
      children: [
        // Arrow icon
        FlyIcon(Icons.arrow_downward).color('#7c5cbd'),

        // Sender avatar
        FlyAvatar(
          size: AvatarSize.sm,
          shape: AvatarShape.circular,
          children: [
            if (senderAvatarUrl != null)
              FlyAvatarImage(
                imageUrl: senderAvatarUrl!,
                child: FlyAvatarFallback(
                  fallbackText:
                      senderInitials ??
                      senderName.substring(0, 1).toUpperCase(),
                ),
              )
            else
              FlyAvatarFallback(
                fallbackText:
                    senderInitials ?? senderName.substring(0, 1).toUpperCase(),
              ),
          ],
        ),

        // Sender name
        FlyText(
          'from $senderName',
        ).text('sm').weight('medium').color('gray700').flex(1),

        // USDC amount and time
        FlyBox(
          children: [
            FlyBox(
              children: [
                FlyIcon(Icons.attach_money).color('#2563eb'),
                FlyText(amount).text('sm').weight('semibold').color('gray800'),
              ],
            ).row().items('center').gap('s1'),
            FlyText(timeAgo).text('xs').color('gray500'),
          ],
        ).col().items('end').gap('s1'),
      ],
    );
  }

  @override
  TransactionCard Function(FlyStyle newStyle) get copyWith => (newStyle) {
    return TransactionCard(
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
      senderName: senderName,
      amount: amount,
      timeAgo: timeAgo,
      senderAvatarUrl: senderAvatarUrl,
      senderInitials: senderInitials,
      children: children,
    );
  };
}
