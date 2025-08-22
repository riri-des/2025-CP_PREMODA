import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'emailjs_config.dart';

class EmailJSService {
  // Generate a random 6-digit OTP code
  static String generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Send verification email using EmailJS REST API directly
  static Future<Map<String, dynamic>> sendVerificationEmail({
    required String toEmail,
    required String userName,
    required String otpCode,
  }) async {
    try {
      print('EmailJS Debug: Sending email...');
      print('Service ID: ${EmailJSConfig.serviceId}');
      print('Template ID: ${EmailJSConfig.templateId}');
      print('Public Key: ${EmailJSConfig.publicKey}');
      print('To Email: $toEmail');
      print('User Name: $userName');
      print('OTP Code: $otpCode');
      
      // Validate configuration
      if (EmailJSConfig.serviceId.isEmpty || 
          EmailJSConfig.templateId.isEmpty || 
          EmailJSConfig.publicKey.isEmpty) {
        throw Exception('EmailJS configuration is incomplete. Please check your credentials.');
      }
      
      // Build request body according to EmailJS REST API documentation
      final requestBody = {
        'service_id': EmailJSConfig.serviceId,
        'template_id': EmailJSConfig.templateId,
        'user_id': EmailJSConfig.publicKey,
        'template_params': {
          'app_name': 'Premoda',
          'user_name': userName,
          'otp_code': otpCode,
          'to_email': toEmail,
        },
      };
      
      // Add accessToken if private key is provided
      if (EmailJSConfig.privateKey != null && EmailJSConfig.privateKey!.isNotEmpty) {
        requestBody['accessToken'] = EmailJSConfig.privateKey!;
      }
      
      print('Request Body: $requestBody');
      
      // Send POST request to EmailJS REST API with browser headers
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Origin': 'https://app.premoda.com',
          'Referer': 'https://app.premoda.com/',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'en-US,en;q=0.9',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
        body: json.encode(requestBody),
      );
      
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('EmailJS: Email sent successfully!');
        return {
          'success': true,
          'message': 'Verification code sent to your email!',
          'otpCode': otpCode,
        };
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      
    } catch (error) {
      print('EmailJS Error: $error');
      return {
        'success': false,
        'message': 'Failed to send verification email: ${error.toString()}',
      };
    }
  }

  // Send password reset email
  static Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String toEmail,
    required String userName,
    required String resetLink,
  }) async {
    try {
      // Build request body for password reset (you'll need a separate template)
      final requestBody = {
        'service_id': EmailJSConfig.serviceId,
        'template_id': 'template_password_reset', // Create this template in EmailJS
        'user_id': EmailJSConfig.publicKey,
        'template_params': {
          'to_email': toEmail,
          'user_name': userName,
          'reset_link': resetLink,
          'app_name': 'Premoda',
          'from_name': 'Premoda Team',
        },
      };
      
      if (EmailJSConfig.privateKey != null && EmailJSConfig.privateKey!.isNotEmpty) {
        requestBody['accessToken'] = EmailJSConfig.privateKey!;
      }
      
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset email sent!',
        };
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to send password reset email: ${error.toString()}',
      };
    }
  }

  // Verify OTP code (you'll need to store the generated OTP temporarily)
  static bool verifyOTP(String inputCode, String generatedCode) {
    return inputCode == generatedCode;
  }
}
