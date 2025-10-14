import 'package:flutter/material.dart';
import 'market_page.dart';
import 'package:koooly_app/src/shared/constants.dart';

class MarketSplashScreen extends StatefulWidget {
  const MarketSplashScreen({super.key});

  @override
  State<MarketSplashScreen> createState() => _MarketSplashScreenState();
}

class _MarketSplashScreenState extends State<MarketSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MarketPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Text("Market Screen"),
        //Image.asset(
        //"old_cust/assets/images/koooly_market_logo.png",
        //height: 120,
        //),
      ),
    );
  }
}
