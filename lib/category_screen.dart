import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedCategoryIndex = 0; // 0 = Women's, 1 = Men's, 2 = Kid's
  
  final List<String> categories = ['Women\'s', 'Men\'s', 'Kid\'s'];
  
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
                    // Category title and small category icons
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: _getProductsForCategory().length,
        itemBuilder: (context, index) {
          final product = _getProductsForCategory()[index];
          return _buildProductCard(
            product['name'],
            product['price'],
            product['color'],
            product['icon'],
            screenWidth,
            screenHeight,
          );
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
  
  Widget _buildProductCard(String name, String price, Color color, IconData clothingIcon, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: () {
        // Navigate to product details
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
            // Product image placeholder
            Expanded(
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
                        width: screenWidth * 0.18,
                        height: screenWidth * 0.18,
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
                          size: screenWidth * 0.07,
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
            Container(
              padding: EdgeInsets.all(screenWidth * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          price,
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.028,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFD4A574),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A574),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 12,
                          color: Colors.white,
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
}
