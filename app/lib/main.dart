import 'package:app/router/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _appShellNavigatorKey = GlobalKey<NavigatorState>();
  final observers = <NavigatorObserver>[];

  late GoRouter router;

  @override
  void initState() {
    super.initState();

    final String? userId =
        null; // when user is logged in we can set it to instantly be in the app without navigating

    router = createRouter(
      _rootNavigatorKey,
      _appShellNavigatorKey,
      observers,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flywind(
      themeMode: ThemeMode.system, // shouldn't mix material and cupertino
      themeData: FlyThemeData.withDefaults(),
      appBuilder: (context) {
        return CupertinoApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Comunifi',
          theme: CupertinoThemeData(
            primaryColor: const Color(0xFF7c5cbd), // Purple theme
            brightness: Brightness.light,
          ),
          routerConfig: router,
        );
      },
    );
  }
}
