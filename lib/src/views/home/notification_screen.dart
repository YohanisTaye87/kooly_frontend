import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:koooly_app/src/cubit/models/notification.dart';
import 'package:koooly_app/src/shared/constants.dart';

class NotificationsScreen extends StatefulWidget {
  final String token;
  const NotificationsScreen({required this.token, super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> notifications = [];
  bool connection = true;

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  Future<int?> getNotifications() async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    try {
      final response = await dio.get(
        "http://$kPrimaryBaseUrl/api/notifications/user",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer ${widget.token}",
          },
        ),
      );

      if (response.statusCode == 200) {
        List<NotificationModel> nots = [];
        for (var element in response.data) {
          nots.add(NotificationModel.fromJson(element));
          print("notifiget - $element");
        }
        nots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          notifications = nots;
        });
        return 200;
      }
    } on DioException catch (e) {
      if (mounted) debugPrint("notification get error: $e");
      setState(() {
        connection = false;
      });
      return 0;
    } catch (e) {
      debugPrint("notification get error: $e");
      setState(() {
        connection = false;
      });
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notification_important),
            title: Text(notifications[index].title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notifications[index].body),
                Builder(
                  builder: (context) {
                    return Text(
                      notifications[index]
                          .createdAt
                          .toString()
                          .substring(0, 16),
                      style: const TextStyle(color: Colors.grey),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
