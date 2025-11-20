import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/product_service.dart';
import 'services/supabase_cart_service.dart';
import 'models/product_model.dart';
import 'widgets/product_card.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedCategoryIndex = 0; // 0 = Women's, 1 = Men's, 2 = Kid's
  
  final List<String> categories = ['Women\'s', 'Men\'s', 'Kid\'s'];
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = false;
  List<String> _availableCategories = [];
  
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final cats = await _productService.getCategories();
      setState(() {
        _availableCategories = cats;
      });
    } catch (_) {}
    _loadProducts();
  }

  Widget _modalImagePlaceholder(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4A574).withValues(alpha: 0.25),
            const Color(0xFFD4A574).withValues(alpha: 0.45),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: screenWidth * 0.2,
          height: screenWidth * 0.2,
          decoration: BoxDecoration(
            color: const Color(0xFFD4A574),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.checkroom_rounded,
            color: Colors.white,
            size: screenWidth * 0.12,
          ),
        ),
      ),
    );
  }

  void _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Resolve selected tab to an exact category present in DB if possible
      final String token = _selectedCategoryIndex == 0
          ? 'women'
          : _selectedCategoryIndex == 1
              ? 'men'
              : 'kid';

      String resolvedCategory = _resolveExactCategory(token);

      // Fetch filtered products by resolved category
      final products = await _productService.getProducts(
        category: resolvedCategory.isNotEmpty ? resolvedCategory : token,
        limit: 20,
      );
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _resolveExactCategory(String token) {
    if (_availableCategories.isEmpty) return '';
    final lowerToken = token.toLowerCase();
    String? match = _availableCategories.firstWhere(
      (c) {
        final lc = (c ?? '').toString().toLowerCase();
        if (lowerToken == 'women') {
          return lc.contains('women') || lc.contains('woman') || lc.contains('lady') || lc.contains('female');
        } else if (lowerToken == 'men') {
          // ensure it doesn't contain women
          return (lc.startsWith('men') || lc.contains("men'") || lc.contains('mens') || lc.contains('male')) && !lc.contains('wom');
        } else {
          return lc.contains('kid') || lc.contains('child');
        }
      },
      orElse: () => '',
    );
    return match ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header with PREMODA title and search
            _buildHeader(screenWidth, screenHeight),
            
            // Category selection buttons
            _buildCategorySelector(screenWidth, screenHeight),
            
            // Main content with scroll
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Category title removed as requested
                    // Promo banner
                    _buildPromoBanner(screenWidth),
                    // Sort & Filter bar
                    _buildSortFilterBar(screenWidth),
                    
                    // Product grid
                    _buildProductGrid(screenWidth, screenHeight),
                    
                    // Bottom padding
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
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
  
  Widget _buildCategorySelector(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: categories.asMap().entries.map((entry) {
          int index = entry.key;
          String category = entry.value;
          bool isSelected = _selectedCategoryIndex == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
                // Reload products when category changes
                _loadProducts();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4A574) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFFD4A574).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Text(
                  category,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildCategoryHeader(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 0, screenWidth * 0.04, screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          Text(
            '${categories[_selectedCategoryIndex]} Apparel',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Small category icons row
          Row(
            children: [
              _buildSmallCategoryIcon('T-shirts', Icons.checkroom_rounded, screenWidth),
              SizedBox(width: screenWidth * 0.06),
              _buildSmallCategoryIcon('Dresses', Icons.woman_rounded, screenWidth),
              SizedBox(width: screenWidth * 0.06),
              _buildSmallCategoryIcon('Skirts', Icons.label_rounded, screenWidth),
              SizedBox(width: screenWidth * 0.06),
              _buildSmallCategoryIcon('Shorts', Icons.crop_free_rounded, screenWidth),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSmallCategoryIcon(String label, IconData icon, double screenWidth) {
    return Column(
      children: [
        Container(
          width: screenWidth * 0.12,
          height: screenWidth * 0.12,
          decoration: BoxDecoration(
            color: const Color(0xFFD4A574),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: screenWidth * 0.05,
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.022,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProductGrid(double screenWidth, double screenHeight) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFD4A574)),
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
              SizedBox(height: 16),
              Text(
                'No products available',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Check back later for new arrivals!',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ProductCard(
            product: product,
            width: double.infinity,
            height: double.infinity,
            onTap: () => _showProductDetailModal(product),
            onAddToCart: () async {
              final cartService = SupabaseCartService();
              final success = await cartService.addToCart(product);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${product.name} added to cart!',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF4CAF50),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    action: SnackBarAction(
                      label: 'VIEW CART',
                      textColor: Colors.white,
                      onPressed: () {},
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEDD7C0), Color(0xFFD4A574)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 18,
              top: 18,
              right: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Arrivals',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: screenWidth * 0.05,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover the latest styles curated for you',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 14,
              left: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Shop now',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD4A574),
                    fontWeight: FontWeight.w700,
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortFilterBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 8, screenWidth * 0.04, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sort_rounded, size: 18, color: Color(0xFFD4A574)),
                  const SizedBox(width: 8),
                  Text(
                    'Sort by',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.tune_rounded, size: 18, color: Color(0xFFD4A574)),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetailModal(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildProductDetailModal(product);
      },
    );
  }

  Widget _buildProductDetailModal(Product product) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    String imageUrl = product.images.isNotEmpty ? product.images.first.url : '';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Container(
                        height: screenHeight * 0.4,
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _modalImagePlaceholder(screenWidth);
                                  },
                                )
                              : _modalImagePlaceholder(screenWidth),
                        ),
                      ),
                      
                      // Product Info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name and Category
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: screenWidth * 0.06,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        product.category,
                                        style: GoogleFonts.poppins(
                                          fontSize: screenWidth * 0.035,
                                          color: const Color(0xFFD4A574),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Favorite button
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.favorite_border_rounded,
                                    color: Colors.grey.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Brand and Stock
                            if (product.brand?.isNotEmpty == true)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.business_rounded,
                                        size: 16,
                                        color: Colors.grey.withValues(alpha: 0.7),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        product.brand!,
                                        style: GoogleFonts.poppins(
                                          fontSize: screenWidth * 0.035,
                                          color: Colors.grey.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            
                            // Stock info
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 16,
                                  color: Colors.grey.withValues(alpha: 0.7),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${product.stock} in stock',
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * 0.035,
                                    color: product.stock > 10 
                                        ? Colors.green 
                                        : product.stock > 0 
                                            ? Colors.orange 
                                            : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Price
                            Row(
                              children: [
                                Text(
                                  'PHP ${product.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * 0.08,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFD4A574),
                                  ),
                                ),
                                if ((product.comparePrice ?? 0) > product.price)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(
                                      'PHP ${product.comparePrice?.toStringAsFixed(2) ?? '0.00'}',
                                      style: GoogleFonts.poppins(
                                        fontSize: screenWidth * 0.04,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            
                            SizedBox(height: 20),
                            
                            // Colors and Sizes
                            if (product.colors.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Colors Available',
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: product.colors.map((color) {
                                      return Chip(
                                        label: Text(
                                          color,
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth * 0.03,
                                          ),
                                        ),
                                        backgroundColor: const Color(0xFFD4A574).withValues(alpha: 0.1),
                                        side: BorderSide(
                                          color: const Color(0xFFD4A574).withValues(alpha: 0.3),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                            
                            if (product.sizes.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sizes Available',
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: product.sizes.map((size) {
                                      return Chip(
                                        label: Text(
                                          size,
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth * 0.03,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        backgroundColor: const Color(0xFFD4A574).withValues(alpha: 0.1),
                                        side: BorderSide(
                                          color: const Color(0xFFD4A574).withValues(alpha: 0.3),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            
                            // Description
                            if (product.description?.isNotEmpty == true)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description',
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    product.description!,
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.grey.withValues(alpha: 0.8),
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                ],
                              ),
                            
                            // Add to Cart Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: product.stock > 0 ? () async {
                                  final cartService = SupabaseCartService();
                                  final success = await cartService.addToCart(product);
                                  
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                  
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${product.name} added to cart!',
                                                style: GoogleFonts.poppins(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color(0xFF4CAF50),
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        action: SnackBarAction(
                                          label: 'VIEW CART',
                                          textColor: Colors.white,
                                          onPressed: () {},
                                        ),
                                      ),
                                    );
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.error_outline, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Failed to add to cart',
                                              style: GoogleFonts.poppins(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4A574),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
