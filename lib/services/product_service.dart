import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import 'supabase_config.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all products with optional filtering
  Future<List<Product>> getProducts({
    String? category,
    bool? featured,
    bool? trending,
    bool? newArrival,
    int? limit,
    int? offset,
  }) async {
    try {
      print('🔎 Debug getProducts: category=$category, featured=$featured, trending=$trending, newArrival=$newArrival, limit=$limit');
      
      var baseQuery = _supabase
          .from('products')
          .select('''
            *,
            product_images (*)
          ''');
          
      // First, let's try without the status and visibility filters to see all products
      print('🔍 Querying products table...');
      
      // Defer category filtering for two-phase strategy below

      if (featured == true) {
        baseQuery = baseQuery.eq('featured', true);
      }

      if (trending == true) {
        baseQuery = baseQuery.eq('trending', true);
      }

      if (newArrival == true) {
        baseQuery = baseQuery.eq('new_arrival', true);
      }
      
      // Let's check what status and visibility values exist in your database
      try {
        final testResponse = await _supabase
            .from('products')
            .select('status, visibility')
            .limit(5);
        print('📊 Sample product statuses: $testResponse');
      } catch (testError) {
        print('⚠️ Could not fetch sample statuses: $testError');
      }
      
      // Apply status and visibility filters (fixed to match database values)
      baseQuery = baseQuery.eq('status', 'active').eq('visibility', 'visible');
      Future<List<dynamic>> _execute(dynamic q) async {
        var ordered = q.order('created_at', ascending: false);
        if (offset != null) {
          ordered = ordered.range(offset, (offset + (limit ?? 10)) - 1);
        } else if (limit != null) {
          ordered = ordered.limit(limit);
        }
        return await ordered;
      }

      List<dynamic> response = [];

      if (category != null && category.isNotEmpty) {
        // Phase 1: exact equality
        final exactQuery = baseQuery.eq('category', category);
        response = await _execute(exactQuery);

        if (response.isEmpty) {
          // Phase 2: safe ilike patterns
          final token = category.toLowerCase();
          dynamic likeQuery = baseQuery;

          if (token.contains('men')) {
            // Avoid matching 'women' by excluding 'wom' in category
            likeQuery = likeQuery
                .or("category.ilike.men%,category.ilike.%men'%,category.ilike.%mens%,category.ilike.% male%,category.ilike.% men %,category.ilike.% men,%,category.ilike.% men/%")
                .not('category', 'ilike', '%wom%');
          } else if (token.contains('women') || token.contains('woman') || token.contains('lady') || token.contains('female')) {
            likeQuery = likeQuery.or("category.ilike.women%,category.ilike.%women'%,category.ilike.%womens%,category.ilike.%woman%,category.ilike.%lady%,category.ilike.%ladies%,category.ilike.%female%");
          } else if (token.contains('kid') || token.contains('child')) {
            likeQuery = likeQuery.or('category.ilike.kid%,category.ilike.%kids%,category.ilike.%child%,category.ilike.%children%');
          } else {
            likeQuery = likeQuery.ilike('category', '%${category.replaceAll("'", '')}%');
          }

          response = await _execute(likeQuery);
        }
      } else {
        // No category: just run base
        response = await _execute(baseQuery);
      }
      print('📦 Raw response: $response');
      print('📊 Response length: ${response.length}');
      
      if (response.isEmpty) {
        // Let's try without status/visibility filters to see if products exist
        print('🔍 No products found with filters, trying without status/visibility filters...');
        var fallbackQuery = _supabase
            .from('products')
            .select('*')
            .limit(3);
            
        final fallbackResponse = await fallbackQuery;
        print('📦 Fallback response (without filters): $fallbackResponse');
      }
      
      final products = (response as List).map((json) {
        print('🔨 Processing product JSON: $json');
        return Product.fromJson(json);
      }).toList();
      
      print('✅ Successfully parsed ${products.length} products');
      return products;
    } catch (e, stackTrace) {
      print('❌ Error fetching products: $e');
      print('📍 Stack trace: $stackTrace');
      return [];
    }
  }

  /// Get featured products for home screen
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    return await getProducts(featured: true, limit: limit);
  }

  /// Get trending products
  Future<List<Product>> getTrendingProducts({int limit = 10}) async {
    return await getProducts(trending: true, limit: limit);
  }

  /// Get new arrival products
  Future<List<Product>> getNewArrivalProducts({int limit = 10}) async {
    return await getProducts(newArrival: true, limit: limit);
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category, {int? limit}) async {
    return await getProducts(category: category, limit: limit);
  }

  /// Get single product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            product_images (*)
          ''')
          .eq('id', productId)
          .eq('status', 'active')
          .eq('visibility', 'visible')
          .single();

      return Product.fromJson(response);
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  /// Search products by name or description
  Future<List<Product>> searchProducts(String searchQuery, {int? limit}) async {
    try {
      var query = _supabase
          .from('products')
          .select('''
            *,
            product_images (*)
          ''')
          .or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%')
          .eq('status', 'active')
          .eq('visibility', 'visible');
      
      var orderedQuery = query.order('created_at', ascending: false);
      
      if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      } else {
        orderedQuery = orderedQuery.limit(20);
      }

      final response = await orderedQuery;
      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  /// Get distinct categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('products')
          .select('category')
          .eq('status', 'active')
          .eq('visibility', 'visible');

      final categories = (response as List)
          .map((item) => item['category'] as String?)
          .where((category) => category != null && category.isNotEmpty)
          .toSet()
          .toList();

      return categories.cast<String>();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  /// Update product view count
  Future<void> incrementProductViews(String productId) async {
    try {
      await _supabase.rpc('increment_product_views', params: {'product_id': productId});
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  /// Get products for "For You" section (mix of featured, trending, and new arrivals)
  Future<List<Product>> getRecommendedProducts({int limit = 10}) async {
    try {
      print('🔍 Debug: Starting getRecommendedProducts');
      
      // Check if Supabase is configured
      if (!SupabaseConfig.isConfigured) {
        print('❌ Supabase not configured properly');
        return [];
      }
      
      print('✅ Supabase configured, fetching products...');
      
      // First, try to get all products to see if there are any
      final allProducts = await getProducts(limit: limit);
      print('📦 Found ${allProducts.length} total products');
      
      if (allProducts.isNotEmpty) {
        return allProducts;
      }
      
      // Get a mix of featured, trending, and new arrival products
      final featured = await getFeaturedProducts(limit: 4);
      print('⭐ Found ${featured.length} featured products');
      
      final trending = await getTrendingProducts(limit: 3);
      print('🔥 Found ${trending.length} trending products');
      
      final newArrivals = await getNewArrivalProducts(limit: 3);
      print('🆕 Found ${newArrivals.length} new arrival products');
      
      final List<Product> recommended = [];
      recommended.addAll(featured);
      recommended.addAll(trending.where((t) => !featured.any((f) => f.id == t.id)));
      recommended.addAll(newArrivals.where((n) => 
        !featured.any((f) => f.id == n.id) && 
        !trending.any((t) => t.id == n.id)
      ));
      
      print('🎯 Total recommended products: ${recommended.length}');
      
      // Shuffle and limit
      recommended.shuffle();
      return recommended.take(limit).toList();
    } catch (e) {
      print('❌ Error getting recommended products: $e');
      print('📍 Error details: ${e.toString()}');
      return [];
    }
  }

  /// Get product filters/options
  Future<Map<String, List<String>>> getProductFilters() async {
    try {
      final response = await _supabase
          .from('products')
          .select('category, brand, colors, sizes')
          .eq('status', 'active')
          .eq('visibility', 'visible');

      final Set<String> categories = {};
      final Set<String> brands = {};
      final Set<String> colors = {};
      final Set<String> sizes = {};

      for (final item in response) {
        if (item['category'] != null) categories.add(item['category']);
        if (item['brand'] != null) brands.add(item['brand']);
        if (item['colors'] != null) {
          final colorList = List<String>.from(item['colors']);
          colors.addAll(colorList);
        }
        if (item['sizes'] != null) {
          final sizeList = List<String>.from(item['sizes']);
          sizes.addAll(sizeList);
        }
      }

      return {
        'categories': categories.toList()..sort(),
        'brands': brands.toList()..sort(),
        'colors': colors.toList()..sort(),
        'sizes': sizes.toList()..sort(),
      };
    } catch (e) {
      print('Error getting filters: $e');
      return {
        'categories': [],
        'brands': [],
        'colors': [],
        'sizes': [],
      };
    }
  }
}
