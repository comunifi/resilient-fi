import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

import 'widgets/avatar.dart';
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
        child: SingleChildScrollView(
          child: FlyBox(
            children: [
              ..._buildButtonExamples(context),
              ..._buildCardExamples(),
              ..._buildAvatarExamples(),
            ],
          ).col().items('start').justify('start').gap('s6').bg('white').p('s8'),
        ),
      ),
    );
  }

  List<Widget> _buildButtonExamples(BuildContext context) {
    return [
      FlyButton(
        onTap: () => _showAlert(context),
        variant: ButtonVariant.primary,
        size: ButtonSize.medium,
        child: FlyText('Primary Button'),
      ),
      FlyButton(
        onTap: () {},
        variant: ButtonVariant.secondary,
        size: ButtonSize.small,
        child: FlyText('Secondary Button'),
      ),
      FlyButton(
        onTap: () {},
        variant: ButtonVariant.success,
        size: ButtonSize.large,
        child: FlyText('Success Button'),
      ),
      FlyButton(
        onTap: () {},
        variant: ButtonVariant.danger,
        size: ButtonSize.medium,
        isLoading: true,
        child: FlyText('Loading Button'),
      ),
      FlyButton(
        onTap: () {},
        variant: ButtonVariant.unstyled,
        size: ButtonSize.medium,
        child: FlyText('Unstyled Button'),
      ),
      FlyButton(
        onTap: () => _showAlert(context),
        variant: ButtonVariant.primary,
        size: ButtonSize.medium,
        children: [
          FlyIcon(Icons.star).color('white'),
          FlyText('Star Button').color('white').text('sm').weight('medium'),
        ],
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
      ).p('0px').m('0px'),
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

  List<Widget> _buildAvatarExamples() {
    return [
      // Size examples
      FlyText('Avatar Examples').text('xl').weight('bold').color('gray800'),

      // Different sizes
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText('Sizes').text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyAvatar(
                size: AvatarSize.xs,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'XS')],
              ),
              FlyAvatar(
                size: AvatarSize.sm,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'SM')],
              ),
              FlyAvatar(
                size: AvatarSize.md,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'MD')],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'LG')],
              ),
              FlyAvatar(
                size: AvatarSize.xl,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'XL')],
              ),
            ],
          ).row().items('start').gap('s4'),
        ],
      ),

      // Different shapes
      FlyCard(
        variant: CardVariant.filled,
        size: CardSize.medium,
        children: [
          FlyText('Shapes').text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'C')],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.rounded,
                children: [FlyAvatarFallback(fallbackText: 'R')],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.square,
                children: [FlyAvatarFallback(fallbackText: 'S')],
              ),
            ],
          ).row().items('start').gap('s4'),
        ],
      ),

      // Fallback types
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText(
            'Fallback Types',
          ).text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackText: 'JD')],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [FlyAvatarFallback(fallbackIcon: Icons.person)],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [
                  FlyAvatarFallback(
                    child: FlyIcon(Icons.star).color('yellow500'),
                  ),
                ],
              ),
            ],
          ).row().items('start').gap('s4'),
        ],
      ),

      // Loading state
      FlyCard(
        variant: CardVariant.filled,
        size: CardSize.medium,
        children: [
          FlyText(
            'Loading State',
          ).text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                isLoading: true,
              ),
            ],
          ).row().items('start').gap('s4'),
        ],
      ),

      // Image examples (with fallback)
      FlyCard(
        variant: CardVariant.outlined,
        size: CardSize.medium,
        children: [
          FlyText(
            'Image with Fallback',
          ).text('lg').weight('semibold').color('gray800'),
          FlyBox(
            children: [
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [
                  FlyAvatarImage(
                    imageUrl:
                        'https://avatars.githubusercontent.com/u/124599?v=4', // GitHub avatar
                    child: FlyAvatarFallback(fallbackText: 'FB'),
                  ),
                ],
              ),
              FlyAvatar(
                size: AvatarSize.lg,
                shape: AvatarShape.circular,
                children: [
                  FlyAvatarImage(
                    imageUrl:
                        'https://invalid-url.com/image.jpg', // This will fail
                    child: FlyAvatarFallback(fallbackText: 'FB'),
                  ),
                ],
              ),
            ],
          ).row().items('start').gap('s4'),
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
