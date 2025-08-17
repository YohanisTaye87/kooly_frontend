import 'package:flutter/material.dart';

class FinalDeliveryScreen extends StatefulWidget {
  const FinalDeliveryScreen({super.key});

  @override
  State<FinalDeliveryScreen> createState() => _FinalDeliveryScreenState();
}

class _FinalDeliveryScreenState extends State<FinalDeliveryScreen> {
  int _rating = 3;

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
              child: Icon(Icons.map, color: Colors.blueGrey, size: 120 * width / 375.0),
            ),
          ),
          // Draggable bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.25,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24 * width / 375.0)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(20 * width / 375.0, 10 * width / 375.0, 20 * width / 375.0, 24 * width / 375.0),
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                children: [
                  Center(
                    child: Container(
                      width: 40 * width / 375.0,
                      height: 5 * width / 375.0,
                      margin: EdgeInsets.only(bottom: 18 * width / 375.0, top: 6 * width / 375.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10 * width / 375.0),
                      ),
                    ),
                  ),
                  // Driver info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22 * scale,
                        backgroundColor: const Color(0xFFD9D9D9),
                        child: Icon(Icons.person, color: Colors.white, size: 28 * scale),
                      ),
                      SizedBox(width: 12 * scale),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Leul Damtew', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 16 * scale)),
                          Row(
                            children: [
                              Text('Grey', style: TextStyle(fontFamily: 'Lora', fontSize: 14 * scale, color: const Color(0xFF757575))),
                              SizedBox(width: 12 * scale),
                              Text('1421', style: TextStyle(fontFamily: 'Lora', fontSize: 14 * scale, color: const Color(0xFF757575))),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.star, color: const Color(0xFFFF9800), size: 20 * scale),
                      SizedBox(width: 4 * scale),
                      Text('4.2', style: TextStyle(fontFamily: 'Lora', fontSize: 16 * scale)),
                    ],
                  ),
                  SizedBox(height: 18 * scale),
                  const Divider(color: Color(0xFFD9D9D9)),
                  // From/To
                  Row(
                    children: [
                      Icon(Icons.my_location, color: const Color(0xFF757575), size: 20 * scale),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: Text('From\nBole, Addis Ababa', style: TextStyle(fontFamily: 'Lora', fontSize: 14 * scale)),
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: const Color(0xFF757575), size: 20 * scale),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: Text('To\nSummit, Addis Ababa', style: TextStyle(fontFamily: 'Lora', fontSize: 14 * scale)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  const Divider(color: Color(0xFFD9D9D9)),
                  // Delivery Status
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Delivery Status', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 15 * scale)),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.play_circle_fill, color: const Color(0xFFFF9800), size: 32 * scale),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('On the way', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 15 * scale)),
                            Text('The package is currently being delivered & is on it\'s way.', style: TextStyle(fontFamily: 'Lora', fontSize: 13 * scale, color: const Color(0xFF757575))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * scale),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: const Color(0xFFFF9800), size: 32 * scale),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delivered', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 15 * scale)),
                            Text('The package has arrived and has been successfully delivered.', style: TextStyle(fontFamily: 'Lora', fontSize: 13 * scale, color: const Color(0xFF757575))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  const Divider(color: Color(0xFFD9D9D9)),
                  // Payment
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: const Color(0xFF4CAF50), size: 28 * scale),
                      SizedBox(width: 8 * scale),
                      Text('Cash', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 15 * scale)),
                      const Spacer(),
                      Text('100ETB', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 15 * scale)),
                    ],
                  ),
                  SizedBox(height: 18 * scale),
                  // Rate your ride
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Rate your ride', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 15 * scale)),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => IconButton(
                      icon: Icon(
                        Icons.star,
                        color: index < _rating ? const Color(0xFFFF9800) : const Color(0xFFD9D9D9),
                        size: 32 * scale,
                      ),
                      onPressed: () => setState(() => _rating = index + 1),
                      splashRadius: 20 * scale,
                    )),
                  ),
                  SizedBox(height: 10 * scale),
                  // Rate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8 * scale),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Rate',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * scale),
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
                      onPressed: () => Navigator.of(context).pop(),
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
          // Back icon at top left (ensure it's last in the stack for highest z-order)
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
              ),
            ),
          ),
          // GPS location icon at top right
          const Positioned(
            top: 48,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Color(0xFFFF9800)),
            ),
          ),
        ],
      ),
    );
  }
} 