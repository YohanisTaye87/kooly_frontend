import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:koooly_app/src/components/blinking_text.dart';
import 'package:koooly_app/src/cubit/models/car_types.dart';
import 'package:koooly_app/src/cubit/user_cubit.dart';
import 'package:koooly_app/src/cubit/user_state.dart';
import 'package:koooly_app/src/shared/cache_storage.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/views/home/address_screen.dart';
import 'package:koooly_app/src/views/home/menu_drawer.dart';
import 'package:koooly_app/src/views/home/wallet_screen.dart';
import 'package:koooly_app/src/views/home/ride_tracking_screen.dart';
import 'package:flutter/services.dart';

import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final LatLng? currentPosition;
  final List<LatLng>? theRoutes;
  final int selectedTypeIndex;
  const HomeScreen(
      {super.key,
      this.theRoutes,
      this.currentPosition,
      this.selectedTypeIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  var renderOverlay = true;

  var childrenButtonSize = const Size(56.0, 56.0);
  var selectedfABLocation = FloatingActionButtonLocation.endDocked;
  double zoomLevel = 12;
  LatLng? _currentPosition;
  String? email;
  final cache = CacheStorage();
  List<CarType> carTypes = [];
  CarType? selectedCartype;
  MapController? _mapController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final List<String> reasons = [
    "Driver delayed",
    "Driver is too far",
    "Changed my mind",
    "Incorrect destination",
    "Driver Started the ride without me",
    "Ride cost too high",
    "Better alternative available",
  ];

  final Map<String, bool> selectedReasons = {};

  bool mapReady = false;
  bool ridecompleted = false;
  String? lastCompletedId;

  final dio = Dio();
  int notificationsCount = 3; // New state variable for notifications
  final Key _polylineKey = UniqueKey();

  // UI variables
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.currentPosition ?? _currentPosition;
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 1.0, end: 1.2).animate(_animationController);
    _determinePosition();

    // UI initialization
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    // Initialize ride completed state properly
    _initializeRideCompletedState();

    // Add listener for user state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userCubit = context.read<UserCubit>();
      if (userCubit.state is UserLoaded) {
        _checkAndSetRideCompletedState(userCubit.state);
      }
    });
  }

  Future<void> _initializeRideCompletedState() async {
    // Load the last completed ride ID from cache
    lastCompletedId = await cache.getLastCompletedId();

    // Only show ride completed card if there's actual completed ride data
    // and it's different from the last shown completed ride
    if (mounted) {
      setState(() {
        // This will be properly set when the user state is loaded
        ridecompleted = false;
      });
    }
  }

  void _checkAndSetRideCompletedState(UserState state) {
    if (state is UserLoaded && state.user.rideCompleted != null) {
      // Show ride completed card if:
      // 1. There's completed ride data
      // 2. It's different from the last shown completed ride
      if (state.user.rideCompleted!['_id'] != lastCompletedId) {
        setState(() {
          ridecompleted = true;
        });
      }
    }
  }

  Future<Position?> _determinePosition({bool fromBuild = false}) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request the user to enable it
      openAppSettings();
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, return an error
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever && mounted) {
      // Permissions are permanently denied, handle appropriately
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Location permissions are permanently denied, we cannot request permissions"),
      ));
    }

    // Get the current position
    try {
      final locc = await Geolocator.getCurrentPosition(
          locationSettings: AndroidSettings(accuracy: LocationAccuracy.best));
      if (mounted && context.mounted) {
        setState(() {
          _currentPosition = LatLng(locc.latitude, locc.longitude);
          zoomLevel = 16.5;
        });
      }
      return locc;
    } catch (e) {
      print("error with location finding");
    }
    return null;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _animationController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<int?> getCarTypes(String token) async {
    try {
      // print("sellerId: ${widget.sellerId}");
      final response = await dio.get("http://$kPrimaryBaseUrl/api/carTypes",
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "authorization": "Bearer $token"
              // "authorization": "Bearer ${widget.user.token}"
            },
          ));
      if (response.statusCode == 200) {
        List<CarType> carTs = [];
        for (var element in response.data) {
          final carT = CarType.fromJson(element);
          carTs.add(carT);
        }
        setState(() {
          carTypes = carTs;
        });
        return 200;
      } else {
        return response.statusCode;
      }
    } on DioException catch (e) {
      if (mounted) {
        debugPrint("car types get error: $e");
        return 0;
      }
    } catch (e) {
      debugPrint("car types get error: $e");
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    if (_currentPosition == null) {
      _determinePosition(fromBuild: true);
    }
    return BlocListener<UserCubit, UserState>(listener: (context, state) {
      if (state is UserLoaded) {
        _checkAndSetRideCompletedState(state);
      }
    }, child: BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: kPrimaryColor,
            ),
          );
        } else if (state is UserLoaded) {
          // Check if there's an active ride and navigate to tracking screen
          if (state.user.ride != null) {
            final rideStatus =
                state.user.ride!['status'].toString().toLowerCase();
            if (rideStatus == 'accepted' ||
                rideStatus == 'started' ||
                rideStatus == 'ongoing') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const RideTrackingScreen(),
                    transitionDuration: const Duration(milliseconds: 150),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              });
              return const Scaffold(
                body: Center(
                    child: CircularProgressIndicator(color: kPrimaryColor)),
              );
            }
          }

          return Scaffold(
              drawer: const MenuDrawer(),
              body: FocusScope(
                  node: FocusScopeNode(),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: SizedBox(
                          height: size.height,
                          width: size.width,
                          child: SizedBox(
                            height: size.height / 5 * 4,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: _currentPosition ??
                                    const LatLng(9.012807, 38.752073),
                                initialZoom:
                                    _currentPosition != null ? 16.5 : zoomLevel,
                                onMapReady: () {
                                  Future.delayed(
                                      const Duration(milliseconds: 50), () {
                                    setState(() {
                                      _mapController = MapController();
                                      mapReady = true;
                                    });
                                  });

                                  // Move the map to the current position in a microtask for extra delay
                                  // Future.microtask(() {
                                  //   if (_currentPosition != null &&
                                  //       mapReady &&
                                  //       _mapController != null) {
                                  //     _mapController!.move(_currentPosition!, 15);
                                  //   }
                                  // });
                                  // setState(() {
                                  //   mapReady = true;
                                  // });
                                  // if (_currentPosition != null) {
                                  //   _mapController?.move(
                                  //       _currentPosition ??
                                  //           const LatLng(9.012807, 38.752073),
                                  //       20.0);
                                  // } else if (_destination != null) {
                                  //   _mapController?.move(_destination!, 20.0);
                                  // }
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                  userAgentPackageName: 'com.koooly.app',
                                ),
                                if (widget.theRoutes != null &&
                                    widget.theRoutes!.isNotEmpty)
                                  PolylineLayer(
                                    key: _polylineKey,
                                    polylines: [
                                      Polyline(
                                        points: widget.theRoutes!,
                                        strokeWidth: 6.8,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                if (_currentPosition != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                          width:
                                              80.0, // Adjust the size as needed
                                          height: 80.0,
                                          point: _currentPosition!,
                                          child: AnimatedBuilder(
                                            animation: _animationController,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale: _animation
                                                    .value, // Apply the scaling animation
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue.withOpacity(
                                                        0.3), // Animated circle background
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        color: const Color(
                                                            0xFFFE620D),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  2.0),
                                                          child: Text(
                                                            "እኔ",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.my_location,
                                                        color: Colors.blue,
                                                        size:
                                                            20.0, // Size of the location icon
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          )),
                                    ],
                                  ),
                                if (state.user.ride != null &&
                                    state.user.ride?["pickUp"] != null &&
                                    state.user.ride?["dropOff"] != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                          width:
                                              80.0, // Adjust the size as needed
                                          height: 80.0,
                                          point: LatLng(
                                            state.user.ride!["pickUp"]["lat"],
                                            state.user.ride?["pickUp"]["lng"],
                                          ),
                                          child: AnimatedBuilder(
                                            animation: _animationController,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale: _animation
                                                    .value, // Apply the scaling animation
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue.withOpacity(
                                                        0.3), // Animated circle background
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        color: kPrimaryColor,
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  2.0),
                                                          child: Text(
                                                            "መነሻ",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.my_location,
                                                        color: kPrimaryColor,
                                                        size:
                                                            20.0, // Size of the location icon
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          )),
                                    ],
                                  ),
                                if (state.user.ride != null &&
                                    state.user.ride?["pickUp"] != null &&
                                    state.user.ride?["dropOff"] != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                          width:
                                              80.0, // Adjust the size as needed
                                          height: 80.0,
                                          point: LatLng(
                                            state.user.ride?["dropOff"]["lat"],
                                            state.user.ride?["dropOff"]["lng"],
                                          ),
                                          child: AnimatedBuilder(
                                            animation: _animationController,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale: _animation
                                                    .value, // Apply the scaling animation
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue.withOpacity(
                                                        0.3), // Animated circle background
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        color: kPrimaryColor,
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  2.0),
                                                          child: Text(
                                                            "መዳረሻ",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.my_location,
                                                        color: kPrimaryColor,
                                                        size:
                                                            20.0, // Size of the location icon
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          )),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Top left menu icon
                      Positioned(
                        top: 44,
                        left: 16,
                        child: GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.menu,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                      // Top right wallet icon
                      Positioned(
                        top: 44,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const WalletScreen()),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.account_balance_wallet,
                                color: Colors.white, size: 26),
                          ),
                        ),
                      ),
                      // Floating location button
                      Positioned(
                        right: 20,
                        bottom: size.height * 0.38,
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child:
                              Icon(Icons.my_location, color: Color(0xFFFF9800)),
                        ),
                      ),
                      // Bottom sheet
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFAF8F4),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 5,
                                  margin:
                                      const EdgeInsets.only(bottom: 14, top: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const Text(
                                'Where to',
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _isSearchFocused
                                        ? const Color(0xFFFF9800)
                                        : const Color(0xFFC8C8C8),
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFFFAF8F4),
                                ),
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Icon(Icons.search,
                                          color: Color(0xFFFF9800)),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        focusNode: _searchFocusNode,
                                        readOnly: true,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddressScreen(
                                                isMotorSelected:
                                                    widget.selectedTypeIndex ==
                                                        1,
                                              ),
                                            ),
                                          );
                                        },
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Search location',
                                          hintStyle: TextStyle(
                                              color: Color(0xFF757575)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )));
        } else {
          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Ooops. Please check your network settings..",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 25),
                      LinearProgressIndicator(
                        color: kPrimaryColor,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    ));
  }

  Future<void> openPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      print('This would open: $phoneUri');
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  Future<void> openMessagesApp(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw 'Could not launch $smsUri';
    }
  }
}

// SwipeToEndTripWidget - Custom swipe widget for ending trips
class SwipeToEndTripWidget extends StatefulWidget {
  final VoidCallback onSwipeComplete;

  const SwipeToEndTripWidget({super.key, required this.onSwipeComplete});

  @override
  State<SwipeToEndTripWidget> createState() => _SwipeToEndTripWidgetState();
}

class _SwipeToEndTripWidgetState extends State<SwipeToEndTripWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    // Start dragging - no state change needed
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final containerWidth = renderBox.size.width;
    const sliderWidth = 56.0;
    final maxDragDistance = containerWidth - sliderWidth - 8; // 8 for padding

    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(
        0.0,
        maxDragDistance,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final containerWidth = renderBox.size.width;
    const sliderWidth = 56.0;
    final maxDragDistance = containerWidth - sliderWidth - 8;

    if (_dragPosition >= maxDragDistance * 0.8) {
      // Complete the swipe
      HapticFeedback.heavyImpact();
      widget.onSwipeComplete();
      setState(() {
        _dragPosition = maxDragDistance;
      });
    } else {
      // Snap back to start
      _animationController.forward().then((_) {
        setState(() {
          _dragPosition = 0.0;
        });
        _animationController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFFF9900),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Background text
          const Center(
            child: Text(
              'Swipe to end the Trip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lora',
              ),
            ),
          ),
          // Slider
          Positioned(
            left: 4 + _dragPosition,
            top: 4,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.touch_app,
                  color: Color(0xFFFF9900),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// New NotificationsScreen widget

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashHeight = 3;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
