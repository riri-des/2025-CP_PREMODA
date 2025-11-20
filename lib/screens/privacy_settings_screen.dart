import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/profile_service.dart';
import 'dart:async';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});
  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final ProfileService _profile = ProfileService();
  bool _loading = true, _saving = false, _dirty = false;
  Map<String, dynamic> _basePrefs = {};
  bool _recs = true, _recent = true, _history = true; // personalization
  bool _usage = true, _crash = true; // analytics
  bool _discover = false, _reviewsName = true; // visibility
  bool _orders = true, _promos = false; // notifications
  // Section enable flags (do not overwrite child values; only disable UI)
  bool _personalEnabled = true;
  bool _analyticsEnabled = true;
  bool _visibilityEnabled = true;
  bool _notificationsEnabled = true;
  Timer? _debouncer;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await _profile.getUserProfile();
    final prefs = (p?['preferences'] as Map<String, dynamic>?) ?? {};
    final privacy = (prefs['privacy'] as Map<String, dynamic>?) ?? {};
    final pers = (privacy['personalization'] as Map<String, dynamic>?) ?? {};
    final anal = (privacy['analytics'] as Map<String, dynamic>?) ?? {};
    final vis = (privacy['visibility'] as Map<String, dynamic>?) ?? {};
    final notif = (prefs['notifications'] as Map<String, dynamic>?) ?? {};
    setState(() {
      _basePrefs = Map.of(prefs);
      _recs = (pers['recommendations'] ?? _recs) == true;
      _recent = (pers['recent'] ?? _recent) == true;
      _history = (pers['history'] ?? _history) == true;
      _usage = (anal['usage'] ?? _usage) == true;
      _crash = (anal['crash'] ?? _crash) == true;
      _discover = (vis['discoverable'] ?? _discover) == true;
      _reviewsName = (vis['show_reviews_as_display_name'] ?? _reviewsName) == true;
      _orders = (notif['orders'] ?? _orders) == true;
      _promos = (notif['promos'] ?? _promos) == true;
      // default section enabled states reflect current children
      _personalEnabled = _recs || _recent || _history;
      _analyticsEnabled = _usage || _crash;
      _visibilityEnabled = _discover || _reviewsName;
      _notificationsEnabled = _orders || _promos;
      _loading = false; _dirty = false;
    });
  }

  Map<String, dynamic> _merged() {
    final prefs = Map<String, dynamic>.from(_basePrefs);
    prefs['notifications'] = { ...(prefs['notifications'] as Map<String, dynamic>? ?? {}), 'orders': _orders, 'promos': _promos };
    final privacy = Map<String, dynamic>.from(prefs['privacy'] as Map<String, dynamic>? ?? {});
    privacy['personalization'] = { ...(privacy['personalization'] as Map<String, dynamic>? ?? {}), 'recommendations': _recs, 'recent': _recent, 'history': _history };
    privacy['analytics'] = { ...(privacy['analytics'] as Map<String, dynamic>? ?? {}), 'usage': _usage, 'crash': _crash };
    privacy['visibility'] = { ...(privacy['visibility'] as Map<String, dynamic>? ?? {}), 'discoverable': _discover, 'show_reviews_as_display_name': _reviewsName };
    prefs['privacy'] = privacy; return prefs;
  }

  void _scheduleAutoSave() {
    _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 500), () async {
      final ok = await _profile.updateProfile(preferences: _merged());
      if (!mounted) return;
      if (ok) {
        setState(() => _dirty = false);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1), content: Text('Saved', style: GoogleFonts.poppins())),
        );
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await _profile.updateProfile(preferences: _merged());
    if (!mounted) return; setState(() { _saving = false; _dirty = !ok; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Saved' : 'Failed', style: GoogleFonts.poppins())));
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: Text('Privacy Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87), onPressed: () => Navigator.pop(context, false)),
        actions: [
          TextButton(
            onPressed: _loading ? null : () { _applyDefaults(); },
            child: Text('Restore', style: GoogleFonts.poppins(color: const Color(0xFFD4A574), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_saving || !_dirty) ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A574), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
              _sectionHeader(
                title: 'Personalization',
                infoText: 'Control how we personalize recommendations, show recently viewed, and use your order history to tailor the experience.',
                masterValue: _personalEnabled,
                onMasterChanged: (v){ setState((){ _personalEnabled = v; _dirty=true;}); _scheduleAutoSave(); },
              ),
              _card([
                _sectionTileWrapper(
                  enabled: _personalEnabled,
                  child: _tile(icon: Icons.recommend_outlined, title: 'Personalized recommendations', subtitle: 'Use your activity to tailor suggestions', value: _recs, onChanged: (v){ setState((){ _recs=v; _dirty=true;}); _scheduleAutoSave(); }),
                ),
                const Divider(height: 1, indent: 16, endIndent: 10),
                _sectionTileWrapper(
                  enabled: _personalEnabled,
                  child: _tile(icon: Icons.history_outlined, title: 'Show recently viewed items', value: _recent, onChanged: (v){ setState((){ _recent=v; _dirty=true;}); _scheduleAutoSave(); }),
                ),
                const Divider(height: 1, indent: 16, endIndent: 10),
                _sectionTileWrapper(
                  enabled: _personalEnabled,
                  child: _tile(icon: Icons.receipt_long_outlined, title: 'Use order history', value: _history, onChanged: (v){ setState((){ _history=v; _dirty=true;}); _scheduleAutoSave(); }),
                ),
              ]),
              const SizedBox(height: 12),
              _sectionHeader(
                title: 'Analytics',
                infoText: 'Help us improve by sending anonymous usage analytics and crash reports. These never include personal data.',
                masterValue: _analyticsEnabled,
                onMasterChanged: (v){ setState((){ _analyticsEnabled = v; _dirty=true;}); _scheduleAutoSave(); },
              ),
              _card([
                _sectionTileWrapper(
                  enabled: _analyticsEnabled,
                  child: _tile(icon: Icons.bar_chart_outlined, title: 'Usage analytics', subtitle: 'Share anonymous usage statistics', value: _usage, onChanged: (v){ setState((){ _usage=v; _dirty=true;}); _scheduleAutoSave(); }),
                ),
                const Divider(height: 1, indent: 16, endIndent: 10),
                _sectionTileWrapper(
                  enabled: _analyticsEnabled,
                  child: _tile(icon: Icons.report_gmailerrorred_outlined, title: 'Crash reports', value: _crash, onChanged: (v){ setState((){ _crash=v; _dirty=true;}); _scheduleAutoSave(); }),
                ),
              ]),
              const SizedBox(height: 12),
              _sectionHeader(
                title: 'Visibility',
                infoText: 'Control if your profile is discoverable and how your name appears on product reviews.',
                masterValue: _visibilityEnabled,
                onMasterChanged: (v){ setState((){ _visibilityEnabled = v; _dirty=true;}); _scheduleAutoSave(); },
              ),
              _card([
                _sectionTileWrapper(
                  enabled: _visibilityEnabled,
                  child: _tile(icon: Icons.visibility_outlined, title: 'Discoverable profile', subtitle: 'Allow others to find your profile (future feature)', value: _discover, onChanged: (v){ setState((){ _discover=v; _dirty=true;}); _scheduleAutoSave(); }),
                ),
                const Divider(height: 1, indent: 16, endIndent: 10),
                _sectionTileWrapper(
                  enabled: _visibilityEnabled,
                  child: _tile(icon: Icons.reviews_outlined, title: 'Show reviews as display name', value: _reviewsName, onChanged: (v){ setState((){ _reviewsName=v; _dirty=true;}); _scheduleAutoSave(); }),
                ),
              ]),
              const SizedBox(height: 12),
              _sectionHeader(
                title: 'Notifications',
                infoText: 'Choose which notifications you receive. Order updates are recommended for delivery and status changes.',
                masterValue: _notificationsEnabled,
                onMasterChanged: (v){ setState((){ _notificationsEnabled = v; _dirty=true;}); _scheduleAutoSave(); },
              ),
              _card([
                _sectionTileWrapper(
                  enabled: _notificationsEnabled,
                  child: _tile(icon: Icons.notifications_active_outlined, title: 'Order updates', subtitle: 'Transactional notifications', value: _orders, onChanged: (v){ setState((){ _orders=v; _dirty=true;}); _scheduleAutoSave(); }),
                ),
                const Divider(height: 1, indent: 16, endIndent: 10),
                _sectionTileWrapper(
                  enabled: _notificationsEnabled,
                  child: _tile(icon: Icons.campaign_outlined, title: 'Promotions', value: _promos, onChanged: (v){ setState((){ _promos=v; _dirty=true;}); _scheduleAutoSave(); }),
                ),
              ]),
              const SizedBox(height: 12),
              _dangerZone(),
            ]),
    );
  }

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
    child: Column(children: children),
  );

  Widget _sectionHeader({required String title, required String infoText, required bool masterValue, required ValueChanged<bool> onMasterChanged}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(children: [
        Expanded(child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
        IconButton(
          tooltip: 'Learn more',
          onPressed: () => _showInfo(infoText),
          icon: const Icon(Icons.info_outline, color: Color(0xFFD4A574)),
        ),
        Switch(value: masterValue, onChanged: (v){ onMasterChanged(v); }),
      ]),
    );
  }

  Widget _tile({required String title, String? subtitle, required bool value, required ValueChanged<bool> onChanged, IconData? icon}) => SwitchListTile(
    title: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: const Color(0xFFD4A574)),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      ],
    ),
    subtitle: subtitle==null?null:Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
    value: value,
    onChanged: (v){ onChanged(v); },
    activeColor: const Color(0xFFD4A574),
  );

  Widget _sectionTileWrapper({required bool enabled, required Widget child}) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: IgnorePointer(ignoring: !enabled, child: child),
    );
  }

  void _showInfo(String text) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About this setting', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(text, style: GoogleFonts.poppins()),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            )
          ],
        ),
      ),
    );
  }

  Widget _dangerZone() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Danger zone', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.red.shade700)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            final ok = await _confirm('Sign out?','You will be signed out on this device.');
            if (ok) { await _profile.signOut(); if (mounted) Navigator.pop(context, true); }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red.shade800),
          icon: const Icon(Icons.logout),
          label: Text('Sign out'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            final ok = await _confirm('Delete account?','This will permanently delete your account and data. This action cannot be undone.');
            if (ok) {
              final res = await _profile.deleteAccount();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res ? 'Account deleted' : 'Failed to delete', style: GoogleFonts.poppins())));
                if (res) Navigator.pop(context, true);
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red.shade900),
          icon: const Icon(Icons.delete_forever),
          label: const Text('Delete account'),
        ),
      ]),
    );
  }

  Future<bool> _confirm(String title, String message) async {
    final ans = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );
    return ans == true;
  }

  void _applyDefaults() {
    setState(() {
      _recs = true; _recent = true; _history = true;
      _usage = true; _crash = true;
      _discover = false; _reviewsName = true;
      _orders = true; _promos = false;
      _dirty = true;
    });
  }
}
