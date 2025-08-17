import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:koooly_app/src/views/home/home_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:koooly_app/src/views/home/menu_drawer.dart';
import 'package:koooly_app/src/views/home/wallet_screen.dart';

class MainHome extends StatefulWidget {
  final int screen;
  final Position? currentposition;
  final List<LatLng>? theRoutes;
  const MainHome(
      {super.key, this.theRoutes, this.currentposition, this.screen = 1});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> with TickerProviderStateMixin {
  List<StatefulWidget> screens = [];
  int currentScreen = 1;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Vehicle type navigation variables
  int _selectedTypeIndex = 0;

  @override
  void initState() {
    super.initState();
    currentScreen = 0;

    // Initialize page controller
    _pageController = PageController(initialPage: 0);

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    screens = [
      HomeScreen(
        currentPosition: widget.currentposition != null
            ? LatLng(widget.currentposition!.latitude,
                widget.currentposition!.longitude)
            : null,
        theRoutes: widget.theRoutes,
        selectedTypeIndex: _selectedTypeIndex,
      ),
    ];

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentScreen = index;
    });

    // Trigger page refresh animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Refresh the specific page
    _refreshPage(index);
  }

  void _refreshPage(int index) {
    // Force rebuild of the specific page
    setState(() {
      // This will trigger a rebuild of the current page
    });

    // Refresh home screen data
    if (index == 0) {
      // Refresh home screen data
    }
  }

  void _onTypeChanged(int index) {
    setState(() {
      _selectedTypeIndex = index;
    });

    // Update the home screen with new type
    if (currentScreen == 0) {
      // Refresh home screen with new type
      setState(() {
        screens[0] = HomeScreen(
          currentPosition: widget.currentposition != null
              ? LatLng(widget.currentposition!.latitude,
                  widget.currentposition!.longitude)
              : null,
          theRoutes: widget.theRoutes,
          selectedTypeIndex: _selectedTypeIndex,
        );
      });
    }
  }

  Widget _buildTypeButton(IconData icon, bool selected, int index,
      {bool isFirst = false, bool isLast = false}) {
    return Expanded(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF9800) : const Color(0xFFFAF8F4),
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(15) : Radius.zero,
            right: isLast ? const Radius.circular(15) : Radius.zero,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(15) : Radius.zero,
              right: isLast ? const Radius.circular(15) : Radius.zero,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              _onTypeChanged(index);
            },
            child: Center(
              child: Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF666666),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1.5,
      height: double.infinity,
      color: const Color(0xFFC0C0C0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const MenuDrawer(),
      body: Builder(
        builder: (context) => Stack(
          children: [
            // PageView for smooth transitions
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: screens.asMap().entries.map((entry) {
                int index = entry.key;
                Widget screen = entry.value;

                return AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: currentScreen == index ? 1.0 : 0.8,
                      child: Transform.scale(
                        scale: currentScreen == index ? 1.0 : 0.98,
                        child: screen,
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            // Top left menu icon
            Positioned(
              top: 44,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 28),
                ),
              ),
            ),
            // Top right wallet icon
            Positioned(
              top: 44,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const WalletScreen()),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 26),
                ),
              ),
            ),
            // Floating location button
            Positioned(
              right: 20,
              bottom: size.height * 0.38,
              child: const CircleAvatar(
                backgroundColor: Color(0xFFFAF8F4),
                child: Icon(Icons.my_location, color: Color(0xFFFF9800)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF8F4),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: const Color(0xFFFF9800),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          height: 55,
          padding: const EdgeInsets.all(0),
          child: Row(
            children: [
              _buildTypeButton(Icons.directions_car, _selectedTypeIndex == 0, 0,
                  isFirst: true, isLast: false),
              _buildTypeButton(Icons.two_wheeler, _selectedTypeIndex == 1, 1,
                  isFirst: false, isLast: false),
              _buildTypeButton(Icons.shopping_bag, _selectedTypeIndex == 2, 2,
                  isFirst: false, isLast: true),
            ],
          ),
        ),
      ),
    );
  }
}
