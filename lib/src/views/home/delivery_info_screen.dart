import 'package:flutter/material.dart';
import 'delivery_info2_screen.dart';

class DeliveryInfoScreen extends StatefulWidget {
  const DeliveryInfoScreen({super.key});

  @override
  State<DeliveryInfoScreen> createState() => _DeliveryInfoScreenState();
}

class _DeliveryInfoScreenState extends State<DeliveryInfoScreen> {
  TimeOfDay? _pickupTime;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final scale = width / 375.0; // 375 is a common mobile width baseline
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.black, size: 24 * scale),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: Text(
          'Personal information',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8 * scale),
            // Step indicator
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepCircle(isActive: true, label: '1', scale: scale),
                  _StepLine(scale: scale),
                  _StepCircle(isActive: false, label: '2', scale: scale),
                ],
              ),
            ),
            SizedBox(height: 8 * scale),
            Center(
              child: Text(
                'Personal information',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * scale,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 18 * scale),
            Text(
              'Lets Get Your Package Delivered',
              style: TextStyle(
                fontFamily: 'Lora',
                fontWeight: FontWeight.bold,
                fontSize: 18 * scale,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              'Please fill the sender and the receiver information.',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 14 * scale,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(height: 22 * scale),
            Text(
              'Sender Details',
              style: TextStyle(
                fontFamily: 'Lora',
                fontWeight: FontWeight.bold,
                fontSize: 15 * scale,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10 * scale),
            _InputField(hint: 'Full Name', icon: Icons.person_outline, scale: scale),
            SizedBox(height: 10 * scale),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFD9D9D9)),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 8 * scale),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4 * scale),
                          child: Image.asset(
                            'lib/assets/flags/et.png',
                            width: 28 * scale,
                            height: 20 * scale,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          '+251',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontWeight: FontWeight.bold,
                            fontSize: 15 * scale,
                            color: Colors.black,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: const Color(0xFF757575), size: 22 * scale),
                        Container(
                          width: 1,
                          height: 28 * scale,
                          color: const Color(0xFFD9D9D9),
                          margin: EdgeInsets.symmetric(horizontal: 8 * scale),
                        ),
                        Expanded(
                          child: TextField(
                            style: TextStyle(fontSize: 15 * scale),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              isDense: true,
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'Enter your phone number',
                              hintStyle: TextStyle(
                                color: const Color(0xFFBDBDBD),
                                fontSize: 15 * scale,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * scale),
            // Pickup Time with time picker
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _pickupTime ?? TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    _pickupTime = picked;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: _pickupTime == null
                        ? ''
                        : _pickupTime!.format(context),
                  ),
                  style: TextStyle(fontSize: 15 * scale),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.access_time, color: const Color(0xFF757575), size: 22 * scale),
                    hintText: 'Pickup Time',
                    hintStyle: TextStyle(
                      color: const Color(0xFFBDBDBD),
                      fontSize: 15 * scale,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 12 * scale),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                      borderSide: const BorderSide(color: Color(0xFFFF9800)),
                    ),
                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF757575)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 22 * scale),
            Text(
              'Receiver Details',
              style: TextStyle(
                fontFamily: 'Lora',
                fontWeight: FontWeight.bold,
                fontSize: 15 * scale,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10 * scale),
            _InputField(hint: 'Full Name', icon: Icons.person_outline, scale: scale),
            SizedBox(height: 10 * scale),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFD9D9D9)),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 8 * scale),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4 * scale),
                          child: Image.asset(
                            'lib/assets/flags/et.png',
                            width: 28 * scale,
                            height: 20 * scale,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          '+251',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontWeight: FontWeight.bold,
                            fontSize: 15 * scale,
                            color: Colors.black,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: const Color(0xFF757575), size: 22 * scale),
                        Container(
                          width: 1,
                          height: 28 * scale,
                          color: const Color(0xFFD9D9D9),
                          margin: EdgeInsets.symmetric(horizontal: 8 * scale),
                        ),
                        Expanded(
                          child: TextField(
                            style: TextStyle(fontSize: 15 * scale),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              isDense: true,
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'Enter receiver phone number',
                              hintStyle: TextStyle(
                                color: const Color(0xFFBDBDBD),
                                fontSize: 15 * scale,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * scale),
            _InputField(hint: 'Delivery instruction (optional)', icon: Icons.notes_outlined, scale: scale),
            SizedBox(height: 30 * scale),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    padding: EdgeInsets.symmetric(vertical: 16 * scale),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DeliveryInfo2Screen(),
                      ),
                    );
                  },
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18 * scale,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20 * scale),
          ],
        ),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final bool isActive;
  final String label;
  final double scale;
  const _StepCircle({required this.isActive, required this.label, required this.scale});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36 * scale,
      height: 36 * scale,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF9800) : const Color(0xFFF3F3F3),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? const Color(0xFFFF9800) : const Color(0xFFD9D9D9),
          width: 2 * scale,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF757575),
            fontWeight: FontWeight.bold,
            fontSize: 16 * scale,
            fontFamily: 'Lora',
          ),
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final double scale;
  const _StepLine({required this.scale});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36 * scale,
      height: 2 * scale,
      color: const Color(0xFFD9D9D9),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final double scale;
  const _InputField({required this.hint, required this.icon, required this.scale});
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(fontSize: 15 * scale),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF757575), size: 22 * scale),
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFFBDBDBD),
          fontSize: 15 * scale,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 12 * scale),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scale),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scale),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scale),
          borderSide: const BorderSide(color: Color(0xFFFF9800)),
        ),
      ),
    );
  }
}

class _FlagBox extends StatelessWidget {
  final double scale;
  const _FlagBox({required this.scale});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56 * scale,
      height: 48 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8 * scale),
          bottomLeft: Radius.circular(8 * scale),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/flags/et.png',
            width: 24 * scale,
            height: 18 * scale,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 4 * scale),
          Text(
            '+251',
            style: TextStyle(
              fontFamily: 'Lora',
              fontWeight: FontWeight.bold,
              fontSize: 14 * scale,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
} 