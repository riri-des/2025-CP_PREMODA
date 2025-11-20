import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'screens/virtual_tryon_camera.dart';
import 'screens/checkout_screen.dart';
import 'services/virtual_tryon_service.dart';
import 'services/supabase_cart_service.dart';
import 'dart:io';
import 'home_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final SupabaseCartService _cartService = SupabaseCartService();
  String _selectedAIModel = 'segmind';
  
  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
    _loadCart();
  }
  
  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }
  
  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  Future<void> _loadCart() async {
    await _cartService.loadCart();
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
            // Header
            _buildHeader(screenWidth, screenHeight),
            
            // Cart Items
            Expanded(
              child: _cartService.cartItems.isEmpty 
                  ? _buildEmptyCart(screenWidth, screenHeight)
                  : ListView.builder(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      itemCount: _cartService.cartItems.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(
                          _cartService.cartItems[index], 
                          screenWidth, 
                          screenHeight,
                          index,
                        );
                      },
                    ),
            ),
            
            // Bottom Total and Checkout
            if (_cartService.cartItems.isNotEmpty) _buildBottomSection(screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.06, screenWidth * 0.04, screenWidth * 0.04),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Title
          Expanded(
            child: Text(
              'My Cart',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Actions
          Row(
            children: [
              // Clear all button
              GestureDetector(
                onTap: () {
                  _showClearCartDialog();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.clear_all_rounded,
                    size: 18,
                    color: Colors.red.withValues(alpha: 0.7),
                  ),
                ),
              ),
              
              SizedBox(width: 8),
              
              // Virtual Try-On button - Enhanced
              GestureDetector(
                onTap: () {
                  _showVirtualTryOnDialog();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4A574),
                        const Color(0xFFD4A574).withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4A574).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/scan-icon.png',
                        width: 16,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Try On',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(width: 8),
              
              // Delete selected button
              GestureDetector(
                onTap: () {
                  // Toggle delete mode or delete selected items
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Colors.red.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCartItem(CartItem item, double screenWidth, double screenHeight, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                _cartService.toggleItemSelection(item.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: item.isSelected ? const Color(0xFFD4A574) : Colors.transparent,
                  border: Border.all(
                    color: item.isSelected ? const Color(0xFFD4A574) : Colors.grey.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: item.isSelected
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            
            SizedBox(width: screenWidth * 0.04),
            
            // Product Image
            Container(
              width: screenWidth * 0.18,
              height: screenWidth * 0.18,
              decoration: BoxDecoration(
                gradient: item.product.images.isEmpty ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withValues(alpha: 0.3),
                    Colors.blue.withValues(alpha: 0.6),
                  ],
                ) : null,
                color: item.product.images.isNotEmpty ? Colors.grey.withValues(alpha: 0.1) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: item.product.images.isNotEmpty 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.product.images.first.url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
                        return _buildIconContainer(item, screenWidth);
                      },
                    ),
                  )
                : _buildIconContainer(item, screenWidth),
            ),
            
            SizedBox(width: screenWidth * 0.04),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4),
                  
                  Text(
                    'Size: ${item.selectedSize}',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.withValues(alpha: 0.7),
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Price section - no Try On button
                  Row(
                    children: [
                      // Price - Left side with flexible width
                      Flexible(
                        flex: 2,
                        child: Text(
                          'PHP ${item.product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.032,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFD4A574),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      SizedBox(width: 8),
                      
                      // Quantity Controls - Right side with constrained width
                      SizedBox(
                        width: 66, // Fixed width to prevent overflow
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (item.quantity > 1) {
                                  await _cartService.updateQuantity(item.id, item.quantity - 1);
                                }
                              },
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: item.quantity > 1 
                                      ? const Color(0xFFD4A574).withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: item.quantity > 1 
                                        ? const Color(0xFFD4A574).withValues(alpha: 0.3)
                                        : Colors.grey.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 10,
                                  color: item.quantity > 1 
                                      ? const Color(0xFFD4A574)
                                      : Colors.grey.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            
                            Container(
                              width: 20,
                              height: 18,
                              alignment: Alignment.center,
                              child: Text(
                                '${item.quantity}',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.024,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            
                            GestureDetector(
                              onTap: () async {
                                await _cartService.updateQuantity(item.id, item.quantity + 1);
                              },
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4A574).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFD4A574).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 10,
                                  color: const Color(0xFFD4A574),
                                ),
                              ),
                            ),
                          ],
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
  
  Widget _buildBottomSection(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Order Summary
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal (${_cartService.cartItems.fold(0, (sum, item) => sum + item.quantity)} items)',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.032,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        'PHP ${_cartService.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.032,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shipping Fee',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.032,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        'Free',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.032,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  
                  Divider(
                    color: Colors.grey.withValues(alpha: 0.3),
                    height: 24,
                    thickness: 1,
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'PHP ${_cartService.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD4A574),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenWidth * 0.04),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        _showCheckoutDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A574),
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: const Color(0xFFD4A574).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_bag_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Checkout',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyCart(double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth * 0.3,
            height: screenWidth * 0.3,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(screenWidth * 0.15),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: screenWidth * 0.15,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),
          
          SizedBox(height: screenWidth * 0.08),
          
          Text(
            'Your Cart is Empty',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: screenWidth * 0.02),
          
          Text(
            'Add some items to get started',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w400,
              color: Colors.grey.withValues(alpha: 0.7),
            ),
          ),
          
          SizedBox(height: screenWidth * 0.08),
          
          ElevatedButton(
            onPressed: () {
              // Navigate to HomeScreen (Shop tab) instead of popping,
              // to avoid returning to a login or previous unrelated route.
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A574),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Start Shopping',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Clear Cart',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to remove all items from your cart?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey.withValues(alpha: 0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _cartService.clearCart();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showCheckoutDialog() {
    // Check if any items are selected, if not select all
    final selectedItems = _cartService.cartItems.where((item) => item.isSelected).toList();
    
    if (selectedItems.isEmpty) {
      // Auto-select all items
      _cartService.selectAllItems();
    }
    
    // Navigate to checkout screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }
  
  void _showVirtualTryOnDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD4A574).withValues(alpha: 0.8),
                          const Color(0xFFD4A574),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Virtual Try-On',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selected items horizontal preview
                    if (_cartService.cartItems.where((i) => i.isSelected).isNotEmpty) ...[
                SizedBox(
                  height: 76,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cartService.cartItems.where((i) => i.isSelected).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final items = _cartService.cartItems.where((i) => i.isSelected).toList();
                      final it = items[idx];
                      return Container(
                        width: 76,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.25), width: 1),
                          color: const Color(0xFFF8F8F8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: it.product.images.isNotEmpty
                            ? Image.network(it.product.images.first.url, fit: BoxFit.cover)
                            : Center(
                                child: Icon(Icons.checkroom, color: const Color(0xFFD4A574), size: 20),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
                    // Feature Description
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD4A574).withValues(alpha: 0.1),
                            const Color(0xFFD4A574).withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.smart_toy,
                            color: const Color(0xFFD4A574),
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try before you buy!',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Choose your AI model, then take or upload a photo to see how the items look on you!',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // AI Model Selection
                    Row(
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          color: const Color(0xFFD4A574),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Choose AI Model:',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    // AI Model Options
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAIModel = 'rapidapi';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedAIModel == 'rapidapi'
                                    ? const Color(0xFFD4A574).withOpacity(0.1)
                                    : const Color(0xFFF8F8F8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedAIModel == 'rapidapi'
                                      ? const Color(0xFFD4A574)
                                      : Colors.grey.withOpacity(0.3),
                                  width: _selectedAIModel == 'rapidapi' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: _selectedAIModel == 'rapidapi'
                                        ? const Color(0xFFD4A574)
                                        : Colors.grey,
                                    size: 24,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Try-On Diffusion',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedAIModel == 'rapidapi'
                                          ? const Color(0xFFD4A574)
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'RapidAPI',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAIModel = 'segmind';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedAIModel == 'segmind'
                                    ? const Color(0xFFD4A574).withOpacity(0.1)
                                    : const Color(0xFFF8F8F8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedAIModel == 'segmind'
                                      ? const Color(0xFFD4A574)
                                      : Colors.grey.withOpacity(0.3),
                                  width: _selectedAIModel == 'segmind' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.smart_toy_outlined,
                                    color: _selectedAIModel == 'segmind'
                                        ? const Color(0xFFD4A574)
                                        : Colors.grey,
                                    size: 24,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'IDM VTON',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedAIModel == 'segmind'
                                          ? const Color(0xFFD4A574)
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Segmind',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    // Selected Items
                    if (_cartService.cartItems.where((item) => item.isSelected).isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.checkroom_outlined,
                            color: const Color(0xFFD4A574),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Selected Items:',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _cartService.cartItems
                              .where((item) => item.isSelected)
                              .map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.checkroom,
                                          color: Colors.blue,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${item.product.name} (Size ${item.selectedSize})',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    
                    // Photo Upload Options
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _startVirtualTryOn('camera');
                            },
                            icon: Icon(Icons.camera_alt_outlined, size: 18),
                            label: Text(
                              'Take Photo',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFD4A574),
                              side: BorderSide(
                                color: const Color(0xFFD4A574),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _startVirtualTryOn('gallery');
                            },
                            icon: Icon(Icons.photo_library_outlined, size: 18),
                            label: Text(
                              'Upload Photo',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4A574),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  

  void _startVirtualTryOn(String source) async {
    // Get selected items for virtual try-on
    List<CartItem> selectedItems = _cartService.cartItems.where((item) => item.isSelected).toList();
    
    if (selectedItems.isEmpty) {
      // If no items are selected, use all items
      selectedItems = _cartService.cartItems;
    }
    
    if (source == 'camera') {
      // Navigate to camera screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VirtualTryOnCamera(
            selectedItems: selectedItems,
            useRapidAPI: _selectedAIModel == 'rapidapi',
          ),
        ),
      );
    } else {
      // Pick image from gallery
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        
        if (image != null) {
          await _processGalleryImage(image.path, selectedItems);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to select image: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  

  Future<void> _processGalleryImage(String imagePath, List<CartItem> selectedItems) async {
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4A574).withValues(alpha: 0.1),
                    const Color(0xFFD4A574).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD4A574).withValues(alpha: 0.8),
                          const Color(0xFFD4A574),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Image.asset(
                      'assets/images/scan-icon.png',
                      width: 30,
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Processing Virtual Try-On',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our AI is analyzing your photo and fitting the selected items...',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFD4A574),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    
    try {
      // Process the image using VirtualTryOnService with selected AI model
      final VirtualTryOnService service = VirtualTryOnService();
      final bool useRapidAPI = _selectedAIModel == 'rapidapi';
      final String? resultPath = await service.processVirtualTryOn(
        imagePath: imagePath,
        selectedItems: selectedItems,
        modelImagePath: useRapidAPI ? imagePath : null,
        useRapidAPI: useRapidAPI,
      );
      
      // Close processing dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        if (resultPath != null) {
          _showGalleryResult(resultPath, selectedItems);
        } else {
          _showErrorDialog('Failed to process virtual try-on. Please try with a clearer image.');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorDialog('Virtual try-on error: $e');
      }
    }
  }
  
  void _showGalleryResult(String resultPath, List<CartItem> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4A574).withOpacity(0.8),
                    const Color(0xFFD4A574),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/scan-icon.png',
                width: 20,
                height: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Virtual Try-On Result',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4A574).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(resultPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Here\'s how the ${items.length} selected item${items.length > 1 ? 's' : ''} look on you!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showVirtualTryOnDialog();
            },
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Virtual try-on completed! Items look great!',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: const Color(0xFFD4A574),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A574),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Looks Great!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Virtual Try-On Error',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.red[700],
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A574),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIconContainer(CartItem item, double screenWidth) {
    return Center(
      child: Container(
        width: screenWidth * 0.12,
        height: screenWidth * 0.12,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withValues(alpha: 0.8),
              Colors.blue,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.checkroom,
          color: Colors.white.withValues(alpha: 0.9),
          size: screenWidth * 0.06,
        ),
      ),
    );
  }

  void _showVirtualTryOnResult(List<CartItem> items, String source) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.smart_toy,
                color: const Color(0xFFD4A574),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Virtual Try-On Result',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simulated result preview
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4A574).withValues(alpha: 0.1),
                      const Color(0xFFD4A574).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4A574).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outlined,
                        size: 80,
                        color: const Color(0xFFD4A574),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Virtual Try-On Preview',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD4A574),
                        ),
                      ),
                      Text(
                        'Photo from ${source == 'camera' ? 'Camera' : 'Gallery'}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Amazing! Here\'s how the items look on you. The AI has perfectly fitted ${items.length} item${items.length > 1 ? 's' : ''} based on your photo.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Try again with different photo
                _showVirtualTryOnDialog();
              },
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Show success feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Virtual try-on completed! Items look great on you!',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFFD4A574),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Looks Great!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

