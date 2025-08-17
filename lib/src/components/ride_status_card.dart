import 'package:flutter/material.dart';
import 'package:koooly_app/src/cubit/user_state.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class RideStatusCard extends StatelessWidget {
  final UserLoaded state;
  final VoidCallback? onCancel;
  
  const RideStatusCard({
    super.key,
    required this.state,
    this.onCancel,
  });

  Future<void> openPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideStatus = state.user.ride?['status']?.toString().toLowerCase();
    
    if (rideStatus == 'started') {
      return _buildStartedRideCard();
    } else if (rideStatus == 'accepted') {
      return _buildAcceptedRideCard(context);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildStartedRideCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 18, top: 30),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Service/Product Details Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.user.ride!["driverInfo"]["carType"]["vehicleType"] ?? "Standard",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "10 min",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "${state.user.ride!["driverInfo"]["carType"]["vehicleType"] ?? "Vitz"} . ${state.user.ride!["driverInfo"]["carColor"] ?? "Grey"}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: Colors.grey[400],
                  size: 40,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Provider/Driver Details Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Driver Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                // Driver Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.user.ride!["riderId"]["userId"]?["name"] ?? "Driver",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "4.2",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Call Button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.call,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Button Section
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFFF9800),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: onCancel,
              borderRadius: BorderRadius.circular(8),
              child: const Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFFFF9800),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedRideCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 18, top: 30),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Ride details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.user.ride!["driverInfo"]["carType"]["vehicleType"] ?? "Standard",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          "10 min",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "${state.user.ride!["driverInfo"]["carType"]["vehicleType"] ?? "Vitz"} . ${state.user.ride!["driverInfo"]["carColor"] ?? "Grey"}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Color(0xFF757575),
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Driver info
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFD9D9D9),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.user.ride != null && state.user.ride!["riderId"] != null
                          ? "${state.user.ride!["riderId"]["userId"]?["name"]}"
                          : "Driver",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFFFF9800), size: 16),
                        SizedBox(width: 4),
                        Text(
                          "4.2",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () async {
                    if (state.user.ride != null &&
                        state.user.ride!["riderId"]["userId"]["phone"] != null) {
                      await openPhoneDialer(
                          state.user.ride?["riderId"]['userId']["phone"]);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: kPrimaryColor,
                          content: Text(
                            'የተመዘገበ ስልክ ቁጥር የለም',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
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
              onPressed: onCancel,
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
      ),
    );
  }
}
