import 'package:flutter/material.dart';
import 'package:flywind/flywind.dart';
import 'package:go_router/go_router.dart';

import '../design/button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void handleGetStarted(BuildContext context) {
    GoRouter.of(context).push('/user123/posts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FlyBox(
          children: [
            // Main content
            FlyBox(
              children: [
                // Big icon
                FlyBox(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 120,
                      color: const Color(0xFF7c5cbd), // Purple500
                    ),
                  ],
                ).mb('s8'),

                // App title
                FlyText(
                  'Comunifi',
                ).text('4xl').weight('bold').color('gray900').mb('s4'),

                // Tagline
                FlyText(
                  'Where communities come together',
                ).text('lg').color('gray600').mb('s12'),
              ],
            ).col().items('center').justify('center').flex(1),

            // Bottom button
            FlyButton(
              onTap: () => handleGetStarted(context),
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              child: FlyText(
                'Get Started',
              ).text('lg').weight('semibold').color('white'),
            ).mb('s8'),
          ],
        ).col().items('center').justify('center').px('s6').py('s8'),
      ),
    );
  }
}
