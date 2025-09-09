import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'category_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'models/product_model.dart';
import 'services/product_service.dart';
import 'services/cart_service.dart';
import 'widgets/product_card.dart';
import 'widgets/new_collection_grid_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _heroSliderController;
  late PageController _heroPageController;
  int _currentHeroPage = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _heroSliderController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _heroPageController = PageController();
    
    // Auto slide products every 3 seconds
    _heroSliderController.addListener(() {
      if (_heroSliderController.status == AnimationStatus.completed) {
        _heroSliderController.reset();
      }
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _heroSliderController.dispose();
    _heroPageController.dispose();
    super.dispose();
  }
  
  // Helper method to add product to cart
  void _addToCart(Product product) {
    try {
      // For now, just show a snackbar. In a full implementation, 
      // you would add the product to a cart state management system
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${product.name} added to cart!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _currentIndex = 2; // Navigate to cart
              });
              _pageController.animateToPage(
                2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add to cart',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Helper method to toggle favorite status
  void _toggleFavorite(Product product) {
    try {
      // For now, just show a snackbar. In a full implementation,
      // you would implement favorites functionality with state management
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added ${product.name} to favorites!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFE91E63),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update favorites',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    return Column(
      children: [
        // Main hero container
        Container(
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
                // Hero background with gradient
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
                ),
                
                // Product images slider
                Center(
                  child: FutureBuilder<List<Product>>(
                    future: ProductService().getNewArrivalProducts(limit: 5),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLoadingPlaceholder(screenWidth * 0.15, screenHeight * 0.18),
                            _buildLoadingPlaceholder(screenWidth * 0.18, screenHeight * 0.20),
                            _buildLoadingPlaceholder(screenWidth * 0.16, screenHeight * 0.19),
                          ],
                        );
                      }
                      
                      final products = snapshot.data ?? [];
                      
                      if (products.isEmpty) {
                        // Fallback to silhouettes if no products
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildModelSilhouette(screenWidth * 0.15, screenHeight * 0.18, const Color(0xFFD4A574)),
                            _buildModelSilhouette(screenWidth * 0.18, screenHeight * 0.20, const Color(0xFFB8956A)),
                            _buildModelSilhouette(screenWidth * 0.16, screenHeight * 0.19, const Color(0xFFC4956A)),
                          ],
                        );
                      }
                      
                      return _buildProductImageSlider(products, screenWidth, screenHeight);
                    },
                  ),
                ),
                
                // Enhanced clickable overlay badge
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      // Show new collection grid slider in a modal bottom sheet
                      _showNewCollectionSlider(context, screenWidth, screenHeight);
                    },
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
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Method to show new collection slider in modal bottom sheet
  void _showNewCollectionSlider(BuildContext context, double screenWidth, double screenHeight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: screenHeight * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F8F8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            // Close button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: const Color(0xFFD4A574),
                        size: screenWidth * 0.05,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'New Collection',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // New collection grid slider
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: FutureBuilder<List<Product>>(
                  future: ProductService().getNewArrivalProducts(limit: 12),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFFD4A574),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading New Collection...',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.grey,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Unable to load new collection',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4A574),
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final products = snapshot.data ?? [];
                    
                    if (products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No new collection items available',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return NewCollectionGridSlider(
                      products: products,
                      height: double.infinity,
                      onProductTap: (product) {
                        Navigator.pop(context);
                        ProductService().incrementProductViews(product.id);
                        print('Navigate to new collection product: ${product.name}');
                      },
                      onAddToCart: (product) {
                        Navigator.pop(context);
                        _addToCart(product);
                      },
                      onFavoriteToggle: (product) {
                        _toggleFavorite(product);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build animated product image slider
  Widget _buildProductImageSlider(List<Product> products, double screenWidth, double screenHeight) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AnimatedBuilder(
          animation: _heroSliderController,
          builder: (context, child) {
            // Calculate current product index based on animation progress
            final currentProductIndex = (_heroSliderController.value * products.length).floor() % products.length;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left product
                _buildAnimatedProductImage(
                  products[(currentProductIndex) % products.length],
                  screenWidth * 0.15,
                  screenHeight * 0.18,
                  0.0,
                ),
                // Center product (larger)
                _buildAnimatedProductImage(
                  products[(currentProductIndex + 1) % products.length],
                  screenWidth * 0.18,
                  screenHeight * 0.20,
                  0.3,
                ),
                // Right product
                _buildAnimatedProductImage(
                  products[(currentProductIndex + 2) % products.length],
                  screenWidth * 0.16,
                  screenHeight * 0.19,
                  0.6,
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Build individual animated product image
  Widget _buildAnimatedProductImage(Product product, double width, double height, double animationOffset) {
    return AnimatedBuilder(
      animation: _heroSliderController,
      builder: (context, child) {
        // Calculate scale and opacity based on animation
        final progress = (_heroSliderController.value + animationOffset) % 1.0;
        final scale = 0.8 + (0.2 * (1 - (progress * 2 - 1).abs()));
        final opacity = 0.6 + (0.4 * (1 - (progress * 2 - 1).abs()));
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.images.isNotEmpty
                    ? Image.network(
                        product.primaryImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildProductPlaceholder(width, height, product);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildProductPlaceholder(width, height, product);
                        },
                      )
                    : _buildProductPlaceholder(width, height, product),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Build product placeholder with category-based styling
  Widget _buildProductPlaceholder(double width, double height, Product product) {
    final color = _getCategoryColor(product.category);
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
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(product.category),
          color: Colors.white.withValues(alpha: 0.9),
          size: width * 0.4,
        ),
      ),
    );
  }
  
  // Build loading placeholder
  Widget _buildLoadingPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4A574).withValues(alpha: 0.3),
            const Color(0xFFD4A574).withValues(alpha: 0.5),
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
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }
  
  // Helper to get color based on category
  Color _getCategoryColor(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('women')) return const Color(0xFF8B7355);
    if (lowerCategory.contains('men')) return const Color(0xFFE8A87C);
    if (lowerCategory.contains('dress')) return const Color(0xFF5C9EAD);
    if (lowerCategory.contains('summer')) return const Color(0xFFD4A574);
    if (lowerCategory.contains('winter')) return const Color(0xFF85CDCA);
    if (lowerCategory.contains('accessory') || lowerCategory.contains('accessories')) return const Color(0xFFE27D60);
    if (lowerCategory.contains('shoe') || lowerCategory.contains('footwear')) return const Color(0xFF41B3A3);
    return const Color(0xFFD4A574); // Default color
  }

  // Helper to get icon based on category
  IconData _getCategoryIcon(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('women')) return Icons.woman_rounded;
    if (lowerCategory.contains('men')) return Icons.man_rounded;
    if (lowerCategory.contains('dress')) return Icons.checkroom_rounded;
    if (lowerCategory.contains('summer')) return Icons.beach_access_rounded;
    if (lowerCategory.contains('winter')) return Icons.snowing;
    if (lowerCategory.contains('accessory') || lowerCategory.contains('accessories')) return Icons.watch;
    if (lowerCategory.contains('shoe') || lowerCategory.contains('footwear')) return Icons.skateboarding;
    return Icons.checkroom_rounded; // Default icon
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
  
  Widget _buildNewCollectionSection(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: FutureBuilder<List<Product>>(
        future: ProductService().getNewArrivalProducts(limit: 12),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 380,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFD4A574),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading New Collection...',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Container(
              height: 380,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Unable to load new collection',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Trigger rebuild
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A574),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          final products = snapshot.data ?? [];
          
          if (products.isEmpty) {
            return Container(
              height: 380,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No new collection items available',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return NewCollectionGridSlider(
            products: products,
            height: 380,
            onProductTap: (product) {
              // Navigate to product details
              ProductService().incrementProductViews(product.id);
              print('Navigate to new collection product: ${product.name}');
            },
            onAddToCart: (product) {
              _addToCart(product);
            },
            onFavoriteToggle: (product) {
              _toggleFavorite(product);
            },
          );
        },
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
        
        // Product cards from database
        SizedBox(
          height: screenHeight * 0.32,
          child: FutureBuilder<List<Product>>(
            future: ProductService().getRecommendedProducts(limit: 8),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  itemCount: 3, // Show 3 loading placeholders
                  itemBuilder: (context, index) {
                    return Container(
                      width: screenWidth * 0.42,
                      margin: EdgeInsets.only(right: screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4A574),
                        ),
                      ),
                    );
                  },
                );
              }
              
              if (snapshot.hasError) {
                return Container(
                  height: screenHeight * 0.32,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.grey,
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Unable to load products',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Trigger rebuild
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A574),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final products = snapshot.data ?? [];
              
              if (products.isEmpty) {
                return Container(
                  height: screenHeight * 0.32,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey,
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No products available',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    margin: EdgeInsets.only(
                      right: index < products.length - 1 ? screenWidth * 0.03 : 0,
                    ),
                    child: ProductCard(
                      product: product,
                      width: screenWidth * 0.42,
                      height: screenHeight * 0.32,
                      onTap: () {
                        // Navigate to product details
                        ProductService().incrementProductViews(product.id);
                        // TODO: Navigate to product details screen
                        print('Navigate to product: ${product.name}');
                      },
                      onAddToCart: () {
                        // Add to cart
                        _addToCart(product);
                      },
                      onFavoriteToggle: () {
                        // Toggle favorite status
                        _toggleFavorite(product);
                      },
                    ),
                  );
                },
              );
            },
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
    bool isCartIcon = index == 2; // Cart is at index 2
    
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
            // Cart icon with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.black87 : Colors.grey.withValues(alpha: 0.6),
                  size: 24,
                ),
                // Cart notification bubble
                if (isCartIcon)
                  ListenableBuilder(
                    listenable: CartService(),
                    builder: (context, child) {
                      final cartService = CartService();
                      if (cartService.itemCount == 0) {
                        return const SizedBox.shrink();
                      }
                      
                      return Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A574),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            cartService.itemCount > 99 
                                ? '99+' 
                                : cartService.itemCount.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
              ],
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
