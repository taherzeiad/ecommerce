import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'presentation/cart/view_model/cart_view_model.dart';
import 'presentation/wishlist/view_model/wishlist_view_model.dart';
import 'presentation/theme/view_model/theme_view_model.dart';

class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeViewModel.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
