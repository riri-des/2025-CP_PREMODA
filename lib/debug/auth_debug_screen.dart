import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Debug screen to check Supabase authentication status
/// Use this to verify if a user is logged in and see their details
class AuthDebugScreen extends StatefulWidget {
  const AuthDebugScreen({super.key});

  @override
  State<AuthDebugScreen> createState() => _AuthDebugScreenState();
}

class _AuthDebugScreenState extends State<AuthDebugScreen> {
  final _supabase = Supabase.instance.client;
  User? currentUser;
  Session? currentSession;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    setState(() {
      currentUser = _supabase.auth.currentUser;
      currentSession = _supabase.auth.currentSession;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth Debug', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFD4A574),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auth Status
            _buildSection(
              'Authentication Status',
              currentUser != null ? 'LOGGED IN ✓' : 'NOT LOGGED IN ✗',
              currentUser != null ? Colors.green : Colors.red,
            ),

            const SizedBox(height: 24),

            // User Details
            if (currentUser != null) ...[
              _buildSection('User ID', currentUser!.id),
              _buildSection('Email', currentUser!.email ?? 'N/A'),
              _buildSection('Created At', currentUser!.createdAt),
              _buildSection('Last Sign In', currentUser!.lastSignInAt ?? 'N/A'),
              _buildSection('Phone', currentUser!.phone ?? 'N/A'),
              
              const SizedBox(height: 16),
              Text(
                'User Metadata',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentUser!.userMetadata?.toString() ?? 'No metadata',
                  style: GoogleFonts.robotoMono(fontSize: 12),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'App Metadata',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentUser!.appMetadata.toString(),
                  style: GoogleFonts.robotoMono(fontSize: 12),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                'No user is currently logged in.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'To test the profile screen, you need to:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('1. Create a login/signup screen'),
              _buildBulletPoint('2. Use Supabase Auth to sign in'),
              _buildBulletPoint('3. Then navigate to the profile screen'),
            ],

            const SizedBox(height: 24),

            // Session Details
            if (currentSession != null) ...[
              Text(
                'Session Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildSection('Access Token', '${currentSession!.accessToken.substring(0, 20)}...'),
              _buildSection('Token Type', currentSession!.tokenType ?? 'N/A'),
              _buildSection('Expires At', currentSession!.expiresAt?.toString() ?? 'N/A'),
            ],

            const SizedBox(height: 24),

            // Refresh Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _checkAuth,
                icon: const Icon(Icons.refresh),
                label: Text('Refresh Auth Status', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A574),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sign Out Button (if logged in)
            if (currentUser != null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _supabase.auth.signOut();
                    _checkAuth();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Signed out successfully',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: Text('Sign Out', style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: valueColor ?? Colors.black87,
              fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.poppins(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
