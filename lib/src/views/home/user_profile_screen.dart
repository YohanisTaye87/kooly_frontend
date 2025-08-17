import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koooly_app/src/cubit/user_cubit.dart';
import 'package:koooly_app/src/cubit/user_state.dart';
import 'package:koooly_app/src/shared/cache_storage.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/views/home/notification_screen.dart';
import 'package:koooly_app/src/views/signup/signup_phone.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? email;
  String? name;
  String? token;
  String? phone;
  bool isLoading = false;
  String? errorText;
  final _oldPassTextController = TextEditingController();
  final _newPassTextController = TextEditingController();
  bool devInfo = false;

  Future<int> updatePassword() async {
    setState(() {
      isLoading = true;
    });
    final dio = Dio(BaseOptions(
        sendTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30)));
    final toBe = {
      "currentPassword": _oldPassTextController.text,
      "newPassword": _newPassTextController.text
    };
    try {
      final response = await dio.post(
          "http://$kPrimaryBaseUrl/api/users/my-password/v1/update",
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "authorization": "Bearer $token"
              // "authorization": "Bearer ${widget.user.token}"
            },
          ),
          data: jsonEncode(toBe));
      if (response.statusCode == 201) {
        setState(() {
          isLoading = false;
        });
        return 201;
      } else {
        print("passerror: ${response.data['error']}");
        setState(() {
          isLoading = false;
          errorText = response.data['error'].toString();
        });
        return 0;
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;

          errorText = e.message.toString();
        });
      }
      return 0;
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;

          errorText = e.toString();
        });
      }
    }
    return 0;
  }

  Future<void> openPhoneDialer() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '0989794002');

    if (await canLaunchUrl(phoneUri)) {
      print('This would open: $phoneUri');
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  void _logout(BuildContext context) {
    // Handle logout functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text(
            "Are you sure you want to log out? You will be redirected to the signup page."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Perform logout action - clear user data and redirect to signup
              context.read<UserCubit>().logout();
              final logoutresult = await CacheStorage().endSession();

              if (context.mounted && logoutresult) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SignupPhoneScreen(notificationToken: null),
                    transitionDuration: const Duration(milliseconds: 150),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              }
            },
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  void _changePassword(BuildContext context) {
    // Handle password change functionality
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Password"),
          content: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _oldPassTextController,
                      decoration: const InputDecoration(
                        labelText: "Current Password",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _newPassTextController,
                      decoration: const InputDecoration(
                        labelText: "New Password",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final passtat = await updatePassword();
                print("passss: $passtat");
                if (passtat != 201 && context.mounted) {
                  _oldPassTextController.clear();
                  _newPassTextController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                            "Password change not successful. Please try again!\n$errorText")),
                  );
                } else {
                  if (context.mounted) {
                    _oldPassTextController.clear();
                    _newPassTextController.clear();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Password changed successfully")),
                    );
                  }
                }
              },
              child: const Text("Change"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    final userCubit = context.read<UserCubit>();
    final currentState = userCubit.state;
    if (currentState is UserLoaded) {
      setState(() {
        name = currentState.user.name;
        email = currentState.user.email;
        token = currentState.user.token;
        phone = currentState.user.phone;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.black, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 40),
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Developer Info"),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "DaguTech",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  final Uri emailUri = Uri(
                                    scheme: 'mailto',
                                    path: 'info@dagutech.com',
                                    query: 'subject=App Inquiry',
                                  );
                                  if (await canLaunchUrl(emailUri)) {
                                    await launchUrl(emailUri);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Could not launch email app",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Row(
                                  children: [
                                    Icon(Icons.email),
                                    SizedBox(width: 8),
                                    Text("info@dagutech.com"),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  await openPhoneDialer();
                                },
                                child: const Row(
                                  children: [
                                    Icon(Icons.phone),
                                    SizedBox(width: 8),
                                    Text("0989794002"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.info),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              color: Colors.grey.shade200,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade300,
                    child:
                        const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email ?? '',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phone != null && !phone!.contains('null') ? phone! : '',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notifications
                  Row(
                    children: [
                      Icon(Icons.notifications,
                          color: Colors.grey[700], size: 20),
                      const SizedBox(width: 10),
                      const Text('Notifications',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      NotificationsScreen(token: token ?? ''),
                              transitionDuration:
                                  const Duration(milliseconds: 150),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Icon(Icons.chevron_right,
                            color: Colors.grey[600], size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Security & Privacy
                  Row(
                    children: [
                      Icon(Icons.lock, color: Colors.grey[700], size: 20),
                      const SizedBox(width: 10),
                      const Text('Security & Privacy',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _changePassword(context),
                        child: Icon(Icons.chevron_right,
                            color: Colors.grey[600], size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Privacy Settings
                  _buildListItem('Privacy Settings', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Privacy settings coming soon")),
                    );
                  }),
                  const SizedBox(height: 18),
                  // Delete account
                  Row(
                    children: [
                      Icon(Icons.person_remove,
                          color: Colors.grey[700], size: 20),
                      const SizedBox(width: 10),
                      const Text('Delete account',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Logout
                  Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      const Text('Log Out',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _logout(context),
                        child: Icon(Icons.chevron_right,
                            color: Colors.grey[600], size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String title, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const SizedBox(width: 30),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(title, style: const TextStyle(fontSize: 15)),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Icon(Icons.chevron_right, color: Colors.grey[600], size: 22),
          ),
        ],
      ),
    );
  }
}
