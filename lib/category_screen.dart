import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/product_service.dart';
import 'services/cart_service.dart';
import 'models/product_model.dart';

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
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Map category index to category names as they appear in database
      String categoryName;
      switch (_selectedCategoryIndex) {
        case 0:
          categoryName = 'Clothing'; // You can adjust this based on actual data
          break;
        case 1:
          categoryName = 'Clothing'; // For now, all products are in 'Clothing'
          break;
        case 2:
          categoryName = 'Clothing';
          break;
        default:
          categoryName = 'Clothing';
      }

      // For now, get all products since we only have one product in the database
      // Later you can filter by actual category when you have more data
      final products = await _productService.getProducts(limit: 20);
      
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
                    // Category title
                    _buildCategoryHeader(screenWidth, screenHeight),
                    
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
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildRealProductCard(product, screenWidth, screenHeight);
        },
      ),
    );
  }
  
  List<Map<String, dynamic>> _getProductsForCategory() {
    switch (_selectedCategoryIndex) {
      case 0: // Women's
        return [
          {'name': 'Women\'s T-shirt', 'price': 'PHP 850.00', 'color': const Color(0xFF8B7355), 'icon': Icons.woman_rounded},
          {'name': 'Women\'s Dress', 'price': 'PHP 1,250.00', 'color': const Color(0xFF5C9EAD), 'icon': Icons.checkroom_rounded},
          {'name': 'Women\'s Skirt', 'price': 'PHP 750.00', 'color': const Color(0xFFE8A87C), 'icon': Icons.label_rounded},
          {'name': 'Women\'s Shorts', 'price': 'PHP 650.00', 'color': const Color(0xFFD4A574), 'icon': Icons.crop_free_rounded},
          {'name': 'Blouse', 'price': 'PHP 950.00', 'color': const Color(0xFFB8956A), 'icon': Icons.woman_2_rounded},
          {'name': 'Cardigan', 'price': 'PHP 1,150.00', 'color': const Color(0xFF9B8A6C), 'icon': Icons.checkroom_outlined},
        ];
      case 1: // Men's
        return [
          {'name': 'Men\'s T-shirt', 'price': 'PHP 800.00', 'color': const Color(0xFF4A5568), 'icon': Icons.man_rounded},
          {'name': 'Men\'s Polo', 'price': 'PHP 1,100.00', 'color': const Color(0xFF2D3748), 'icon': Icons.man_2_rounded},
          {'name': 'Jeans', 'price': 'PHP 1,450.00', 'color': const Color(0xFF1A365D), 'icon': Icons.man_3_rounded},
          {'name': 'Men\'s Shorts', 'price': 'PHP 720.00', 'color': const Color(0xFF2C5282), 'icon': Icons.man_4_rounded},
          {'name': 'Hoodie', 'price': 'PHP 1,300.00', 'color': const Color(0xFF4A5568), 'icon': Icons.checkroom_rounded},
          {'name': 'Jacket', 'price': 'PHP 1,850.00', 'color': const Color(0xFF2D3748), 'icon': Icons.work_outline_rounded},
        ];
      case 2: // Kid's
        return [
          {'name': 'Kid\'s T-shirt', 'price': 'PHP 450.00', 'color': const Color(0xFFEC407A), 'icon': Icons.child_care_rounded},
          {'name': 'Kid\'s Dress', 'price': 'PHP 650.00', 'color': const Color(0xFFAB47BC), 'icon': Icons.child_friendly_rounded},
          {'name': 'Kid\'s Shorts', 'price': 'PHP 350.00', 'color': const Color(0xFF42A5F5), 'icon': Icons.sports_rounded},
          {'name': 'Kid\'s Pants', 'price': 'PHP 550.00', 'color': const Color(0xFF66BB6A), 'icon': Icons.people_rounded},
          {'name': 'Kid\'s Jacket', 'price': 'PHP 750.00', 'color': const Color(0xFFFF7043), 'icon': Icons.family_restroom_rounded},
          {'name': 'Kid\'s Shoes', 'price': 'PHP 850.00', 'color': const Color(0xFFFFCA28), 'icon': Icons.directions_walk_rounded},
        ];
      default:
        return [];
    }
  }
  
  Widget _buildRealProductCard(Product product, double screenWidth, double screenHeight) {
    String imageUrl = '';
    if (product.images.isNotEmpty) {
      imageUrl = product.images.first.url;
    }

    return GestureDetector(
      onTap: () {
        _showProductDetailModal(product);
      },
      child: Container(
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
            // Product image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: const Color(0xFFF8F8F8),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          const Color(0xFFD4A574)),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage(screenWidth);
                              },
                            )
                          : _buildPlaceholderImage(screenWidth),
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
                  // Featured/Trending badges
                  if (product.featured || product.trending)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.featured ? Colors.orange : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.featured ? 'Featured' : 'Trending',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.022,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Product details
            Container(
              padding: EdgeInsets.all(screenWidth * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  if (product.brand?.isNotEmpty == true)
                    Text(
                      product.brand!,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.025,
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                    ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PHP ${product.price.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFD4A574),
                              ),
                            ),
                            if ((product.comparePrice ?? 0) > product.price)
                              Text(
                                'PHP ${product.comparePrice?.toStringAsFixed(2) ?? '0.00'}',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.025,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey.withValues(alpha: 0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Quick add to cart functionality
                          CartService().addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} added to cart!',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: const Color(0xFFD4A574),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'VIEW CART',
                                textColor: Colors.white,
                                onPressed: () {
                                  // Navigate to cart - You'll need to handle this based on your navigation
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A574),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(double screenWidth) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4A574).withValues(alpha: 0.2),
            const Color(0xFFD4A574).withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: screenWidth * 0.15,
          height: screenWidth * 0.15,
          decoration: BoxDecoration(
            color: const Color(0xFFD4A574),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.checkroom_rounded,
            color: Colors.white,
            size: screenWidth * 0.08,
          ),
        ),
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
                                    return _buildPlaceholderImage(screenWidth);
                                  },
                                )
                              : _buildPlaceholderImage(screenWidth),
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
                                onPressed: product.stock > 0 ? () {
                                  // Add to cart functionality
                                  CartService().addToCart(product);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name} added to cart!',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: const Color(0xFFD4A574),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                      action: SnackBarAction(
                                        label: 'VIEW CART',
                                        textColor: Colors.white,
                                        onPressed: () {
                                          // Navigate to cart - You'll need to handle this based on your navigation
                                        },
                                      ),
                                    ),
                                  );
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
