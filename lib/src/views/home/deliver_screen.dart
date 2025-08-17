import 'package:flutter/material.dart';
import 'delivery_info_screen.dart';

class DeliverScreen extends StatefulWidget {
  const DeliverScreen({super.key});

  @override
  State<DeliverScreen> createState() => _DeliverScreenState();
}

class _DeliverScreenState extends State<DeliverScreen> {
  int _selectedType = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map background (placeholder)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE5EFFF),
            child: const Center(
              child: Text(
                'Map Placeholder',
                style: TextStyle(color: Colors.blueGrey, fontSize: 18),
              ),
            ),
          ),
          // Back icon at top left
          Positioned(
            top: 0,
            left: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
              ),
            ),
          ),
          // Floating location button
          Positioned(
            right: 20,
            bottom: size.height * 0.38,
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Color(0xFFFF9800)),
            ),
          ),
          // Bottom sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFAF8F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 18, top: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // From/To box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: const Color(0xFFFF9800), width: 1.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.my_location, color: Color(0xFF444444), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'From',
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xFF757575),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Bole, Addis Ababa',
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: Color(0xFF444444), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'To',
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xFF757575),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Summit, Addis Ababa',
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Delivery type cards
                  Row(
                    children: [
                      _buildTypeCard('Cycle', '400 ETB', 0),
                      const SizedBox(width: 10),
                      _buildTypeCard('Motor', '540 ETB', 1),
                      const SizedBox(width: 10),
                      _buildTypeCard('Pickup', '600 ETB', 2),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Request button and gift icon
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD9D9D9)),
                        ),
                        child: const Icon(Icons.card_giftcard, color: Color(0xFFFF9800), size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0x33FF9900),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DeliveryInfoScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Request',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'Lora',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD9D9D9)),
                        ),
                        child: const Icon(Icons.card_giftcard, color: Color(0xFFFF9800), size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(String title, String price, int index) {
    final bool selected = _selectedType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = index;
          });
        },
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: selected ? Colors.white : const Color(0xFFFAF8F4),
            border: Border.all(
              color: selected ? const Color(0xFFFF9800) : const Color(0xFFD9D9D9),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 