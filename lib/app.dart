import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce/core/constants/app_strings.dart';
import 'package:ecommerce/core/routes/app_router.dart';
import 'package:ecommerce/core/routes/app_routes.dart';
import 'package:ecommerce/core/theme/app_theme.dart';
import 'package:ecommerce/core/extensions/context_extension.dart';
import 'package:ecommerce/presentation/cart/view_model/cart_view_model.dart';
import 'package:ecommerce/presentation/theme/view_model/locale_view_model.dart';
import 'package:ecommerce/presentation/theme/view_model/theme_view_model.dart';
import 'package:ecommerce/presentation/wishlist/view_model/wishlist_view_model.dart';
import 'package:ecommerce/core/widgets/privacy_gate.dart';

class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => LocaleViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
      ],
      child: Consumer2<ThemeViewModel, LocaleViewModel>(
        builder: (context, themeViewModel, localeViewModel, _) {
          return PrivacyGate(
            child: MaterialApp(
              onGenerateTitle: (context) => context.tr('app_name', listen: false),
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeViewModel.themeMode,
              locale: localeViewModel.locale,
              supportedLocales: const [Locale('en'), Locale('ar')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute: AppRoutes.splash,
              onGenerateRoute: AppRouter.generateRoute,
            ),
          );
        },
      ),
    );
  }
}
