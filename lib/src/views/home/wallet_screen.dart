import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koooly_app/src/cubit/user_cubit.dart';
import 'package:koooly_app/src/cubit/user_state.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        String userName = 'User';
        if (state is UserLoaded) {
          userName = state.user.name ?? 'User';
        }
        
        return Scaffold(
          backgroundColor: const Color(0xFFFAF8F4),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: 40),
                          child: Text(
                            'Set Destination',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hello,', style: TextStyle(fontSize: 18, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFFB347)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Wallet Balance', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Lora')),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _showBalance ? '357.00' : '•••••',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      fontFamily: 'Lora',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('ETB', style: TextStyle(color: Colors.white, fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {},
                                child: const Text('Deposit', style: TextStyle(fontFamily: 'Lora')),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(_showBalance ? Icons.visibility : Icons.visibility_off, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _showBalance = !_showBalance;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
} 