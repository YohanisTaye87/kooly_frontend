import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koooly_app/src/cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  void newNotification(RemoteMessage message) {
    emit(NewNotification(message));
  }

  void clearNotification() {
    emit(NotificationInitial());
  }
}
