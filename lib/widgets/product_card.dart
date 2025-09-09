import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const ProductCard({
    Key? key,
    required this.product,
    this.width = 180,
    this.height = 250,
    this.onTap,
    this.onAddToCart,
    this.onFavoriteToggle,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hasImage = product.images.isNotEmpty;
    
    // Determine text sizes based on screen width
    final double nameFontSize = screenWidth * 0.032;
    final double priceFontSize = screenWidth * 0.03;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image or placeholder
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      // If we have an image, use it; otherwise, use a gradient background
                      image: hasImage
                          ? DecorationImage(
                              image: NetworkImage(product.primaryImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: !hasImage
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getCategoryColor(product.category).withOpacity(0.2),
                                _getCategoryColor(product.category).withOpacity(0.4),
                              ],
                            )
                          : null,
                    ),
                    // If there's no image, show a category icon
                    child: !hasImage
                        ? Center(
                            child: Container(
                              width: width * 0.5,
                              height: height * 0.3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _getCategoryColor(product.category).withOpacity(0.8),
                                    _getCategoryColor(product.category),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getCategoryColor(product.category).withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getCategoryIcon(product.category),
                                color: Colors.white.withOpacity(0.9),
                                size: width * 0.18,
                              ),
                            ),
                          )
                        : null,
                  ),
                  
                  // Sale badge
                  if (product.isOnSale)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${product.discountPercentage.toInt()}% OFF',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 16,
                          color: isFavorite ? Colors.red : Colors.grey.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  
                  // Out of stock overlay
                  if (!product.isInStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'OUT OF STOCK',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.isOnSale)
                              Text(
                                product.formattedComparePrice!,
                                style: GoogleFonts.poppins(
                                  fontSize: priceFontSize - 2,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              product.formattedPrice,
                              style: GoogleFonts.poppins(
                                fontSize: priceFontSize,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFD4A574),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: product.isInStock ? onAddToCart : null,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: product.isInStock ? const Color(0xFFD4A574) : Colors.grey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
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
}
