import 'package:app/state/feed.dart';
import 'package:app/state/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

Widget provideAppState(
  String userId,
  Widget? child, {
  Widget Function(BuildContext, Widget?)? builder,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => FeedState()),
    ChangeNotifierProvider(create: (_) => WalletState()),
  ],
  builder: builder,
  child: child,
);
