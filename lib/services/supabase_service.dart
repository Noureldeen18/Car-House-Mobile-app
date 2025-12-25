import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schema_models.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  // Singleton
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // ================= Auth =================
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': phone},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo:
          'https://noureldeen18.github.io/Car-House-Admin-Panel/reset-password.html',
    );
  }

  // ================= Data =================

  /// Get all products with category names and images
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client
          .from('products')
          .select('*, categories(name), product_images(id, url, position)')
          .order('created_at', ascending: false);

      print('Products response: ${response.length} items');

      final products = <Product>[];
      for (final item in response) {
        final product = Product.fromMap(item);

        // Parse product_images if available
        if (item['product_images'] != null && item['product_images'] is List) {
          product.gallery = (item['product_images'] as List)
              .map(
                (e) => ProductImage.fromMap({
                  'id': e['id']?.toString() ?? '',
                  'product_id': product.id,
                  'url': e['url']?.toString() ?? '',
                  'position': e['position'] ?? 0,
                }),
              )
              .toList();
        }

        // Debug: Print image info
        print(
          'Product: ${product.name}, imageUrl: ${product.imageUrl}, gallery: ${product.gallery.length} images',
        );

        products.add(product);
      }

      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .eq('category_id', categoryId);

      return (response as List).map((e) => Product.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }

  /// Get Single Product with images
  Future<Product?> getProduct(String id) async {
    try {
      final response = await _client
          .from('products')
          .select('*, product_images(*)')
          .eq('id', id)
          .single();

      final product = Product.fromMap(response);

      // Parse images if joined
      if (response['product_images'] != null) {
        product.gallery = (response['product_images'] as List)
            .map((e) => ProductImage.fromMap(e))
            .toList();
      }

      return product;
    } catch (e) {
      print('Error fetching product $id: $e');
      return null;
    }
  }

  /// Get Categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .order('name');

      print('Categories response: ${response.length} items');
      return (response as List).map((e) => Category.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // ================= Profile =================
  Future<Profile?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return Profile.fromMap(response);
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception("User must be logged in");

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _client.from('profiles').update(updates).eq('id', user.id);
  }

  // ================= Cart =================
  Future<Cart> getOrCreateCart() async {
    final user = currentUser;
    if (user == null) throw Exception("User must be logged in");

    // Try to find existing cart
    final existing = await _client
        .from('carts')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      return Cart.fromMap(existing);
    }

    // Create new cart
    final newCart = await _client
        .from('carts')
        .insert({'user_id': user.id})
        .select()
        .single();

    return Cart.fromMap(newCart);
  }

  Future<List<CartItem>> getCartItems(String cartId) async {
    final response = await _client
        .from('cart_items')
        .select('*, products(*, product_images(id, url, position))')
        .eq('cart_id', cartId);

    print('📦 CART ITEMS RESPONSE: ${response.length} items');

    final cartItems = <CartItem>[];
    for (final item in response) {
      final cartItem = CartItem.fromMap(item);

      print('🛒 Cart Item: ${cartItem.product?.name}');
      print('   - Product imageUrl: ${cartItem.product?.imageUrl}');
      print('   - Raw product_images: ${item['products']?['product_images']}');

      // Parse product_images if available
      if (cartItem.product != null &&
          item['products'] != null &&
          item['products']['product_images'] != null &&
          item['products']['product_images'] is List) {
        cartItem.product!.gallery = (item['products']['product_images'] as List)
            .map(
              (e) => ProductImage.fromMap({
                'id': e['id']?.toString() ?? '',
                'product_id': cartItem.product!.id,
                'url': e['url']?.toString() ?? '',
                'position': e['position'] ?? 0,
              }),
            )
            .toList();
        print(
          '   - Parsed gallery: ${cartItem.product!.gallery.length} images',
        );
        if (cartItem.product!.gallery.isNotEmpty) {
          print(
            '   - First gallery image: ${cartItem.product!.gallery.first.url}',
          );
        }
      } else {
        print('   - No product_images found in response');
      }

      cartItems.add(cartItem);
    }

    return cartItems;
  }

  Future<void> addToCart(String cartId, String productId, int quantity) async {
    await _client.from('cart_items').upsert({
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
    }, onConflict: 'cart_id, product_id');
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await _client
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', cartItemId);
    }
  }

  Future<void> clearCart(String cartId) async {
    await _client.from('cart_items').delete().eq('cart_id', cartId);
  }

  // ================= Storage =================
  Future<void> debugBuckets() async {
    try {
      final buckets = await _client.storage.listBuckets();
      print('-------- AVAILABLE BUCKETS --------');
      for (final bucket in buckets) {
        print('Bucket: ${bucket.name}, Public: ${bucket.public}');
      }
      print('-----------------------------------');
    } catch (e) {
      print('Error listing buckets: $e');
    }
  }

  Future<String?> uploadProfileImage(File file, String userId) async {
    // Debug buckets before upload
    await debugBuckets();

    String bucketName = 'users';

    try {
      bucketName = 'users';
      // removed listBuckets check as it requires extra permissions

      // 2. CHECK FILE
      if (!file.existsSync()) {
        throw Exception('File does not exist at path: ${file.path}');
      }

      final fileExt = file.path.split('.').last;
      // Sanitize filename: replace colons and spaces
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll(' ', '_');
      final fileName = '$timestamp.$fileExt';
      final filePath = '$userId/$fileName';

      print('🚀 Uploading to bucket: "$bucketName", path: "$filePath"');

      // 3. UPLOAD
      await _client.storage
          .from(bucketName)
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      print('✅ Upload successful');

      // 4. GET URL
      final imageUrl = _client.storage.from(bucketName).getPublicUrl(filePath);

      print('🔗 Image URL: $imageUrl');

      // Update Profile with new Avatar URL
      await updateProfile(avatarUrl: imageUrl);

      return imageUrl;
    } catch (e) {
      print('❌ Error uploading profile image (Details): $e');
      if (e.toString().contains('404')) {
        print(
          '👉 Tip: Ensure the bucket "users" exists and is set to PUBLIC in Supabase Dashboard.',
        );
      }
      return null;
    }
  }

  // ================= Favorites =================
  Future<List<Favorite>> getFavorites() async {
    final user = currentUser;
    if (user == null) return [];

    final response = await _client
        .from('favorites')
        .select('*, products(*, product_images(id, url, position))')
        .eq('user_id', user.id);

    return (response as List).map((e) => Favorite.fromMap(e)).toList();
  }

  Future<void> toggleFavorite(String productId) async {
    final user = currentUser;
    if (user == null) return;

    final existing = await _client
        .from('favorites')
        .select()
        .eq('user_id', user.id)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      await _client.from('favorites').delete().eq('id', existing['id']);
    } else {
      await _client.from('favorites').insert({
        'user_id': user.id,
        'product_id': productId,
      });
    }
  }

  // ================= Workshop Bookings =================

  /// Get all service types
  Future<List<ServiceType>> getServiceTypes() async {
    try {
      final response = await _client
          .from('service_types')
          .select('*')
          .eq('is_active', true)
          .order('position', ascending: true);

      return (response as List).map((e) => ServiceType.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching service types: $e');
      return [];
    }
  }

  /// Get products for a service type
  Future<List<ServiceTypeProduct>> getServiceProducts(
    String serviceTypeId,
  ) async {
    try {
      final response = await _client
          .from('service_type_products')
          .select('*, products(*, product_images(id, url, position))')
          .eq('service_type_id', serviceTypeId);

      return (response as List).map((item) {
        final serviceProduct = ServiceTypeProduct.fromMap(item);

        // Parse product images if joined
        if (serviceProduct.product != null &&
            item['products'] != null &&
            item['products']['product_images'] != null &&
            item['products']['product_images'] is List) {
          serviceProduct.product!.gallery =
              (item['products']['product_images'] as List)
                  .map(
                    (e) => ProductImage.fromMap({
                      'id': e['id']?.toString() ?? '',
                      'product_id': serviceProduct.product!.id,
                      'url': e['url']?.toString() ?? '',
                      'position': e['position'] ?? 0,
                    }),
                  )
                  .toList();
        }

        return serviceProduct;
      }).toList();
    } catch (e) {
      print('Error fetching service products: $e');
      return [];
    }
  }

  /// Create a new booking
  Future<void> createBooking({
    required String serviceTypeId,
    required String serviceTypeName,
    required Map<String, dynamic> vehicleInfo,
    required DateTime scheduledDate,
    String? notes,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception("User must be logged in");

    await _client.from('workshop_bookings').insert({
      'user_id': user.id,
      'service_type_id': serviceTypeId,
      'service_type': serviceTypeName,
      'vehicle_info': vehicleInfo,
      'scheduled_date': scheduledDate.toIso8601String(),
      'notes': notes,
      'status': 'scheduled',
    });
  }

  /// Get user's bookings
  Future<List<WorkshopBooking>> getUserBookings() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('workshop_bookings')
          .select('*')
          .eq('user_id', user.id)
          .order('scheduled_date', ascending: false);

      return (response as List).map((e) => WorkshopBooking.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  // ================= Orders =================
  Future<String?> createOrder({
    required double totalAmount,
    required String paymentMethod,
    required Map<String, dynamic> shippingAddress,
    required List<CartItem> items,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception("User must be logged in");

    try {
      // 1. Create Order
      final orderResponse = await _client
          .from('orders')
          .insert({
            'user_id': user.id,
            'status': 'pending',
            'total_amount': totalAmount,
            'total': totalAmount,
            'payment_method': paymentMethod,
            'shipping_address': shippingAddress,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final orderId = orderResponse['id'] as String;

      // 2. Create Order Items
      final orderItemsData = items.map((item) {
        return {
          'order_id': orderId,
          'product_id': item.productId,
          'title':
              item.product?.name ?? item.product?.title ?? 'Unknown Product',
          'unit_price': item.product?.price ?? 0.0,
          'quantity': item.quantity,
          'subtotal': (item.product?.price ?? 0.0) * item.quantity,
          'price': (item.product?.price ?? 0.0),
        };
      }).toList();

      await _client.from('order_items').insert(orderItemsData);

      // 3. Decrease product stock
      for (final item in items) {
        if (item.productId.isNotEmpty && item.quantity > 0) {
          // Get current stock
          final productResponse = await _client
              .from('products')
              .select('stock')
              .eq('id', item.productId)
              .single();

          final currentStock = productResponse['stock'] as int? ?? 0;
          final newStock = (currentStock - item.quantity).clamp(
            0,
            currentStock,
          );

          // Update stock
          await _client
              .from('products')
              .update({'stock': newStock})
              .eq('id', item.productId);
        }
      }

      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  Future<List<Order>> getOrders() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((e) => Order.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<Order?> getOrder(String orderId) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      return Order.fromMap(response);
    } catch (e) {
      print('Error fetching order $orderId: $e');
      return null;
    }
  }

  Future<List<OrderItem>> getOrderDetails(String orderId) async {
    try {
      final response = await _client
          .from('order_items')
          .select('*, products(*, product_images(id, url, position))')
          .eq('order_id', orderId);

      print('📋 ORDER ITEMS RESPONSE: ${response.length} items');

      final orderItems = <OrderItem>[];
      for (final item in response) {
        final orderItem = OrderItem.fromMap(item);

        print('📦 Order Item: ${orderItem.title}');
        print('   - Product: ${orderItem.product?.name}');
        print('   - Product imageUrl: ${orderItem.product?.imageUrl}');
        print(
          '   - Raw product_images: ${item['products']?['product_images']}',
        );

        // Parse product_images if available
        if (orderItem.product != null &&
            item['products'] != null &&
            item['products']['product_images'] != null &&
            item['products']['product_images'] is List) {
          orderItem.product!.gallery =
              (item['products']['product_images'] as List)
                  .map(
                    (e) => ProductImage.fromMap({
                      'id': e['id']?.toString() ?? '',
                      'product_id': orderItem.product!.id,
                      'url': e['url']?.toString() ?? '',
                      'position': e['position'] ?? 0,
                    }),
                  )
                  .toList();
          print(
            '   - Parsed gallery: ${orderItem.product!.gallery.length} images',
          );
          if (orderItem.product!.gallery.isNotEmpty) {
            print(
              '   - First gallery image: ${orderItem.product!.gallery.first.url}',
            );
          }
        } else {
          print('   - No product_images found in response');
        }

        orderItems.add(orderItem);
      }

      return orderItems;
    } catch (e) {
      print('Error fetching order items: $e');
      return [];
    }
  }
}
