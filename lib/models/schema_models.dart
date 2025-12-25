import 'package:flutter/material.dart';

class Profile {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String role;

  Profile({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.role = 'customer',
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      email: map['email'],
      fullName: map['full_name'],
      phone: map['phone'],
      avatarUrl: map['avatar_url'],
      role: map['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
    };
  }
}

class Category {
  final String id;
  final String name;
  final String? slug;
  final String? icon;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    this.slug,
    this.icon,
    this.imageUrl,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    // Try multiple possible image column names
    String? imageUrl = map['image_url']?.toString();
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = map['imageUrl']?.toString();
    }
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = map['image']?.toString();
    }
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = map['icon']?.toString();
    }

    // Debug print
    print('Category keys: ${map.keys.toList()}');
    print('Category: ${map['name']}, image: $imageUrl');

    return Category(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown',
      slug: map['slug']?.toString(),
      icon: map['icon']?.toString(),
      imageUrl: imageUrl,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String? title;
  final String? description;
  final double price;
  final double? comparePrice;
  final int stock;
  final double rating;
  final String? imageUrl;
  final String? categoryId;
  final String? categoryName;
  final String? brand;
  final String? carModel;
  final List<String> tags;
  final Map<String, dynamic> meta;

  // Helper to store additional images from product_images table if needed
  List<ProductImage> gallery = [];

  Product({
    required this.id,
    required this.name,
    this.title,
    this.description,
    required this.price,
    this.comparePrice,
    this.stock = 0,
    this.rating = 0.0,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.brand,
    this.carModel,
    this.tags = const [],
    this.meta = const {},
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    // Try multiple possible image column names
    String? imageUrl = map['image_url']?.toString();
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = map['imageUrl']?.toString();
    }
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = map['image']?.toString();
    }
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = map['thumbnail']?.toString();
    }
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = map['img']?.toString();
    }

    // Debug print the map keys
    print('Product keys: ${map.keys.toList()}');
    print('Product image_url value: ${map['image_url']}');

    return Product(
      id: map['id']?.toString() ?? '',
      name:
          map['name']?.toString() ??
          map['title']?.toString() ??
          'Unknown Product',
      title: map['title']?.toString(),
      description: map['description']?.toString(),
      price: map['price'] != null ? (map['price'] as num).toDouble() : 0.0,
      comparePrice: map['compare_price'] != null
          ? (map['compare_price'] as num).toDouble()
          : null,
      stock: map['stock'] ?? 0,
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : 0.0,
      imageUrl: imageUrl,
      categoryId: map['category_id']?.toString(),
      categoryName:
          map['category_name']?.toString() ??
          map['categories']?['name']?.toString(),
      brand: map['brand']?.toString(),
      carModel: map['car_model']?.toString(),
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      meta: map['meta'] ?? {},
    );
  }

  // Compatibility getters
  // Return imageUrl as the first image, and any gallery images
  List<String> get images {
    final list = <String>[];
    if (imageUrl != null && imageUrl!.isNotEmpty) list.add(imageUrl!);
    list.addAll(gallery.map((e) => e.url));
    return list;
  }

  List<Color> get colors => []; // Return empty or parse from meta if needed
  String get category => categoryName ?? categoryId ?? 'General';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'price': price,
      'compare_price': comparePrice,
      'stock': stock,
      'rating': rating,
      'image_url': imageUrl,
      'category_id': categoryId,
      'tags': tags,
      'meta': meta,
    };
  }
}

class ProductImage {
  final String id;
  final String productId;
  final String url;
  final String? alt;
  final int position;

  ProductImage({
    required this.id,
    required this.productId,
    required this.url,
    this.alt,
    this.position = 0,
  });

  factory ProductImage.fromMap(Map<String, dynamic> map) {
    return ProductImage(
      id: map['id'],
      productId: map['product_id'],
      url: map['url'],
      alt: map['alt'],
      position: map['position'] ?? 0,
    );
  }
}

class Order {
  final String id;
  final String? userId;
  final String status;
  final double totalAmount;
  final Map<String, dynamic> shippingAddress;
  final DateTime createdAt;

  Order({
    required this.id,
    this.userId,
    this.status = 'pending',
    required this.totalAmount,
    this.shippingAddress = const {},
    required this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['user_id'],
      status: map['status'] ?? 'pending',
      totalAmount: (map['total_amount'] as num).toDouble(),
      shippingAddress: map['shipping_address'] ?? {},
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String? productId;
  final String? title;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    this.title,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.product,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      title: map['title'],
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: map['quantity'],
      subtotal: (map['subtotal'] as num).toDouble(),
      product: map['products'] != null
          ? Product.fromMap(map['products'])
          : null,
    );
  }
}

class Cart {
  final String id;
  final String? userId;
  final DateTime createdAt;

  Cart({required this.id, this.userId, required this.createdAt});

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class CartItem {
  final String id;
  final String cartId;
  final String productId;
  final int quantity;
  final Product? product; // Joined Product

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    this.quantity = 1,
    this.product,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      cartId: map['cart_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      product: map['products'] != null
          ? Product.fromMap(map['products'])
          : null,
    );
  }
}

class Favorite {
  final String id;
  final String userId;
  final String productId;
  final Product? product; // Joined Product

  Favorite({
    required this.id,
    required this.userId,
    required this.productId,
    this.product,
  });

  factory Favorite.fromMap(Map<String, dynamic> map) {
    Product? product;
    if (map['products'] != null) {
      product = Product.fromMap(map['products']);

      // Parse product_images if available
      if (map['products']['product_images'] != null &&
          map['products']['product_images'] is List) {
        product.gallery = (map['products']['product_images'] as List)
            .map(
              (e) => ProductImage.fromMap({
                'id': e['id']?.toString() ?? '',
                'product_id': product!.id,
                'url': e['url']?.toString() ?? '',
                'position': e['position'] ?? 0,
              }),
            )
            .toList();
      }
    }

    return Favorite(
      id: map['id'],
      userId: map['user_id'],
      productId: map['product_id'],
      product: product,
    );
  }
}

class ServiceType {
  final String id;
  final String name;
  final String? description;
  final int? estimatedDuration; // in minutes
  final double? basePrice;
  final String? icon;
  final bool isActive;
  final int position;
  final DateTime createdAt;

  ServiceType({
    required this.id,
    required this.name,
    this.description,
    this.estimatedDuration,
    this.basePrice,
    this.icon,
    this.isActive = true,
    this.position = 0,
    required this.createdAt,
  });

  factory ServiceType.fromMap(Map<String, dynamic> map) {
    return ServiceType(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      estimatedDuration: map['estimated_duration'],
      basePrice: map['base_price'] != null
          ? (map['base_price'] as num).toDouble()
          : null,
      icon: map['icon'],
      isActive: map['is_active'] ?? true,
      position: map['position'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class WorkshopBooking {
  final String id;
  final String userId;
  final String? serviceTypeId;
  final String serviceType;
  final Map<String, dynamic> vehicleInfo;
  final DateTime scheduledDate;
  final String status;
  final String? notes;
  final DateTime createdAt;

  WorkshopBooking({
    required this.id,
    required this.userId,
    this.serviceTypeId,
    required this.serviceType,
    required this.vehicleInfo,
    required this.scheduledDate,
    this.status = 'scheduled',
    this.notes,
    required this.createdAt,
  });

  factory WorkshopBooking.fromMap(Map<String, dynamic> map) {
    return WorkshopBooking(
      id: map['id'],
      userId: map['user_id'],
      serviceTypeId: map['service_type_id'],
      serviceType: map['service_type'],
      vehicleInfo: map['vehicle_info'] ?? {},
      scheduledDate: DateTime.parse(map['scheduled_date']),
      status: map['status'] ?? 'scheduled',
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class ServiceTypeProduct {
  final String id;
  final String serviceTypeId;
  final String productId;
  final int quantity;
  final Product? product;

  ServiceTypeProduct({
    required this.id,
    required this.serviceTypeId,
    required this.productId,
    this.quantity = 1,
    this.product,
  });

  factory ServiceTypeProduct.fromMap(Map<String, dynamic> map) {
    return ServiceTypeProduct(
      id: map['id'],
      serviceTypeId: map['service_type_id'],
      productId: map['product_id'],
      quantity: map['quantity'] ?? 1,
      product: map['products'] != null
          ? Product.fromMap(map['products'])
          : null,
    );
  }
}
