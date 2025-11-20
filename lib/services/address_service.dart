import 'package:supabase_flutter/supabase_flutter.dart';

class AddressService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAddresses() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await _supabase
        .from('addresses')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getDefaultAddress() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final res = await _supabase
        .from('addresses')
        .select('*')
        .eq('user_id', userId)
        .eq('is_default', true)
        .maybeSingle();
    return (res is Map<String, dynamic>) ? res : null;
  }

  Future<String?> createAddress({
    required String fullName,
    required String phoneNumber,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    String country = 'Philippines',
    bool isDefault = false,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = {
      'user_id': userId,
      'label': 'home',
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault,
    };

    final inserted = await _supabase.from('addresses').insert(data).select('id').single();
    return inserted['id'] as String?;
  }

  Future<void> updateAddress(String id, Map<String, dynamic> fields) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Never allow user_id to be modified from here
    fields.remove('user_id');
    fields['updated_at'] = DateTime.now().toIso8601String();

    await _supabase
        .from('addresses')
        .update(fields)
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> deleteAddress(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('addresses').delete().eq('id', id).eq('user_id', userId);
  }

  Future<void> setDefaultAddress(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    // Clear previous default, then set new one
    await _supabase.from('addresses').update({'is_default': false}).eq('user_id', userId).eq('is_default', true);
    await _supabase.from('addresses').update({'is_default': true}).eq('id', id).eq('user_id', userId);
  }
}
