import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'category_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Home Page
          SafeArea(
            child: Column(
              children: [
                // Header with PREMODA title and search
                _buildHeader(screenWidth, screenHeight),
                
                // Main content with scroll
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Hero section with main image
                        _buildHeroSection(screenWidth, screenHeight),
                        
                        // Category tiles
                        _buildCategorySection(screenWidth, screenHeight),
                        
                        // For You section
                        _buildForYouSection(screenWidth, screenHeight),
                        
                        // Bottom padding to prevent overlap with bottom nav
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Category Page
          const CategoryScreen(),
          // Cart Page
          const CartScreen(),
          // Profile Page
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: _buildBottomNavigationBar(screenWidth),
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
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // PREMODA title
          Text(
            'PREMODA',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.065,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2.5,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
          
          SizedBox(height: screenHeight * 0.018),
          
          // Search bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.035,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Search here',
                hintStyle: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: const Color(0xFFD4A574),
                  size: 22,
                ),
                suffixIcon: Icon(
                  Icons.tune_rounded,
                  color: Colors.grey.withValues(alpha: 0.5),
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeroSection(double screenWidth, double screenHeight) {
    return Container(
      height: screenHeight * 0.32,
      width: screenWidth,
      margin: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.05, screenWidth * 0.04, screenWidth * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image placeholder with improved gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8F8F8),
                    Color(0xFFEEEEEE),
                    Color(0xFFE0E0E0),
                    Color(0xFFD6D6D6),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Simulate fashion models silhouettes with improved styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildModelSilhouette(screenWidth * 0.15, screenHeight * 0.18, const Color(0xFFD4A574)),
                        _buildModelSilhouette(screenWidth * 0.18, screenHeight * 0.20, const Color(0xFFB8956A)),
                        _buildModelSilhouette(screenWidth * 0.16, screenHeight * 0.19, const Color(0xFFC4956A)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Enhanced overlay badge
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xDD000000),
                      Color(0xBB000000),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'New Collection',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.028,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModelSilhouette(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color,
            color.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategorySection(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.03, screenWidth * 0.04, screenWidth * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCategoryTile('Women\'s\nApparel', const Color(0xFFD4A574), Icons.woman_2_rounded, screenWidth, screenHeight),
          _buildCategoryTile('Men\'s\nOutfit', const Color(0xFFB8956A), Icons.man_2_rounded, screenWidth, screenHeight),
          _buildCategoryTile('Outfits\nCollection', const Color(0xFFC4956A), Icons.checkroom_rounded, screenWidth, screenHeight),
        ],
      ),
    );
  }
  
  Widget _buildCategoryTile(String title, Color color, IconData icon, double screenWidth, double screenHeight) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Add haptic feedback and navigation here
        },
        child: Container(
          height: screenHeight * 0.12,
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.9),
                color,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: screenWidth * 0.06,
              ),
              SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.024,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildForYouSection(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // For You header
        Padding(
          padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: const Color(0xFFD4A574),
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'For You',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to view all
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.032,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD4A574),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: const Color(0xFFD4A574),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Product cards
        SizedBox(
          height: screenHeight * 0.32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            children: [
              _buildProductCard('Women\'s T-shirt', 'PHP 850.00', const Color(0xFF8B7355), Icons.woman_rounded, screenWidth, screenHeight),
              SizedBox(width: screenWidth * 0.03),
              _buildProductCard('Women\'s Dress', 'PHP 1,250.00', const Color(0xFF5C9EAD), Icons.checkroom_rounded, screenWidth, screenHeight),
              SizedBox(width: screenWidth * 0.03),
              _buildProductCard('Men\'s Shirt', 'PHP 950.00', const Color(0xFFE8A87C), Icons.man_rounded, screenWidth, screenHeight),
              SizedBox(width: screenWidth * 0.03),
              _buildProductCard('Summer Outfit', 'PHP 1,450.00', const Color(0xFFD4A574), Icons.beach_access_rounded, screenWidth, screenHeight),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildProductCard(String name, String price, Color color, IconData clothingIcon, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: () {
        // Navigate to product details
      },
      child: Container(
        width: screenWidth * 0.42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.4),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: screenWidth * 0.22,
                        height: screenHeight * 0.11,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withValues(alpha: 0.8),
                              color,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          clothingIcon,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: screenWidth * 0.08,
                        ),
                      ),
                    ),
                  ),
                  // Heart icon for favorites
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 16,
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Product details
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.032,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          price,
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFD4A574),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A574),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomNavigationBar(double screenWidth) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.shopping_bag_outlined, 'Shop', 0, screenWidth),
          _buildNavItem(Icons.grid_view_outlined, 'Category', 1, screenWidth),
          _buildNavItem(Icons.shopping_cart_outlined, 'Cart', 2, screenWidth),
          _buildNavItem(Icons.person_outline, 'Profile', 3, screenWidth),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, int index, double screenWidth) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black87 : Colors.grey.withValues(alpha: 0.6),
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.025,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.black87 : Colors.grey.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
