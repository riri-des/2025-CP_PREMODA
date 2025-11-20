import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/address_service.dart';

class AddressFormScreen extends StatefulWidget {
  final Map<String, dynamic>? address; // null => create; not null => edit
  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postal = TextEditingController();
  bool _isDefault = false;

  final AddressService _addressService = AddressService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    if (a != null) {
      _fullName.text = (a['full_name'] ?? '').toString();
      _phone.text = (a['phone_number'] ?? '').toString();
      _line1.text = (a['address_line1'] ?? '').toString();
      _line2.text = (a['address_line2'] ?? '').toString();
      _city.text = (a['city'] ?? '').toString();
      _state.text = (a['state'] ?? '').toString();
      _postal.text = (a['postal_code'] ?? '').toString();
      _isDefault = (a['is_default'] ?? false) as bool;
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _state.dispose();
    _postal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.address != null;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(editing ? 'Edit Address' : 'Add Address', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(w * 0.05),
          children: [
            _field(_fullName, 'Full Name', Icons.person_outline, (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            _field(_phone, 'Phone Number', Icons.phone_outlined, (v) => v == null || v.trim().isEmpty ? 'Required' : null, keyboard: TextInputType.phone),
            const SizedBox(height: 12),
            _field(_line1, 'Address Line 1', Icons.home_outlined, (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            _field(_line2, 'Address Line 2 (optional)', Icons.home_work_outlined, null),
            const SizedBox(height: 12),
            _field(_city, 'City', Icons.location_city_outlined, (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            _field(_state, 'State/Province', Icons.map_outlined, (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            _field(_postal, 'Postal Code', Icons.local_post_office_outlined, (v) => v == null || v.trim().isEmpty ? 'Required' : null, keyboard: TextInputType.number),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _isDefault,
              onChanged: (val) => setState(() => _isDefault = val ?? false),
              title: Text('Set as default', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A574),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(editing ? 'Save Changes' : 'Add Address', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, String? Function(String?)? validator, {TextInputType? keyboard}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFD4A574)),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFFD4A574), width: 2)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (widget.address == null) {
        final id = await _addressService.createAddress(
          fullName: _fullName.text.trim(),
          phoneNumber: _phone.text.trim(),
          addressLine1: _line1.text.trim(),
          addressLine2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
          city: _city.text.trim(),
          state: _state.text.trim(),
          postalCode: _postal.text.trim(),
          isDefault: _isDefault,
        );
        if (id != null && _isDefault) {
          await _addressService.setDefaultAddress(id);
        }
      } else {
        final id = widget.address!['id'].toString();
        await _addressService.updateAddress(id, {
          'full_name': _fullName.text.trim(),
          'phone_number': _phone.text.trim(),
          'address_line1': _line1.text.trim(),
          'address_line2': _line2.text.trim().isEmpty ? null : _line2.text.trim(),
          'city': _city.text.trim(),
          'state': _state.text.trim(),
          'postal_code': _postal.text.trim(),
          'is_default': _isDefault,
        });
        if (_isDefault) {
          await _addressService.setDefaultAddress(id);
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address: $e', style: GoogleFonts.poppins())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
