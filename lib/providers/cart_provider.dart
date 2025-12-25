import 'package:flutter/material.dart';
import '../models/schema_models.dart' as schema;
import '../services/supabase_service.dart';

class CartProvider with ChangeNotifier {
  final SupabaseService _service = SupabaseService();
  String? _cartId;
  List<schema.CartItem> _items = [];
  bool _isLoading = false;

  List<schema.CartItem> get items => _items;
  bool get isLoading => _isLoading;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(
    0,
    (sum, item) => sum + ((item.product?.price ?? 0) * item.quantity),
  );

  double get tax => subtotal * 0.14;

  double get totalPrice => subtotal + tax;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cart = await _service.getOrCreateCart();
      _cartId = cart.id;
      _items = await _service.getCartItems(_cartId!);
    } catch (e) {
      debugPrint("Error loading cart: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(schema.Product product, {int quantity = 1}) async {
    if (_cartId == null) await loadCart();
    if (_cartId == null) return;

    // Check if item exists to increment
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );

    try {
      if (existingIndex >= 0) {
        final currentItem = _items[existingIndex];
        final newQty = currentItem.quantity + quantity;
        await _service.addToCart(_cartId!, product.id, newQty);
      } else {
        await _service.addToCart(_cartId!, product.id, quantity);
      }
      await loadCart();
    } catch (e) {
      debugPrint("Error adding to cart: $e");
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    // Optimistic update - remove from local list first
    final removedIndex = _items.indexWhere((item) => item.id == cartItemId);
    schema.CartItem? removedItem;
    if (removedIndex >= 0) {
      removedItem = _items[removedIndex];
      _items.removeAt(removedIndex);
      notifyListeners();
    }

    try {
      await _service.removeFromCart(cartItemId);
    } catch (e) {
      debugPrint("Error removing from cart: $e");
      // Rollback on error
      if (removedItem != null && removedIndex >= 0) {
        _items.insert(removedIndex, removedItem);
        notifyListeners();
      }
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    // Find item and update locally first (optimistic update)
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return;

    final oldQuantity = _items[index].quantity;

    // Create updated item with new quantity
    final oldItem = _items[index];
    _items[index] = schema.CartItem(
      id: oldItem.id,
      cartId: oldItem.cartId,
      productId: oldItem.productId,
      quantity: newQuantity,
      product: oldItem.product,
    );
    notifyListeners();

    try {
      await _service.updateCartItemQuantity(cartItemId, newQuantity);
    } catch (e) {
      debugPrint("Error updating quantity: $e");
      // Rollback on error
      _items[index] = schema.CartItem(
        id: oldItem.id,
        cartId: oldItem.cartId,
        productId: oldItem.productId,
        quantity: oldQuantity,
        product: oldItem.product,
      );
      notifyListeners();
    }
  }

  // Helper for UI - optimistic updates, no page refresh
  void increaseQuantity(schema.CartItem item) {
    updateQuantity(item.id, item.quantity + 1);
  }

  void decreaseQuantity(schema.CartItem item) {
    if (item.quantity > 1) {
      updateQuantity(item.id, item.quantity - 1);
    } else {
      removeFromCart(item.id);
    }
  }

  Future<void> clearCart() async {
    if (_cartId == null) return;

    // Optimistic update - clear local list first
    final oldItems = List<schema.CartItem>.from(_items);
    _items.clear();
    notifyListeners();

    try {
      await _service.clearCart(_cartId!);
    } catch (e) {
      debugPrint("Error clearing cart: $e");
      // Rollback on error
      _items = oldItems;
      notifyListeners();
    }
  }
}
