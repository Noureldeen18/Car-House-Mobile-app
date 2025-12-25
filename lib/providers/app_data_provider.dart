import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/schema_models.dart';

class AppDataProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  List<Category> _categories = [];
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AppDataProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getCategories(),
        _service.getProducts(),
      ]);

      _categories = results[0] as List<Category>;
      _products = results[1] as List<Product>;
    } catch (e) {
      _error = e.toString();
      print('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> getProductsByCategory(String categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }
}
