import 'package:supabase_flutter/supabase_flutter.dart';
import 'emailjs_service.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  
  // Store OTP codes temporarily (in production, use a more secure method)
  static final Map<String, String> _otpStorage = {};
  static final Map<String, DateTime> _otpExpiry = {};

  /// Sign up with EmailJS verification
  Future<Map<String, dynamic>> signUpWithEmailJS({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Generate OTP
      final otpCode = EmailJSService.generateOTP();
      
      // Store OTP with expiry (5 minutes)
      _otpStorage[email] = otpCode;
      _otpExpiry[email] = DateTime.now().add(const Duration(minutes: 5));
      
      // Send verification email using EmailJS
      final emailResult = await EmailJSService.sendVerificationEmail(
        toEmail: email,
        toName: fullName,
        otpCode: otpCode,
      );
      
      if (emailResult['success']) {
        return {
          'success': true,
          'message': 'Verification email sent. Please check your inbox and enter the OTP.',
          'needsVerification': true,
        };
      } else {
        return {
          'success': false,
          'message': emailResult['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error during signup: $e',
      };
    }
  }

  /// Verify OTP and complete signup
  Future<Map<String, dynamic>> verifyOTPAndSignUp({
    required String email,
    required String password,
    required String fullName,
    required String otpCode,
  }) async {
    try {
      // Check if OTP exists and is valid
      if (!_otpStorage.containsKey(email)) {
        return {
          'success': false,
          'message': 'No OTP found for this email. Please request a new one.',
        };
      }

      // Check if OTP has expired
      final expiry = _otpExpiry[email];
      if (expiry == null || DateTime.now().isAfter(expiry)) {
        _otpStorage.remove(email);
        _otpExpiry.remove(email);
        return {
          'success': false,
          'message': 'OTP has expired. Please request a new one.',
        };
      }

      // Verify OTP
      final storedOtp = _otpStorage[email];
      if (storedOtp != otpCode) {
        return {
          'success': false,
          'message': 'Invalid OTP. Please try again.',
        };
      }

      // OTP is valid, now create the account
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      // Clear OTP from storage
      _otpStorage.remove(email);
      _otpExpiry.remove(email);

      if (response.user != null) {
        return {
          'success': true,
          'message': 'Account created successfully!',
          'user': response.user,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create account. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying OTP: $e',
      };
    }
  }

  /// Resend OTP using EmailJS
  Future<Map<String, dynamic>> resendOTP({
    required String email,
    required String fullName,
  }) async {
    try {
      // Generate new OTP
      final otpCode = EmailJSService.generateOTP();
      
      // Store new OTP with expiry (5 minutes)
      _otpStorage[email] = otpCode;
      _otpExpiry[email] = DateTime.now().add(const Duration(minutes: 5));
      
      // Send verification email using EmailJS
      final emailResult = await EmailJSService.sendVerificationEmail(
        toEmail: email,
        toName: fullName,
        otpCode: otpCode,
      );
      
      if (emailResult['success']) {
        return {
          'success': true,
          'message': 'New verification code sent to your email.',
        };
      } else {
        return {
          'success': false,
          'message': emailResult['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error resending OTP: $e',
      };
    }
  }

  /// Sign in
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return {
          'success': true,
          'message': 'Signed in successfully',
          'user': response.user,
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid credentials',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error signing in: $e',
      };
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return {
        'success': true,
        'message': 'Password reset email sent',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending reset email: $e',
      };
    }
  }
}
