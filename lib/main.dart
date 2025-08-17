import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koooly_app/firebase_options.dart';
import 'package:koooly_app/src/cubit/models/user.dart';
import 'package:koooly_app/src/shared/cache_storage.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/views/onboarding/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:koooly_app/src/cubit/user_cubit.dart';
import 'package:koooly_app/src/repositories/user_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:koooly_app/src/cubit/notification_cubit.dart';

final _messageStreamController = BehaviorSubject<RemoteMessage>();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  PermissionStatus status = await Permission.location.request();
  await Permission.phone.request();
  // await Permission.notification.request();
  if (status.isDenied) {
    await Permission.location.request();
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  String? token = await messaging.getToken().catchError((e) {
    return "firebase token error: $e";
  });

  print("got firebase token: $token");
  final notificationCubit = NotificationCubit();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Handling a foreground message: ${message.messageId}');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
      print('Message notification: ${message.notification?.body}');
    }
    notificationCubit.newNotification(message);
    _messageStreamController.sink.add(message);
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  final userRepository = UserRepository(dio: dio);

  final cacheStorage = CacheStorage();
  bool isFirstTime = await cacheStorage.isFirstTime();

  // Use the UserRepository to get user session
  final userToken = await userRepository.loadTokenFromLocal();
  final userSession = await userRepository.getUserSession(userToken);

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => UserCubit(userRepository: userRepository),
      ),
    ],
    child: MyApp(
      isFirstTime: isFirstTime,
      userSession: userSession,
      notificationToken: token, // Pass the user session if needed
    ),
  ));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  final User? userSession; // Added userToken parameter
  final String? notificationToken;
  const MyApp({
    required this.isFirstTime,
    this.userSession,
    required this.notificationToken,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koooly App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: kPrimaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 23),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: SplashScreen(
        isFirstTime: isFirstTime,
        userSession: userSession,
        notificationToken:
            notificationToken, // Pass it to SplashScreen if needed
      ),
    );
  }
}
