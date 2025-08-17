import 'package:koooly_app/src/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../cubit/models/user.dart';

class UserRepository {
  final Dio dio;

  UserRepository({required this.dio});

  Future<String?> loadTokenFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token != null) {
      return token;
    }
    return null;
  }

  Future<void> saveTokenToLocal(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<User?> fetchUserData(String token) async {
    try {
      final response = await dio.get(
        "http://$kPrimaryBaseUrl/api/users/my-profile",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // print("debugcubitCustomer: ${response.statusCode} : ${response.data}");
      if (response.statusCode == 200) {
        // print("debugcubit011: ${response.data["ride"]}");
        return User.fromJson(response.data["user"],
            rideJson: response.data["ride"],
            rideCompletedJson: response.data["completedRide"]);
      } else {
        throw Exception('Failed to fetch user data\n${response.data['error']}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  // New method to check if the user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey('token');
  }

  // New method to get the user session from local storage
  Future<User?> getUserSession(String? token) async {
    if (token != null && await isLoggedIn()) {
      return await fetchUserData(token);
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Removes the user token from local storage
    await prefs.remove('user'); // Remove any additional user data
  }
}
