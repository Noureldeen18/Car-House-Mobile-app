import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/schema_models.dart';

class SupabaseAuthProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  User? _user;
  Profile? _profile;
  bool _isLoading = false;

  User? get user => _user;
  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  SupabaseAuthProvider() {
    _init();
  }

  void _init() {
    _user = _service.currentUser;
    if (_user != null) {
      _loadProfile();
    }

    _service.authStateChanges.listen((data) {
      final Session? session = data.session;

      _user = session?.user;
      if (_user != null) {
        _loadProfile();
      } else {
        _profile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadProfile() async {
    try {
      _profile = await _service.getProfile();
      notifyListeners();
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _service.signIn(email: email, password: password);
      return null; // Success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signUp(
    String email,
    String password, {
    String? fullName,
    String? phone,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _service.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
  }
}
