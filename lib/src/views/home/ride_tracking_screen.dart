import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:koooly_app/src/cubit/user_cubit.dart';
import 'package:koooly_app/src/cubit/user_state.dart';
import 'package:koooly_app/src/shared/cache_storage.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/views/home/main_home.dart';
import 'package:koooly_app/src/views/home/address_screen.dart';
import 'package:latlong2/latlong.dart';

class RideTrackingScreen extends StatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  final cache = CacheStorage();
  bool ridecompleted = false;
  int _rating = 4;
  MapController? _mapController;
  bool mapReady = false;
  Key _mapKey = UniqueKey();
  Key _polylineKey = UniqueKey();
  List<LatLng> routePoints = [];
  bool routeLoading = true;

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  @override
  void initState() {
    super.initState();
    _checkRideCompletion();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  List<LatLng> _parseRoute(List direction) {
    try {
      List<LatLng> points = [];
      for (var element in direction) {
        points.add(LatLng(element[0], element[1]));
      }
      return points;
    } catch (e) {
      print('Error parsing route: $e');
      return [];
    }
  }

  Future<List<LatLng>?> _fetchRoute(LatLng start, LatLng end) async {
    print("fetchroute $start $end");
    try {
      final response = await dio.get(
          "https://mapapi.gebeta.app/api/route/direction/?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&apiKey=$gebetaAPI");

      if (response.statusCode == 200) {
        final decodedData = response.data;

        if (decodedData['msg'] == 'Ok') {
          final finalRoute = _parseRoute(decodedData['direction']);
          return finalRoute;
        } else {
          throw Exception('API did not return a successful response');
        }
      } else {
        print('Route API error: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print("fetch route error: $e");
      return null;
    }
  }

  Future<void> _loadRouteFromRideData(UserLoaded state) async {
    var pickupLat = state.user.ride?['pickUp']?['lat']?.toDouble();
    var pickupLng = state.user.ride?['pickUp']?['lng']?.toDouble();
    var dropoffLat = state.user.ride?['dropOff']?['lat']?.toDouble();
    var dropoffLng = state.user.ride?['dropOff']?['lng']?.toDouble();

    // If coordinates not found in active ride, check completed ride data
    if ((pickupLat == null ||
            pickupLng == null ||
            dropoffLat == null ||
            dropoffLng == null) &&
        state.user.rideCompleted != null) {
      pickupLat = state.user.rideCompleted?['pickUp']?['lat']?.toDouble();
      pickupLng = state.user.rideCompleted?['pickUp']?['lng']?.toDouble();
      dropoffLat = state.user.rideCompleted?['dropOff']?['lat']?.toDouble();
      dropoffLng = state.user.rideCompleted?['dropOff']?['lng']?.toDouble();
    }

    if (pickupLat != null &&
        pickupLng != null &&
        dropoffLat != null &&
        dropoffLng != null) {
      final pickupPoint = LatLng(pickupLat, pickupLng);
      final dropoffPoint = LatLng(dropoffLat, dropoffLng);

      setState(() {
        routeLoading = true;
      });

      final fetchedRoute = await _fetchRoute(pickupPoint, dropoffPoint);

      if (mounted && fetchedRoute != null && fetchedRoute.isNotEmpty) {
        setState(() {
          routePoints = fetchedRoute;
          routeLoading = false;
          _polylineKey = UniqueKey(); // Refresh polyline
        });
      } else {
        // Fallback to straight line if route fetch fails
        setState(() {
          routePoints = [pickupPoint, dropoffPoint];
          routeLoading = false;
        });
      }
    }
  }

  void _checkRideCompletion() {
    final userCubit = context.read<UserCubit>();
    final currentState = userCubit.state;
    if (currentState is UserLoaded) {
      // Only show completion screen if:
      // 1. There's completed ride data AND
      // 2. The current active ride status is actually 'completed' OR there's no active ride
      final hasCompletedRide = currentState.user.rideCompleted != null;
      final activeRideStatus =
          currentState.user.ride?['status']?.toString().toLowerCase();
      final isRideActuallyCompleted =
          activeRideStatus == null || activeRideStatus == 'completed';

      if (hasCompletedRide && isRideActuallyCompleted) {
        setState(() {
          ridecompleted = true;
        });
      } else {
        setState(() {
          ridecompleted = false;
        });
      }
    }
  }

  Future<void> _submitRatingFromTracking(UserLoaded state) async {
    print("🚀 [RATING] Starting rating submission from tracking screen");
    print("🚀 [RATING] Current rating: $_rating");
    print("🚀 [RATING] Ride completed data: ${state.user.rideCompleted}");

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

    print("✅ [RATING] Rating validation passed, submitting rating");

    try {
      final userCubit = context.read<UserCubit>();
      final currentState = userCubit.state;
      String? token;

      if (currentState is UserLoaded) {
        token = currentState.user.token;
        print("✅ [RATING] Token obtained: ${token?.substring(0, 20)}...");
      } else {
        print("❌ [RATING] User not loaded, no token available");
        return;
      }

      final ratingData = {
        "rating": _rating,
        "feedback": "", // No feedback field in tracking screen
      };

      print("📤 [RATING] Preparing API request:");
      print(
          "📤 [RATING] URL: http://$kPrimaryBaseUrl/api/rideRequest/${state.user.rideCompleted!['_id']}/rating");
      print("📤 [RATING] Data: ${jsonEncode(ratingData)}");
      print(
          "📤 [RATING] Headers: Content-Type: application/json, Authorization: Bearer ${token?.substring(0, 20)}...");

      final response = await dio.put(
        "http://$kPrimaryBaseUrl/api/rideRequest/${state.user.rideCompleted!['_id']}/rating",
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
        print(
            "🏠 [RATING] Clearing ride data and navigating to address screen");

        if (mounted) {
          setState(() {
            ridecompleted = false;
          });

          await cache.saveLastCompletedId(state.user.rideCompleted!['_id']);

          context.read<UserCubit>().clearAllRideData();

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AddressScreen(),
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
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
    }
  }

  Future<int?> _cancelRide(String rideId, String token) async {
    try {
      final response = await dio.put(
        "http://$kPrimaryBaseUrl/api/rideRequest/$rideId/status",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $token",
          },
        ),
        data: jsonEncode({
          "status": "Cancelled",
          "cancelledReason": ["User cancelled"],
        }),
      );

      debugPrint("cancel stat: ${response.statusCode}: ${response.data}");

      if (mounted &&
          (response.statusCode == 200 || response.statusCode == 218)) {
        // Navigate to address screen for new ride after cancellation
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AddressScreen(),
            transitionDuration: const Duration(milliseconds: 150),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }

      return response.statusCode;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Connection problem. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      debugPrint("ride request cancel error: ${e.toString()}");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            ),
          );
        }

        if (state is! UserLoaded) {
          return const Scaffold(
            body: Center(
              child: Text('Error loading ride information'),
            ),
          );
        }

        // Re-check ride completion status when state updates
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkRideCompletion();
        });

        // Check current ride status
        final rideStatus = state.user.ride?['status']?.toString().toLowerCase();

        // Show completion screen if:
        // 1. Ride status is 'completed' OR
        // 2. We have completed ride data and ridecompleted flag is true OR
        // 3. We have completed ride data but no active ride (ride was completed and cleared)
        if (rideStatus == 'completed' ||
            (state.user.rideCompleted != null && ridecompleted == true) ||
            (state.user.rideCompleted != null && rideStatus == null)) {
          return _buildRideCompletedScreen(state, size);
        }

        if (rideStatus == null && state.user.rideCompleted == null) {
          // No active ride and no completed ride, navigate back to home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const MainHome(),
                transitionDuration: const Duration(milliseconds: 150),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Map with route
              _buildMap(state, size),

              // Back button
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
                      icon: Icon(Icons.chevron_left,
                          color: Colors.grey[700], size: 28),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const AddressScreen(),
                            transitionDuration:
                                const Duration(milliseconds: 150),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Location button
              Positioned(
                right: 20,
                bottom: size.height * 0.38,
                child: const CircleAvatar(
                  backgroundColor: Color(0xFFFF9800),
                  child: Icon(Icons.my_location, color: Colors.white, size: 24),
                ),
              ),

              // Active ride bottom sheet
              _buildActiveRideBottomSheet(state, size),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveRideBottomSheet(UserLoaded state, Size size) {
    final rideStatus = state.user.ride?['status']?.toString().toLowerCase();

    return DraggableScrollableSheet(
      key: ValueKey('active_ride_${state.user.ride?['_id']}'),
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                // Content based on ride status
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildActiveRideContent(state, rideStatus),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveRideContent(UserLoaded state, String? rideStatus) {
    switch (rideStatus) {
      case 'pending':
        return _buildPendingContent(state);
      case 'accepted':
        return _buildAcceptedContent(state);
      case 'started':
      case 'ongoing':
        return _buildStartedContent(state);
      default:
        return _buildDefaultContent(state, rideStatus);
    }
  }

  Widget _buildPendingContent(UserLoaded state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.search,
          color: kPrimaryColor,
          size: 48,
        ),
        const SizedBox(height: 16),
        const Text(
          'Finding Driver...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please wait while we find a driver for you',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(color: kPrimaryColor),
        const SizedBox(height: 24),
        // Cancel button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF9800),
              side: const BorderSide(color: Color(0xFFFF9800)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (state.user.ride != null && state.user.ride!['_id'] != null) {
                await _cancelRide(state.user.ride!['_id'], state.user.token!);
              }
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptedContent(UserLoaded state) {
    final driverName =
        state.user.ride?['riderId']?['userId']?['name'] ?? 'Driver';
    final vehicleType =
        state.user.ride?['driverInfo']?['carType']?['vehicleType'] ?? 'Vehicle';
    final driverRating =
        state.user.ride?['driverInfo']?['rating']?.toString() ?? '4.5';

    // Additional driver information
    final carColor = state.user.ride?['driverInfo']?['carColor'] ?? 'Unknown';
    final carModel = state.user.ride?['driverInfo']?['carModel'] ?? 'Unknown';
    final carPlate = state.user.ride?['driverInfo']?['carPlate'] ?? 'Unknown';
    final driverStatus = state.user.ride?['driverInfo']?['status'] ?? 'Unknown';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Driver info
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: const Icon(
                Icons.person,
                size: 30,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driverName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vehicleType,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  driverRating,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Additional driver details
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Driver Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Car Information
              Row(
                children: [
                  const Icon(Icons.directions_car,
                      size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$carColor $carModel',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // License Plate
              Row(
                children: [
                  const Icon(Icons.credit_card, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Plate: $carPlate',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Driver Status
              Row(
                children: [
                  const Icon(Icons.circle, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Status: $driverStatus',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Driver Accepted!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your driver is on the way to pick you up',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF9800),
                  side: const BorderSide(color: Color(0xFFFF9800)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (state.user.ride != null &&
                      state.user.ride!['_id'] != null) {
                    await _cancelRide(
                        state.user.ride!['_id'], state.user.token!);
                  }
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
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
                ),
                onPressed: () {
                  // Call driver functionality
                },
                child: const Text(
                  'Call',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartedContent(UserLoaded state) {
    final driverName =
        state.user.ride?['riderId']?['userId']?['name'] ?? 'Driver';
    final vehicleType =
        state.user.ride?['driverInfo']?['carType']?['vehicleType'] ?? 'Vehicle';
    final driverRating =
        state.user.ride?['driverInfo']?['rating']?.toString() ?? '4.5';

    // Additional driver information
    final carColor = state.user.ride?['driverInfo']?['carColor'] ?? 'Unknown';
    final carModel = state.user.ride?['driverInfo']?['carModel'] ?? 'Unknown';
    final carPlate = state.user.ride?['driverInfo']?['carPlate'] ?? 'Unknown';
    final driverStatus = state.user.ride?['driverInfo']?['status'] ?? 'Unknown';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Driver info
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: const Icon(
                Icons.person,
                size: 30,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driverName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vehicleType,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  driverRating,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Additional driver details
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Driver Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Car Information
              Row(
                children: [
                  const Icon(Icons.directions_car,
                      size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$carColor $carModel',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // License Plate
              Row(
                children: [
                  const Icon(Icons.credit_card, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Plate: $carPlate',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Driver Status
              Row(
                children: [
                  const Icon(Icons.circle, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Status: $driverStatus',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Ride Status: ONGOING',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your ride is being processed',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Call button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // Call driver functionality
            },
            child: const Text(
              'Call Driver',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent(UserLoaded state, String? status) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.directions_car,
          color: kPrimaryColor,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Ride Status: ${status?.toUpperCase() ?? 'UNKNOWN'}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your ride is being processed',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Cancel button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF9800),
              side: const BorderSide(color: Color(0xFFFF9800)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (state.user.ride != null && state.user.ride!['_id'] != null) {
                await _cancelRide(state.user.ride!['_id'], state.user.token!);
              }
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMap(UserLoaded state, Size size,
      {bool isCompletionScreen = false}) {
    // Extract pickup and dropoff coordinates from ride data or completed ride data
    var pickupLat = state.user.ride?['pickUp']?['lat']?.toDouble();
    var pickupLng = state.user.ride?['pickUp']?['lng']?.toDouble();
    var dropoffLat = state.user.ride?['dropOff']?['lat']?.toDouble();
    var dropoffLng = state.user.ride?['dropOff']?['lng']?.toDouble();

    // If coordinates not found in active ride, check completed ride data
    if ((pickupLat == null ||
            pickupLng == null ||
            dropoffLat == null ||
            dropoffLng == null) &&
        state.user.rideCompleted != null) {
      pickupLat = state.user.rideCompleted?['pickUp']?['lat']?.toDouble();
      pickupLng = state.user.rideCompleted?['pickUp']?['lng']?.toDouble();
      dropoffLat = state.user.rideCompleted?['dropOff']?['lat']?.toDouble();
      dropoffLng = state.user.rideCompleted?['dropOff']?['lng']?.toDouble();
    }

    // If we don't have coordinates, show placeholder
    if (pickupLat == null ||
        pickupLng == null ||
        dropoffLat == null ||
        dropoffLng == null) {
      return Container(
        width: double.infinity,
        height: size.height,
        color: const Color(0xFFE5EFFF),
        child: const Center(
          child: Icon(Icons.map, color: Colors.blueGrey, size: 120),
        ),
      );
    }

    final pickupPoint = LatLng(pickupLat, pickupLng);
    final dropoffPoint = LatLng(dropoffLat, dropoffLng);

    // Load detailed route if not already loaded
    if (routePoints.isEmpty && !routeLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRouteFromRideData(state);
      });
    }

    // Use fetched route points or fallback to simple line
    final displayRoutePoints =
        routePoints.isNotEmpty ? routePoints : [pickupPoint, dropoffPoint];

    return SizedBox(
      height: size
          .height, // Full height for both completion and active tracking (using draggable sheets)
      width: size.width,
      child: FlutterMap(
        key: _mapKey,
        options: MapOptions(
          initialCenter: pickupPoint,
          initialZoom: 14.0,
          onMapReady: () {
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                setState(() {
                  _mapController = MapController();
                  mapReady = true;
                });
              }
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.koooly.app',
          ),
          PolylineLayer(
            key: _polylineKey,
            polylines: [
              Polyline(
                points: displayRoutePoints,
                strokeWidth: 6.8,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              // Pickup marker
              Marker(
                point: pickupPoint,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              // Dropoff marker
              Marker(
                point: dropoffPoint,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideCompletedScreen(UserLoaded state, Size size) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map with route
          _buildMap(state, size, isCompletionScreen: true),

          // Ride completion bottom sheet
          DraggableScrollableSheet(
            key: ValueKey('ride_completed_${state.user.rideCompleted?['_id']}'),
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF8F4),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // Drag handle
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      // Trip completion content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Driver Info Section
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.user.rideCompleted!["riderId"]
                                                ?["userId"]?["name"] ??
                                            'Driver',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Lora',
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        state.user.rideCompleted!["driverInfo"]
                                                ?["carType"]?["vehicleType"] ??
                                            'Vehicle',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF757575),
                                          fontFamily: 'Lora',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      state
                                              .user
                                              .rideCompleted!["driverInfo"]
                                                  ?["rating"]
                                              ?.toString() ??
                                          '4.2',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Lora',
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Trip Status
                            const Text(
                              'Trip Completed!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lora',
                                color: Colors.green,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Payment Section
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.money,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Payment',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Lora',
                                    ),
                                  ),
                                ),
                                Text(
                                  '${state.user.rideCompleted != null && state.user.rideCompleted!["driverInfo"] != null && state.user.rideCompleted!["driverInfo"]['carType'] != null ? ((state.user.rideCompleted!["driverInfo"]["carType"]["startingPrice"]) + (state.user.rideCompleted!["driverInfo"]["carType"]["pricePerKm"] * (state.user.rideCompleted!["distanceInKm"] ?? 0))).toStringAsFixed(0) : "100"}ETB',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Lora',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Rating Section
                            const Text(
                              'Rate your ride',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lora',
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Star Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: GestureDetector(
                                    onTap: () {
                                      print(
                                          "⭐ [RATING] Star ${index + 1} tapped in tracking screen, setting rating to ${index + 1}");
                                      setState(() {
                                        _rating = index + 1;
                                      });
                                      print(
                                          "⭐ [RATING] Current rating updated to: $_rating");
                                    },
                                    child: Icon(
                                      Icons.star,
                                      size: 32,
                                      color: index < _rating
                                          ? Colors.amber
                                          : Colors.grey[300],
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 24),

                            // Rate Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9900),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    if (!mounted) return;

                                    print(
                                        "🔘 [RATING] Rate button pressed in ride completion screen");
                                    print(
                                        "🔘 [RATING] Current rating: $_rating");
                                    print(
                                        "🔘 [RATING] Ride completed data: ${state.user.rideCompleted}");

                                    // Submit rating directly from tracking screen
                                    await _submitRatingFromTracking(state);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Center(
                                    child: Text(
                                      'Rate',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Lora',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Done Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFFF9900),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    if (!mounted) return;

                                    setState(() {
                                      ridecompleted = false;
                                    });

                                    try {
                                      await cache.saveLastCompletedId(
                                          state.user.rideCompleted!['_id']);

                                      if (mounted && context.mounted) {
                                        context
                                            .read<UserCubit>()
                                            .clearAllRideData();

                                        // Navigate to address screen for new ride
                                        Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                const AddressScreen(),
                                            transitionDuration: const Duration(
                                                milliseconds: 150),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              return FadeTransition(
                                                  opacity: animation,
                                                  child: child);
                                            },
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      debugPrint(
                                          'Error handling done button: $e');
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Center(
                                    child: Text(
                                      'Done',
                                      style: TextStyle(
                                        color: Color(0xFFFF9900),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Lora',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
