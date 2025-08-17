import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:koooly_app/src/components/rounded_form_field.dart';
import 'package:koooly_app/src/components/rounded_button.dart';
import 'package:koooly_app/src/cubit/models/user.dart';

import 'package:koooly_app/src/views/home/main_home.dart';
import 'package:koooly_app/src/views/login/login_screen.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/shared/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koooly_app/src/cubit/user_cubit.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String? notificationToken;
  const VerifyAccountScreen({required this.notificationToken, super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen>
    with FormValidators {
  final TextEditingController _phoneTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _verificationTextController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String meme = '';
  // final CacheStorage secureStorage = CacheStorage();
  bool isLoading = false;
  bool otpSent = false;
  bool connection = true;
  bool byEmail = true;
  String errorText = '';
  User? successUser;

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  @override
  void dispose() {
    _phoneTextController.dispose();
    _verificationTextController.dispose();
    _emailTextController.dispose();
    super.dispose();
  }

  Future<int?> verifyOtp() async {
    final Map<String, dynamic> toBe = {
      "phoneNumber": byEmail ? null : _phoneTextController.text,
      "email": byEmail ? _emailTextController.text : null,
      "otp": _verificationTextController.text.trim(),
      "password": _passwordTextController.text.trim()
    };
    debugPrint("toooobeVerify: ${jsonEncode(toBe)}");
    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/users/otp-verify",
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          headers: {
            "Content-Type": "application/json",
            // "authorization": "Bearer ${widget.user.token}",
          },
        ),
        data: jsonEncode(toBe),
      );
      debugPrint("signup status: ${response.statusCode}");
      if (response.statusCode == 201) {
        final me = User.fromJson(response.data);
        setState(() {
          successUser = me;
        });
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

  Future<int?> sendOtp() async {
    setState(() {
      isLoading = true;
    });
    final Map<String, dynamic> toBe = {
      "phoneNumber": byEmail ? "" : _phoneTextController.text,
      "email": byEmail ? _emailTextController.text : "",
    };
    debugPrint("toooobeVerify: ${jsonEncode(toBe)}");
    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/users/otp-generate",
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          headers: {
            "Content-Type": "application/json",
            // "authorization": "Bearer ${widget.user.token}",
          },
        ),
        data: jsonEncode(toBe),
      );
      debugPrint("sendotp status: ${response.statusCode}: ${response.data}");
      if (response.statusCode == 201) {
        setState(() {
          otpSent = true;
          isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: size.width,
                      height: size.height / 3,
                      color: kPrimaryColor,
                      child: Padding(
                        padding: EdgeInsets.only(top: size.height / 22),
                        child: Center(
                          child: Image.asset(
                            "assets/images/logo.png",
                            color: Colors.white,
                            fit: BoxFit.contain,
                            height: size.width / 2,
                            width: size.width / 2,
                          ),
                        ),
                      ),
                      // decoration: const BoxDecoration(
                      //   color: kPrimaryColor,
                      //   image: DecorationImage(
                      //     image: AssetImage('assets/images/logo.png'),
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                    ),
                    SizedBox(
                      height: size.height / 13,
                    ),
                    Center(
                      child: Text(
                        "አካውንትዎን ያረጋግጡ",
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 20.5 * size.height * 0.002,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Center(
                      child: Text(
                        otpSent
                            ? "የተላከሎትን ኮድ ያስገቡ"
                            : "${byEmail ? "ኢሜይልዎን" : "ስልክዎን"} በማስገባት አካውንዎን ያረጋግጡ",
                        style: TextStyle(
                          color: const Color(0xFF585656),
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5 * size.height * 0.002,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !otpSent && !byEmail,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 12),
                        child: RoundedFormField(
                            mainText: "ስልክ",
                            validator: validatePhoneNumber,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            controller: _phoneTextController,
                            assetIcon: SvgPicture.asset(
                              "assets/icons/phone.svg",
                              colorFilter: const ColorFilter.mode(
                                  kPrimaryColor, BlendMode.srcIn),
                            )),
                      ),
                    ),
                    Visibility(
                      visible: !otpSent && byEmail,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 12.0),
                        child: RoundedFormField(
                            mainText: "ኢ-ሜይል",
                            validator: validateEmail,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailTextController,
                            assetIcon: SvgPicture.asset(
                              "assets/icons/email.svg",
                              colorFilter: const ColorFilter.mode(
                                  kPrimaryColor, BlendMode.srcIn),
                            )),
                      ),
                    ),
                    Visibility(
                      visible: !otpSent,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 12.0),
                        child: RoundedFormField(
                            mainText: "ይለፍ ቃል",
                            validator: validatePassword,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.emailAddress,
                            controller: _passwordTextController,
                            assetIcon: SvgPicture.asset(
                              "assets/icons/password.svg",
                              colorFilter: const ColorFilter.mode(
                                  kPrimaryColor, BlendMode.srcIn),
                            )),
                      ),
                    ),
                    Visibility(
                      visible: otpSent,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                        child: RoundedFormField(
                            mainText: "ኮድ",
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.emailAddress,
                            controller: _verificationTextController,
                            assetIcon: SvgPicture.asset(
                              "assets/icons/phone.svg",
                              colorFilter: const ColorFilter.mode(
                                  kPrimaryColor, BlendMode.srcIn),
                            )),
                      ),
                    ),
                    SizedBox(height: size.height / 50),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            byEmail = !byEmail;
                          });
                        },
                        child: Text(
                          !byEmail ? "ወይም በኢሜይል ይግቡ" : "ወይም በስልክዎ ይግቡ",
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(size.width / 15,
                          size.height / 200, size.width / 15, size.height / 55),
                      child: RoundedButton(
                          width: size.width / 1.2,
                          text: "ይቀጥሉ",
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5 * size.height * 0.002),
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              if (!otpSent) {
                                await sendOtp();
                              } else {
                                final verifyResp = await verifyOtp();
                                if (verifyResp == 201 &&
                                    context.mounted &&
                                    successUser != null) {
                                  context
                                      .read<UserCubit>()
                                      .setUserAfterLogin(successUser!);
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const MainHome(),
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
                          }),
                    ),
                    Center(
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
                        child: const Text(
                          "አካውንት አሎት? እዚህ ይግቡ",
                          style: TextStyle(
                            color: Color(0xFF585656),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
