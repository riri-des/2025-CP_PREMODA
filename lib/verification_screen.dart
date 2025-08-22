import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'home_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final String name;
  final String? password;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.name,
    this.password,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otpCode {
    return _controllers.map((controller) => controller.text).join();
  }

  bool get _isCodeComplete {
    return _otpCode.length == 6 && _otpCode.isNotEmpty;
  }

  void _onCodeChanged(int index) {
    final text = _controllers[index].text;
    
    if (text.isNotEmpty) {
      // Move to next field if not the last one
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // If it's the last field, unfocus
        _focusNodes[index].unfocus();
      }
    }
    
    setState(() {});
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      // Move to previous field if current is empty
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyCode() async {
    if (!_isCodeComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the complete verification code',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.verifyEmailJS(
        email: widget.email,
        token: _otpCode,
        name: widget.name,
        password: widget.password,
      );

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'],
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );

        // Navigate to home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'],
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An unexpected error occurred. Please try again.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
    });

    try {
      final result = await AuthService.resendVerificationEmailJS(widget.email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'],
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: result['success'] ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
        ),
      );

      if (result['success']) {
        // Clear the current inputs
        for (var controller in _controllers) {
          controller.clear();
        }
        // Focus on first input
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to resend verification code. Please try again.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).viewInsets.bottom - 100,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.04),
                    
                    // Lock icon
                    Container(
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: screenWidth * 0.1,
                        color: const Color(0xFFD4A574),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.04),
                    
                    // Title
                    Text(
                      'Verification Code',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.015),
                    
                    // Subtitle
                    Text(
                      'Enter 6-digit code sent to your email address',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenHeight * 0.05),
                    
                    // OTP Input Fields
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return _buildOtpField(index, screenWidth);
                        }),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.03),
                    
                    // Resend code link
                    TextButton(
                      onPressed: _isResending ? null : _resendCode,
                      child: _isResending
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFFD4A574),
                                ),
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                text: "Didn't receive code? ",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.032,
                                  color: Colors.grey[600],
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Resend now',
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.032,
                                      color: const Color(0xFFD4A574),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    
                    const Spacer(),
                    
                    // Verify button
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.06,
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom > 0 
                            ? 20 
                            : screenHeight * 0.03,
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading || !_isCodeComplete ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A574),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Verify',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index, double screenWidth) {
    return Flexible(
      child: Container(
        width: screenWidth * 0.11,
        height: screenWidth * 0.11,
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          border: Border.all(
            color: _controllers[index].text.isNotEmpty 
                ? const Color(0xFFD4A574) 
                : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            if (value.length == 1) {
              _onCodeChanged(index);
            }
          },
          onTap: () {
            // Clear the field when tapped
            _controllers[index].clear();
          },
          onEditingComplete: () {
            if (_controllers[index].text.isEmpty) {
              _onBackspace(index);
            }
          },
        ),
      ),
    );
  }
}
