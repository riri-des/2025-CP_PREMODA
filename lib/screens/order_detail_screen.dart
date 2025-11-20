import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  bool _loading = true;
  Map<String, dynamic>? _order;
  List<dynamic> _items = [];
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Widget _buildTimeline(double w) {
    // If no events yet, render a simple placeholder card using current status
    if (_events.isEmpty) {
      final status = (_order?['status'] ?? 'pending') as String;
      final createdAt = (_order?['created_at'] ?? '').toString();
      final fallback = [
        {
          'status': 'placed',
          'created_at': createdAt,
          'note': 'Order placed'
        },
        {'status': status, 'created_at': createdAt, 'note': 'Current status'}
      ];
      return _timelineCard(w, fallback);
    }
    return _timelineCard(w, _events);
  }

  Widget _timelineCard(double w, List<dynamic> events) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsets.all(w * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFD4A574).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.timeline_rounded, color: Color(0xFFD4A574), size: 18),
            ),
            const SizedBox(width: 8),
            Text('Status Timeline', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          ...events.asMap().entries.map((e) {
            final i = e.key;
            final data = e.value as Map<String, dynamic>;
            final status = (data['status'] ?? '').toString();
            final note = (data['note'] ?? '').toString();
            final ts = (data['created_at'] ?? '').toString();
            final isLast = i == events.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline indicator
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: _statusColor(status), shape: BoxShape.circle),
                    ),
                    if (!isLast)
                      Container(width: 2, height: 36, color: Colors.grey.withOpacity(0.3)),
                  ],
                ),
                const SizedBox(width: 10),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(status.isEmpty ? 'Event' : status.toUpperCase(), style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: _statusColor(status))),
                        if (note.isNotEmpty)
                          Text(note, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade800)),
                        Text(ts, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _orderService.getOrderDetail(widget.orderId);
    final ev = await _orderService.getOrderEvents(widget.orderId);
    setState(() {
      _order = res?['order'] as Map<String, dynamic>?;
      _items = (res?['items'] as List?) ?? [];
      _events = ev;
      _loading = false;
    });
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'processing':
        return const Color(0xFFFFA000);
      case 'shipped':
        return const Color(0xFF1E88E5);
      case 'delivered':
        return const Color(0xFF43A047);
      case 'cancelled':
      case 'refunded':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Order Detail', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? Center(child: Text('Order not found', style: GoogleFonts.poppins(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.all(w * 0.04),
                    children: [
                      _buildHeader(w),
                      const SizedBox(height: 12),
                      _buildTimeline(w),
                      const SizedBox(height: 12),
                      _buildItems(w),
                      const SizedBox(height: 12),
                      _buildTotals(w),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(double w) {
    final number = _order?['order_number']?.toString() ?? '';
    final status = (_order?['status'] ?? 'pending') as String;
    final tracking = _order?['tracking_number']?.toString();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsets.all(w * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(number, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(status))),
              ),
            ],
          ),
          if (tracking != null && tracking.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_shipping_outlined, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Expanded(child: Text('Tracking: $tracking', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade800))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItems(double w) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsets.all(w * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFD4A574).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFD4A574), size: 18),
            ),
            const SizedBox(width: 8),
            Text('Items', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          ..._items.map((it) {
            final product = it['product'] as Map<String, dynamic>?;
            final images = (product?['product_images'] as List?) ?? [];
            final img = images.isNotEmpty ? (images.first['url']?.toString() ?? '') : '';
            final name = product?['name']?.toString() ?? 'Product';
            final qty = (it['quantity'] ?? 1) as int;
            final price = (it['price'] ?? 0).toString();
            final size = it['size']?.toString() ?? '';
            final color = it['color']?.toString() ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    clipBehavior: Clip.antiAlias,
                    child: img.isNotEmpty ? Image.network(img, fit: BoxFit.cover) : const Icon(Icons.checkroom_rounded, color: Color(0xFFD4A574)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('Size: $size • Color: $color', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                        const SizedBox(height: 2),
                        Text('Qty: $qty', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  Text('PHP $price', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Color(0xFFD4A574))),
                ],
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildTotals(double w) {
    final subtotal = (_order?['subtotal'] ?? 0).toString();
    final shipping = (_order?['shipping_fee'] ?? 0).toString();
    final tax = (_order?['tax'] ?? 0).toString();
    final total = (_order?['total_amount'] ?? 0).toString();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsets.all(w * 0.04),
      child: Column(
        children: [
          _row('Subtotal', subtotal),
          const SizedBox(height: 8),
          _row('Shipping', shipping),
          const SizedBox(height: 8),
          _row('Tax', tax),
          Divider(color: Colors.grey.withOpacity(0.3), height: 24),
          Row(
            children: [
              Text('Total', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('PHP $total', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: Color(0xFFD4A574))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String amount) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.grey.shade700)),
        const Spacer(),
        Text('PHP $amount', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
