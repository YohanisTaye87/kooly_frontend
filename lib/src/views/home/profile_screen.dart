import 'package:flutter/material.dart';
import 'main_home.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isSmall ? 8 : 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: -18,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Enter your name',
                      style: TextStyle(
                        fontSize: isSmall ? 20 : 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Lora',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmall ? 18 : 24),
              Center(
                child: Text(
                  'KOOOLY',
                  style: TextStyle(
                    fontSize: isSmall ? 38 : 48,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFF9900),
                    fontFamily: 'Showg',
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: isSmall ? 32 : 48),
              Text(
                'Tell us  something about yourself',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 18 : 20,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please Enter Your personal information Here',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: isSmall ? 13.5 : 15,
                  fontFamily: 'Lora',
                  height: 1.4,
                ),
              ),
              SizedBox(height: isSmall ? 18 : 28),
              TextField(
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.person, color: Color(0xFF757575)),
                  hintText: 'First name',
                  hintStyle: const TextStyle(
                      fontFamily: 'Lora', color: Color(0xFF757575)),
                  filled: true,
                  fillColor: const Color(0xFFFAF8F4),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFC8C8C8), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFFF9800), width: 1.2),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Lora'),
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.person, color: Color(0xFF757575)),
                  hintText: 'Last name',
                  hintStyle: const TextStyle(
                      fontFamily: 'Lora', color: Color(0xFF757575)),
                  filled: true,
                  fillColor: const Color(0xFFFAF8F4),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFC8C8C8), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFFF9800), width: 1.2),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Lora'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.wc, color: Color(0xFF757575)),
                  hintText: 'Gender',
                  hintStyle: const TextStyle(
                      fontFamily: 'Lora', color: Color(0xFF757575)),
                  filled: true,
                  fillColor: const Color(0xFFFAF8F4),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFC8C8C8), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFFF9800), width: 1.2),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Male',
                    child: Text('Male', style: TextStyle(fontFamily: 'Lora')),
                  ),
                  DropdownMenuItem(
                    value: 'Female',
                    child: Text('Female', style: TextStyle(fontFamily: 'Lora')),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.card_giftcard, color: Color(0xFF757575)),
                  hintText: 'Referral code (optional)',
                  hintStyle: const TextStyle(
                      fontFamily: 'Lora', color: Color(0xFF757575)),
                  filled: true,
                  fillColor: const Color(0xFFFAF8F4),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFC8C8C8), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFFF9800), width: 1.2),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Lora'),
              ),
              SizedBox(height: isSmall ? 24 : 32),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9900),
                      padding:
                          EdgeInsets.symmetric(vertical: isSmall ? 14 : 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0x33FF9900),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const MainHome()),
                      );
                    },
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmall ? 16 : 18,
                        color: Colors.white,
                        fontFamily: 'Lora',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
