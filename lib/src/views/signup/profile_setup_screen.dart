import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/views/signup/otp_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String phoneNumber;
  final String email;
  final String? notificationToken;

  const ProfileSetupScreen({
    required this.phoneNumber,
    required this.email,
    required this.notificationToken,
    super.key,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = false;
  String _errorText = '';

  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _referralCodeFocusNode = FocusNode();

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  @override
  void initState() {
    super.initState();
    _firstNameFocusNode.addListener(() {
      setState(() {});
    });
    _lastNameFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _referralCodeFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _referralCodeFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _referralCodeController.dispose();
    dio.close();
    super.dispose();
  }

  Future<int?> _register() async {
    final Map<String, dynamic> requestData = {
      "phoneNumber": widget.phoneNumber,
      "email": widget.email,
      "name":
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}"
              .trim(),
      "password": _passwordController.text.trim(),
      "isSeller": false,
      "notificationToken": widget.notificationToken,
      "gender": _selectedGender,
      "referralCode": _referralCodeController.text.trim().isNotEmpty
          ? _referralCodeController.text.trim()
          : null,
    };

    print(
        'Registration request to: http://$kPrimaryBaseUrl/api/users/device/register');
    print('Request data: $requestData');

    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/users/device/register",
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: jsonEncode(requestData),
      );

      print('Registration status: ${response.statusCode} --- ${response.data}');

      if (response.statusCode == 201) {
        print('Registration successful: ${response.data}');
        return 201;
      } else {
        setState(() {
          _errorText = response.data['error'] ?? 'Registration failed';
        });
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            "Connection timed out. Please check your internet connection and try again.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            "Unable to connect to server. Please check your internet connection or try again later.";
      } else if (e.response != null) {
        errorMessage = e.response?.data['error'] ??
            'Registration failed. Please try again.';
      }

      setState(() {
        _errorText = errorMessage;
        _isLoading = false;
      });

      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      setState(() {
        _errorText = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('An unexpected error occurred. Please try again.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
      return null;
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Enter your name',
          style: TextStyle(
            fontSize: isSmall ? 18 : 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontFamily: 'Lora',
          ),
        ),
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

              SizedBox(height: isSmall ? 32 : 48),

              // Tell us something about yourself
              Text(
                'Tell us something about yourself',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 18 : 20,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please Enter Your personal information Here',
                style: TextStyle(
                  color: const Color(0xFF757575),
                  fontSize: isSmall ? 13.5 : 15,
                  fontFamily: 'Lora',
                  height: 1.4,
                ),
              ),

              SizedBox(height: isSmall ? 18 : 28),

              // First Name Input
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _firstNameFocusNode.hasFocus
                        ? const Color(0xFFFF9900)
                        : const Color(0xFFEEEEEE),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFFAF8F4),
                ),
                child: TextField(
                  focusNode: _firstNameFocusNode,
                  controller: _firstNameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Color(0xFF757575)),
                    hintText: 'First name',
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

              const SizedBox(height: 14),

              // Last Name Input
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _lastNameFocusNode.hasFocus
                        ? const Color(0xFFFF9900)
                        : const Color(0xFFEEEEEE),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFFAF8F4),
                ),
                child: TextField(
                  focusNode: _lastNameFocusNode,
                  controller: _lastNameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Color(0xFF757575)),
                    hintText: 'Last name',
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

              const SizedBox(height: 14),

              // Password Input
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _passwordFocusNode.hasFocus
                        ? const Color(0xFFFF9900)
                        : const Color(0xFFEEEEEE),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFFAF8F4),
                ),
                child: TextField(
                  focusNode: _passwordFocusNode,
                  controller: _passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF757575)),
                    hintText: 'Password',
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

              const SizedBox(height: 14),

              // Gender Dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedGender != null
                        ? const Color(0xFFFF9900)
                        : const Color(0xFFEEEEEE),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFFAF8F4),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Color(0xFF757575)),
                    hintText: 'Gender',
                    hintStyle: TextStyle(
                      color: Color(0xFF757575),
                      fontFamily: 'Lora',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    suffixIcon: Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF757575)),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Male',
                      child: Text('Male', style: TextStyle(fontFamily: 'Lora')),
                    ),
                    DropdownMenuItem(
                      value: 'Female',
                      child:
                          Text('Female', style: TextStyle(fontFamily: 'Lora')),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child:
                          Text('Other', style: TextStyle(fontFamily: 'Lora')),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Referral Code Input
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _referralCodeFocusNode.hasFocus
                        ? const Color(0xFFFF9900)
                        : const Color(0xFFEEEEEE),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFFAF8F4),
                ),
                child: TextField(
                  focusNode: _referralCodeFocusNode,
                  controller: _referralCodeController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.card_giftcard, color: Color(0xFF757575)),
                    hintText: 'Referral code (optional)',
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

              SizedBox(height: isSmall ? 24 : 32),

              // Continue Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9900),
                      padding:
                          EdgeInsets.symmetric(vertical: isSmall ? 14 : 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0x33FF9900),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            // Validate required fields
                            if (_firstNameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('Please enter your first name'),
                                ),
                              );
                              return;
                            }

                            if (_lastNameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('Please enter your last name'),
                                ),
                              );
                              return;
                            }

                            if (_passwordController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('Please enter a password'),
                                ),
                              );
                              return;
                            }

                            if (_passwordController.text.trim().length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                      'Password must be at least 6 characters'),
                                ),
                              );
                              return;
                            }

                            // Start registration process
                            setState(() {
                              _isLoading = true;
                              _errorText = '';
                            });

                            final registrationResult = await _register();

                            if (registrationResult == 201 && mounted) {
                              setState(() {
                                _isLoading = false;
                              });

                              // Navigate to OTP screen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => OtpScreen(
                                    phoneNumber: widget.phoneNumber,
                                    email: widget.email,
                                    password: _passwordController.text.trim(),
                                    notificationToken: widget.notificationToken,
                                  ),
                                ),
                              );
                            } else if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(_errorText.isNotEmpty
                                      ? _errorText
                                      : 'Registration failed'),
                                ),
                              );
                            }
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
                              fontWeight: FontWeight.bold,
                              fontSize: isSmall ? 16 : 18,
                              color: Colors.white,
                              fontFamily: 'Lora',
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
