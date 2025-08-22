import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'emailjs_service.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  // Sign up with email using Supabase OTP with custom SMTP
  static Future<Map<String, dynamic>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Use standard signup - now with custom SMTP it will send OTP codes
      final AuthResponse response = await _client.auth.signUp(
        email: email.toLowerCase().trim(),
        password: password,
        data: {
          'name': name.trim(),
          'provider': 'email',
        },
      );

      if (response.user != null) {
        return {
          'success': true,
          'message': 'Verification code sent to your email!',
          'needsVerification': true,
          'email': email.toLowerCase().trim(),
          'name': name.trim(),
          'password': password,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create account. Please try again.',
          'needsVerification': false,
        };
      }

    } on AuthException catch (error) {
      String message;
      switch (error.message) {
        case 'User already registered':
          message = 'An account with this email already exists';
          break;
        case 'Password should be at least 6 characters':
          message = 'Password must be at least 6 characters long';
          break;
        case 'Invalid email':
          message = 'Please enter a valid email address';
          break;
        default:
          message = error.message ?? 'Failed to create account';
      }
      return {
        'success': false,
        'message': message,
        'needsVerification': false,
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${error.toString()}',
        'needsVerification': false,
      };
    }
  }

  // Login with email and password using Supabase Auth
  static Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );

      if (response.user != null) {
        return {
          'success': true,
          'message': 'Login successful!',
          'user': response.user,
          'session': response.session,
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid email or password'
        };
      }

    } on AuthException catch (error) {
      String message;
      switch (error.message) {
        case 'Invalid login credentials':
          message = 'Invalid email or password';
          break;
        case 'Email not confirmed':
          message = 'Please check your email and confirm your account';
          break;
        default:
          message = error.message ?? 'Login failed';
      }
      return {
        'success': false,
        'message': message
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Login failed: ${error.toString()}'
      };
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name.trim();
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      final response = await _client
          .from('users')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Profile updated successfully!',
        'user': response,
      };

    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to update profile: ${error.toString()}'
      };
    }
  }

  // Get user by ID
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      return response;
    } catch (error) {
      return null;
    }
  }

  // Sign out the current user
  static Future<Map<String, dynamic>> signOut() async {
    try {
      await _client.auth.signOut();
      return {
        'success': true,
        'message': 'Signed out successfully'
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to sign out: ${error.toString()}'
      };
    }
  }

  // Get current user session
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Get current session
  static Session? getCurrentSession() {
    return _client.auth.currentSession;
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _client.auth.currentUser != null;
  }

  // Change password using Supabase Auth
  static Future<Map<String, dynamic>> changePassword({
    required String newPassword,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        return {
          'success': true,
          'message': 'Password updated successfully!'
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update password'
        };
      }
    } on AuthException catch (error) {
      return {
        'success': false,
        'message': error.message ?? 'Failed to update password'
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to update password: ${error.toString()}'
      };
    }
  }

  // Update user profile using Supabase Auth
  static Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name.trim();
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final response = await _client.auth.updateUser(
        UserAttributes(data: data),
      );

      if (response.user != null) {
        return {
          'success': true,
          'message': 'Profile updated successfully!',
          'user': response.user,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update profile'
        };
      }
    } on AuthException catch (error) {
      return {
        'success': false,
        'message': error.message ?? 'Failed to update profile'
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to update profile: ${error.toString()}'
      };
    }
  }

  // Reset password
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.toLowerCase().trim());
      return {
        'success': true,
        'message': 'Password reset email sent! Please check your inbox.'
      };
    } on AuthException catch (error) {
      return {
        'success': false,
        'message': error.message ?? 'Failed to send password reset email'
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to send password reset email: ${error.toString()}'
      };
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  static Map<String, dynamic> validatePassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));

    final isValid = hasMinLength && hasUpperCase && hasLowerCase && hasNumbers;

    return {
      'isValid': isValid,
      'hasMinLength': hasMinLength,
      'hasUpperCase': hasUpperCase,
      'hasLowerCase': hasLowerCase,
      'hasNumbers': hasNumbers,
      'message': isValid 
          ? 'Password is strong'
          : 'Password must be at least 8 characters with uppercase, lowercase, and numbers'
    };
  }

  // Verify email with Supabase OTP code and complete user setup
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String token,
    required String name,
    String? password,
  }) async {
    try {
      final AuthResponse response = await _client.auth.verifyOTP(
        email: email.toLowerCase().trim(),
        token: token,
        type: OtpType.signup,
      );

      if (response.user != null && response.session != null) {
        // User verified successfully, now sync with users table
        try {
          await _syncUserToTable(
            userId: response.user!.id,
            name: name.trim(),
            email: email.toLowerCase().trim(),
            provider: 'email',
          );
        } catch (e) {
          // Even if table sync fails, auth user was verified successfully
          print('Warning: Failed to sync user to table: $e');
        }

        return {
          'success': true,
          'message': 'Email verified successfully!',
          'user': response.user,
          'session': response.session,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to verify email. Please try again.'
        };
      }

    } on AuthException catch (error) {
      String message;
      switch (error.message) {
        case 'Token has expired':
          message = 'Verification code has expired. Please request a new one.';
          break;
        case 'Invalid token':
          message = 'Invalid verification code. Please check and try again.';
          break;
        case 'Token already used':
          message = 'This verification code has already been used.';
          break;
        default:
          message = error.message ?? 'Failed to verify email';
      }
      return {
        'success': false,
        'message': message
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to verify email: ${error.toString()}'
      };
    }
  }

  // Resend verification email
  static Future<Map<String, dynamic>> resendVerification(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email.toLowerCase().trim(),
      );
      return {
        'success': true,
        'message': 'Verification code sent! Please check your email.'
      };
    } on AuthException catch (error) {
      return {
        'success': false,
        'message': error.message ?? 'Failed to resend verification code'
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to resend verification code: ${error.toString()}'
      };
    }
  }

  // Private helper method to generate custom 6-digit OTP
  static String _generateCustomOTP() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (100000 + (random % 900000)).toString();
  }

  // EmailJS-based signup with custom OTP
  static Future<Map<String, dynamic>> signUpWithEmailJS({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // First create the user in Supabase without email confirmation
      final AuthResponse response = await _client.auth.signUp(
        email: email.toLowerCase().trim(),
        password: password,
        data: {
          'name': name.trim(),
          'provider': 'email',
        },
        emailRedirectTo: null, // Disable automatic email
      );

      if (response.user != null) {
        // Generate custom OTP
        final otpCode = EmailJSService.generateOTP();
        
        // Store OTP temporarily in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('otp_${email.toLowerCase().trim()}', otpCode);
        await prefs.setString('otp_name_${email.toLowerCase().trim()}', name.trim());
        await prefs.setString('otp_password_${email.toLowerCase().trim()}', password);
        await prefs.setInt('otp_timestamp_${email.toLowerCase().trim()}', DateTime.now().millisecondsSinceEpoch);
        
        // Send email using EmailJS
        final emailResult = await EmailJSService.sendVerificationEmail(
          toEmail: email.toLowerCase().trim(),
          userName: name.trim(),
          otpCode: otpCode,
        );
        
        if (emailResult['success']) {
          return {
            'success': true,
            'message': 'Verification code sent to your email!',
            'needsVerification': true,
            'email': email.toLowerCase().trim(),
            'name': name.trim(),
            'password': password,
          };
        } else {
          return {
            'success': false,
            'message': emailResult['message'],
            'needsVerification': false,
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to create account. Please try again.',
          'needsVerification': false,
        };
      }

    } on AuthException catch (error) {
      String message;
      switch (error.message) {
        case 'User already registered':
          message = 'An account with this email already exists';
          break;
        case 'Password should be at least 6 characters':
          message = 'Password must be at least 6 characters long';
          break;
        case 'Invalid email':
          message = 'Please enter a valid email address';
          break;
        default:
          message = error.message ?? 'Failed to create account';
      }
      return {
        'success': false,
        'message': message,
        'needsVerification': false,
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${error.toString()}',
        'needsVerification': false,
      };
    }
  }

  // Verify EmailJS OTP and complete user setup
  static Future<Map<String, dynamic>> verifyEmailJS({
    required String email,
    required String token,
    required String name,
    String? password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedOtp = prefs.getString('otp_${email.toLowerCase().trim()}');
      final storedTimestamp = prefs.getInt('otp_timestamp_${email.toLowerCase().trim()}');
      
      if (storedOtp == null || storedTimestamp == null) {
        return {
          'success': false,
          'message': 'Verification code has expired. Please request a new one.'
        };
      }
      
      // Check if OTP is expired (10 minutes)
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - storedTimestamp > 600000) { // 10 minutes in milliseconds
        // Clean up expired OTP
        await _cleanupOTPData(email.toLowerCase().trim());
        return {
          'success': false,
          'message': 'Verification code has expired. Please request a new one.'
        };
      }
      
      // Verify OTP
      if (token != storedOtp) {
        return {
          'success': false,
          'message': 'Invalid verification code. Please check and try again.'
        };
      }
      
      // OTP is valid, now confirm the user manually
      // Since we can't directly confirm via Supabase without the email link,
      // we'll sign them in and consider them verified
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email.toLowerCase().trim(),
        password: password ?? prefs.getString('otp_password_${email.toLowerCase().trim()}') ?? '',
      );
      
      if (response.user != null && response.session != null) {
        // Clean up OTP data
        await _cleanupOTPData(email.toLowerCase().trim());
        
        // Sync user to table
        try {
          await _syncUserToTable(
            userId: response.user!.id,
            name: name.trim(),
            email: email.toLowerCase().trim(),
            provider: 'email',
          );
        } catch (e) {
          print('Warning: Failed to sync user to table: $e');
        }
        
        return {
          'success': true,
          'message': 'Email verified successfully!',
          'user': response.user,
          'session': response.session,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to verify email. Please try again.'
        };
      }
      
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to verify email: ${error.toString()}'
      };
    }
  }
  
  // Resend EmailJS verification
  static Future<Map<String, dynamic>> resendVerificationEmailJS(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedName = prefs.getString('otp_name_${email.toLowerCase().trim()}');
      
      if (storedName == null) {
        return {
          'success': false,
          'message': 'Please start the signup process again.'
        };
      }
      
      // Generate new OTP
      final otpCode = EmailJSService.generateOTP();
      
      // Update stored OTP
      await prefs.setString('otp_${email.toLowerCase().trim()}', otpCode);
      await prefs.setInt('otp_timestamp_${email.toLowerCase().trim()}', DateTime.now().millisecondsSinceEpoch);
      
      // Send email using EmailJS
      final emailResult = await EmailJSService.sendVerificationEmail(
        toEmail: email.toLowerCase().trim(),
        userName: storedName,
        otpCode: otpCode,
      );
      
      return emailResult;
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to resend verification code: ${error.toString()}'
      };
    }
  }
  
  // Helper method to cleanup OTP data
  static Future<void> _cleanupOTPData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('otp_$email');
    await prefs.remove('otp_name_$email');
    await prefs.remove('otp_password_$email');
    await prefs.remove('otp_timestamp_$email');
  }

  // Private helper method to sync user data to custom users table
  static Future<void> _syncUserToTable({
    required String userId,
    required String name,
    required String email,
    required String provider,
  }) async {
    try {
      await _client.from('users').insert({
        'id': userId,
        'name': name,
        'email': email,
        'provider': provider,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Re-throw the error so it can be handled by the calling method
      throw Exception('Failed to sync user to table: $e');
    }
  }
}
