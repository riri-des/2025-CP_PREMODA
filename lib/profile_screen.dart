import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'services/profile_service.dart';
import 'screens/orders_list_screen.dart';
import 'screens/addresses_list_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/privacy_settings_screen.dart';
import 'screens/terms_and_conditions_screen.dart';
import 'debug/quick_auth_test.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _logout() async {
    // Show loading toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text('Logging out...', style: GoogleFonts.poppins()),
          ],
        ),
        backgroundColor: const Color(0xFFD4A574),
      ),
    );

    // Call service
    await _profileService.signOut();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged out successfully!', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );

    // Redirect to login screen using named routes
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
  
  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final profile = await _profileService.getUserProfile();
      if (profile != null) {
        setState(() {
          userData = profile;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No user logged in. Please sign in to view your profile.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading profile: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  String _getMembershipDisplay(String? status) {
    if (status == null) return 'Standard Member';
    switch (status.toLowerCase()) {
      case 'premium':
        return 'Premium Member';
      case 'vip':
        return 'VIP Member';
      default:
        return 'Standard Member';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(screenWidth, screenHeight),
              
              // Profile Content
              Expanded(
                child: isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFFD4A574),
                      ),
                    )
                    : errorMessage != null
                        ? Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                // Auth Status Widget
                                const QuickAuthTest(),
                                const SizedBox(height: 24),
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  errorMessage!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadUserProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4A574),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUserProfile,
                            color: const Color(0xFFD4A574),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                // Profile Info Card
                                _buildProfileInfoCard(screenWidth, screenHeight),
                                
                                // Quick Stats
                                _buildQuickStats(screenWidth, screenHeight),
                                
                                // Menu Options
                                _buildMenuOptions(screenWidth, screenHeight),
                                
                                // Account Settings
                                _buildAccountSettings(screenWidth, screenHeight),
                                
                                // Logout Button
                                _buildLogoutButton(screenWidth, screenHeight),
                                
                                // Bottom padding
                                SizedBox(height: screenHeight * 0.02),
                                ],
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.06, screenWidth * 0.04, screenWidth * 0.04),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8BB8F),
            Color(0xFFD4A574),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button (optional - since this is in bottom nav)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.menu_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          
          // Title
          Expanded(
            child: Text(
              'My Profile',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          
          // Settings button
          GestureDetector(
            onTap: () {
              _showSettingsDialog();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.settings_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileInfoCard(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile picture with edit button
          Stack(
            children: [
              Container(
                width: screenWidth * 0.22,
                height: screenWidth * 0.22,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFD4A574).withValues(alpha: 0.8),
                      const Color(0xFFD4A574),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.11),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4A574).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: userData?['profile_picture_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.11),
                        child: Image.network(
                          userData!['profile_picture_url'],
                          width: screenWidth * 0.22,
                          height: screenWidth * 0.22,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                _getInitials(userData?['name']),
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.08,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          _getInitials(userData?['name']),
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    _showImagePickerDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: const Color(0xFFD4A574),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: screenWidth * 0.04),
          
          // Name and email
          Text(
            userData?['full_name'] ?? userData?['name'] ?? 'User',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 4),
          
          Text(
            userData?['email'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.032,
              fontWeight: FontWeight.w400,
              color: Colors.grey.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: screenWidth * 0.04),
          
          // User details
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDetailRow('User ID:', userData?['id']?.toString().substring(0, 13) ?? 'N/A', Icons.badge_rounded),
                SizedBox(height: 8),
                _buildDetailRow('Joined:', _formatDate(userData?['created_at']), Icons.calendar_today_rounded),
                SizedBox(height: 8),
                _buildDetailRow('Status:', _getMembershipDisplay(userData?['membership_status']), Icons.star_rounded, isSpecial: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon, {bool isSpecial = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isSpecial ? Colors.amber : const Color(0xFFD4A574),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSpecial ? Colors.amber.shade700 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickStats(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Orders',
              userData?['total_orders']?.toString() ?? '0',
              Icons.shopping_bag_outlined,
              const Color(0xFFD4A574),
              screenWidth,
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: _buildStatCard(
              'Wishlist',
              userData?['wishlist_count']?.toString() ?? '0',
              Icons.favorite_border,
              const Color(0xFFD4A574),
              screenWidth,
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: _buildStatCard(
              'Reviews',
              userData?['review_count']?.toString() ?? '0',
              Icons.rate_review_outlined,
              const Color(0xFFD4A574),
              screenWidth,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.025,
              fontWeight: FontWeight.w500,
              color: Colors.grey.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuOptions(double screenWidth, double screenHeight) {
    final menuItems = [
      {'title': 'Order History', 'icon': Icons.receipt_long_outlined, 'color': const Color(0xFFD4A574)},
      {'title': 'My Addresses', 'icon': Icons.location_on_outlined, 'color': const Color(0xFFD4A574)},
    ];
    
    return Container(
      margin: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04, 0),
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Text(
              'Menu',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          ...menuItems.map((item) => _buildMenuItem(
            item['title'] as String,
            item['icon'] as IconData,
            item['color'] as Color,
            screenWidth,
          )),
        ],
      ),
    );
  }
  
  Widget _buildMenuItem(String title, IconData icon, Color color, double screenWidth) {
    return GestureDetector(
      onTap: () {
        _handleMenuTap(title);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenWidth * 0.035,
        ),
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAccountSettings(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Text(
              'Account Settings',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          _buildMenuItem('Edit Profile', Icons.person_outline, const Color(0xFFD4A574), screenWidth),
          _buildMenuItem('Privacy Settings', Icons.security_outlined, const Color(0xFFD4A574), screenWidth),
          _buildMenuItem('Terms & Conditions', Icons.description_outlined, const Color(0xFFD4A574), screenWidth),
          _buildMenuItem('Delete Account', Icons.delete_outline, const Color(0xFFF44336), screenWidth),
        ],
      ),
    );
  }
  
  Widget _buildLogoutButton(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showLogoutDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF44336),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: const Color(0xFFF44336).withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              'Log Out',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleMenuTap(String title) {
    if (title == 'Order History') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OrdersListScreen()),
      );
      return;
    }
    if (title == 'My Addresses') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddressesListScreen()),
      );
      return;
    }
    if (title == 'Edit Profile') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
      ).then((saved) {
        if (saved == true) {
          _loadUserProfile();
        }
      });
      return;
    }
    if (title == 'Privacy Settings') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()),
      );
      return;
    }
    if (title == 'Terms & Conditions' || title == 'Terms and Conditions') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
      );
      return;
    }
    // Default feedback for other items (placeholder)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title feature coming soon!', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFD4A574),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.dark_mode_rounded),
                title: Text('Dark Mode', style: GoogleFonts.poppins()),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // Handle dark mode toggle
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.notifications_rounded),
                title: Text('Push Notifications', style: GoogleFonts.poppins()),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // Handle notifications toggle
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD4A574),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Change Profile Picture',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: const Color(0xFFD4A574)),
                title: Text('Take Photo', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.of(context).pop();
                  // Handle camera
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: const Color(0xFFD4A574)),
                title: Text('Choose from Gallery', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.of(context).pop();
                  // Handle gallery
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Log Out',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Log Out', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}
