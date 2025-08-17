import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:koooly_app/src/components/ride_status_card.dart';
import 'package:koooly_app/src/cubit/models/car_types.dart';
import 'package:koooly_app/src/cubit/models/pick_up_drop.dart';
import 'package:koooly_app/src/cubit/user_cubit.dart';
import 'package:koooly_app/src/cubit/user_state.dart';
import 'package:koooly_app/src/shared/cache_storage.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/views/home/main_home.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteScreen extends StatefulWidget {
  final List<LatLng> routePoints;
  final DropOff destination;
  final PickUp departure;
  final double totalDistance;
  final num? timeTaken;
  final String? pickupAddress;
  final String? dropOffAddress;
  const RouteScreen({
    required this.departure,
    required this.destination,
    required this.routePoints,
    required this.pickupAddress,
    required this.dropOffAddress,
    required this.totalDistance,
    required this.timeTaken,
    super.key,
  });

  @override
  State<RouteScreen> createState() => _RouteScreen();
}

class _RouteScreen extends State<RouteScreen> {
  double zoomLevel = 11;

  Key _mapKey = UniqueKey(); // Key for the FlutterMap to force a refresh
  Key _polylineKey = UniqueKey();
  List<LatLng> theRoutes = [];
  final cache = CacheStorage();
  List<CarType> carTypes = [];
  bool driverLoading = false;
  bool cancelLoading = false;
  MapController? _mapController;
  Timer? _checkRideStatusTimer;
  Timer? _cancelRideStatusTimer;
  Timer? _waitingTimer;
  String? token;
  String? errorText;
  bool cancelVisible = false;
  late final String rideId;
  int _waitingSeconds = 0;
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  // Map<String, dynamic> driverInfo = {};
  bool mapReady = false;
  int? carSelectIndex;

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

  @override
  void initState() {
    super.initState();
    theRoutes = widget.routePoints;
    final userCubit = context.read<UserCubit>();
    final currentState = userCubit.state;
    if (currentState is UserLoaded) {
      getCarTypes(currentState.user.token);
      token = currentState.user.token;
      setState(() {});
    }
    for (var reason in reasons) {
      selectedReasons[reason] = false;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _checkRideStatusTimer?.cancel();
    _cancelRideStatusTimer?.cancel();
    _waitingTimer?.cancel();
    super.dispose();
  }

  Future<int?> getCarTypes(String? token) async {
    // print("getcartype: http://$kPrimaryBaseUrl/api/carTypes");
    try {
      final response = await dio.get(
        "http://$kPrimaryBaseUrl/api/carTypes",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $token",
          },
        ),
      );
      print("getcartypes: ${response.statusCode}: ${response.data}");
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

  Future<int?> _requestRide(CarType selectedCarType) async {
    final toBe = {
      "distanceInKm": widget.totalDistance / 1000,
      "dropOff": widget.destination.toJson(),
      "pickUp": widget.departure.toJson(),
      "pickupAddress": widget.pickupAddress,
      "dropOffAddress": widget.dropOffAddress,
      "selectedCarType": selectedCarType.id,
    };
    print("request data: $toBe");
    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/rideRequest",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $token",
          },
        ),
        data: jsonEncode(toBe),
      );
      print(
        "requestRide status code: ${response.statusCode}: ${response.data}",
      );
      if (response.statusCode == 201) {
        setState(() {
          driverLoading = true;
          rideId = response.data['_id'];
          _waitingSeconds = 0;
        });
        _startWaitingTimer();
      } else {
        setState(() {
          driverLoading = false;
          errorText = response.data['error'];
        });
      }
      return response.statusCode;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text(
              'Connection problem. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      debugPrint("ride request error: ${e.toString()}");
    }
    return null;
  }

  Future<int?> _cancelRide(
    String rideId, [
    List<String>? selectedReasons,
  ]) async {
    // print("cancelss: http://$kPrimaryBaseUrl/api/rideRequest/$rideId/status");
    // print("cancelsstoken: $token");
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
          "cancelledReason": selectedReasons ?? reasons,
        }),
      );
      print("cancel stat: ${response.statusCode}: ${response.data}");

      _stopWaitingTimer();

      // Navigate directly to home page after successful cancellation
      if (mounted &&
          (response.statusCode == 200 || response.statusCode == 218)) {
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
      }

      return response.statusCode;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryColor,
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

  void _startWaitingTimer() {
    _waitingTimer?.cancel();
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _waitingSeconds++;
      });
    });
  }

  void _stopWaitingTimer() {
    _waitingTimer?.cancel();
    setState(() {
      _waitingSeconds = 0;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void updateRoute(List<LatLng> newRoutePoints) {
    setState(() {
      theRoutes = newRoutePoints;
      print("Updated route points: $theRoutes");
      _polylineKey =
          UniqueKey(); // Assign a new key to refresh the PolylineLayer
      _mapKey = UniqueKey(); // Optionally, update the map key as well if needed
    });
  }

  @override
  void didUpdateWidget(covariant RouteScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detect changes in routePoints and update polyline
    if (oldWidget.routePoints != widget.routePoints) {
      updateRoute(widget.routePoints);
    }
  }

  Widget _buildRideTypeCard(CarType carType, int index) {
    final bool selected = carSelectIndex == index;
    final double price = carType.startingPrice +
        (carType.pricePerKm * widget.totalDistance / 1000);

    return GestureDetector(
      onTap: () {
        setState(() {
          carSelectIndex = index;
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          double cardWidth = MediaQuery.of(context).size.width * 0.36;
          cardWidth = cardWidth < 140 ? 140 : cardWidth; // min width
          return Container(
            width: cardWidth,
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? Colors.white : const Color(0xFFFAF8F4),
              border: Border.all(
                color: selected
                    ? const Color(0xFFFF9800)
                    : const Color(0xFFC8C8C8),
                width: 1.4,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  carType.vehicleType,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "ETB ${price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // print("driverinfoishere: $driverInfo");
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const CircularProgressIndicator(color: kPrimaryColor);
        } else if (state is UserLoaded) {
          print(
            "popol: ${(state.user.ride == null || state.user.ride?['status'].toLowerCase() == 'failed')}",
          );
          if (state.user.ride != null &&
              (state.user.ride!['status'].toString().toLowerCase() ==
                      'accepted' ||
                  state.user.ride!['status'].toString().toLowerCase() ==
                      'started')) {
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
          }
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                // Map background
                SizedBox(
                  height: size.height,
                  width: size.width,
                  child: FlutterMap(
                    key: _mapKey,
                    options: MapOptions(
                      initialCenter: LatLng(
                        widget.departure.lat,
                        widget.departure.lng,
                      ), // This replaces 'center'
                      initialZoom: 16.0,
                      onMapReady: () {
                        Future.delayed(const Duration(milliseconds: 50), () {
                          setState(() {
                            _mapController = MapController();
                            mapReady = true;
                          });
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.koooly.app',
                      ),
                      PolylineLayer(
                        key: _polylineKey,
                        polylines: [
                          Polyline(
                            points: theRoutes,
                            strokeWidth: 6.8,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              widget.departure.lat,
                              widget.departure.lng,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 50,
                            ),
                          ),
                          Marker(
                            point: LatLng(
                              widget.destination.lat,
                              widget.destination.lng,
                            ),
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
                ),
                // Back icon on map
                Positioned(
                  top: 48,
                  left: 4,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 24,
                  ),
                ),
                // Floating location button
                Positioned(
                  right: 20,
                  bottom: size.height * 0.55,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.my_location,
                        color: Color(0xFFFF9800),
                      ),
                      onPressed: () async {
                        if (_mapController != null) {
                          _mapController!.move(
                            LatLng(widget.departure.lat, widget.departure.lng),
                            16.0,
                          );
                        }
                      },
                      splashRadius: 24,
                    ),
                  ),
                ),
                // Bottom sheet
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: state.user.ride != null &&
                            state.user.ride!['status'] != null &&
                            state.user.ride!['status'].toLowerCase() ==
                                'accepted'
                        ? 420 // Fixed height for fourth card (driver accepted)
                        : null, // Dynamic height for other cards
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // First card: Ride type selection
                        if (carTypes.isNotEmpty &&
                            !driverLoading &&
                            (state.user.ride == null ||
                                state.user.ride?['status'].toLowerCase() ==
                                    'failed' ||
                                state.user.ride?['status'].toLowerCase() ==
                                    'declined'))
                          Column(
                            children: [
                              // From/To box
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: const Color(0xFFFF9800),
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Icons and dotted line
                                    Column(
                                      children: [
                                        const Icon(
                                          Icons.my_location,
                                          color: Color(0xFF757575),
                                          size: 28,
                                        ),
                                        Container(
                                          width: 2,
                                          height: 28,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: Color(0xFFBDBDBD),
                                                width: 1,
                                                style: BorderStyle.solid,
                                              ),
                                            ),
                                          ),
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: List.generate(
                                                  6,
                                                  (index) => Container(
                                                    width: 2,
                                                    height: 4,
                                                    color: index % 2 == 0
                                                        ? const Color(
                                                            0xFFBDBDBD,
                                                          )
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const Icon(
                                          Icons.location_on_outlined,
                                          color: Color(0xFF757575),
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    // Texts
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'From',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF757575),
                                            ),
                                          ),
                                          Text(
                                            widget.pickupAddress ??
                                                'Departure Location',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF757575),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'To',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF757575),
                                            ),
                                          ),
                                          Text(
                                            widget.dropOffAddress ??
                                                'Destination Location',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF757575),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 110,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: carTypes.length,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                  ),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.only(
                                        right: index < carTypes.length - 1
                                            ? 14
                                            : 0,
                                      ),
                                      child: _buildRideTypeCard(
                                        carTypes[index],
                                        index,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        // Second card: Waiting for driver response
                        else if (driverLoading &&
                            (state.user.ride == null ||
                                state.user.ride?['status'].toLowerCase() ==
                                    'failed' ||
                                state.user.ride?['status'].toLowerCase() ==
                                    'declined'))
                          Column(
                            children: [
                              // Waiting and timer row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Waiting for Driver response...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                  Text(
                                    _formatTime(_waitingSeconds),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // Ride info and driver image
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          carSelectIndex != null
                                              ? carTypes[carSelectIndex!]
                                                  .vehicleType
                                              : 'Standard',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                const Icon(
                                                  Icons.my_location,
                                                  color: Color(0xFF444444),
                                                  size: 28,
                                                ),
                                                Container(
                                                  width: 1.2,
                                                  height: 32,
                                                  color: const Color(
                                                    0xFFD9D9D9,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  color: Color(0xFF444444),
                                                  size: 28,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'From',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF757575),
                                                    ),
                                                  ),
                                                  Text(
                                                    widget.pickupAddress ??
                                                        'Departure Location',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const Text(
                                                    'To',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF757575),
                                                    ),
                                                  ),
                                                  Text(
                                                    widget.dropOffAddress ??
                                                        'Destination Location',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFD9D9D9),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Color(0xFF757575),
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // Cash row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.money,
                                    color: Color(0xFF4CAF50),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Cash:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    carSelectIndex != null
                                        ? '${(carTypes[carSelectIndex!].startingPrice + (carTypes[carSelectIndex!].pricePerKm * widget.totalDistance / 1000)).toStringAsFixed(0)} ETB'
                                        : '0 ETB',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                            ],
                          )
                        // Third card: Driver pending/ongoing state
                        else if (state.user.ride != null &&
                            state.user.ride!['status'] != null &&
                            (state.user.ride!['status'].toLowerCase() ==
                                    'pending' ||
                                state.user.ride!['status'].toLowerCase() ==
                                    'ongoing'))
                          Column(
                            children: [
                              // Waiting and timer row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Waiting for Driver response...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                  Text(
                                    _formatTime(_waitingSeconds),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // Ride info and driver image
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          carSelectIndex != null
                                              ? carTypes[carSelectIndex!]
                                                  .vehicleType
                                              : 'Standard',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                const Icon(
                                                  Icons.my_location,
                                                  color: Color(0xFF444444),
                                                  size: 28,
                                                ),
                                                Container(
                                                  width: 1.2,
                                                  height: 32,
                                                  color: const Color(
                                                    0xFFD9D9D9,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  color: Color(0xFF444444),
                                                  size: 28,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'From',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF757575),
                                                    ),
                                                  ),
                                                  Text(
                                                    widget.pickupAddress ??
                                                        'Departure Location',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const Text(
                                                    'To',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF757575),
                                                    ),
                                                  ),
                                                  Text(
                                                    widget.dropOffAddress ??
                                                        'Destination Location',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFD9D9D9),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Color(0xFF757575),
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // Cash row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.money,
                                    color: Color(0xFF4CAF50),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Cash:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    carSelectIndex != null
                                        ? '${(carTypes[carSelectIndex!].startingPrice + (carTypes[carSelectIndex!].pricePerKm * widget.totalDistance / 1000)).toStringAsFixed(0)} ETB'
                                        : '0 ETB',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                            ],
                          ),
                        const SizedBox(height: 18),
                        // Button logic for different card states
                        // First card: Request button and gift icon
                        if (carTypes.isNotEmpty &&
                            !driverLoading &&
                            (state.user.ride == null ||
                                state.user.ride?['status'].toLowerCase() ==
                                    'failed' ||
                                state.user.ride?['status'].toLowerCase() ==
                                    'declined'))
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF9800),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 4,
                                    shadowColor: const Color(0x33FF9900),
                                  ),
                                  onPressed: carSelectIndex != null
                                      ? () async {
                                          final requestStat =
                                              await _requestRide(
                                            carTypes[carSelectIndex!],
                                          );
                                          if (requestStat == 201 &&
                                              context.mounted) {
                                            _cancelRideStatusTimer = Timer(
                                              const Duration(seconds: 30),
                                              () {
                                                setState(() {
                                                  cancelVisible = true;
                                                });
                                              },
                                            );
                                          } else {
                                            if (context.mounted &&
                                                errorText != null) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                    errorText!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      : null,
                                  child: Text(
                                    carSelectIndex != null
                                        ? "Request ${carTypes[carSelectIndex!].vehicleType.split(" ").first}"
                                        : "Select Ride Type",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
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
                                  border: Border.all(
                                    color: const Color(0xFFD9D9D9),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.card_giftcard,
                                  color: Color(0xFFFF9800),
                                  size: 28,
                                ),
                              ),
                            ],
                          )
                        // Second card: Cancel button for waiting state
                        else if (driverLoading &&
                            (state.user.ride == null ||
                                state.user.ride?['status'].toLowerCase() ==
                                    'failed' ||
                                state.user.ride?['status'].toLowerCase() ==
                                    'declined'))
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF9800),
                                side: const BorderSide(
                                  color: Color(0xFFFF9800),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                if (driverLoading) {
                                  await _cancelRide(rideId);
                                }
                              },
                              child: const Text(
                                'Cancel Request',
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        // Third card: Cancel button for pending/ongoing state
                        else if (state.user.ride != null &&
                            state.user.ride!['status'] != null &&
                            (state.user.ride!['status'].toLowerCase() ==
                                    'pending' ||
                                state.user.ride!['status'].toLowerCase() ==
                                    'ongoing'))
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF9800),
                                side: const BorderSide(
                                  color: Color(0xFFFF9800),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: const Text(
                                        'Why are you canceling the ride?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      content: StatefulBuilder(
                                        builder: (
                                          BuildContext context,
                                          StateSetter setDialogState,
                                        ) {
                                          return SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: reasons.map((
                                                reason,
                                              ) {
                                                return CheckboxListTile(
                                                  title: Text(
                                                    reason,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(
                                                        0xFF757575,
                                                      ),
                                                    ),
                                                  ),
                                                  value:
                                                      selectedReasons[reason],
                                                  activeColor: const Color(
                                                    0xFFFF9800,
                                                  ),
                                                  checkColor: Colors.white,
                                                  onChanged: (bool? value) {
                                                    setDialogState(() {
                                                      selectedReasons[reason] =
                                                          value ?? false;
                                                    });
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          );
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: const Color(
                                              0xFF757575,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFFF9800,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            elevation: 2,
                                          ),
                                          onPressed: () async {
                                            bool hasSelectedReason =
                                                selectedReasons.values.any(
                                              (selected) => selected,
                                            );
                                            if (!hasSelectedReason) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Please select at least one reason for cancellation',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            List<String> selectedReasonsList =
                                                selectedReasons.entries
                                                    .where(
                                                      (entry) => entry.value,
                                                    )
                                                    .map((entry) => entry.key)
                                                    .toList();

                                            String currentRideId = '';
                                            if (state.user.ride != null &&
                                                state.user.ride!['_id'] !=
                                                    null) {
                                              currentRideId =
                                                  state.user.ride!['_id'];
                                            }

                                            if (currentRideId.isNotEmpty) {
                                              final result = await _cancelRide(
                                                currentRideId,
                                                selectedReasonsList,
                                              );
                                              if (result == 200 ||
                                                  result == 218) {
                                                if (context.mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              } else {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Failed to cancel ride. Please try again.',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          child: const Text(
                                            'Submit',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        // Fourth card: Driver accepted/started state using reusable component
                        else if (state.user.ride != null &&
                            state.user.ride!['status'] != null &&
                            (state.user.ride!['status'].toLowerCase() == 'started' ||
                                state.user.ride!['status'].toLowerCase() == 'accepted'))
                          RideStatusCard(
                            state: state,
                            onCancel: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: const Text(
                                      'Why are you canceling the ride?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    content: StatefulBuilder(
                                      builder: (
                                        BuildContext context,
                                        StateSetter setDialogState,
                                      ) {
                                        return SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: reasons.map((reason) {
                                              return CheckboxListTile(
                                                title: Text(
                                                  reason,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF757575),
                                                  ),
                                                ),
                                                value: selectedReasons[reason],
                                                activeColor: const Color(0xFFFF9800),
                                                checkColor: Colors.white,
                                                onChanged: (bool? value) {
                                                  setDialogState(() {
                                                    selectedReasons[reason] = value ?? false;
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF757575),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFF9800),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 2,
                                        ),
                                        onPressed: () async {
                                          bool hasSelectedReason = selectedReasons.values.any((selected) => selected);
                                          if (!hasSelectedReason) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Please select at least one reason for cancellation'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          List<String> selectedReasonsList = selectedReasons.entries
                                              .where((entry) => entry.value)
                                              .map((entry) => entry.key)
                                              .toList();

                                          String currentRideId = '';
                                          if (state.user.ride != null && state.user.ride!['_id'] != null) {
                                            currentRideId = state.user.ride!['_id'];
                                          }

                                          if (currentRideId.isNotEmpty) {
                                            final result = await _cancelRide(currentRideId, selectedReasonsList);
                                            if (result == 200 || result == 218) {
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                              }
                                            } else {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Failed to cancel ride. Please try again.'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                        child: const Text(
                                          'Submit',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text("Koooly")),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Error connecting to server. Please check your network settings..",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 25),
                      LinearProgressIndicator(color: kPrimaryColor),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
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
