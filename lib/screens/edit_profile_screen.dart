import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/profile_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileService _profileService = ProfileService();

  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _displayName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _dob = TextEditingController();
  final _bio = TextEditingController();

  String _gender = 'Prefer not to say';
  bool _notifOrders = true;
  bool _notifPromos = false;
  String _sizeTops = '';
  String _sizeBottoms = '';
  String _sizeShoes = '';

  bool _loading = true;
  bool _saving = false;
  String? _avatarUrl;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await _profileService.getUserProfile();
    if (p != null) {
      _fullName.text = (p['full_name'] ?? p['name'] ?? '').toString();
      _displayName.text = (p['name'] ?? '').toString();
      _email.text = (p['email'] ?? '').toString();
      _phone.text = (p['phone_number'] ?? '').toString();
      _dob.text = (p['date_of_birth'] ?? '').toString();
      _bio.text = (p['bio'] ?? '').toString();
      _gender = (p['gender'] ?? _gender).toString();
      _avatarUrl = (p['profile_picture_url'] ?? p['avatar_url'])?.toString();
      final prefs = (p['preferences'] as Map<String, dynamic>?) ?? {};
      final sizes = (prefs['sizes'] as Map<String, dynamic>?) ?? {};
      _sizeTops = (sizes['tops'] ?? '').toString();
      _sizeBottoms = (sizes['bottoms'] ?? '').toString();
      _sizeShoes = (sizes['shoes'] ?? '').toString();
      final notifications = (prefs['notifications'] as Map<String, dynamic>?) ?? {};
      _notifOrders = (notifications['orders'] ?? true) == true;
      _notifPromos = (notifications['promos'] ?? false) == true;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _displayName.dispose();
    _email.dispose();
    _phone.dispose();
    _dob.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Edit Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_saving || !_dirty) ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Save Changes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(w * 0.05),
                children: [
                  _avatarSection(w),
                  const SizedBox(height: 16),
                  _sectionTitle('Basic Info'),
                  _text(_fullName, 'Full Name', Icons.person_outline, required: true),
                  const SizedBox(height: 12),
                  _text(_displayName, 'Display Name (optional)', Icons.badge_outlined),
                  const SizedBox(height: 12),
                  _text(_email, 'Email', Icons.email_outlined, readOnly: true),

                  const SizedBox(height: 18),
                  _sectionTitle('Contact'),
                  _text(_phone, 'Phone (+63)', Icons.phone_outlined, required: true, keyboard: TextInputType.phone),

                  const SizedBox(height: 18),
                  _sectionTitle('Personal'),
                  _genderChips(),
                  const SizedBox(height: 8),
                  _dateField(context, _dob, 'Date of Birth'),
                  const SizedBox(height: 12),
                  _multiline(_bio, 'Bio (max 300 chars)'),

                  const SizedBox(height: 18),
                  _sectionTitle('Preferences'),
                  _sizesRow(),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _notifOrders,
                    onChanged: (v) => setState(() { _notifOrders = v; _dirty = true; }),
                    title: Text('Order updates', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                  SwitchListTile(
                    value: _notifPromos,
                    onChanged: (v) => setState(() { _notifPromos = v; _dirty = true; }),
                    title: Text('Promotions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _avatarSection(double w) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: w * 0.28,
                height: w * 0.28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  shape: BoxShape.circle,
                  image: _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                    ? Icon(Icons.person, size: w * 0.14, color: Colors.grey.shade500)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: const Color(0xFFD4A574),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _pickAvatar,
                    splashColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.2),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.edit, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
          if (_avatarUrl != null && _avatarUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() { _avatarUrl = ''; _dirty = true; }),
              child: const Text('Remove photo'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;
    setState(() => _saving = true);
    final url = await _profileService.uploadProfilePicture(image.path);
    if (!mounted) return;
    setState(() {
      _avatarUrl = url ?? _avatarUrl;
      _saving = false;
      _dirty = true;
    });
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
      );

  Widget _text(TextEditingController c, String label, IconData icon,
      {bool required = false, bool readOnly = false, TextInputType? keyboard}) {
    return TextFormField(
      controller: c,
      readOnly: readOnly,
      keyboardType: keyboard,
      onChanged: (_) => setState(() => _dirty = true),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFD4A574)),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black.withOpacity(0.35), fontWeight: FontWeight.w400),
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w500),
        floatingLabelStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFD4A574), fontWeight: FontWeight.w600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFFD4A574), width: 2)),
      ),
    );
  }

  Widget _multiline(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      maxLines: 4,
      maxLength: 300,
      onChanged: (_) => setState(() => _dirty = true),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: const Icon(Icons.notes_outlined, color: Color(0xFFD4A574)),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black.withOpacity(0.35), fontWeight: FontWeight.w400),
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w500),
        floatingLabelStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFD4A574), fontWeight: FontWeight.w600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFFD4A574), width: 2)),
      ),
    );
  }

  Widget _genderChips() {
    final options = ['Male', 'Female', 'Other', 'Prefer not to say'];
    return Wrap(
      spacing: 8,
      children: options.map((g) {
        final sel = _gender == g;
        return ChoiceChip(
          label: Text(g),
          selected: sel,
          onSelected: (_) => setState(() { _gender = g; _dirty = true; }),
          selectedColor: const Color(0xFFD4A574).withOpacity(0.15),
          labelStyle: GoogleFonts.poppins(
            color: sel ? const Color(0xFFD4A574) : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          shape: StadiumBorder(side: BorderSide(color: sel ? const Color(0xFFD4A574) : Colors.grey.shade300)),
        );
      }).toList(),
    );
  }

  Widget _sizesRow() {
    return Row(
      children: [
        Expanded(child: _sizesField('Tops', (v) => _sizeTops = v)),
        const SizedBox(width: 8),
        Expanded(child: _sizesField('Bottoms', (v) => _sizeBottoms = v)),
        const SizedBox(width: 8),
        Expanded(child: _sizesField('Shoes', (v) => _sizeShoes = v)),
      ],
    );
  }

  Widget _sizesField(String label, void Function(String) onChanged) {
    return TextFormField(
      initialValue: label == 'Tops' ? _sizeTops : label == 'Bottoms' ? _sizeBottoms : _sizeShoes,
      onChanged: (v) { onChanged(v); setState(() => _dirty = true); },
      decoration: InputDecoration(
        labelText: '$label size',
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black.withOpacity(0.35), fontWeight: FontWeight.w400),
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w500),
        floatingLabelStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFD4A574), fontWeight: FontWeight.w600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFFD4A574), width: 2)),
      ),
    );
  }

  Widget _dateField(BuildContext context, TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFFD4A574)),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFFD4A574), width: 2)),
      ),
      onTap: () async {
        final initial = DateTime.tryParse(c.text) ?? DateTime(2000, 1, 1);
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1900, 1, 1),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
        );
        if (picked != null) {
          c.text = picked.toIso8601String().split('T').first;
        }
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // basic PH phone validation
    final phone = _phone.text.trim();
    if (!RegExp(r'^\+?63\s?9\d{2}[\s-]?\d{3}[\s-]?\d{4}$').hasMatch(phone) &&
        !RegExp(r'^09\d{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a valid PH phone number', style: GoogleFonts.poppins())),
      );
      return;
    }

    setState(() => _saving = true);
    final prefs = {
      'sizes': {'tops': _sizeTops, 'bottoms': _sizeBottoms, 'shoes': _sizeShoes},
      'notifications': {'orders': _notifOrders, 'promos': _notifPromos},
    };
    final ok = await _profileService.updateProfile(
      fullName: _fullName.text.trim(),
      phoneNumber: phone,
      bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      dateOfBirth: _dob.text.trim().isEmpty ? null : _dob.text.trim(),
      gender: _gender,
      preferences: prefs,
      displayName: _displayName.text.trim().isEmpty ? null : _displayName.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated', style: GoogleFonts.poppins())),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile', style: GoogleFonts.poppins())),
      );
    }
  }
}
