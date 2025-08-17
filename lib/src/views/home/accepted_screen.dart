import 'package:flutter/material.dart';
import 'package:koooly_app/src/views/home/finaldelivery_screen.dart';

class AcceptedScreen extends StatelessWidget {
  const AcceptedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final scale = width / 375.0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map background (placeholder)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE5EFFF),
            child: Center(
              child: Icon(Icons.map, color: Colors.blueGrey, size: 120 * scale),
            ),
          ),
          // Back icon at top left
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.grey[700], size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
              ),
            ),
          ),
          // Floating location button
          Positioned(
            right: 20 * scale,
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(20 * scale, 10 * scale, 20 * scale, 24 * scale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40 * scale,
                      height: 5 * scale,
                      margin: EdgeInsets.only(bottom: 18 * scale, top: 6 * scale),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                    ),
                  ),
                  // Ride info
                  Row(
                    children: [
                      Text(
                        'Cycle',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          fontSize: 22 * scale,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 60 * scale,
                        height: 36 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(8 * scale),
                        ),
                        child: Center(
                          child: Text(
                            '1421',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontWeight: FontWeight.bold,
                              fontSize: 16 * scale,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: [
                      Text('10 min', style: TextStyle(fontFamily: 'Lora', fontSize: 14 * scale, color: const Color(0xFF757575))),
                      SizedBox(width: 16 * scale),
                      Text('Grey', style: TextStyle(fontFamily: 'Lora', fontSize: 14 * scale, color: const Color(0xFF757575))),
                    ],
                  ),
                  SizedBox(height: 18 * scale),
                  // Driver info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22 * scale,
                        backgroundImage: const AssetImage('lib/assets/driver_avatar.png'),
                      ),
                      SizedBox(width: 12 * scale),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Leul Damtew', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 16 * scale)),
                          Row(
                            children: [
                              Icon(Icons.star, color: const Color(0xFFFF9800), size: 16 * scale),
                              SizedBox(width: 4 * scale),
                              Text('4.2', style: TextStyle(fontFamily: 'Lora', fontSize: 14 * scale)),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800),
                          borderRadius: BorderRadius.circular(8 * scale),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.phone, color: Colors.white, size: 22 * scale),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18 * scale),
                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF9800)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8 * scale),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FinalDeliveryScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * scale,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 