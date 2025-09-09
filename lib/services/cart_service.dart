import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartItem {
  final String id;
  final Product product;
  String selectedSize;
  String selectedColor;
  int quantity;
  bool isSelected;

  CartItem({
    required this.id,
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
    this.isSelected = false,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    String? selectedSize,
    String? selectedColor,
    int? quantity,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      selectedSize: json['selectedSize'],
      selectedColor: json['selectedColor'],
      quantity: json['quantity'] ?? 1,
      isSelected: json['isSelected'] ?? false,
    );
  }
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _cartItems = [];
  
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalPrice => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get selectedItemsTotal => _cartItems
      .where((item) => item.isSelected)
      .fold(0.0, (sum, item) => sum + item.totalPrice);
  
  int get selectedItemsCount => _cartItems
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.quantity);

  bool get hasItems => _cartItems.isNotEmpty;

  void addToCart(Product product, {String? selectedSize, String? selectedColor}) {
    // Generate a unique cart item ID
    final cartItemId = '${product.id}_${selectedSize ?? 'default'}_${selectedColor ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Check if an identical item exists (same product, size, color)
    final existingItemIndex = _cartItems.indexWhere((item) => 
      item.product.id == product.id && 
      item.selectedSize == (selectedSize ?? (product.sizes.isNotEmpty ? product.sizes.first : '')) &&
      item.selectedColor == (selectedColor ?? (product.colors.isNotEmpty ? product.colors.first : ''))
    );

    if (existingItemIndex != -1) {
      // Update quantity of existing item
      _cartItems[existingItemIndex] = _cartItems[existingItemIndex].copyWith(
        quantity: _cartItems[existingItemIndex].quantity + 1,
      );
    } else {
      // Add new item to cart
      final cartItem = CartItem(
        id: cartItemId,
        product: product,
        selectedSize: selectedSize ?? (product.sizes.isNotEmpty ? product.sizes.first : ''),
        selectedColor: selectedColor ?? (product.colors.isNotEmpty ? product.colors.first : ''),
      );
      _cartItems.add(cartItem);
    }
    
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(cartItemId);
      return;
    }

    final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (itemIndex != -1) {
      _cartItems[itemIndex] = _cartItems[itemIndex].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  void toggleItemSelection(String cartItemId) {
    final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (itemIndex != -1) {
      _cartItems[itemIndex] = _cartItems[itemIndex].copyWith(
        isSelected: !_cartItems[itemIndex].isSelected,
      );
      notifyListeners();
    }
  }

  void selectAllItems() {
    for (int i = 0; i < _cartItems.length; i++) {
      _cartItems[i] = _cartItems[i].copyWith(isSelected: true);
    }
    notifyListeners();
  }

  void deselectAllItems() {
    for (int i = 0; i < _cartItems.length; i++) {
      _cartItems[i] = _cartItems[i].copyWith(isSelected: false);
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void removeSelectedItems() {
    _cartItems.removeWhere((item) => item.isSelected);
    notifyListeners();
  }

  bool isProductInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  int getProductQuantityInCart(String productId) {
    return _cartItems
        .where((item) => item.product.id == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }
}
