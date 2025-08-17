// File: lib/cubit/user_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_state.dart';
import '../repositories/user_repository.dart';
import 'models/user.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository userRepository;
  Timer? _timer;

  UserCubit({required this.userRepository}) : super(UserLoading()) {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    emit(UserLoading());
    try {
      final token = await userRepository.loadTokenFromLocal();
      final user = await userRepository.fetchUserData(token!);
      if (user != null) {
        emit(UserLoaded(user));
        _startHourlyUserUpdate(user);
      } else {
        emit(const UserError('No user data found.'));
      }
    } catch (e) {
      emit(const UserError('Failed to load user from local'));
    }
  }

  Future<void> _fetchUserData(User user) async {
    // print("debugcubit00driver: ${user.toJson()}");
    try {
      final updatedUser = await userRepository.fetchUserData(user.token!);
      // print("debugcubit00driver22: $updatedUser");
      if (updatedUser != null) {
        await userRepository.saveTokenToLocal(updatedUser.token!);
        emit(UserLoaded(updatedUser));
      }
    } catch (e) {
      print("debugcubit11: $e");
      emit(const UserError('Failed to update user data.'));
    }
  }

  Future<void> logout() async {
    emit(UserLoading());
    try {
      await userRepository.logout(); // Clears user data
      _timer?.cancel(); // Stops the hourly update timer
      emit(const UserLoggedOut()); // Emits logged out state
    } catch (e) {
      emit(const UserError('Failed to logout.'));
    }
  }

  void _startHourlyUserUpdate(User user) {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchUserData(user);
    });
  }

  Future<void> setUserAfterLogin(User user) async {
    emit(UserLoading());
    try {
      // Save user data to local storage
      await userRepository.saveTokenToLocal(user.token!);
      // Emit loaded state with the new user data
      emit(UserLoaded(user));
      // Start hourly update timer for user data
      _startHourlyUserUpdate(user);
    } catch (e) {
      emit(const UserError('Failed to set user after login.'));
    }
  }

  void clearRideCompleted() {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      final updatedUser = User(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        phone: currentUser.phone,
        token: currentUser.token,
        ride: currentUser.ride,
        rideCompleted: null, // Clear the completed ride data
      );
      emit(UserLoaded(updatedUser));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
