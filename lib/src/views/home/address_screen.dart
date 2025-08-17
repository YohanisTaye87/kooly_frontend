import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:koooly_app/src/components/rounded_button.dart';
import 'package:koooly_app/src/cubit/models/loc_history.dart';
import 'package:koooly_app/src/cubit/models/pick_up_drop.dart';
import 'package:koooly_app/src/shared/cache_storage.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/shared/validators.dart';
import 'package:koooly_app/src/views/home/route_screen.dart';
import 'package:koooly_app/src/views/home/deliver_screen.dart';
import 'package:latlong2/latlong.dart';

class AddressScreen extends StatefulWidget {
  final LatLng? currentLocation;
  final LatLng? destination;
  final String? currentLocatioName;
  final String? destinatioName;
  final bool isMotorSelected;
  const AddressScreen(
      {this.currentLocation,
      this.currentLocatioName,
      this.destinatioName,
      this.destination,
      this.isMotorSelected = false,
      super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> with FormValidators {
  double? totalDistance;
  bool dataSafeLoad = false;
  bool isLoading = false;
  num? timeTaken;
  String? city;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  List<LatLng> _parseRoute(List direction) {
    try {
      List<LatLng> points = [];
      for (var element in direction) {
        points.add(LatLng(element[0], element[1]));
      }
      return points;
    } catch (e) {
      print('Error fetching route: $e');
      return [];
    }
  }

  Future<List<LatLng>?> fetchRoute(LatLng start, LatLng end) async {
    print("fetchroute $start $end");
    // final g =
    //     "https://mapapi.gebeta.app/api/route/direction/?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&apiKey=$gebetaAPI";
    try {
      final response = await dio.get(
          "https://mapapi.gebeta.app/api/route/direction/?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&apiKey=$gebetaAPI");
      // print("gebeta route return: $g");

      if (response.statusCode == 200) {
        final decodedData = response.data;

        if (decodedData['msg'] == 'Ok') {
          final finalRoute = _parseRoute(decodedData['direction']);

          if (mounted && context.mounted) {
            setState(() {
              totalDistance = response.data['totalDistance'];
              timeTaken = response.data['timetaken'];
              dataSafeLoad = true;
            });
          }
          return finalRoute;
        } else {
          throw Exception('API did not return a successful response');
        }
      } else {
        if (context.mounted && mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: kPrimaryColor,
              content: Text(
                'Problem with fetching routes. Please try again.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      }
      return null;
    } catch (e) {
      print("fetch route error: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _searchLocation(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15)))
          .get(
        'https://mapapi.gebeta.app/api/v1/route/geocoding?name=$query&apiKey=$gebetaAPI',
      );
      setState(() {
        city = response.data['City'];
      });

      if (response.data['data'] != null && response.data['data'].isNotEmpty) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
    } catch (e) {
      print('Error searching location: $e');
    }

    return [];
  }

  Future<void> _reverseGeocode(LatLng location) async {
    try {
      final response = await dio.get(
        'https://mapapi.gebeta.app/api/v1/route/reverse-geocoding?lat=${location.latitude}&lng=${location.longitude}&apiKey=$gebetaAPI',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['data'] != null && data['data'].isNotEmpty) {
          final address = data['data'][0]['name'] ?? 'Current Location';
          if (mounted) {
            setState(() {
              _departureController.text = address;
            });
            // Automatically focus on destination field after current location is set
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                FocusScope.of(context).requestFocus(_destinationFocusNode);
              }
            });
          }
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      // Keep "Current Location" as fallback and still focus destination
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(_destinationFocusNode);
          }
        });
      }
    }
  }

  Future<Position?> _determinePosition() async {
    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
      });
    }

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: kPrimaryColor,
              content: Text(
                'Location services are disabled. Please enable them in settings.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoadingLocation = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: kPrimaryColor,
                content: Text(
                  'Location permissions are denied.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: kPrimaryColor,
              content: Text(
                'Location permissions are permanently denied. Please enable them in app settings.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        return null;
      }

      // Get the current position with optimized settings for speed
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);

      // Set location immediately and then reverse geocode for proper address
      if (mounted) {
        setState(() {
          departure = currentLatLng;
          _departureController.text = 'Current Location';
        });
      }

      // Reverse geocode to get actual address
      await _reverseGeocode(currentLatLng);

      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }

      return position;
    } catch (e) {
      print("Error getting current location: $e");
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text(
              'Failed to get current location. Please enter manually.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
    return null;
  }

  LatLng? departure;
  LatLng? destination;
  bool _isLoadingLocation = false;

  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _departureFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();
  bool _isDepartureFocused = false;
  bool _isDestinationFocused = false;

  @override
  void initState() {
    super.initState();
    _departureFocusNode.addListener(() {
      setState(() {
        _isDepartureFocused = _departureFocusNode.hasFocus;
      });
    });
    _destinationFocusNode.addListener(() {
      setState(() {
        _isDestinationFocused = _destinationFocusNode.hasFocus;
      });
    });
    _departureController.addListener(() {
      setState(() {
        // This will trigger rebuild when departure text changes
      });
    });
    _destinationController.text =
        widget.destinatioName ?? _destinationController.text;
    _departureController.text =
        widget.currentLocatioName ?? _departureController.text;
    departure = widget.currentLocation;
    destination = widget.destination;

    // Auto-detect current location if no departure is set
    if (widget.currentLocation == null && widget.currentLocatioName == null) {
      _determinePosition();
    } else {
      // Only focus departure if location is already set
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_departureFocusNode);
      });
    }
  }

  @override
  void dispose() {
    _departureFocusNode.dispose();
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
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.black, size: 20),
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
                  // Origin box (Departure)
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: _isDepartureFocused
                            ? const Color(0xFFFF9800)
                            : const Color(0xFFC8C8C8),
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
                          child: _isLoadingLocation
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFF9800)),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () => _determinePosition(),
                                  child: const Icon(Icons.my_location,
                                      color: Color(0xFF444444)),
                                ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: const Color(0xFFD9D9D9),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: TypeAheadField<Map<String, dynamic>>(
                              hideWithKeyboard: true,
                              hideKeyboardOnDrag: true,
                              hideOnSelect: true,
                              hideOnUnfocus: true,
                              controller: _departureController,
                              focusNode: _departureFocusNode,
                              suggestionsCallback: (pattern) async {
                                // Don't search if it's current location or if field is not being actively typed
                                if (pattern.toLowerCase() ==
                                        'current location' ||
                                    pattern.isEmpty ||
                                    !_departureFocusNode.hasFocus) {
                                  return [];
                                }
                                return await _searchLocation(pattern);
                              },
                              emptyBuilder: (context) => Container(
                                padding: const EdgeInsets.all(16),
                                child: const Text(
                                  '',
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 14,
                                    color: Color(0xFF757575),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              decorationBuilder: (context, child) {
                                return Material(
                                  type: MaterialType.card,
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFFFAF8F4),
                                  child: child,
                                );
                              },
                              builder: (context, controller, focusNode) {
                                return TextFormField(
                                  controller: controller,
                                  focusNode: _departureFocusNode,
                                  validator: validateEmpty,
                                  autofocus: true,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter Departure',
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
                                );
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion['name']),
                                  onTap: () {
                                    _departureController.text =
                                        suggestion['name'];
                                    setState(() {
                                      departure = LatLng(suggestion['latitude'],
                                          suggestion['longitude']);
                                    });
                                    FocusScope.of(context)
                                        .requestFocus(_destinationFocusNode);
                                  },
                                );
                              },
                              onSelected: (suggestion) {
                                _departureController.text = suggestion['name'];
                                setState(() {
                                  departure = LatLng(suggestion['latitude'],
                                      suggestion['longitude']);
                                });
                                FocusScope.of(context)
                                    .requestFocus(_destinationFocusNode);
                              },
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
                      color: _departureController.text.isEmpty
                          ? Colors.grey[100]
                          : Colors.transparent,
                      border: Border.all(
                        color: _isDestinationFocused
                            ? const Color(0xFFFF9800)
                            : const Color(0xFFC8C8C8),
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
                          child: Icon(Icons.location_on_outlined,
                              color: _departureController.text.isEmpty
                                  ? const Color(0xFFCCCCCC)
                                  : const Color(0xFF444444)),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: const Color(0xFFD9D9D9),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: TypeAheadField<Map<String, dynamic>>(
                              controller: _destinationController,
                              focusNode: _destinationFocusNode,
                              suggestionsCallback: (pattern) async {
                                if (_departureController.text.isEmpty) {
                                  return [];
                                }
                                return await _searchLocation(pattern);
                              },
                              emptyBuilder: (context) => Container(
                                padding: const EdgeInsets.all(16),
                                child: const Text(
                                  '',
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 14,
                                    color: Color(0xFF757575),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              decorationBuilder: (context, child) {
                                return Material(
                                  type: MaterialType.card,
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFFFAF8F4),
                                  child: child,
                                );
                              },
                              builder: (context, controller, focusNode) {
                                return TextFormField(
                                  controller: controller,
                                  focusNode: _destinationFocusNode,
                                  enabled: _departureController.text.isNotEmpty,
                                  validator: validateEmpty,
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: _departureController.text.isEmpty
                                        ? 'Enter departure first'
                                        : 'Enter Destination',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Lora',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: _departureController.text.isEmpty
                                          ? const Color(0xFFCCCCCC)
                                          : const Color(0xFF757575),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Lora',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                );
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion['name']),
                                  onTap: () {
                                    _destinationController.text =
                                        suggestion['name'];
                                    setState(() {
                                      destination = LatLng(
                                          suggestion['latitude'],
                                          suggestion['longitude']);
                                    });
                                  },
                                );
                              },
                              onSelected: (suggestion) {
                                _destinationController.text =
                                    suggestion['name'];
                                setState(() {
                                  destination = LatLng(suggestion['latitude'],
                                      suggestion['longitude']);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: RoundedButton(
                      text: 'Find Route',
                      color: const Color(0xFFFF9800),
                      isLoading: isLoading,
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          // Geocode departure if null
                          if (departure == null) {
                            var depResults = await _searchLocation(
                                _departureController.text);
                            if (depResults.isNotEmpty) {
                              setState(() {
                                departure = LatLng(depResults[0]['latitude'],
                                    depResults[0]['longitude']);
                              });
                            }
                          }
                          // Geocode destination if null
                          if (destination == null) {
                            var destResults = await _searchLocation(
                                _destinationController.text);
                            if (destResults.isNotEmpty) {
                              setState(() {
                                destination = LatLng(destResults[0]['latitude'],
                                    destResults[0]['longitude']);
                              });
                            }
                          }
                          if (departure != null && destination != null) {
                            setState(() {
                              isLoading = true;
                            });
                            final his = LocationHistory(
                              name: _destinationController.text,
                              location: destination!,
                            );
                            CacheStorage().saveSearchTerm(term: his.toJson());
                            var routePoints =
                                await fetchRoute(departure!, destination!);
                            // var routePoints = _fakeLoadRoute();
                            if (context.mounted &&
                                routePoints != null &&
                                routePoints.isNotEmpty) {
                              // Check if motor is selected
                              if (widget.isMotorSelected) {
                                // Navigate to deliver screen for motor
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const DeliverScreen(),
                                    transitionDuration:
                                        const Duration(milliseconds: 150),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                // Navigate to route screen for car
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        RouteScreen(
                                      dropOffAddress:
                                          _destinationController.text,
                                      pickupAddress: _departureController.text,
                                      departure: PickUp(
                                        lat: departure!.latitude,
                                        lng: departure!.longitude,
                                      ),
                                      destination: DropOff(
                                        lat: destination!.latitude,
                                        lng: destination!.longitude,
                                      ),
                                      routePoints: routePoints,
                                      totalDistance: totalDistance!,
                                      timeTaken: timeTaken,
                                    ),
                                    transitionDuration:
                                        const Duration(milliseconds: 150),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: kPrimaryColor,
                                content: Text(
                                  'Could not find a valid location for your input. Please check your addresses and try again.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      width: MediaQuery.sizeOf(context).width / 1.3,
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
