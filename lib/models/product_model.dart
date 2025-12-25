import 'package:flutter/material.dart';
import '../views/product/category/barke.dart';
import '../views/product/category/engine_parts.dart';
import '../views/product/category/maintenance_fluids.dart';
import '../views/product/category/maintenance_parts.dart';
import '../views/product/category/suspension.dart';

class Product {
  final int id;
  final String title;
  final List<String> images;
  final List<Color> colors;
  final double rating;
  final double price;
  final String category;
  final String description;

  Product({
    required this.id,
    required this.images,
    required this.colors,
    this.rating = 0.0,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
  });

  /// ✅ تحويل المنتج إلى Map (للتخزين)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'images': images,
      'colors': colors.map((c) => c.value).toList(), // نخزن قيمة اللون كـ int
      'rating': rating,
      'price': price,
      'category': category,
      'description': description,
    };
  }

  /// ✅ إنشاء منتج من Map (للاسترجاع)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      title: map['title'],
      images: List<String>.from(map['images']),
      colors: (map['colors'] as List).map((c) => Color(c)).toList(),
      rating: (map['rating'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
      category: map['category'],
      description: map['description'],
    );
  }
}

// دمج القوائم من الكاتيجوري المختلفة
List<Product> demoProducts = [
  ...brakeProducts,
  ...engineProducts,
  ...fluidsProducts,
  ...partsProducts,
  ...suspensionProducts,
];
