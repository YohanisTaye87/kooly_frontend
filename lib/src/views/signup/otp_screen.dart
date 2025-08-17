import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:koooly_app/src/views/home/main_home.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/repositories/user_repository.dart';
import 'package:koooly_app/src/cubit/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koooly_app/src/cubit/user_cubit.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String email;
  final String password;
  final String? notificationToken;

  const OtpScreen({
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.notificationToken,
    super.key,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _seconds = 60;
  bool _isLoading = false;
  bool _isResending = false;

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Check if all OTP fields are filled
  bool get _isOtpComplete {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  // Get the complete OTP string
  String get _otpCode {
    return _controllers.map((controller) => controller.text).join();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (_seconds > 0 && mounted) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _seconds--;
          });
        }
        return _seconds > 0 && mounted;
      }
      return false;
    });
  }

  Future<User?> _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> requestData = {
      "email": widget.email,
      "otp": _otpCode,
    };

    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/users/otp-verify",
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: jsonEncode(requestData),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        final user = User.fromJson(response.data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('OTP verified successfully!'),
          ),
        );
        return user;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
                response.data['error'] ?? 'Invalid OTP. Please try again.'),
          ),
        );
        return null;
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.response?.data['error'] ?? 'Network error occurred'),
        ),
      );
      return null;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('An unexpected error occurred'),
        ),
      );
      return null;
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
    });

    final Map<String, dynamic> requestData = {
      "email": widget.email,
      "phoneNumber": widget.phoneNumber,
      "password": widget.password,
    };

    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/users/send-otp",
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: jsonEncode(requestData),
      );

      setState(() {
        _isResending = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear existing OTP fields
        for (final controller in _controllers) {
          controller.clear();
        }

        // Reset timer
        setState(() {
          _seconds = 60;
        });
        _startTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('New OTP sent to your email successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(response.data['message'] ?? 'Failed to resend OTP'),
          ),
        );
      }
    } on DioException catch (e) {
      setState(() {
        _isResending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content:
              Text(e.response?.data['message'] ?? 'Network error occurred'),
        ),
      );
    } catch (e) {
      setState(() {
        _isResending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to resend OTP. Please try again.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Widget _buildOtpBox(int index) {
    final hasValue = _controllers[index].text.isNotEmpty;
    return SizedBox(
      width: 50,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: hasValue
              ? const Color(0xFFFFE0B2) // bolder orange when filled
              : const Color(0xFFFAF8F4), // match main background when empty
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF9900),
            fontFamily: 'Lora',
          ),
          cursorHeight: 36,
          cursorWidth: 3,
          decoration: InputDecoration(
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasValue
                    ? const Color(0xFFFF9900)
                    : const Color(0xFFEEEEEE),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF9900), width: 2),
            ),
            filled: true,
            fillColor: hasValue
                ? const Color.fromARGB(
                    255,
                    253,
                    242,
                    224,
                  ) // bolder orange when filled
                : const Color(
                    0xFFFAF8F4,
                  ), // match main background when empty
            contentPadding: const EdgeInsets.only(top: 6),
          ),
          onChanged: (value) {
            setState(() {});
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: isSmall ? 8 : 10),
            Center(
              child: Text(
                'KOOOLY',
                style: TextStyle(
                  fontSize: isSmall ? 38 : 48,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFF9900),
                  fontFamily: 'showg',
                  letterSpacing: 2,
                ),
              ),
            ),
            SizedBox(height: isSmall ? 18 : 32),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Verification',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 18 : 24,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Please enter the code we just sent to your email.',
                style: TextStyle(
                  color: const Color(0xFF757575),
                  fontSize: isSmall ? 13.5 : 15,
                  fontFamily: 'Lora',
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: isSmall ? 18 : 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _buildOtpBox(i),
                ),
              ),
            ),
            SizedBox(height: isSmall ? 24 : 32),
            Center(
              child: SizedBox(
                width: 242,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33FF9900), // 20% orange
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: Offset(0, 6),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9900),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0, // Remove default shadow
                      shadowColor: Colors.transparent,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmall ? 18 : 20,
                        fontFamily: 'Lora',
                      ),
                    ),
                    onPressed: (_isOtpComplete && !_isLoading)
                        ? () async {
                            // Validate OTP length
                            if (_otpCode.length == 6) {
                              final user = await _verifyOtp();
                              if (user != null && mounted) {
                                // Save user token
                                final userRepository = UserRepository(dio: dio);
                                if (user.token != null) {
                                  await userRepository
                                      .saveTokenToLocal(user.token!);
                                }

                                // Set user in cubit
                                context
                                    .read<UserCubit>()
                                    .setUserAfterLogin(user);

                                // For first-time signup users, always redirect to home page
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const MainHome(),
                                  ),
                                );
                              }
                            } else {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please enter the complete 6-digit verification code'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        : null, // Disable button if OTP is not complete or loading
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmall ? 12 : 18),
            _seconds > 0
                ? Text.rich(
                    TextSpan(
                      text: 'Resend code in ',
                      style: TextStyle(
                        color: const Color(0xFF757575),
                        fontSize: isSmall ? 13 : 16,
                        fontFamily: 'Lora',
                      ),
                      children: [
                        TextSpan(
                          text: '${_seconds}s',
                          style: const TextStyle(color: Color(0xFFFF9900)),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: _isResending ? null : _resendOtp,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isResending
                            ? const Color(0xFFEEEEEE)
                            : const Color(0xFFFF9900).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isResending
                              ? const Color(0xFFCCCCCC)
                              : const Color(0xFFFF9900),
                          width: 1,
                        ),
                      ),
                      child: _isResending
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF757575),
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sending...',
                                  style: TextStyle(
                                    color: const Color(0xFF757575),
                                    fontSize: isSmall ? 13 : 16,
                                    fontFamily: 'Lora',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Resend code',
                              style: TextStyle(
                                color: const Color(0xFFFF9900),
                                fontSize: isSmall ? 13 : 16,
                                fontFamily: 'Lora',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
