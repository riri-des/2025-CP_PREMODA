import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/address_service.dart';
import 'address_form_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AddressesListScreen extends StatefulWidget {
  const AddressesListScreen({super.key});

  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  final AddressService _addressService = AddressService();
  bool _loading = true;
  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _addressService.getAddresses();
    setState(() {
      _addresses = list;
      _loading = false;
    });
  }

  Future<void> _setDefaultOptimistic(String id) async {
    // Optimistic: update local list first
    setState(() {
      _addresses = _addresses.map((a) {
        if (a['id'].toString() == id) {
          return {...a, 'is_default': true};
        }
        return {...a, 'is_default': false};
      }).toList();
    });
    try {
      await _addressService.setDefaultAddress(id);
    } catch (e) {
      // reload to recover
      _load();
    }
  }

  Future<void> _deleteWithUndo(Map<String, dynamic> a) async {
    final idx = _addresses.indexWhere((x) => x['id'] == a['id']);
    if (idx < 0) return;
    final removed = a;
    setState(() {
      _addresses.removeAt(idx);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    final snack = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Address deleted', style: GoogleFonts.poppins()),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _addresses.insert(idx, removed);
            });
          },
        ),
      ),
    );
    final res = await snack.closed;
    // If not undone, delete on server
    if (mounted && res != SnackBarClosedReason.action) {
      await _addressService.deleteAddress(a['id'].toString());
      // Ensure default still exists
      if (!_addresses.any((x) => x['is_default'] == true) && _addresses.isNotEmpty) {
        await _setDefaultOptimistic(_addresses.first['id'].toString());
      }
    }
  }

  Future<void> _openInMaps(String addressText) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addressText)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        title: Text('My Addresses', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressFormScreen()),
          );
          if (saved == true) _load();
        },
        backgroundColor: const Color(0xFFD4A574),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _addresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('No addresses yet', style: GoogleFonts.poppins(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(w * 0.04),
                      itemCount: _addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final a = _addresses[i];
                        final isDefault = (a['is_default'] ?? false) as bool;
                        final addressText = [
                          a['address_line1'],
                          a['address_line2'],
                          a['city'],
                          a['state'],
                          a['postal_code'],
                          a['country'] ?? 'Philippines',
                        ].where((e) => (e?.toString().isNotEmpty ?? false)).join(', ');

                        return Dismissible(
                          key: Key(a['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            color: const Color(0xFFF44336).withOpacity(0.12),
                            child: const Icon(Icons.delete_outline, color: Color(0xFFF44336)),
                          ),
                          confirmDismiss: (dir) async {
                            await _deleteWithUndo(a);
                            return false; // we handle removal ourselves
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: isDefault
                                  ? Border.all(color: const Color(0xFFD4A574), width: 1.5)
                                  : null,
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD4A574).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.home_outlined, size: 14, color: Color(0xFFD4A574)),
                                          const SizedBox(width: 4),
                                          Text((a['label']?.toString().isNotEmpty ?? false) ? a['label'].toString() : 'Address',
                                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFFD4A574))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isDefault)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF43A047).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text('DEFAULT', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2E7D32))),
                                      ),
                                    const Spacer(),
                                    IconButton(
                                      tooltip: isDefault ? 'Default address' : 'Set as default',
                                      onPressed: isDefault ? null : () => _setDefaultOptimistic(a['id'].toString()),
                                      icon: Icon(
                                        isDefault ? Icons.star : Icons.star_border,
                                        color: const Color(0xFFD4A574),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (v) async {
                                        if (v == 'edit') {
                                          final saved = await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => AddressFormScreen(address: a)),
                                          );
                                          if (saved == true) _load();
                                        } else if (v == 'map') {
                                          await _openInMaps(addressText);
                                        }
                                      },
                                      itemBuilder: (ctx) => const [
                                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                                        PopupMenuItem(value: 'map', child: Text('Open in Maps')),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(a['full_name']?.toString() ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(
                                  addressText,
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade800),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(a['phone_number']?.toString() ?? '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
