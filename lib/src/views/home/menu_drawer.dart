import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_profile_screen.dart';
import 'wallet_screen.dart';
import '../login/login_screen.dart';
import '../market/market_page.dart';
import '../../cubit/user_cubit.dart';
import '../../cubit/user_state.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        String userName = 'User';
        if (state is UserLoaded) {
          userName = state.user.name ?? 'User';
        }

        return Drawer(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: const Color(0xFFFF9800),
                padding: const EdgeInsets.fromLTRB(16, 56, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Lora')),
                    const SizedBox(height: 4),
                    Text(userName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Lora')),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuItem(context, Icons.store, 'Marketplace'),
              _buildMenuItem(context, Icons.account_balance_wallet, 'wallet'),
              _buildMenuItem(context, Icons.card_giftcard, 'My referral'),
              _buildMenuItem(context, Icons.settings, 'Setting'),
              _buildMenuItem(context, Icons.help, 'Help'),
              const Spacer(),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(); // Close the drawer
                      Future.delayed(const Duration(milliseconds: 250), () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      });
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          fontFamily: 'Lora'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          if (label == 'Setting') {
            Navigator.of(context).pop(); // Close the drawer
            Future.delayed(const Duration(milliseconds: 250), () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const UserProfilePage()),
              );
            });
          } else if (label == 'wallet') {
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 250), () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const WalletScreen()),
              );
            });
          } else if (label == 'Marketplace') {
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 250), () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MarketPage()),
              );
            });
          }
        },
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF444444), size: 24),
            const SizedBox(width: 18),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 16, color: Colors.black, fontFamily: 'Lora'),
            ),
          ],
        ),
      ),
    );
  }
}
