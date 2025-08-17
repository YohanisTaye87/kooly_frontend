import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/shared/validators.dart';
import 'package:flutter/material.dart';
import 'package:koooly_app/src/views/signup/profile_setup_screen.dart';
import 'package:koooly_app/src/views/login/login_screen.dart';

class SignupPhoneScreen extends StatefulWidget {
  final String? notificationToken;
  const SignupPhoneScreen({required this.notificationToken, super.key});

  @override
  State<SignupPhoneScreen> createState() => _SignupPhoneScreenState();
}

class _SignupPhoneScreenState extends State<SignupPhoneScreen>
    with FormValidators {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedCountryCode = '+251';
  bool _phoneFocused = false;
  bool _emailFocused = false;
  bool _nameFocused = false;
  bool _passwordFocused = false;
  final bool _isLoading = false;
  final bool _otpSent = false;
  final String _errorText = '';

  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {
        _phoneFocused = _phoneFocusNode.hasFocus;
      });
    });
    _emailFocusNode.addListener(() {
      setState(() {
        _emailFocused = _emailFocusNode.hasFocus;
      });
    });
    _nameFocusNode.addListener(() {
      setState(() {
        _nameFocused = _nameFocusNode.hasFocus;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _passwordFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  // Check if email exists in the system
  Future<bool> _checkEmailExists(String email) async {
    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/users/check-email",
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
        data: jsonEncode({"email": email}),
      );
      if (response.statusCode == 200) {
        return response.data['exists'] ?? false;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("Email check error: ${e.message}");
      // Fallback to login attempt
      return await _checkEmailViaLogin(email);
    } catch (e) {
      debugPrint("Email check error: $e");
      return await _checkEmailViaLogin(email);
    }
  }

  // Alternative method to check email via login attempt
  Future<bool> _checkEmailViaLogin(String email) async {
    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/users/device/login",
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
        data: jsonEncode({
          "email": email,
          "password": "dummy_password_for_check",
          "notificationToken": widget.notificationToken
        }),
      );
      print("Email check status: ${response.statusCode} --- ${response.data}");
      // Handle specific status codes like in login screen
      if (response.statusCode == 215) {
        // User exists but needs verification
        return true;
      } else if (response.statusCode == 213) {
        // User not found
        return false;
      } else if (response.statusCode.toString()[0] == '2') {
        // Other 2xx responses - check error message
        if (response.data != null &&
            response.data['error']
                    ?.toString()
                    .toLowerCase()
                    .contains('password') ==
                true) {
          return true;
        }
        return false;
      }
      // If we get a specific error about wrong password, email exists
      if (response.statusCode == 401 ||
          (response.data != null &&
              response.data['error']
                      ?.toString()
                      .toLowerCase()
                      .contains('password') ==
                  true)) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      // Check if it's a password-related error (email exists)
      if (e.response?.statusCode == 401) {
        return true;
      } else if (e.response?.statusCode == 215) {
        return true; // User exists but needs verification
      } else if (e.response?.statusCode == 213) {
        return false; // User not found
      }
      debugPrint("Login check error: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("Login check error: $e");
      return false;
    }
  }

  // Send OTP to existing user's email
  Future<bool> _sendOTPToEmail(String email) async {
    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/users/send-login-otp",
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
        data: jsonEncode({"email": email}),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(e.response?.data['error'] ?? 'Failed to send OTP'),
          ),
        );
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to send OTP. Please try again.'),
          ),
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _nameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F4),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isSmall ? 20 : 40),

              // KOOOLY Branding

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

              SizedBox(height: isSmall ? 40 : 60),

              // SIGN UP

              Center(
                child: Text(
                  'SIGN UP',
                  style: TextStyle(
                    fontSize: isSmall ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF9900),
                    fontFamily: 'Lora',
                  ),
                ),
              ),

              SizedBox(height: isSmall ? 8 : 12),

              // Welcome message

              Center(
                child: Text(
                  'Welcome! Let\'s get you started',
                  style: TextStyle(
                    fontSize: isSmall ? 16 : 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontFamily: 'Lora',
                  ),
                ),
              ),

              SizedBox(height: isSmall ? 8 : 12),

              // Instructions

              Center(
                child: Text(
                  'Please enter your phone number and email to create your account. We\'ll send you a verification code to your email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmall ? 14 : 16,
                    color: const Color(0xFF757575),
                    fontFamily: 'Lora',
                    height: 1.4,
                  ),
                ),
              ),

              SizedBox(height: isSmall ? 30 : 40),

              // Phone Number Input

              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _phoneFocused
                        ? const Color(0xFFFF9900)
                        : const Color(0xFFEEEEEE),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFFAF8F4),
                ),
                child: Row(
                  children: [
                    // Country Code Picker

                    CountryCodePicker(
                      onChanged: (country) {
                        setState(() {
                          _selectedCountryCode = country.dialCode!;
                        });
                      },
                      initialSelection: 'ET',
                      favorite: const ['+251', 'ET'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
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
                      boxDecoration: const BoxDecoration(
                        color: Color(0xFFFAF8F4),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),

                    // Divider

                    Container(
                      height: 40,
                      width: 1.2,
                      color: _phoneFocused
                          ? const Color(0xFFFF9900)
                          : const Color(0xFFEEEEEE),
                    ),

                    // Phone Number Input

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                          focusNode: _phoneFocusNode,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Enter your phone number',
                            hintStyle: TextStyle(
                              color: Color(0xFF757575),
                              fontFamily: 'Lora',
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmall ? 20 : 24),

              // Email Input for OTP

              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _emailFocused
                        ? const Color(0xFFFF9900)
                        : const Color(0xFFEEEEEE),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFFAF8F4),
                ),
                child: TextField(
                  focusNode: _emailFocusNode,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      color: Color(0xFF757575),
                      fontFamily: 'Lora',
                    ),
                    border: InputBorder.none,
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

              SizedBox(height: isSmall ? 30 : 40),

              // Continue Button

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9900),
                    padding: EdgeInsets.symmetric(vertical: isSmall ? 16 : 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0x40FF9900),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          // Validate phone number

                          if (_phoneController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('Please enter your phone number'),
                              ),
                            );

                            return;
                          }

                          // Validate email

                          if (_emailController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content:
                                    Text('Please enter your email address'),
                              ),
                            );

                            return;
                          }

                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(_emailController.text.trim())) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content:
                                    Text('Please enter a valid email address'),
                              ),
                            );

                            return;
                          }

                          // Navigate to profile setup screen

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileSetupScreen(
                                phoneNumber: _selectedCountryCode +
                                    _phoneController.text.trim(),
                                email: _emailController.text.trim(),
                                notificationToken: widget.notificationToken,
                              ),
                            ),
                          );
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmall ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Lora',
                          ),
                        ),
                ),
              ),

              SizedBox(height: isSmall ? 30 : 40),

              // Terms and Conditions

              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: isSmall ? 12 : 14,
                      color: const Color(0xFF757575),
                      fontFamily: 'Lora',
                    ),
                    children: const [
                      TextSpan(text: 'By continuing, you agree to our'),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: Color(0xFFFF9900),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Color(0xFFFF9900),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: isSmall ? 20 : 40),

              // Sign In option for existing users
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12.0,
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: const Color(0xFF757575),
                        fontSize: isSmall ? 14 : 16,
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
                                      LoginScreen(
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
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: const Color(0xFFFF9900),
                                fontSize: isSmall ? 14 : 16,
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

              SizedBox(height: isSmall ? 20 : 40),
            ],
          ),
        ),
      ),
    );
  }
}
