import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      // Get current authenticated user from Supabase Auth
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No user is currently logged in');
        return null;
      }

      final userId = currentUser.id;
      final userEmail = currentUser.email ?? '';
      final userName = currentUser.userMetadata?['name'] ?? 
                       currentUser.userMetadata?['full_name'] ?? 
                       userEmail.split('@')[0];

      // Try to get profile data from profiles table (may not exist yet)
      Map<String, dynamic>? profileResponse;
      try {
        profileResponse = await _supabase
            .from('profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
      } catch (e) {
        // Profile table doesn't exist yet or query failed - use default values
        profileResponse = null;
      }

      // Get stats (with error handling)
      final ordersCount = await _getOrdersCount(userId);
      final wishlistCount = await _getWishlistCount(userId);
      final reviewsCount = await _getReviewsCount(userId);

      return {
        'id': userId,
        'name': userName,
        'email': userEmail,
        'avatar_url': currentUser.userMetadata?['avatar_url'],
        'full_name': profileResponse?['full_name'] ?? userName,
        'phone_number': profileResponse?['phone_number'],
        'membership_status': profileResponse?['membership_status'] ?? 'standard',
        'total_orders': ordersCount,
        'total_spent': profileResponse?['total_spent'] ?? 0.0,
        'wishlist_count': wishlistCount,
        'review_count': reviewsCount,
        'created_at': currentUser.createdAt,
        'profile_picture_url': profileResponse?['profile_picture_url'],
        'bio': profileResponse?['bio'],
        'date_of_birth': profileResponse?['date_of_birth'],
        'gender': profileResponse?['gender'],
      };
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Get orders count
  Future<int> _getOrdersCount(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('id')
          .eq('user_id', userId);
      return (response as List).length;
    } catch (e) {
      // Table doesn't exist yet or no data - return 0 silently
      return 0;
    }
  }

  // Get wishlist count
  Future<int> _getWishlistCount(String userId) async {
    try {
      final response = await _supabase
          .from('wishlists')
          .select('id')
          .eq('user_id', userId);
      return (response as List).length;
    } catch (e) {
      // Table doesn't exist yet or no data - return 0 silently
      return 0;
    }
  }

  // Get reviews count
  Future<int> _getReviewsCount(String userId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('id')
          .eq('user_id', userId);
      return (response as List).length;
    } catch (e) {
      // Table doesn't exist yet or no data - return 0 silently
      return 0;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? bio,
    String? dateOfBirth,
    String? gender,
    String? profilePictureUrl,
    Map<String, dynamic>? preferences,
    String? displayName,
    String? userAvatarUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Check if profile exists
      final existingProfile = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      final profileData = {
        'user_id': userId,
        if (fullName != null) 'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (bio != null) 'bio': bio,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (gender != null) 'gender': gender,
        if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
        if (preferences != null) 'preferences': preferences,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existingProfile == null) {
        // Create new profile
        await _supabase.from('profiles').insert(profileData);
      } else {
        // Update existing profile
        await _supabase
            .from('profiles')
            .update(profileData)
            .eq('user_id', userId);
      }

      // Update user record if requested
      if (displayName != null || userAvatarUrl != null) {
        await _supabase
            .from('users')
            .update({
              if (displayName != null) 'name': displayName,
              if (userAvatarUrl != null) 'avatar_url': userAvatarUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Get user addresses
  Future<List<Map<String, dynamic>>> getUserAddresses() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }

  // Get user orders
  Future<List<Map<String, dynamic>>> getUserOrders({int limit = 10}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  // Upload profile picture
  Future<String?> uploadProfilePicture(String filePath) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final fileName = 'profile_$userId.jpg';
      final path = 'profiles/$fileName';
      final file = File(filePath);

      // Read file as bytes
      final bytes = await file.readAsBytes();

      // Upload to Supabase Storage
      await _supabase.storage
          .from('avatars')
          .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));

      // Get public URL
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);

      // Update profile with new URL
      await updateProfile(profilePictureUrl: publicUrl);

      return publicUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Delete user (cascade will handle related records)
      await _supabase.from('users').delete().eq('id', userId);

      // Sign out
      await _supabase.auth.signOut();

      return true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
