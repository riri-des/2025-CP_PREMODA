class Product {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String? brand;
  final double price;
  final double? comparePrice;
  final double? costPrice;
  final int stock;
  final String status;
  final String visibility;
  final bool featured;
  final bool trending;
  final bool newArrival;
  final List<String> colors;
  final List<String> sizes;
  final List<String> tags;
  final int views;
  final int orders;
  final double? rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final List<ProductImage> images;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.brand,
    required this.price,
    this.comparePrice,
    this.costPrice,
    required this.stock,
    required this.status,
    required this.visibility,
    required this.featured,
    required this.trending,
    required this.newArrival,
    required this.colors,
    required this.sizes,
    required this.tags,
    required this.views,
    required this.orders,
    this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? '',
      brand: json['brand'],
      price: (json['price'] ?? 0).toDouble(),
      comparePrice: json['compare_price']?.toDouble(),
      costPrice: json['cost_price']?.toDouble(),
      stock: json['stock'] ?? 0,
      status: json['status'] ?? 'draft',
      visibility: json['visibility'] ?? 'private',
      featured: json['featured'] ?? false,
      trending: json['trending'] ?? false,
      newArrival: json['new_arrival'] ?? false,
      colors: json['colors'] != null ? List<String>.from(json['colors']) : [],
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : [],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      views: json['views'] ?? 0,
      orders: json['orders'] ?? 0,
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      createdBy: json['created_by'] ?? '',
      updatedBy: json['updated_by'] ?? '',
      images: json['product_images'] != null 
          ? (json['product_images'] as List).map((img) => ProductImage.fromJson(img)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'price': price,
      'compare_price': comparePrice,
      'cost_price': costPrice,
      'stock': stock,
      'status': status,
      'visibility': visibility,
      'featured': featured,
      'trending': trending,
      'new_arrival': newArrival,
      'colors': colors,
      'sizes': sizes,
      'tags': tags,
      'views': views,
      'orders': orders,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  // Helper methods
  bool get isInStock => stock > 0;
  bool get isOnSale => comparePrice != null && comparePrice! > price;
  double get discountPercentage => isOnSale ? ((comparePrice! - price) / comparePrice! * 100) : 0;
  String get primaryImage => images.isNotEmpty ? images.first.url : '';
  
  // Get formatted price
  String get formattedPrice => 'PHP ${price.toStringAsFixed(2)}';
  String? get formattedComparePrice => comparePrice != null ? 'PHP ${comparePrice!.toStringAsFixed(2)}' : null;
}

class ProductImage {
  final String id;
  final String productId;
  final String url;
  final String? alt;
  final bool isPrimary;
  final int sortOrder;
  final DateTime createdAt;

  ProductImage({
    required this.id,
    required this.productId,
    required this.url,
    this.alt,
    required this.isPrimary,
    required this.sortOrder,
    required this.createdAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      url: json['url'] ?? '',
      alt: json['alt'],
      isPrimary: json['is_primary'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'url': url,
      'alt': alt,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
