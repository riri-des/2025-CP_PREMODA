import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'emailjs_config.dart';

class EmailJSService {
  static final Random _random = Random();
  
  /// Generate a 6-digit OTP code
  static String generateOTP() {
    return (_random.nextInt(900000) + 100000).toString();
  }

  /// Send verification email using EmailJS
  static Future<Map<String, dynamic>> sendVerificationEmail({
    required String toEmail,
    required String toName,
    required String otpCode,
  }) async {
    try {
      print('=== EmailJS Debug Info ===');
      print('Service ID: ${EmailJSConfig.serviceId}');
      print('Template ID: ${EmailJSConfig.templateId}');
      print('Public Key: ${EmailJSConfig.publicKey}');
      print('To Email: $toEmail');
      print('To Name: $toName');
      print('OTP Code: $otpCode');
      print('========================');

      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': EmailJSConfig.serviceId,
          'template_id': EmailJSConfig.templateId,
          'user_id': EmailJSConfig.publicKey,
          'template_params': {
            'to_email': toEmail,
            'to_name': toName,
            'otp_code': otpCode,
            'app_name': 'StyleHub',
          },
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Verification email sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to send email: ${response.body}',
        };
      }
    } catch (e) {
      print('Error sending email: $e');
      return {
        'success': false,
        'message': 'Error sending email: $e',
      };
    }
  }

  /// Send password reset email using EmailJS
  static Future<Map<String, dynamic>> sendResetPasswordEmail({
    required String toEmail,
    required String toName,
    required String resetCode,
  }) async {
    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': EmailJSConfig.serviceId,
          'template_id': EmailJSConfig.resetTemplateId,
          'user_id': EmailJSConfig.publicKey,
          'template_params': {
            'to_email': toEmail,
            'to_name': toName,
            'reset_code': resetCode,
            'app_name': 'StyleHub',
          },
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset email sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to send reset email: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending reset email: $e',
      };
    }
  }
}
