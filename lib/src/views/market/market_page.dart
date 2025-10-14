import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_providers.dart';
import 'tabs/market_home_tab.dart';
import 'tabs/market_cart_tab.dart';
import 'tabs/market_profile_tab.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/views/home/main_home.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  int _selectedIndex = 0;
  bool showSearchBar = false;
  bool _cartRestored = false;

  AppBar _buildAppBar() {
    if (_selectedIndex == 1) {
      return AppBar(
        backgroundColor: primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
          onPressed: () => setState(() => _selectedIndex = 0),
        ),
        title: const Text("My Cart",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w300,
                fontSize: 20)),
        centerTitle: true,
      );
    }

    return AppBar(
      backgroundColor: primaryBackground,
      elevation: 0,
      // leading: IconButton(
      //   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
      //   onPressed: () {
      //     Navigator.pushAndRemoveUntil(
      //       context,
      //       MaterialPageRoute(builder: (_) => const MainHome(screen: 0)),
      //       (route) => false,
      //     );
      //   },
      // ),
      actions: [
        const _CircleIcon(icon: Icons.notifications_none),
        const _CircleIcon(icon: Icons.favorite_border),
        _CircleIcon(
          icon: Icons.search,
          onTap: () => setState(() => showSearchBar = !showSearchBar),
        ),
        const SizedBox(width: 0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: Builder(
        builder: (context) {
          final cartProvider = context.read<CartProvider>();

          // ✅ Restore cart only once after provider is ready
          if (!_cartRestored) {
            _cartRestored = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              cartProvider.restore();
            });
          }

          final List<Widget> tabs = [
            MarketHomeTab(showSearchBar: showSearchBar),
            const MarketCartTab(),
            const MarketProfileTab(),
          ];

          return Scaffold(
            backgroundColor: primaryBackground,
            appBar: _buildAppBar(),
            body: tabs[_selectedIndex],
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  backgroundColor: primaryBackground,
                  selectedItemColor: kPrimaryColor,
                  unselectedItemColor: Colors.grey,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  onTap: (index) => setState(() => _selectedIndex = index),
                  items: [
                    _buildNavItem(Icons.store, 0),
                    _buildNavItem(Icons.shopping_bag_outlined, 1),
                    _buildNavItem(Icons.person, 2),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      label: '',
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 35, color: isSelected ? kPrimaryColor : Colors.grey),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 6 : 0,
            height: isSelected ? 6 : 0,
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 1.2),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.grey, size: 20),
        onPressed: onTap,
      ),
    );
  }
}
