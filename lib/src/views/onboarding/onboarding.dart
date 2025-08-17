// // ignore_for_file: library_private_types_in_public_api

// import 'package:koooly_app/src/components/rounded_button.dart';
// import 'package:koooly_app/src/components/rounded_light_button.dart';
// import 'package:koooly_app/src/views/login/login_screen.dart';
// import 'package:koooly_app/src/views/signup/signup_phone.dart';
// import 'package:flutter/material.dart';

// class OnboardingScreen extends StatefulWidget {
//   final String? notificationToken;
//   const OnboardingScreen({required this.notificationToken, super.key});

//   @override
//   _OnboardingScreenState createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   int _currentPage = 0;
//   final _pageController = PageController();

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.sizeOf(context);
//     return Scaffold(
//       body: Stack(
//         children: <Widget>[
//           PageView(
//             controller: _pageController,
//             onPageChanged: (int page) {
//               setState(() {
//                 _currentPage = page;
//               });
//             },
//             children: <Widget>[
//               _buildPage(
//                   'assets/images/onboarding_2.jpg',
//                   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
//                   _currentPage),
//               _buildPage(
//                   'assets/images/onboarding_1.jpeg',
//                   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
//                   _currentPage),
//               _buildPage(
//                   'assets/images/onboarding_3.jpeg',
//                   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
//                   _currentPage),
//             ],
//           ),
//           Positioned(
//             bottom: size.height / 2.2,
//             left: size.width / 3,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 Row(
//                   children: List<Widget>.generate(3, _buildDot),
//                 ),
//                 Padding(padding: EdgeInsets.only(left: size.width / 5)),
//                 _currentPage != 2
//                     ? IconButton(
//                         icon: const Icon(
//                           Icons.arrow_forward,
//                           size: 60,
//                         ),
//                         color: Colors.white,
//                         onPressed: () {
//                           _pageController.nextPage(
//                             duration: const Duration(milliseconds: 500),
//                             curve: Curves.ease,
//                           );
//                         },
//                       )
//                     : SizedBox(
//                         height: size.height / 12.5,
//                       ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPage(String imagePath, String text, int index) {
//     final size = MediaQuery.sizeOf(context);
//     return ClipRRect(
//         borderRadius: BorderRadius.circular(12.0),
//         child: index >= 2
//             ? Stack(
//                 children: <Widget>[
//                   Container(
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage(imagePath),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: <Color>[
//                           Colors.black.withAlpha(100),
//                           Colors.black26,
//                           Colors.black54
//                         ],
//                       ),
//                     ),
//                   ),
//                   Center(
//                     child: Padding(
//                       padding: EdgeInsets.fromLTRB(size.width / 10,
//                           size.width / 1.6, size.width / 10, size.width / 8),
//                       child: Text(
//                         text,
//                         style: TextStyle(
//                           fontSize: 24 * size.width * 0.002,
//                           color: const Color(0xFFFFFFFF),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: size.height / 1.4,
//                     left: size.width / 10,
//                     child: RoundedButton(
//                       width: size.width / 1.25,
//                       text: 'Sign Up',
//                       onTap: () {
//                         Navigator.pushReplacement(
//                           context,
//                           PageRouteBuilder(
//                             pageBuilder:
//                                 (context, animation, secondaryAnimation) =>
//                                     SignupPhoneScreen(
//                               notificationToken: widget.notificationToken,
//                             ),
//                             transitionDuration:
//                                 const Duration(milliseconds: 150),
//                             transitionsBuilder: (context, animation,
//                                 secondaryAnimation, child) {
//                               return FadeTransition(
//                                 opacity: animation,
//                                 child: child,
//                               );
//                             },
//                           ),
//                         );
//                       },
//                       textStyle: TextStyle(
//                           color: Colors.white,
//                           fontSize: 13.5 * size.height * 0.002),
//                     ),
//                   ),
//                   Positioned(
//                     top: size.height / 1.25,
//                     left: size.width / 10,
//                     child: RoundedLightButton(
//                       width: size.width / 1.25,
//                       text: 'Login',
//                       onTap: () {
//                         Navigator.pushReplacement(
//                           context,
//                           PageRouteBuilder(
//                             pageBuilder:
//                                 (context, animation, secondaryAnimation) =>
//                                     LoginScreen(
//                               notificationToken: widget.notificationToken,
//                             ),
//                             transitionDuration:
//                                 const Duration(milliseconds: 150),
//                             transitionsBuilder: (context, animation,
//                                 secondaryAnimation, child) {
//                               return FadeTransition(
//                                 opacity: animation,
//                                 child: child,
//                               );
//                             },
//                           ),
//                         );
//                       },
//                       textStyle: TextStyle(
//                           color: Colors.white,
//                           fontSize: 13.5 * size.height * 0.002),
//                     ),
//                   ),
//                 ],
//               )
//             : Stack(
//                 children: <Widget>[
//                   Container(
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage(imagePath),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: <Color>[
//                           Colors.black.withAlpha(100),
//                           Colors.black26,
//                           Colors.black54
//                         ],
//                       ),
//                     ),
//                   ),
//                   Center(
//                     child: Padding(
//                       padding: EdgeInsets.fromLTRB(size.width / 10,
//                           size.width / 1.2, size.width / 10, size.width / 8),
//                       child: Text(
//                         text,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           color: Color(0xFFFFFFFF),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ));
//   }

//   Widget _buildDot(int index) {
//     final size = MediaQuery.sizeOf(context);
//     return Container(
//       margin: EdgeInsets.only(right: size.width / 15),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: _currentPage == index ? Colors.white : Colors.white60,
//       ),
//       width: size.height / 65,
//       height: size.height / 65,
//     );
//   }
// }
