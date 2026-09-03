import 'package:flutter/material.dart';
import '../cart/view/cart_view.dart';
import '../categories/view/categories_view.dart';
import '../home/view/home_view.dart';
import '../profile/view/profile_view.dart';
import '../wishlist/view/wishlist_view.dart';
import 'widgets/custom_bottom_nav.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _currentIndex = args;
    }
  }

  final List<Widget> _screens = [
    const HomeView(),
    const CategoriesView(),
    const CartView(),
    const WishlistView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
