import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

/// Quick test widget to check if user is logged in
/// Add this to your app temporarily to debug
class QuickAuthTest extends StatelessWidget {
  const QuickAuthTest({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.isLoggedIn();
    final currentUser = AuthService.getCurrentUser();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLoggedIn ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLoggedIn ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLoggedIn ? Icons.check_circle : Icons.error,
            color: isLoggedIn ? Colors.green : Colors.red,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            isLoggedIn ? 'USER LOGGED IN ✓' : 'NO USER LOGGED IN ✗',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isLoggedIn ? Colors.green[900] : Colors.red[900],
            ),
          ),
          if (currentUser != null) ...[
            const SizedBox(height: 8),
            Text(
              'Email: ${currentUser.email}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            Text(
              'ID: ${currentUser.id.substring(0, 8)}...',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Please login to view profile',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
