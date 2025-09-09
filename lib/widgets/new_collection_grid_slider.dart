import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product_model.dart';
import 'product_card.dart';

class NewCollectionGridSlider extends StatefulWidget {
  final List<Product> products;
  final double height;
  final Function(Product) onProductTap;
  final Function(Product) onAddToCart;
  final Function(Product) onFavoriteToggle;

  const NewCollectionGridSlider({
    Key? key,
    required this.products,
    this.height = 300,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<NewCollectionGridSlider> createState() => _NewCollectionGridSliderState();
}

class _NewCollectionGridSliderState extends State<NewCollectionGridSlider> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: 0,
    );
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
    
    // Listen for page changes to update animation
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
        _animationController.reset();
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text('No new collection products available'),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final gridItemsPerPage = 4; // 2x2 grid
    final int totalPages = (widget.products.length / gridItemsPerPage).ceil();
    
    return Column(
      children: [
        // Header section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 10),
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
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to view all new collection
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
        
        // Grid slider
        SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              // Main content with PageView
              PageView.builder(
                controller: _pageController,
                itemCount: totalPages,
                onPageChanged: (int page) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, pageIndex) {
                  return ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 6,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: min(
                              gridItemsPerPage,
                              widget.products.length - (pageIndex * gridItemsPerPage),
                            ),
                            itemBuilder: (context, index) {
                              final productIndex = pageIndex * gridItemsPerPage + index;
                              if (productIndex < widget.products.length) {
                                final product = widget.products[productIndex];
                                return ProductCard(
                                  product: product,
                                  width: (screenWidth - 80) / 2,
                                  height: double.infinity,
                                  onTap: () => widget.onProductTap(product),
                                  onAddToCart: () => widget.onAddToCart(product),
                                  onFavoriteToggle: () => widget.onFavoriteToggle(product),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Page indicator dots
              Positioned(
                bottom: 15,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalPages,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFFD4A574)
                            : Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper function to get minimum of two values
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
