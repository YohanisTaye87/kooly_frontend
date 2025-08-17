import 'package:flutter/material.dart';
import 'deliver_screen.dart';

class Dashboard2Screen extends StatefulWidget {
  final int selectedTypeIndex;
  const Dashboard2Screen({super.key, required this.selectedTypeIndex});

  @override
  State<Dashboard2Screen> createState() => _Dashboard2ScreenState();
}

class _Dashboard2ScreenState extends State<Dashboard2Screen> {
  final FocusNode _originFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();
  bool _isOriginFocused = false;
  bool _isDestinationFocused = false;

  @override
  void initState() {
    super.initState();
    _originFocusNode.addListener(() {
      setState(() {
        _isOriginFocused = _originFocusNode.hasFocus;
      });
    });
    _destinationFocusNode.addListener(() {
      setState(() {
        _isDestinationFocused = _destinationFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _originFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Origin box
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: _isOriginFocused ? const Color(0xFFFF9800) : const Color(0xFFC8C8C8),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: const Icon(Icons.my_location, color: Color(0xFF444444)),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: const Color(0xFFD9D9D9),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: TextField(
                              focusNode: _originFocusNode,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Bole',
                                hintStyle: TextStyle(
                                  fontFamily: 'Lora',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Lora',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Destination box
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: _isDestinationFocused ? const Color(0xFFFF9800) : const Color(0xFFC8C8C8),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: const Icon(Icons.location_on_outlined, color: Color(0xFF444444)),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: const Color(0xFFD9D9D9),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: TextField(
                              focusNode: _destinationFocusNode,
                              onSubmitted: (_) {
                                if (widget.selectedTypeIndex == 1) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const DeliverScreen()),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const DeliverScreen()),
                                  );
                                }
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter Destination',
                                hintStyle: TextStyle(
                                  fontFamily: 'Lora',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Lora',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ),
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
  }
} 