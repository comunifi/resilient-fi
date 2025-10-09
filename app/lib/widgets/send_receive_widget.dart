import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import '../design/button.dart';

class SendReceiveWidget extends StatefulWidget {
  const SendReceiveWidget({super.key});

  @override
  State<SendReceiveWidget> createState() => _SendReceiveWidgetState();
}

class _SendReceiveWidgetState extends State<SendReceiveWidget> {
  TransactionEntry? _transaction;
  final TextEditingController _amountController = TextEditingController();
  String _mode = 'none'; // 'send', 'receive', or 'none'

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
    return FlyBox(
          children: [
            // Main content (two rows)
            FlyBox(
              children: [
                // First row: Action icon, label, and recipient dropdown
                FlyBox(
                  children: [
                    // Action icon and label
                    FlyBox(
                      children: [
                        FlyBox(
                              child: FlyIcon(
                                isSend ? Icons.send : Icons.call_received,
                              ).color('gray600').w('s4').h('s4'),
                            )
                            .w('s8')
                            .h('s8')
                            .bg('purple100')
                            .rounded('sm')
                            .items('center')
                            .justify('center'),

                        FlyText(
                          isSend ? 'Send to' : 'Receive from',
                        ).text('sm').weight('medium').color('gray700'),
                      ],
                    ).row().items('center').gap('s2'),

                    // Recipient dropdown
                    FlyButton(
                      onTap: () => _showRecipientSelection(transaction),
                      variant: ButtonVariant.secondary,
                      child: FlyBox(
                        children: [
                          FlyText(
                            transaction.recipient,
                          ).text('sm').weight('medium').color('gray900'),
                          FlyIcon(
                            Icons.keyboard_arrow_down,
                          ).color('gray600').w('s3').h('s3'),
                        ],
                      ).row().items('center').gap('s1'),
                    ),
                  ],
                ).row().items('center').gap('s3').justify('space-between'),

                // Second row: Amount input and currency dropdown
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
                    ).w('s16').h('s8').bg('gray100').rounded('sm').px('s2'),

                    // Currency dropdown
                    FlyButton(
                      onTap: () => _showCurrencySelection(transaction),
                      variant: ButtonVariant.secondary,
                      child: FlyBox(
                        children: [
                          FlyText(
                            transaction.currency,
                          ).text('sm').weight('medium').color('gray900'),
                          FlyIcon(
                            Icons.keyboard_arrow_down,
                          ).color('gray600').w('s3').h('s3'),
                        ],
                      ).row().items('center').gap('s1'),
                    ),
                  ],
                ).row().items('center').gap('s2'),
              ],
            ).col().gap('s3'),

            // Close button (positioned in top right corner)
            Positioned(
              top: 12,
              right: 0,
              child: FlyButton(
                onTap: () {
                  setState(() {
                    _mode = 'none';
                    _transaction = null;
                  });
                },
                variant: ButtonVariant.secondary,
                size: ButtonSize.small,
                child: FlyIcon(Icons.close).color('gray600').w('s4').h('s4'),
              ),
            ),
          ],
        )
        .stack()
        .bg('purple50')
        .rounded('lg')
        .border(1)
        .borderColor('purple200')
        .px('s3')
        .py('s2');
  }

  Widget _buildActionButtons() {
    return FlyBox(
      children: [
        // Send button (toggles send mode)
        FlyButton(
          onTap: _toggleSend,
          variant: _mode == 'send'
              ? ButtonVariant.primary
              : ButtonVariant.secondary,
          child: FlyText('Send').text('sm').weight('medium'),
        ),

        // Receive button (toggles receive mode)
        FlyButton(
          onTap: _toggleReceive,
          variant: _mode == 'receive'
              ? ButtonVariant.primary
              : ButtonVariant.secondary,
          child: FlyText('Receive').text('sm').weight('medium'),
        ),

        // Post button (final action)
        FlyButton(
          onTap: _handlePost,
          variant: ButtonVariant.primary,
          size: ButtonSize.large,
          child: FlyIcon(Icons.send).color('white').w('s4').h('s4'),
        ),
      ],
    ).row().items('center').gap('s3').justify('space-between');
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
      _showDialog('Error', 'Please select Send or Receive first');
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
