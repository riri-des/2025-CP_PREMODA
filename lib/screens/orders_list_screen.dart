import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final OrderService _orderService = OrderService();
  bool _loading = true;
  bool _loadingMore = false;
  List<Map<String, dynamic>> _orders = [];
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  final Map<String, Future<Map<String, dynamic>>> _previewCache = {};
  String _status = 'all';
  int _limit = 20;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('MMM d, yyyy • h:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatCurrency(num n) {
    final f = NumberFormat.currency(locale: 'en_PH', symbol: 'PHP ');
    return f.format(n);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _offset = 0;
        _orders = [];
        _previewCache.clear();
      });
    }
    final res = await _orderService.getOrders(
      limit: _limit,
      offset: _offset,
      // Fetch like 'All' for speed; we'll filter client-side
      status: null,
      query: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
    );
    setState(() {
      _orders = [..._orders, ...res];
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore) return;
    setState(() => _loadingMore = true);
    _offset += _limit;
    final res = await _orderService.getOrders(
      limit: _limit,
      offset: _offset,
      status: _status,
      query: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
    );
    setState(() {
      _orders.addAll(res);
      _loadingMore = false;
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
        title: Text('My Orders', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: ListView(
                controller: _scrollCtrl,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(w * 0.04),
                children: [
                  // Search + Filter chips
                  _buildQueryBar(w),
                  const SizedBox(height: 8),
                  _buildStatusChips(),
                  const SizedBox(height: 12),
                  ...(() {
                    final visible = _filteredOrders();
                    if (visible.isEmpty) {
                      return [
                        Container(
                          margin: EdgeInsets.only(top: w * 0.2),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text('No orders found', style: GoogleFonts.poppins(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ];
                    }
                    return [
                      ...List.generate(visible.length, (i) => _buildOrderCard(visible[i], w, i)),
                      if (_loadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ];
                  })(),
                ],
              ),
            ),
    );
  }

  // Client-side filter to match current status chip selection
  List<Map<String, dynamic>> _filteredOrders() {
    if (_status == 'all') return _orders;
    final token = _status.toLowerCase();
    return _orders.where((o) => (o['status']?.toString().toLowerCase() ?? '').contains(token)).toList();
  }

  Widget _buildQueryBar(double w) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _load(reset: true),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search order number',
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _load(reset: true),
          icon: const Icon(Icons.tune_rounded, color: Color(0xFFD4A574)),
        ),
      ],
    );
  }

  Widget _buildStatusChips() {
    final statuses = ['all', 'pending', 'processing', 'shipped', 'delivered'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((s) {
          final sel = _status == s;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(s[0].toUpperCase() + s.substring(1)),
              selected: sel,
              onSelected: (_) {
                setState(() => _status = s);
                _load(reset: true);
              },
              selectedColor: const Color(0xFFD4A574).withOpacity(0.15),
              labelStyle: GoogleFonts.poppins(
                color: sel ? const Color(0xFFD4A574) : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              shape: StadiumBorder(side: BorderSide(color: sel ? const Color(0xFFD4A574) : Colors.grey.shade300)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> o, double w, int index) {
    final status = (o['status'] ?? 'pending') as String;
    final totalNum = (o['total_amount'] ?? 0);
    final createdAt = (o['created_at'] ?? '').toString();
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o['id'].toString())),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  o['order_number']?.toString() ?? 'Order',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatDate(createdAt),
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Items preview row (limit network calls to first 5 cards)
            if (index < 5)
              FutureBuilder<Map<String, dynamic>>(
                future: _previewCache.putIfAbsent(
                  o['id'].toString(),
                  () => _orderService.getOrderItemsPreview(o['id'].toString()),
                ),
                builder: (ctx, snap) {
                  final count = (snap.data?['count'] ?? 0) as int;
                  final images = (snap.data?['images'] as List?)?.cast<String>() ?? const <String>[];
                  if (count == 0) return const SizedBox.shrink();
                  return Row(
                    children: [
                      ...images.map((url) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                color: Colors.grey.withOpacity(0.1),
                                width: 28,
                                height: 28,
                                child: url.isNotEmpty ? Image.network(url, fit: BoxFit.cover) : const SizedBox(),
                              ),
                            ),
                          )),
                      if (count > images.length)
                        Text('+${count - images.length} more', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700)),
                    ],
                  );
                },
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Total', style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 13)),
                const Spacer(),
                Text(_formatCurrency(totalNum is num ? totalNum : num.tryParse(totalNum.toString()) ?? 0),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFFD4A574))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
