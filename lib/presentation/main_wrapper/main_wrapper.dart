import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../categories/view/categories_view.dart';
import '../home/view/home_view.dart';
import '../notifications/view_model/notifications_view_model.dart';
import '../profile/view_model/profile_view_model.dart';
import '../wishlist/view/wishlist_view.dart';
import '../wishlist/view_model/wishlist_view_model.dart';
import 'widgets/custom_bottom_nav.dart';
import '../../core/routes/app_routes.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  static const int homeTab = 0;
  static const int categoriesTab = 1;
  static const int wishlistTab = 3;

  /// Switches the tab of the enclosing main screen. Returns `false` when
  /// [context] is not inside one (then callers navigate instead).
  static bool switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainWrapperState>();
    if (state == null) return false;
    state._select(index);
    return true;
  }

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  bool _readInitialTab = false;

  @override
  void initState() {
    super.initState();
    // Load the signed-in user's data once on entry, so wishlist hearts, the
    // greeting and the notification badge are right from the start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileViewModel>().refresh();
      context.read<WishlistViewModel>().fetchWishlist();
      context.read<NotificationsViewModel>().fetchNotifications();
      context.read<NotificationsViewModel>().initRealtime();
    });
  }

  void _select(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs again whenever another route is pushed or popped on top; only
    // the first call may pick the tab, or the user's choice gets reset.
    if (_readInitialTab) return;
    _readInitialTab = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _currentIndex = args;
    }
  }

  final List<Widget> _screens = [
    const HomeView(),
    const CategoriesView(),
    const SizedBox.shrink(), // Cart is now a separate screen
    const WishlistView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.02),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.cart);
          } else {
            _select(index);
          }
        },
      ),
    );
  }
}
