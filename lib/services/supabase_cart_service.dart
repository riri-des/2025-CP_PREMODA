import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      'product_id': product.id,
      'selected_size': selectedSize,
      'selected_color': selectedColor,
      'quantity': quantity,
      'price': product.price,
    };
  }
}

class SupabaseCartService extends ChangeNotifier {
  static final SupabaseCartService _instance = SupabaseCartService._internal();
  factory SupabaseCartService() => _instance;
  SupabaseCartService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  bool get isLoading => _isLoading;
  
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalPrice => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get selectedItemsTotal => _cartItems
      .where((item) => item.isSelected)
      .fold(0.0, (sum, item) => sum + item.totalPrice);
  
  int get selectedItemsCount => _cartItems
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.quantity);

  bool get hasItems => _cartItems.isNotEmpty;

  Future<void> loadCart() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _cartItems.clear();
        _isLoading = false;
        notifyListeners();
        return;
      }
      // Fetch from Supabase cart_items with joined product and images
      final response = await _supabase
          .from('cart_items')
          .select('''
            id,
            product_id,
            selected_size,
            selected_color,
            quantity,
            products:product_id (
              *,
              product_images (*)
            )
          ''')
          .eq('user_id', userId);

      _cartItems
        ..clear()
        ..addAll((response as List).map((row) {
          final productJson = row['products'] as Map<String, dynamic>;
          final product = Product.fromJson(productJson);
          return CartItem(
            id: row['id'].toString(),
            product: product,
            selectedSize: (row['selected_size'] ?? '').toString(),
            selectedColor: (row['selected_color'] ?? '').toString(),
            quantity: (row['quantity'] ?? 1) as int,
          );
        }));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading cart: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(Product product, {String? selectedSize, String? selectedColor}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _addToLocalCart(product, selectedSize: selectedSize, selectedColor: selectedColor);
        return true;
      }

      final size = selectedSize ?? (product.sizes.isNotEmpty ? product.sizes.first : '');
      final color = selectedColor ?? (product.colors.isNotEmpty ? product.colors.first : '');

      // Check if item exists for this user/product/variant
      final existing = await _supabase
          .from('cart_items')
          .select('id, quantity')
          .eq('user_id', userId)
          .eq('product_id', product.id)
          .eq('selected_size', size)
          .eq('selected_color', color)
          .maybeSingle();

      if (existing != null) {
        final currentQty = (existing['quantity'] ?? 1) as int;
        await _supabase
            .from('cart_items')
            .update({'quantity': currentQty + 1})
            .eq('id', existing['id']);
      } else {
        await _supabase.from('cart_items').insert({
          'user_id': userId,
          'product_id': product.id,
          'selected_size': size,
          'selected_color': color,
          'quantity': 1,
        });
      }

      // Refresh local cache
      await loadCart();
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  void _addToLocalCart(Product product, {String? selectedSize, String? selectedColor}) {
    final size = selectedSize ?? (product.sizes.isNotEmpty ? product.sizes.first : '');
    final color = selectedColor ?? (product.colors.isNotEmpty ? product.colors.first : '');

    final existingItemIndex = _cartItems.indexWhere((item) => 
      item.product.id == product.id && 
      item.selectedSize == size &&
      item.selectedColor == color
    );

    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex] = _cartItems[existingItemIndex].copyWith(
        quantity: _cartItems[existingItemIndex].quantity + 1,
      );
    } else {
      final cartItemId = '${product.id}_${size}_${color}_${DateTime.now().millisecondsSinceEpoch}';
      final cartItem = CartItem(
        id: cartItemId,
        product: product,
        selectedSize: size,
        selectedColor: color,
      );
      _cartItems.add(cartItem);
    }
    
    notifyListeners();
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _cartItems.removeWhere((item) => item.id == cartItemId);
        notifyListeners();
        return;
      }

      await _supabase
          .from('cart_items')
          .delete()
          .eq('id', cartItemId)
          .eq('user_id', userId);

      await loadCart();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
        if (itemIndex != -1) {
          _cartItems[itemIndex] = _cartItems[itemIndex].copyWith(quantity: newQuantity);
          notifyListeners();
        }
        return;
      }

      await _supabase
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', cartItemId)
          .eq('user_id', userId);

      await loadCart();
    } catch (e) {
      print('Error updating quantity: $e');
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

  Future<void> clearCart() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _cartItems.clear();
        notifyListeners();
        return;
      }

      await _supabase
          .from('cart_items')
          .delete()
          .eq('user_id', userId);

      await loadCart();
    } catch (e) {
      print('Error clearing cart: $e');
    }
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

  /// Falls back to client-side createOrder if RPC isn't available.
  Future<String?> createOrderAtomic({
    required String shippingAddressId,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final selectedItems = _cartItems.where((i) => i.isSelected).toList();
      if (selectedItems.isEmpty) {
        throw Exception('No items selected');
      }

      final itemsPayload = selectedItems.map((i) => {
            'product_id': i.product.id,
            'quantity': i.quantity,
            'size': i.selectedSize,
            'color': i.selectedColor,
          }).toList();

      final result = await _supabase.rpc('create_order', params: {
        'p_shipping_address_id': shippingAddressId,
        'p_payment_method': paymentMethod ?? 'cash_on_delivery',
        'p_notes': notes,
        'p_items': itemsPayload,
      });

      final orderId = (result is Map && result['order_id'] != null)
          ? result['order_id'] as String
          : (result is String ? result : null);

      // Refresh cart after order; server may have removed purchased items
      await loadCart();
      return orderId;
    } catch (e) {
      // Fallback to client-side insertion if RPC is missing
      print('RPC create_order failed, falling back: $e');
      return await createOrder(
        shippingAddressId: shippingAddressId,
        paymentMethod: paymentMethod,
        notes: notes,
      );
    }
  }

  Future<String?> createOrder({
    required String shippingAddressId,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (_cartItems.isEmpty) {
        throw Exception('Cart is empty');
      }

      final selectedItems = _cartItems.where((item) => item.isSelected).toList();
      if (selectedItems.isEmpty) {
        throw Exception('No items selected');
      }

      final subtotal = selectedItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      final shippingFee = 50.0;
      final tax = subtotal * 0.12;
      final totalAmount = subtotal + shippingFee + tax;

      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      final orderData = {
        'user_id': userId,
        'order_number': orderNumber,
        'status': 'pending',
        'subtotal': subtotal,
        'shipping_fee': shippingFee,
        'tax': tax,
        'total_amount': totalAmount,
        'payment_method': paymentMethod ?? 'cash_on_delivery',
        'payment_status': 'pending',
        'shipping_address_id': shippingAddressId,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      };

      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      final orderId = orderResponse['id'];

      final orderItems = selectedItems.map((item) => {
        'order_id': orderId,
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price': item.product.price,
        'size': item.selectedSize,
        'color': item.selectedColor,
      }).toList();

      await _supabase.from('order_items').insert(orderItems);

      _cartItems.removeWhere((item) => item.isSelected);
      notifyListeners();

      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }
}
