import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:koooly_app/src/views/login/login_screen.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/shared/validators.dart';
import 'package:flutter/material.dart';

class ForgotpasswordScreen extends StatefulWidget {
  final String? notificationToken;
  const ForgotpasswordScreen({required this.notificationToken, super.key});

  @override
  State<ForgotpasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen>
    with FormValidators {
  final TextEditingController _phoneTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool otpSent = false;
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
    otpController.dispose();
    _passwordTextController.dispose();
    _repeatPasswordController.dispose();
    _emailTextController.dispose();
    super.dispose();
  }

  Future<int?> _resetPassword(Size size) async {
    final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 40)));

    try {
      final Map<String, dynamic> toBe = {
        "newPassword": _passwordTextController.text,
      };

      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/password/reset-password/${otpController.text}",
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: jsonEncode(toBe),
      );
      print("reset password status code: ${response.statusCode}");

      return response.statusCode;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text(
              'Connection problem. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
      debugPrint("login error: ${e.toString()}");
    }
    return null;
  }

  Future<int?> _forgotPassword() async {
    final Map<String, dynamic> toBe = {
      "email": byEmail ? _emailTextController.text : null,
    };
    debugPrint("toooobe: ${jsonEncode(toBe)}");
    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/password/forgot-password",
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: jsonEncode(toBe),
      );
      debugPrint("signup status: ${response.statusCode} --- ${response.data}");
      if (response.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text('Password reset info has been sent to your email'),
          ),
        );

        return 201;
      } else {
        setState(() {
          isLoading = false;
          errorText = response.data['error'];
        });
        return null;
      }
    } on DioException catch (e) {
      setState(() {
        connection = false;
        errorText = e.message ?? '';
        isLoading = false;
      });
    } catch (e) {
      debugPrint("signup error: $e");
      setState(() {
        isLoading = false;
        connection = false;
        errorText = e.toString();
      });
    }
    return null;
  }

  String? validatePasswordMatch(String? toValidate) {
    if (_repeatPasswordController.text != _passwordTextController.text) {
      return 'Password mismatch!';
    } else if (toValidate!.isEmpty) {
      return 'Password is required';
    } else if (toValidate.length < 6) {
      return 'Password must be at least 6 characters';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFF9900)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isSmall ? 8 : 20),
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
                'FORGOT PASSWORD',
                style: TextStyle(
                  color: const Color(0xFFFF9900),
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 20 : 24,
                  fontFamily: 'Lora',
                ),
              ),
              SizedBox(height: isSmall ? 18 : 28),
              Text(
                otpSent
                    ? "Reset your password"
                    : "Don't worry, we'll help you!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 18 : 24,
                  color: Colors.black,
                  fontFamily: 'Lora',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                otpSent
                    ? "Enter the OTP code sent to your email and create a new password."
                    : "Enter your email address to reset your password.",
                style: TextStyle(
                  color: const Color(0xFF757575),
                  fontSize: isSmall ? 14 : 16,
                  fontFamily: 'Lora',
                  height: 1.4,
                ),
              ),
              SizedBox(height: isSmall ? 18 : 28),

              // Loading indicator
              Visibility(
                visible: isLoading,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF9900)),
                ),
              ),

              // Email Field (when OTP not sent)
              Visibility(
                visible: !otpSent && !isLoading,
                child: Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFFEEEEEE), width: 1.2),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFFAF8F4),
                  ),
                  child: TextFormField(
                    controller: _emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: validateEmail,
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
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              // OTP and Password Fields (when OTP is sent)
              Visibility(
                visible: otpSent && !isLoading,
                child: Column(
                  children: [
                    // OTP Field
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFEEEEEE),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFFAF8F4),
                      ),
                      child: TextFormField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the OTP code';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter OTP code',
                          hintStyle: TextStyle(color: Color(0xFF757575)),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color(0xFFFAF8F4),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // New Password Field
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFEEEEEE),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFFAF8F4),
                      ),
                      child: TextFormField(
                        controller: _passwordTextController,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'New password',
                          hintStyle: TextStyle(color: Color(0xFF757575)),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color(0xFFFAF8F4),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password Field
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFEEEEEE),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFFAF8F4),
                      ),
                      child: TextFormField(
                        controller: _repeatPasswordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: validatePasswordMatch,
                        decoration: const InputDecoration(
                          hintText: 'Confirm password',
                          hintStyle: TextStyle(color: Color(0xFF757575)),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color(0xFFFAF8F4),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmall ? 32 : 40),

              // Continue/Reset Button
              Visibility(
                visible: !isLoading,
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9900),
                        padding: EdgeInsets.symmetric(
                          vertical: isSmall ? 18 : 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 12,
                        shadowColor: const Color(0x80FF9900),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (!otpSent) {
                            setState(() {
                              isLoading = true;
                              connection = true;
                            });
                            _formKey.currentState!.save();
                            final loginCheck = await _forgotPassword();
                            if (loginCheck != null &&
                                loginCheck == 201 &&
                                context.mounted) {
                              setState(() {
                                otpSent = true;
                                isLoading = false;
                              });
                            } else {
                              debugPrint("Signup error $errorText");
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
                            final verifyResp = await _resetPassword(size);
                            if (verifyResp == 201 && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text(
                                      'You have succesfully reset your password, Please login again'),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      LoginScreen(
                                    notificationToken: widget.notificationToken,
                                  ),
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
                          }
                        }
                      },
                      child: Text(
                        otpSent ? "Reset Password" : "Continue",
                        style: TextStyle(
                          fontFamily: 'Lora',
                          color: Colors.white,
                          fontSize: isSmall ? 18 : 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Back to Login Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  LoginScreen(
                            notificationToken: widget.notificationToken,
                          ),
                          transitionDuration: const Duration(milliseconds: 150),
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
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          color: const Color(0xFF757575),
                          fontSize: isSmall ? 14 : 16,
                          fontFamily: 'Lora',
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              color: const Color(0xFFFF9900),
                              fontSize: isSmall ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Lora',
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
