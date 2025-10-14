import 'package:flutter/material.dart';
import 'market_splash_screen.dart';

class MarketNavigator extends StatelessWidget {
  const MarketNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const MarketSplashScreen(),
        );
      },
    );
  }
}
