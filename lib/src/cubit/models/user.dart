import 'package:koooly_app/src/cubit/models/driver_info.dart';
import 'package:koooly_app/src/cubit/models/ride_request.dart';
import 'package:koooly_app/src/cubit/models/role.dart';

class User {
  final String? id;
  final String? email;
  final String? name;
  final String? otp;
  final DateTime? otpExpires;
  final String? password;
  final String? phone;
  final String? token;
  final Role? role; // MongoDB ObjectId for Role
  final String? notificationToken;
  final bool isOnline;
  final bool isDisabled;
  final DateTime lastActivity;
  final bool isVerified;
  final bool emailVerified;
  final RideRequest? rideRequest;
  final DateTime? emailVerifiedAt;
  final bool phoneVerified;
  final DateTime? phoneVerifiedAt;
  final String? resetPasswordOtp;
  final DateTime? resetPasswordExpires;
  final DriverInfo? driverInfo;
  final Map<String, dynamic>? driverStats;
  final Map<String, dynamic>? ride;
  final Map<String, dynamic>? rideCompleted;

  User({
    this.email,
    this.id,
    required this.name,
    required this.token,
    this.otp,
    this.otpExpires,
    this.password,
    this.phone,
    this.rideCompleted,
    this.driverStats,
    this.notificationToken,
    this.rideRequest,
    this.ride,
    this.driverInfo,
    this.role,
    this.isOnline = false,
    this.isDisabled = false,
    DateTime? lastActivity,
    this.isVerified = false,
    this.emailVerified = false,
    this.emailVerifiedAt,
    this.phoneVerified = false,
    this.phoneVerifiedAt,
    this.resetPasswordOtp,
    this.resetPasswordExpires,
  }) : lastActivity = lastActivity ?? DateTime.now();

  // Factory constructor for creating a User instance from a JSON object
  factory User.fromJson(Map<String, dynamic> json,
      {Map<String, dynamic>? rideJson,
      Map<String, dynamic>? rideCompletedJson}) {
    return User(
        id: json['_id'] as String?,
        email: json['email'] as String?,
        token: json['token'] as String?,
        name: json['name'] as String?,
        otp: json['otp'] as String?,
        rideRequest: rideJson != null ? RideRequest.fromJson(rideJson) : null,
        otpExpires: json['otpExpires'] != null
            ? DateTime.parse(json['otpExpires'])
            : null,
        driverStats: json['driverStats'] as Map<String, dynamic>?,
        password: json['password'] as String?,
        driverInfo: json['driverInfo'] != null
            ? DriverInfo.fromJson(json['driverInfo'])
            : null,
        phone: json['phone'] as String?,
        role: Role.fromJson(json['role']),
        isOnline: json['isOnline'] as bool? ?? false,
        isDisabled: json['isDisabled'] as bool? ?? false,
        lastActivity: json['lastActivity'] != null
            ? DateTime.parse(json['lastActivity'])
            : DateTime.now(),
        isVerified: json['isVerified'] as bool? ?? false,
        emailVerified: json['emailVerified'] as bool? ?? false,
        emailVerifiedAt: json['emailVerifiedAt'] != null
            ? DateTime.parse(json['emailVerifiedAt'])
            : null,
        phoneVerified: json['phoneVerified'] as bool? ?? false,
        phoneVerifiedAt: json['phoneVerifiedAt'] != null
            ? DateTime.parse(json['phoneVerifiedAt'])
            : null,
        resetPasswordOtp: json['resetPasswordOtp'] as String?,
        resetPasswordExpires: json['resetPasswordExpires'] != null
            ? DateTime.parse(json['resetPasswordExpires'])
            : null,
        ride: rideJson,
        rideCompleted: rideCompletedJson);
  }

  // Method to convert User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'otp': otp,
      'otpExpires': otpExpires?.toIso8601String(),
      'password': password,
      'phone': phone,
      'role': role?.toJson(),
      'token': token,
      'isOnline': isOnline,
      'isDisabled': isDisabled,
      'lastActivity': lastActivity.toIso8601String(),
      'isVerified': isVerified,
      'emailVerified': emailVerified,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'phoneVerified': phoneVerified,
      'phoneVerifiedAt': phoneVerifiedAt?.toIso8601String(),
      'resetPasswordOtp': resetPasswordOtp,
      'resetPasswordExpires': resetPasswordExpires?.toIso8601String(),
      'notificationToken': notificationToken,
      'driverInfo': driverInfo?.toJson(),
      'driverStats': driverStats,
      'ride': ride,
      'rideRequest': rideRequest?.toJson(),
      'rideCompleted': rideCompleted
    };
  }
}
