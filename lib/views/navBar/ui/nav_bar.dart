import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../favorite_view.dart';
import '../../home_view.dart';
import '../../profile_view.dart';
import 'Store_view.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _pageIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const StoreView(),
    const FavoriteView(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: AppColors.backgroundLight,
        color: AppColors.primaryBlue,
        buttonBackgroundColor: AppColors.secondaryOrange,
        height: 60,
        index: _pageIndex,
        animationDuration: const Duration(milliseconds: 300),
        items: <Widget>[
          Icon(
            Icons.home,
            size: 30,
            color: _pageIndex == 0 ? AppColors.white : AppColors.white,
          ),
          Icon(
            Icons.store,
            size: 30,
            color: _pageIndex == 1 ? AppColors.white : AppColors.white,
          ),
          Icon(
            Icons.favorite,
            size: 30,
            color: _pageIndex == 2 ? AppColors.white : AppColors.white,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: _pageIndex == 3 ? AppColors.white : AppColors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
