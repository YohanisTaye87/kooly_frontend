// import 'package:koooly_driver_app/src/cubit/models/car_types.dart';
import 'package:koooly_app/src/cubit/models/pick_up_drop.dart';

class RideRequest {
  final String? id;
  final DropOff dropOff;
  final String? dropOffAddress;
  final bool isPreorder;
  final String? pickupAddress;

  final num? distanceInKm;
  final PickUp pickUp;
  final DateTime? pickupDate;
  final String? selectedCarType;
  final Map<String, dynamic>? riderId;
  final Map<String, dynamic>? customerId;
  final String? paymentMethod;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RideRequest({
    this.id,
    required this.dropOff,
    required this.dropOffAddress,
    this.isPreorder = false,
    required this.pickupAddress,
    this.customerId,
    required this.distanceInKm,
    required this.pickUp,
    this.pickupDate,
    required this.selectedCarType,
    this.riderId,
    this.paymentMethod,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    // print("kkkk: ${json['selectedCarType']['vehicleType']}");
    return RideRequest(
        id: json['_id'],
        dropOff: DropOff.fromJson(json['dropOff']),
        dropOffAddress: json['dropOffAddress'] as String?,
        isPreorder: json['isPreorder'] ?? false,
        pickupAddress: json['pickupAddress'] as String?,
        distanceInKm: json['distanceInKm'],
        pickUp: PickUp.fromJson(json['pickUp']),
        pickupDate: json['pickupDate'] != null
            ? DateTime.parse(json['pickupDate'])
            : null,
        selectedCarType: json['selectedCarType'] as String?,
        riderId: json['riderId'] as Map<String, dynamic>?,
        paymentMethod: json['paymentMethod'] as String?,
        status: json['status'] as String?,
        customerId: json['customerId'] as Map<String, dynamic>?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null);
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'dropOff': dropOff.toJson(),
      'dropOffAddress': dropOffAddress,
      'isPreorder': isPreorder,
      'pickupAddress': pickupAddress,
      'pickUp': pickUp.toJson(),
      'pickupDate': pickupDate?.toIso8601String(),
      'selectedCarType': selectedCarType,
      'riderId': riderId,
      'paymentMethod': paymentMethod,
      'status': status,
      'customerId': customerId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
