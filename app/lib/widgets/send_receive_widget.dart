import 'package:flutter/cupertino.dart';
import 'package:flywind/flywind.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../design/button.dart';
import '../design/card.dart';
import '../screens/feed/new_post.dart';

class SendReceiveWidget extends StatefulWidget {
  final Function() onPost;
  final PrefilledTransaction? prefilledTransaction;

  const SendReceiveWidget({
    super.key, 
    required this.onPost,
    this.prefilledTransaction,
  });

  @override
  State<SendReceiveWidget> createState() => _SendReceiveWidgetState();
}

class _SendReceiveWidgetState extends State<SendReceiveWidget> {
  TransactionEntry? _transaction;
  final TextEditingController _amountController = TextEditingController();
  String _mode = 'none'; // 'send', 'receive', or 'none'

  @override
  void initState() {
    super.initState();
    // If there's a prefilled transaction, set up send mode
    if (widget.prefilledTransaction != null) {
      _mode = 'send';
      _transaction = TransactionEntry(
        recipient: widget.prefilledTransaction!.recipient,
        amount: widget.prefilledTransaction!.amount,
        currency: widget.prefilledTransaction!.currency,
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlyBox(
      children: [
        // Transaction entry (only show if not 'none')
        if (_mode != 'none')
          _buildTransactionEntry(_transaction!, _mode == 'send'),

        // Action buttons
        _buildActionButtons(),
      ],
    ).col().gap('s3');
  }

  Widget _buildTransactionEntry(TransactionEntry transaction, bool isSend) {
    return FlyCardWithHeader(
      title: isSend ? 'Send Tokens' : 'Request Tokens',
      headerIcon: isSend ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
      headerActionIcon: LucideIcons.trash2,
      onHeaderActionTap: () {
        setState(() {
          _mode = 'none';
          _transaction = null;
        });
      },
      headerBackgroundColor: 'gray100',
      cardBackgroundColor: 'gray50',
      children: [
        // Main content (two rows)
        FlyBox(
          children: [
            // First row: Recipient dropdown
            FlyBox(
              children: [
                FlyText(
                  isSend ? 'to' : 'from',
                ).text('sm').color('gray600'),
                FlyButton(
                  onTap: () => _showRecipientSelection(transaction),
                  variant: ButtonVariant.outlined,
                  buttonColor: ButtonColor.secondary,
                  child: FlyBox(
                    children: [
                      FlyText(
                        transaction.recipient,
                      ).text('sm').weight('medium').color('gray900'),
                      FlyIcon(
                        LucideIcons.chevronDown,
                      ).color('gray600').w('s3').h('s3'),
                    ],
                  ).row().items('center').gap('s1'),
                ),
              ],
            ).row().items('center').gap('s2').justify('between'),

            // Second row: Amount input and currency dropdown
            FlyBox(
              children: [
                FlyText('amount').text('sm').color('gray600'),
                FlyBox(
                  children: [
                    // Amount input
                    FlyBox(
                      child: CupertinoTextField(
                        controller: TextEditingController(
                          text: transaction.amount.toString(),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14),
                        decoration: const BoxDecoration(),
                        onChanged: (value) {
                          final amount = double.tryParse(value) ?? 0;
                          setState(() {
                            transaction.amount = amount;
                          });
                        },
                      ),
                    ).w('s16').h('s8').bg('white').rounded('sm').px('s2').border(1).borderColor('gray200'),

                    // Currency dropdown
                    FlyButton(
                      onTap: () => _showCurrencySelection(transaction),
                      variant: ButtonVariant.outlined,
                      buttonColor: ButtonColor.secondary,
                      child: FlyBox(
                        children: [
                          FlyText(
                            transaction.currency,
                          ).text('sm').weight('medium').color('gray900'),
                          FlyIcon(
                            LucideIcons.chevronDown,
                          ).color('gray600').w('s3').h('s3'),
                        ],
                      ).row().items('center').gap('s1'),
                    ),
                  ],
                ).row().items('center').gap('s2'),
              ],
            ).row().items('center').gap('s2').justify('between'),
          ],
        ).col().gap('s3'),
      ],
    );
  }

  Widget _buildActionButtons() {
    return FlyBox(
      children: [
        // Send button (toggles send mode)
        FlyBox(
          children: [
          FlyButton(
            onTap: _toggleSend,
            buttonColor: _mode == 'send'
                ? ButtonColor.primary
                : ButtonColor.secondary,
            variant: ButtonVariant.outlined,
            children: [
              FlyIcon(LucideIcons.arrowUpRight).w('s4').h('s4'),
              FlyText('Send').text('sm').weight('medium'),
            ],
          ),

          // Receive button (toggles receive mode)
          FlyButton(
            onTap: _toggleReceive,
            buttonColor: _mode == 'receive'
                ? ButtonColor.primary
                : ButtonColor.secondary,
            variant: ButtonVariant.outlined,
            children: [
              FlyIcon(LucideIcons.arrowDownLeft).w('s4').h('s4'),
              FlyText('Receive').text('sm').weight('medium'),
            ],
          ),
          ],
        ).row().gap('s3'),

        // Post button (final action)
        FlyButton(
          onTap: _handlePost,
          variant: ButtonVariant.solid,
          buttonColor: ButtonColor.primary,
          size: ButtonSize.large,
          child: FlyIcon(LucideIcons.send).w('s4').h('s4'),
        ),
      ],
    ).row().items('center').gap('s3').justify('between');
  }

  void _toggleSend() {
    setState(() {
      if (_mode == 'send') {
        _mode = 'none';
        _transaction = null;
      } else {
        _mode = 'send';
        _transaction = TransactionEntry(
          recipient: 'John Smith',
          amount: 20,
          currency: 'USDC',
        );
      }
    });
  }

  void _toggleReceive() {
    setState(() {
      if (_mode == 'receive') {
        _mode = 'none';
        _transaction = null;
      } else {
        _mode = 'receive';
        _transaction = TransactionEntry(
          recipient: 'John Smith',
          amount: 20,
          currency: 'USDC',
        );
      }
    });
  }

  void _showRecipientSelection(TransactionEntry transaction) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: FlyText(
          'Select Recipient',
        ).text('lg').weight('bold').color('gray900'),
        actions: [
          CupertinoActionSheetAction(
            child: FlyText('John Smith').color('purple600'),
            onPressed: () {
              setState(() {
                transaction.recipient = 'John Smith';
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: FlyText('Jane Doe').color('purple600'),
            onPressed: () {
              setState(() {
                transaction.recipient = 'Jane Doe';
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: FlyText('Bob Wilson').color('purple600'),
            onPressed: () {
              setState(() {
                transaction.recipient = 'Bob Wilson';
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

  void _showCurrencySelection(TransactionEntry transaction) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: FlyText(
          'Select Currency',
        ).text('lg').weight('bold').color('gray900'),
        actions: [
          CupertinoActionSheetAction(
            child: FlyText('USDC').color('purple600'),
            onPressed: () {
              setState(() {
                transaction.currency = 'USDC';
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: FlyText('USDT').color('purple600'),
            onPressed: () {
              setState(() {
                transaction.currency = 'USDT';
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: FlyText('ETH').color('purple600'),
            onPressed: () {
              setState(() {
                transaction.currency = 'ETH';
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

  void _handlePost() {
    if (_mode == 'none') {
      // _showDialog('Error', 'Please select Send or Receive first');
      widget.onPost();
      return;
    }

    if (_mode == 'send') {
      print(
        'Sending: ${_transaction!.amount} ${_transaction!.currency} to ${_transaction!.recipient}',
      );
    } else if (_mode == 'receive') {
      print(
        'Receiving: ${_transaction!.amount} ${_transaction!.currency} from ${_transaction!.recipient}',
      );
    }

    _showDialog('Success', 'Transaction posted successfully!');

    // Clear transaction after successful post
    setState(() {
      _mode = 'none';
      _transaction = null;
    });
  }

  void _showDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: FlyText(title)
            .text('lg')
            .weight('bold')
            .color(title == 'Error' ? 'red600' : 'green600'),
        content: FlyText(message).color('gray700'),
        actions: [
          CupertinoDialogAction(
            child: FlyText('OK').color('purple600'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class TransactionEntry {
  String recipient;
  double amount;
  String currency;

  TransactionEntry({
    required this.recipient,
    required this.amount,
    required this.currency,
  });
}
