import 'package:koooly_app/src/cubit/models/car_types.dart';

class DriverInfo {
  final String? carColor;
  final String? carModel;
  final String? carPlate;
  final CarType? carType;
  final num? creditAmount;
  final num? rating;
  final num? totalEarnings;
  final String? status;
  final DateTime? lastActivity;

  DriverInfo({
    required this.carColor,
    required this.carModel,
    required this.carPlate,
    required this.carType,
    required this.creditAmount,
    required this.rating,
    required this.totalEarnings,
    required this.status,
    required this.lastActivity,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      carColor: json['carColor'],
      carModel: json['carModel'],
      carPlate: json['carPlate'],
      carType:
          json['carType'] != null ? CarType.fromJson(json['carType']) : null,
      creditAmount: json['creditAmount'],
      rating: json['rating'],
      totalEarnings: json['totalEarnings'],
      status: json['status'],
      lastActivity: DateTime.parse(json['lastActivity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carColor': carColor,
      'carModel': carModel,
      'carPlate': carPlate,
      'carType': carType?.toJson(),
      'creditAmount': creditAmount,
      'rating': rating,
      'totalEarnings': totalEarnings,
      'status': status,
      'lastActivity': lastActivity?.toIso8601String(),
    };
  }
}
