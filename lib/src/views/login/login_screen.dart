import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:koooly_app/src/cubit/models/user.dart';
import 'package:koooly_app/src/views/home/main_home.dart';
import 'package:koooly_app/src/views/login/forgot_password.dart';
import 'package:koooly_app/src/views/signup/signup_phone.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/shared/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koooly_app/src/cubit/user_cubit.dart';
import 'package:koooly_app/src/views/signup/verify_phone.dart';
import 'package:country_code_picker/country_code_picker.dart';

class LoginScreen extends StatefulWidget {
  final String? notificationToken;
  const LoginScreen({this.notificationToken, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with FormValidators {
  final TextEditingController _phoneTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCountryCode = '+251';
  // final CacheStorage secureStorage = CacheStorage();

  bool isLoading = false;
  bool connection = true;
  bool byEmail = true;
  String errorText = '';
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  @override
  void dispose() {
    _phoneTextController.dispose();
    _passwordController.dispose();
    _emailTextController.dispose();
    super.dispose();
  }

  Future<User?> _login() async {
    final Map<String, dynamic> toBe = {
      "phoneNumber": byEmail
          ? null
          : _selectedCountryCode + _phoneTextController.text.trim(),
      "email": byEmail ? _emailTextController.text.trim() : null,
      "password": _passwordController.text.trim(),
      "notificationToken": widget.notificationToken,
    };
    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/users/device/login",
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: jsonEncode(toBe),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final me = User.fromJson(response.data);
        // Accept any user regardless of role - no driver restrictions
        return me;
      } else if (response.statusCode.toString()[0] == '2' && mounted) {
        if (response.statusCode == 215) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  VerifyAccountScreen(
                notificationToken: widget.notificationToken,
              ),
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        } else if (response.statusCode == 213) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SignupPhoneScreen(
                notificationToken: widget.notificationToken,
              ),
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
        setState(() {
          isLoading = false;
          errorText = response.data['error'];
        });
        return null;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        setState(() {
          isLoading = false;
          errorText = "Connection timed out. Please try again.";
        });
      } else {
        setState(() {
          connection = false;
          errorText = e.message ?? '';
        });
      }
    } catch (e) {
      debugPrint("login error: $e");
      setState(() {
        isLoading = false;
        connection = false;
        errorText = e.toString();
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isSmall ? 8 : 10),
                Center(
                  child: Text(
                    'KOOOLY',
                    style: TextStyle(
                      fontSize: isSmall ? 48 : 64,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFF9900),
                      fontFamily: 'showg',
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 18 : 40),
                Text(
                  'SIGN IN',
                  style: TextStyle(
                    color: const Color(0xFFFF9900),
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 20 : 24,
                    fontFamily: 'Lora',
                  ),
                ),
                SizedBox(height: isSmall ? 18 : 28),
                Text(
                  "Welcome back!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 18 : 24,
                    color: Colors.black,
                    fontFamily: 'Lora',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Please sign in to your account to continue using the app.",
                  style: TextStyle(
                    color: const Color(0xFF757575),
                    fontSize: isSmall ? 14 : 16,
                    fontFamily: 'Lora',
                    height: 1.4,
                  ),
                ),
                SizedBox(height: isSmall ? 18 : 28),
                Visibility(
                  visible: isLoading,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF9900)),
                  ),
                ),
                Visibility(
                  visible: byEmail && !isLoading,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFEEEEEE),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFFAF8F4),
                        ),
                        child: TextField(
                          controller: _emailTextController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Color(0xFF757575)),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Color(0xFFFAF8F4),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFEEEEEE),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFFAF8F4),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: Color(0xFF757575)),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Color(0xFFFAF8F4),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: !byEmail && !isLoading,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFFEEEEEE), width: 1.2),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFFAF8F4),
                    ),
                    child: Row(
                      children: [
                        CountryCodePicker(
                          onChanged: (country) {
                            setState(() {
                              _selectedCountryCode = country.dialCode!;
                            });
                          },
                          initialSelection: 'ET',
                          favorite: const ['+251', 'ET'],
                          showCountryOnly: false,
                          alignLeft: false,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Lora',
                          ),
                          dialogTextStyle: const TextStyle(fontFamily: 'Lora'),
                          searchStyle: const TextStyle(fontFamily: 'Lora'),
                          backgroundColor: const Color(0xFFFAF8F4),
                          barrierColor: Colors.black54,
                          boxDecoration: BoxDecoration(
                            color: const Color(0xFFFAF8F4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Container(
                          height: 40,
                          width: 1.2,
                          color: const Color(0xFFEEEEEE),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: TextField(
                              controller: _phoneTextController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Enter your phone number',
                                hintStyle: TextStyle(color: Color(0xFF757575)),
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Color(0xFFFAF8F4),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 16 : 24),
                Visibility(
                  visible: !isLoading,
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          byEmail = !byEmail;
                        });
                      },
                      child: Text(
                        !byEmail ? "Sign in with email" : "Sign in with phone",
                        style: const TextStyle(
                          color: Color(0xFFFF9900),
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 32 : 18),
                Visibility(
                  visible: !isLoading,
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmall ? 18 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 12,
                          shadowColor: const Color(0x80FF9900),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 18 : 20,
                            fontFamily: 'Lora',
                          ),
                        ),
                        onPressed: () async {
                          // Basic validation
                          bool isValid = true;
                          if (byEmail) {
                            if (_emailTextController.text.trim().isEmpty ||
                                _passwordController.text.trim().isEmpty) {
                              isValid = false;
                            }
                          } else {
                            if (_phoneTextController.text.trim().isEmpty) {
                              isValid = false;
                            }
                          }

                          if (isValid) {
                            setState(() {
                              isLoading = true;
                              connection = true;
                            });
                            final loginCheck = await _login();
                            if (loginCheck != null && context.mounted) {
                              context.read<UserCubit>().setUserAfterLogin(
                                    loginCheck,
                                  );
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                  ) =>
                                      const MainHome(),
                                  transitionDuration: const Duration(
                                    milliseconds: 150,
                                  ),
                                  transitionsBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: kPrimaryColor,
                                    content: Text(errorText),
                                  ),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('Please fill in all fields'),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 16 : 15),
                Visibility(
                  visible: !isLoading,
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ForgotpasswordScreen(
                              notificationToken: widget.notificationToken,
                            ),
                            transitionDuration: const Duration(
                              milliseconds: 150,
                            ),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: Color(0xFFFF9900),
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 12 : 0),
                Visibility(
                  visible: !isLoading,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 12.0,
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: const Color(0xFF757575),
                            fontSize: isSmall ? 11 : 16,
                            fontFamily: 'Lora',
                          ),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) =>
                                          SignupPhoneScreen(
                                        notificationToken:
                                            widget.notificationToken,
                                      ),
                                      transitionDuration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      transitionsBuilder: (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                    color: const Color(0xFFFF9900),
                                    fontSize: isSmall ? 11 : 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Lora',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
