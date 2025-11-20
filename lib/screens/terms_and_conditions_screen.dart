import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/profile_service.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  final bool requireAcceptance; // Kapoy na ako
  const TermsAndConditionsScreen({super.key, this.requireAcceptance = false});

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final ProfileService _profile = ProfileService();
  bool _agree = false;
  bool _saving = false;

  static const String _version = '1.0.0';
  static const String _lastUpdated = '2025-10-24';

  final sections = const [
    (
      'Introduction & Acceptance',
      'Welcome to PREMODA. By accessing or using our app and services, you agree to these Terms and our Privacy Policy.'
    ),
    (
      'Account & Eligibility',
      'Provide accurate information and keep your credentials secure. We may suspend accounts for suspected misuse.'
    ),
    (
      'Products & Pricing',
      'We strive for accuracy but errors may occur. Colors on-screen may vary. Prices and availability are subject to change.'
    ),
    (
      'Orders & Payments',
      'Orders are offers to purchase. We may accept or cancel at our discretion. Taxes and payment processor terms may apply.'
    ),
    (
      'Shipping & Delivery',
      'Estimated timelines are not guarantees. Risk of loss transfers on delivery. Ensure your address is accurate.'
    ),
    (
      'Returns, Exchanges, Refunds',
      'Items must be in original condition within the stated window. Certain categories may be non-returnable.'
    ),
    (
      'Virtual Try-On Disclaimer',
      'VTO is for visualization only and does not guarantee fit, size, or color. Do not upload infringing or inappropriate images.'
    ),
    (
      'User Content & Reviews',
      'You are responsible for your reviews and images. We may moderate or remove content that violates our guidelines.'
    ),
    (
      'Promotions & Loyalty',
      'Promo codes are limited, non-transferable, and may not be combined unless stated. We may modify or terminate offers.'
    ),
    (
      'Intellectual Property',
      'All app content and trademarks are owned by PREMODA or licensors. Limited personal, non-commercial license granted.'
    ),
    (
      'Acceptable Use',
      'No scraping, reverse engineering, security breaches, or abusive behavior.'
    ),
    (
      'Third-party Links & Services',
      'We are not responsible for third-party sites and services you access from the app.'
    ),
    (
      'Warranties & Liability',
      'The app is provided “as-is” with no implied warranties to the extent permitted by law. Liability is limited.'
    ),
    (
      'Governing Law & Disputes',
      'These Terms are governed by the laws of the Philippines. Venue and/or arbitration terms may apply.'
    ),
    (
      'Changes to Terms',
      'We may update these Terms. Continued use after changes constitutes acceptance.'
    ),
    (
      'Contact',
      'For support, contact us at support@premoda.example.'
    ),
  ];

  Future<void> _accept() async {
    setState(() => _saving = true);
    final prefs = {
      'legal': {
        'terms_version': _version,
        'terms_accepted_at': DateTime.now().toIso8601String(),
      }
    };
    final ok = await _profile.updateProfile(preferences: prefs);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record acceptance', style: GoogleFonts.poppins())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Terms & Conditions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      bottomNavigationBar: widget.requireAcceptance
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                color: Colors.white,
                child: Row(
                  children: [
                    Checkbox(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeColor: const Color(0xFFD4A574),
                    ),
                    Expanded(
                      child: Text('I have read and agree to the Terms & Conditions', style: GoogleFonts.poppins(fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: (!_agree || _saving) ? null : _accept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A574),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _saving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Agree', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
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
                      child: Text('Version $_version', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFFD4A574))),
                    ),
                    const SizedBox(width: 8),
                    Text('Last updated: $_lastUpdated', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Please read these Terms carefully before using PREMODA.', style: GoogleFonts.poppins()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...sections.map((s) => _sectionTile(s.$1, s.$2)).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTile(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          trailing: const Icon(Icons.keyboard_arrow_down_rounded),
          collapsedBackgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          children: [
            Text(body, style: GoogleFonts.poppins(height: 1.5, color: Colors.grey.shade800)),
          ],
        ),
      ),
    );
  }
}
