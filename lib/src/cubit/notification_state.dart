// File: lib/cubit/Notification_state.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NewNotification extends NotificationState {
  final RemoteMessage message;

  const NewNotification(this.message);

  @override
  List<Object?> get props => [message];
}
