import 'package:app/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';

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
        return const FlywindApp();
      },
    );
  }
}

class FlywindApp extends StatelessWidget {
  const FlywindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: FlyContainer(
        child: SafeArea(
          child: FlyLayout([
            const FlyCard(
              title: 'Welcome to Flywind!',
              description:
                  'This is a simple card example using Flywind utilities.',
              buttonText: 'Get Started',
            ),
          ]).col().justify('center').items('center'),
        ),
      ).bg('white'),
    );
  }
}
