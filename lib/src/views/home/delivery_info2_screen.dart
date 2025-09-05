import 'package:flutter/material.dart';
import 'accepted_screen.dart';

class DeliveryInfo2Screen extends StatefulWidget {
  const DeliveryInfo2Screen({super.key});

  @override
  State<DeliveryInfo2Screen> createState() => _DeliveryInfo2ScreenState();
}

class _DeliveryInfo2ScreenState extends State<DeliveryInfo2Screen> {
  String? _selectedType;
  bool _isFragile = false;
  String? _selectedPackageSize;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final scale = width / 375.0;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24 * scale),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Package information',
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
        padding:
            EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8 * scale),
            // Step indicator
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepCircle(
                      isActive: false,
                      label: '1',
                      scale: scale,
                      labelText: 'Personal\nInformation'),
                  _StepLine(scale: scale),
                  _StepCircle(
                      isActive: true,
                      label: '2',
                      scale: scale,
                      labelText: 'Package\nInformation'),
                ],
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
              'Provide package details to help us deliver it safely.',
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
            // Package Type Dropdown
            Container(
              width: double.infinity,
              height: 48 * scale,
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD9D9D9)),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF757575)),
                  hint: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          color: Color(0xFF757575)),
                      SizedBox(width: 8 * scale),
                      Text('Package Type',
                          style: TextStyle(
                              color: const Color(0xFFBDBDBD),
                              fontSize: 15 * scale)),
                    ],
                  ),
                  items: ['Box', 'Envelope', 'Bag', 'Other']
                      .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type,
                                style: TextStyle(fontSize: 15 * scale)),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedType = val),
                ),
              ),
            ),
            SizedBox(height: 10 * scale),
            // Package Size Dropdown
            Container(
              width: double.infinity,
              height: 48 * scale,
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD9D9D9)),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPackageSize,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF757575)),
                  hint: Row(
                    children: [
                      const Icon(Icons.straighten, color: Color(0xFF757575)),
                      SizedBox(width: 8 * scale),
                      Text('Package Size',
                          style: TextStyle(
                              color: const Color(0xFFBDBDBD),
                              fontSize: 15 * scale)),
                    ],
                  ),
                  items: ['Small', 'Medium', 'Large', 'Extra Large']
                      .map((size) => DropdownMenuItem<String>(
                            value: size,
                            child: Text(size,
                                style: TextStyle(fontSize: 15 * scale)),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedPackageSize = val),
                ),
              ),
            ),
            SizedBox(height: 10 * scale),
            // Weight
            _InputField(
                hint: 'Weight(kg)',
                icon: Icons.monitor_weight_outlined,
                scale: scale),
            SizedBox(height: 10 * scale),
            // Description
            _InputField(
                hint: 'Description',
                icon: Icons.description_outlined,
                scale: scale),
            SizedBox(height: 10 * scale),
            // Fragile toggle
            Container(
              width: double.infinity,
              height: 48 * scale,
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD9D9D9)),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip_outlined,
                      color: Color(0xFF757575)),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: Text('Is it fragile',
                        style: TextStyle(
                            color: const Color(0xFF757575),
                            fontSize: 15 * scale)),
                  ),
                  Switch(
                    value: _isFragile,
                    onChanged: (val) => setState(() => _isFragile = val),
                    // activeThumbColor: const Color(0xFFFF9800),
                  ),
                ],
              ),
            ),
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
                        builder: (context) => const AcceptedScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Submit Delivery Request',
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
  final String labelText;
  const _StepCircle(
      {required this.isActive,
      required this.label,
      required this.scale,
      required this.labelText});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36 * scale,
          height: 36 * scale,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFF9800) : const Color(0xFFF3F3F3),
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isActive ? const Color(0xFFFF9800) : const Color(0xFFD9D9D9),
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
              ),
            ),
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          labelText.replaceAll('\\n', '\n'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11 * scale,
            color: isActive ? const Color(0xFFFF9800) : const Color(0xFF757575),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
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
  const _InputField(
      {required this.hint, required this.icon, required this.scale});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48 * scale,
      margin: const EdgeInsets.only(bottom: 0),
      child: TextField(
        style: TextStyle(fontSize: 15 * scale),
        decoration: InputDecoration(
          prefixIcon:
              Icon(icon, color: const Color(0xFF757575), size: 22 * scale),
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFFBDBDBD),
            fontSize: 15 * scale,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
              vertical: 14 * scale, horizontal: 12 * scale),
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
      ),
    );
  }
}
