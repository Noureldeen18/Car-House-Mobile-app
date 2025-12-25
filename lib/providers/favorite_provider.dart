import 'package:flutter/material.dart';
import '../models/schema_models.dart';
import '../services/supabase_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();
  List<Favorite> _favorites = []; // Stores Favorite objects
  Set<String> _favoriteIds = {}; // Quick lookup set for instant UI updates
  bool _isLoading = false;

  List<Product> get favorites => _favorites
      .where((f) => f.product != null)
      .map((f) => f.product!)
      .toList();

  bool get isLoading => _isLoading;

  /// Load Favorites from Supabase
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _service.getFavorites();
      // Rebuild the quick lookup set
      _favoriteIds = _favorites.map((f) => f.productId).toSet();
    } catch (e) {
      debugPrint("Error loading favorites: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if product is in favorite (instant lookup)
  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  /// Toggle Favorite with optimistic update for instant UI response
  Future<void> toggleFavorite(String productId) async {
    final wasInFavorites = _favoriteIds.contains(productId);

    // Optimistic update: Toggle immediately in UI
    if (wasInFavorites) {
      _favoriteIds.remove(productId);
      _favorites.removeWhere((f) => f.productId == productId);
    } else {
      _favoriteIds.add(productId);
      // Add a placeholder favorite (product will be loaded on next full refresh)
      _favorites.add(
        Favorite(
          id: 'temp_$productId', // Temporary ID
          userId: '',
          productId: productId,
        ),
      );
    }
    notifyListeners(); // Instant UI update!

    try {
      // Perform actual server operation in background
      await _service.toggleFavorite(productId);

      // Reload to sync with server (silent refresh)
      final updatedFavorites = await _service.getFavorites();
      _favorites = updatedFavorites;
      _favoriteIds = _favorites.map((f) => f.productId).toSet();
      notifyListeners();
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
      // Rollback on error
      if (wasInFavorites) {
        _favoriteIds.add(productId);
      } else {
        _favoriteIds.remove(productId);
        _favorites.removeWhere((f) => f.productId == productId);
      }
      notifyListeners();
    }
  }
}
