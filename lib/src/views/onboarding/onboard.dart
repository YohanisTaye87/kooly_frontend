import 'package:flutter/material.dart';
import 'package:koooly_app/src/shared/cache_storage.dart';
import 'package:koooly_app/src/views/signup/signup_phone.dart';

class OnboardScreen extends StatefulWidget {
  final String? notificationToken;
  const OnboardScreen({required this.notificationToken, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 0) {
              // Swipe right: go to previous page
              if (_currentPage > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            } else if (details.primaryVelocity != null &&
                details.primaryVelocity! < 0) {
              // Swipe left: go to next page
              if (_currentPage < 3) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: isSmall ? 16 : 102),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: const [
                      OnboardingPage(
                        image: 'assets/images/Logistics-rafiki (1).png',
                        title: 'Fast & Reliable Deliveries and Rides',
                        description:
                            'Send Packages or get to your destination quickly with trusted drivers, any time you need.',
                      ),
                      OnboardingPage(
                        image: 'assets/images/Take Away-pana.png',
                        title: 'Track in Real-Time',
                        description:
                            'Follow your delivery or ride on the live map, from pickup to drop-off, for full peace of mind.',
                      ),
                      OnboardingPage(
                        image: 'assets/images/Ecommerce campaign-rafiki.png',
                        title: 'Shop from Your Favorite Stores',
                        description:
                            'Order Furnitures, electronics, and more-all in one app, delivered fast to your doorstep.',
                      ),
                      OnboardingPage(
                        image: 'assets/images/In no time-cuate.png',
                        title: 'Simple & Secure payments',
                        description:
                            'Pay easily with cash, wallet, or cards, and enjoy safe, transparent pricing.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmall ? 18 : 32),
                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isSmall ? 9 : 12,
                      height: isSmall ? 9 : 12,
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? const Color(0xFFFF9900)
                            : Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFFFF9900),
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                SizedBox(height: isSmall ? 18 : 32),
                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9900),
                      padding: EdgeInsets.symmetric(
                        vertical: isSmall ? 14 : 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 12,
                      shadowColor: const Color(0x80FF9900),
                    ),
                    onPressed: () async {
                      if (_currentPage < 3) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        // Mark onboarding as completed
                        final cacheStorage = CacheStorage();
                        await cacheStorage.markOnboardingCompleted();

                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SignupPhoneScreen(
                              notificationToken: widget.notificationToken,
                            ),
                            transitionDuration: const Duration(
                              milliseconds: 150,
                            ),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      }
                    },
                    child: Text(
                      _currentPage < 3 ? 'Next' : 'Start',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmall ? 16 : 18,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 6 : 12),
                // Skip button
                TextButton(
                  onPressed: () async {
                    // Mark onboarding as completed
                    final cacheStorage = CacheStorage();
                    await cacheStorage.markOnboardingCompleted();

                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SignupPhoneScreen(
                          notificationToken: widget.notificationToken,
                        ),
                        transitionDuration: const Duration(milliseconds: 150),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: const Color(0xFF757575),
                      fontSize: isSmall ? 14 : 16,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 8 : 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final bool isBig;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    this.isBig = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image with proper sizing and positioning like OnboardingScreen2
        Image.asset(
          image,
          width: size.width * 0.8,
          height: isSmall ? size.height * 0.28 : size.height * 0.33,
          fit: BoxFit.contain,
        ),
        SizedBox(height: isSmall ? 18 : 32),
        // Title with orange color and proper styling
        SizedBox(
          width: double.infinity,
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFFFF9900),
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 18 : 20,
              fontFamily: 'SF Pro Display',
            ),
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 10),
        // Description with gray color and proper styling
        SizedBox(
          width: double.infinity,
          child: Text(
            description,
            style: TextStyle(
              color: const Color(0xFF757575),
              fontSize: isSmall ? 13.5 : 15,
              fontFamily: 'SF Pro Display',
              height: 1.4,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
