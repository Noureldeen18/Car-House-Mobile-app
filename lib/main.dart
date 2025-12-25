import 'package:car_house/views/auth/ui/onboarding_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants/supabase_constants.dart';
import 'providers/favorite_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/supabase_auth_provider.dart';
import 'providers/app_data_provider.dart';
import 'views/navBar/ui/nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  /// نعمل instance من FavoriteProvider
  final favoriteProvider = FavoriteProvider();
  await favoriteProvider.loadFavorites();

  /// نعمل instance من CartProvider
  final cartProvider = CartProvider();
  await cartProvider.loadCart(); // ✅ تحميل المنتجات المحفوظة

  // No longer strictly needed since Supabase handles auth persistence,
  // but we can keep it for now or rely on SupabaseAuthProvider
  // Better to check Supabase session
  final session = Supabase.instance.client.auth.currentSession;
  final isLoggedIn = session != null;

  runApp(
    MyApp(
      favoriteProvider: favoriteProvider,
      cartProvider: cartProvider,
      isLoggedIn: isLoggedIn,
    ),
  );
}

class MyApp extends StatelessWidget {
  final FavoriteProvider favoriteProvider;
  final CartProvider cartProvider;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.favoriteProvider,
    required this.cartProvider,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: favoriteProvider),
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider(create: (_) => SupabaseAuthProvider()),
        ChangeNotifierProvider(create: (_) => AppDataProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Auto Shop',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
        ),
        // Listen to Auth State logic is better inside a wrapper, but for now:
        home: isLoggedIn ? const NavBar() : const OnBoardingView(),
      ),
    );
  }
}
