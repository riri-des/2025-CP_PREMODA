import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getOrders({int limit = 20, int offset = 0, String? status, String? query}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    dynamic q = _supabase
        .from('orders')
        .select('id, order_number, status, total_amount, created_at, tracking_number, payment_method')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      // Case-insensitive contains to tolerate spacing/variants, e.g., 'Pending ', 'PENDING'
      final token = status.trim();
      q = q.ilike('status', '%$token%');
    }
    if (query != null && query.isNotEmpty) {
      q = q.ilike('order_number', '%${query.replaceAll("'", '')}%');
    }

    try {
      final res = await q.range(offset, offset + limit - 1).timeout(const Duration(seconds: 12));
      return (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      // Log and return empty list to prevent UI hang
      // ignore: avoid_print
      print('getOrders error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getOrderDetail(String orderId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final order = await _supabase
        .from('orders')
        .select('*')
        .eq('id', orderId)
        .single();

    final items = await _supabase
        .from('order_items')
        .select('''
          *,
          product:product_id (*, product_images (*))
        ''')
        .eq('order_id', orderId);

    return {
      'order': order,
      'items': items,
    };
  }

  Future<List<Map<String, dynamic>>> getOrderEvents(String orderId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    // Requires RLS policy that checks orders.owner
    final res = await _supabase
        .from('order_status_events')
        .select('*')
        .eq('order_id', orderId)
        .order('created_at', ascending: true);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getOrderItemsPreview(String orderId, {int limit = 3}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {'count': 0, 'images': <String>[]};

    final items = await _supabase
        .from('order_items')
        .select('''
          product:product_id (product_images (url))
        ''')
        .eq('order_id', orderId)
        .limit(limit);

    final countList = await _supabase
        .from('order_items')
        .select('id')
        .eq('order_id', orderId);

    final images = <String>[];
    for (final it in (items as List)) {
      final prod = it['product'] as Map<String, dynamic>?;
      final imgs = (prod?['product_images'] as List?) ?? [];
      if (imgs.isNotEmpty && imgs.first['url'] != null) {
        images.add(imgs.first['url'].toString());
      }
    }

    final count = (countList as List).length;
    return {'count': count, 'images': images};
  }
}
