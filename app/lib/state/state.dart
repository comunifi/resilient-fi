import 'package:app/state/feed.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

Widget provideAppState(
  String userId,
  Widget? child, {
  Widget Function(BuildContext, Widget?)? builder,
}) => MultiProvider(
  providers: [ChangeNotifierProvider(create: (_) => FeedState(userId))],
  builder: builder,
  child: child,
);
