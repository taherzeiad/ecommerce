import 'package:ecommerce/core/extensions/context_extension.dart';
import 'package:ecommerce/core/routes/app_router.dart';
import 'package:ecommerce/core/routes/app_routes.dart';
import 'package:ecommerce/core/theme/app_theme.dart';
import 'package:ecommerce/core/widgets/privacy_gate.dart';
import 'package:ecommerce/presentation/cart/view_model/cart_view_model.dart';
import 'package:ecommerce/presentation/theme/view_model/locale_view_model.dart';
import 'package:ecommerce/presentation/theme/view_model/theme_view_model.dart';
import 'package:ecommerce/presentation/wishlist/view_model/wishlist_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

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
          return MaterialApp(
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
            builder: (context, child) {
              return ResponsiveBreakpoints.builder(
                child: Builder(
                  builder: (context) {
                    return MaxWidthBox(
                      maxWidth: 1200,
                      background: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: ResponsiveScaledBox(
                        width: ResponsiveValue<double>(
                          context,
                          conditionalValues: [
                            const Condition.equals(name: MOBILE, value: 375),
                            const Condition.between(
                              start: 600,
                              end: 800,
                              name: TABLET,
                              value: 600,
                            ),
                            const Condition.greaterThan(
                              name: TABLET,
                              value: 1000,
                            ),
                          ],
                        ).value,
                        child: PrivacyGate(child: child!),
                      ),
                    );
                  },
                ),
                breakpoints: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 800, name: TABLET),
                  const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  const Breakpoint(
                    start: 1921,
                    end: double.infinity,
                    name: '4K',
                  ),
                ],
              );
            },
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
