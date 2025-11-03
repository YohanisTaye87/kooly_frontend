import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koooly_app/src/cubit/user_cubit.dart';
import 'package:koooly_app/src/cubit/user_state.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/views/home/main_home.dart';

class TripEndingScreen extends StatefulWidget {
  final Map<String, dynamic> rideData;
  final String? pickupAddress;
  final String? dropOffAddress;
  final double totalDistance;
  final num? timeTaken;

  const TripEndingScreen({
    required this.rideData,
    required this.pickupAddress,
    required this.dropOffAddress,
    required this.totalDistance,
    required this.timeTaken,
    super.key,
  });

  @override
  State<TripEndingScreen> createState() => _TripEndingScreenState();
}

class _TripEndingScreenState extends State<TripEndingScreen> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  @override
  void initState() {
    super.initState();
    print("🏁 [RATING] TripEndingScreen initialized");
    print("🏁 [RATING] Ride data: ${widget.rideData}");
    print("🏁 [RATING] Pickup address: ${widget.pickupAddress}");
    print("🏁 [RATING] Dropoff address: ${widget.dropOffAddress}");
    print("🏁 [RATING] Total distance: ${widget.totalDistance}");
    print("🏁 [RATING] Time taken: ${widget.timeTaken}");
    print("🏁 [RATING] Initial rating: $_rating");
  }

  @override
  void dispose() {
    print("🏁 [RATING] TripEndingScreen disposed");
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    print("🚀 [RATING] Starting rating submission process");
    print("🚀 [RATING] Current rating: $_rating");
    print("🚀 [RATING] Feedback text: '${_feedbackController.text.trim()}'");

    if (_rating == 0) {
      print("❌ [RATING] No rating selected, showing error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("✅ [RATING] Rating validation passed, setting loading state");
    setState(() {
      _isSubmitting = true;
    });

    try {
      print("🔍 [RATING] Getting user token from UserCubit");
      final userCubit = context.read<UserCubit>();
      final currentState = userCubit.state;
      String? token;

      if (currentState is UserLoaded) {
        token = currentState.user.token;
        print("✅ [RATING] Token obtained: ${token?.substring(0, 20)}...");
      } else {
        print("❌ [RATING] User not loaded, no token available");
      }

      final ratingData = {
        "rating": _rating,
        "feedback": _feedbackController.text.trim(),
      };

      print("📤 [RATING] Preparing API request:");
      print(
          "📤 [RATING] URL: http://$kPrimaryBaseUrl/api/rideRequest/${widget.rideData['_id']}/rating");
      print("📤 [RATING] Data: ${jsonEncode(ratingData)}");
      print(
          "📤 [RATING] Headers: Content-Type: application/json, Authorization: Bearer ${token?.substring(0, 20)}...");

      final response = await dio.put(
        "http://$kPrimaryBaseUrl/api/rideRequest/${widget.rideData['_id']}/rating",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $token"
          },
        ),
        data: jsonEncode(ratingData),
      );

      print("📥 [RATING] API Response received:");
      print("📥 [RATING] Status Code: ${response.statusCode}");
      print("📥 [RATING] Response Data: ${response.data}");
      print("📥 [RATING] Response Headers: ${response.headers}");

      if (response.statusCode == 200) {
        print("✅ [RATING] Rating submitted successfully!");
        print("🏠 [RATING] Navigating back to MainHome");
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const MainHome(),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
            (route) => false,
          );
        }
      } else {
        print("❌ [RATING] API returned non-200 status: ${response.statusCode}");
        print("❌ [RATING] Response: ${response.data}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Rating submission failed. Status: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("💥 [RATING] Exception occurred during rating submission:");
      print("💥 [RATING] Error type: ${e.runtimeType}");
      print("💥 [RATING] Error message: $e");
      if (e is DioException) {
        print("💥 [RATING] DioException details:");
        print("💥 [RATING] Response: ${e.response?.data}");
        print("💥 [RATING] Status Code: ${e.response?.statusCode}");
        print("💥 [RATING] Request Options: ${e.requestOptions.uri}");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      print("🔄 [RATING] Cleaning up loading state");
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            print(
                "⭐ [RATING] Star ${index + 1} tapped, setting rating to ${index + 1}");
            setState(() {
              _rating = index + 1;
            });
            print("⭐ [RATING] Current rating updated to: $_rating");
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.star,
              size: 40,
              color: index < _rating
                  ? const Color(0xFFFFB300)
                  : const Color(0xFFE0E0E0),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.rideData['totalPrice'] ?? 0.0;
    final driverName = widget.rideData['driver']?['name'] ?? 'Driver';
    final vehicleType =
        widget.rideData['selectedCarType']?['vehicleType'] ?? 'Standard';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const MainHome(),
                          transitionDuration: const Duration(milliseconds: 300),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Trip Completed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
              const SizedBox(height: 30),

              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),

              // Trip details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vehicleType,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'ETB ${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Route info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.my_location,
                                color: Color(0xFF4CAF50), size: 20),
                            Container(
                              width: 2,
                              height: 30,
                              color: const Color(0xFFD9D9D9),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            const Icon(Icons.location_on,
                                color: Color(0xFFFF5722), size: 20),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'From',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              Text(
                                widget.pickupAddress ?? 'Pickup Location',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'To',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              Text(
                                widget.dropOffAddress ?? 'Drop-off Location',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Trip stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Distance',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                            Text(
                              '${(widget.totalDistance / 1000).toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                            Text(
                              '${widget.timeTaken ?? 10} min',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Driver',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                            Text(
                              driverName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Rating section
              const Text(
                'How was your trip?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildStarRating(),
              const SizedBox(height: 20),

              // Feedback text field
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Leave a comment (optional)',
                  hintStyle: const TextStyle(color: Color(0xFF757575)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFF9800)),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const Spacer(),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          print("🔘 [RATING] Submit Rating button pressed");
                          print("🔘 [RATING] Current rating: $_rating");
                          print(
                              "🔘 [RATING] Feedback: '${_feedbackController.text.trim()}'");
                          print("🔘 [RATING] Is submitting: $_isSubmitting");
                          _submitRating();
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Rating',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
