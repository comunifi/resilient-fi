import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../design/card.dart';
import '../design/button.dart';
import '../design/avatar.dart';
import '../design/avatar_blockies.dart';
import '../utils/address.dart';

class TransactionCard extends FlyCardWithHeader {
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
    required this.senderAddress,
    required this.amount,
    required this.timeAgo,
    this.senderAvatarUrl,
    this.senderInitials,
    this.status = 'Request Pending',
    this.onBackTap,
    this.onDeleteTap,
    this.onFulfillRequest,
  }) : super(
          title: status,
          showBackButton: true,
          headerActionIcon: null,
          onBackTap: onBackTap,
          onHeaderActionTap: null,
          headerBackgroundColor: 'gray100',
          cardBackgroundColor: 'white',
        );

  final String senderName;
  final String senderAddress;
  final String amount;
  final String timeAgo;
  final String? senderAvatarUrl;
  final String? senderInitials;
  final String status;
  @override
  final VoidCallback? onBackTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onFulfillRequest;

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
        // Header section
        FlyBox(
          children: [
            // Left side: Back button (if enabled) + Icon + Title
            FlyBox(
              children: [
                if (showBackButton)
                  FlyButton(
                    onTap: onBackTap,
                    buttonColor: ButtonColor.none,
                    child: FlyIcon(LucideIcons.arrowDownLeft).color('gray600').w('s5').h('s5'),
                  ),
                FlyText(title).text('sm').weight('medium').color('gray700'),
              ],
            ).row().items('center').gap('s2'),

            // Right side: Action button (if provided)
            if (headerActionIcon != null && onHeaderActionTap != null)
              FlyButton(
                onTap: onHeaderActionTap,
                buttonColor: ButtonColor.none,
                child: FlyIcon(headerActionIcon!).color('gray600').w('s4').h('s4'),
              ),
          ],
        )
        .row()
        .items('center')
        .justify('between')
        .px('s3')
        .py('s2')
        .bg(headerBackgroundColor)
        .rounded('lg'),

        // Main content section
        FlyBox(
          children: [
            // Row 1 & 2: From and To sections on same row
            FlyBox(
              children: [
                // From section
                FlyBox(
                  children: [
                    // Sender avatar
                    FlyAvatar(
                      size: AvatarSize.sm,
                      shape: AvatarShape.circular,
                      child: FlyAvatarBlockies(
                        address: senderAddress,
                        size: AvatarSize.sm,
                        shape: AvatarShape.circular,
                        fallbackText: senderInitials ?? AddressUtils.getAddressInitials(senderAddress),
                      ),
                    ),
                    
                    // Text labels stacked vertically
                    FlyBox(
                      children: [
                        FlyText('from').text('xs').color('gray600'),
                        FlyText(AddressUtils.truncateIfAddress(senderName)).text('sm').weight('medium'),
                      ],
                    ).col().items('start'),
                  ],
                ).row().items('center').gap('s2'),
                
                // To section
                FlyBox(
                  children: [
                    // Receiver avatar
                    FlyAvatar(
                      size: AvatarSize.sm,
                      shape: AvatarShape.circular,
                      children: [
                        FlyAvatarFallback(
                          fallbackText: 'GF',
                        ),
                      ],
                    ),
                    
                    // Text labels stacked vertically
                    FlyBox(
                      children: [
                        FlyText('to').text('xs').color('gray600'),
                        FlyText('Gordon Freem...').text('sm').weight('medium'),
                      ],
                    ).col().items('start'),
                  ],
                ).row().items('center').gap('s2'),
              ],
            ).row().items('center').gap('s8').mb('s3'),
            
            // Row 3: Amount section
            FlyBox(
              children: [
                // Amount icon
                FlyAvatar(
                  size: AvatarSize.sm,
                  shape: AvatarShape.circular,
                  child: FlyIcon(LucideIcons.dollarSign).w('s4').h('s4'),
                ),
                
                // Text labels stacked vertically
                FlyBox(
                  children: [
                    FlyText('amount').text('xs').color('gray600'),
                    FlyText(amount).text('sm').weight('medium'),
                  ],
                ).col().items('start'),
              ],
            ).row().items('center').gap('s2'),
            
            // Action button for pending requests only
            if (status == 'Request Pending') ...[
              FlyButton(
                onTap: onFulfillRequest,
                variant: ButtonVariant.solid,
                buttonColor: ButtonColor.primary,
                child: FlyText('Fulfill Request').text('sm').weight('bold').color('white'),
              ).w('auto').py('s3').rounded('md').mt('s4'),
            ],
          ],
        ).p('s3'),
      ],
    ).col();
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
      senderAddress: senderAddress,
      amount: amount,
      timeAgo: timeAgo,
      senderAvatarUrl: senderAvatarUrl,
      senderInitials: senderInitials,
      status: status,
      onBackTap: onBackTap,
      onDeleteTap: onDeleteTap,
      onFulfillRequest: onFulfillRequest,
      children: children,
    );
  };
}
