// import 'package:koooly_app/src/views/home/home_screen.dart';
// import 'package:koooly_app/src/views/login/login_screen.dart';
// import 'package:koooly_app/src/views/onboarding/onboarding.dart';
// import 'package:flutter/material.dart';


// class Wrapper extends StatefulWidget {
//   final bool isFirstTime;
//   final Map<String, dynamic>? json;

//   const Wrapper({required this.isFirstTime, required this.json, super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _WrapperState createState() => _WrapperState();
// }

// class _WrapperState extends State<Wrapper> {
//   User? _currentUser;

//   @override
//   void initState() {
//     super.initState();

//     FirebaseAuth.instance.authStateChanges().listen((User? user) {
//       setState(() {
//         _currentUser = user;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_currentUser != null && widget.json != null) {
//       return HomeScreen(
//         baseUser: _currentUser,
//       );
//     } else if (widget.json != null && !widget.isFirstTime) {
//       return const LoginScreen();
//     } else {
//       return const OnboardingScreen();
//     }
//   }
// }
