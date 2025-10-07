import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import 'widgets/button.dart';
import 'widgets/card.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Flywind(
      themeMode: ThemeMode.system,
      themeData: FlyThemeData.withDefaults(),
      appBuilder: (context) {
        final flyTheme = FlyTheme.of(context);

        return CupertinoApp(
          title: 'Resilient Fi App',
          theme: CupertinoThemeData(
            primaryColor:
                flyTheme.colors['primary'] ?? CupertinoColors.systemBlue,
            brightness: Brightness.light,
          ),
          home: const FlywindApp(),
        );
      },
    );
  }
}

class FlywindApp extends StatelessWidget {
  const FlywindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Resilient Fi'),
        backgroundColor: CupertinoColors.systemBlue,
      ),
      child: SafeArea(
        child: FlyBox(
          children: [..._buildButtonExamples(context), ..._buildCardExamples()],
        ).col().items('center').justify('center').gap('s6').bg('white').p('s8'),
      ),
    );
  }

  List<Widget> _buildButtonExamples(BuildContext context) {
    return [
      FlyButton(
        'Primary Button',
        () => _showAlert(context),
        variant: ButtonVariant.primary,
        size: ButtonSize.medium,
      ),
      FlyButton(
        'Secondary Button',
        () {},
        variant: ButtonVariant.secondary,
        size: ButtonSize.small,
      ),
      FlyButton(
        'Success Button',
        () {},
        variant: ButtonVariant.success,
        size: ButtonSize.large,
      ),
      FlyButton(
        'Loading Button',
        () {},
        variant: ButtonVariant.danger,
        size: ButtonSize.medium,
        isLoading: true,
      ),
      FlyButton(
        'Unstyled Button',
        () {},
        variant: ButtonVariant.unstyled,
        size: ButtonSize.medium,
      ),
    ];
  }

  List<Widget> _buildCardExamples() {
    return [
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText(
            'Outlined Card',
          ).text('lg').weight('semibold').color('gray800'),
          FlyText(
            'This is an outlined card with border',
          ).text('sm').color('gray600'),
        ],
      ),
      FlyCard(
        variant: CardVariant.filled,
        size: CardSize.medium,
        children: [
          FlyText('Filled Card').text('lg').weight('semibold').color('gray800'),
          FlyText(
            'This is a filled card with background',
          ).text('sm').color('gray600'),
        ],
      ),
      FlyCard(
        variant: CardVariant.unstyled,
        size: CardSize.medium,
        children: [
          FlyText(
            'Unstyled Card',
          ).text('lg').weight('semibold').color('gray800'),
          FlyText(
            'This is an unstyled card with no background or border',
          ).text('sm').color('gray600'),
        ],
      ),
    ];
  }

  void _showAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Alert!'),
          content: const Text('This is a Cupertino alert dialog.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
