import 'package:koooly_app/src/cubit/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koooly_app/src/views/home/main_home.dart';
import 'package:koooly_app/src/views/onboarding/onboard.dart';
import 'package:koooly_app/src/views/login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isFirstTime;
  final User? userSession;
  final String? notificationToken;
  const SplashScreen({
    super.key,
    required this.isFirstTime,
    required this.userSession,
    required this.notificationToken,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();

    // Delay splash screen for 1 second and navigate based on userSession and isFirstTime
    Future.delayed(const Duration(seconds: 1), () {
      if (widget.userSession != null && mounted) {
        // User is logged in, navigate to main screen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainHome(),
            transitionDuration: const Duration(milliseconds: 150),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else if (widget.isFirstTime && mounted) {
        // First time user, show onboarding
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                OnboardScreen(notificationToken: widget.notificationToken),
            transitionDuration: const Duration(milliseconds: 150),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        // User is not logged in but has completed onboarding, go to login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LoginScreen(
                      notificationToken: widget.notificationToken),
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF9900),
      body: Center(
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontFamily: 'Showg',
              color: Colors.white,
            ),
            children: [
              TextSpan(text: 'K'),
              TextSpan(
                text: 'OOO',
                style: TextStyle(
                  color: Color(0xFFFFD600), // Yellow for OOO
                ),
              ),
              TextSpan(text: 'LY'),
            ],
          ),
        ),
      ),
    );
  }
}
