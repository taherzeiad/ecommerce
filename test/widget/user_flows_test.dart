import 'package:ecommerce/core/constants/app_strings.dart';
import 'package:ecommerce/core/widgets/custom_search_bar.dart';
import 'package:ecommerce/core/localization/translations.dart';
import 'package:ecommerce/core/routes/app_routes.dart';
import 'package:ecommerce/presentation/auth/forgot_password/reset_password_view.dart';
import 'package:ecommerce/presentation/auth/forgot_password/verify_account_view.dart';
import 'package:ecommerce/presentation/auth/login/login_view.dart';
import 'package:ecommerce/presentation/auth/signup/signup_view.dart';
import 'package:ecommerce/presentation/auth/success/success_view.dart';
import 'package:ecommerce/presentation/cart/view/cart_view.dart';
import 'package:ecommerce/presentation/categories/view/categories_view.dart';
import 'package:ecommerce/presentation/checkout/view/checkout_view.dart';
import 'package:ecommerce/presentation/checkout/view/order_success_view.dart';
import 'package:ecommerce/presentation/home/view/home_view.dart';
import 'package:ecommerce/presentation/home/widgets/product_card.dart';
import 'package:ecommerce/presentation/main_wrapper/main_wrapper.dart';
import 'package:ecommerce/presentation/onboarding/view/onboarding_view.dart';
import 'package:ecommerce/presentation/product_details/view/all_products_view.dart';
import 'package:ecommerce/presentation/product_details/view/product_details_view.dart';
import 'package:ecommerce/presentation/reviews/view/reviews_view.dart';
import 'package:ecommerce/presentation/search/view/filter_sort_view.dart';
import 'package:ecommerce/presentation/settings/view/settings_view.dart';
import 'package:ecommerce/presentation/wishlist/view/wishlist_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fakes.dart';
import '../helpers/flow_helpers.dart';
import '../helpers/test_app.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    useFakeNetworkImages();
  });

  group('Onboarding and authentication', () {
    testWidgets('first launch walks through onboarding to login, once', (
      tester,
    ) async {
      await TestBackend(loggedIn: false).install(onboardingCompleted: false);
      await launchApp(tester);
      expect(find.byType(OnboardingView), findsOneWidget);

      await tapOn(tester, find.text(t('next')));
      await tapOn(tester, find.text(t('next')));
      await tapOn(tester, find.text(t('start')));

      expect(find.byType(LoginView), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppStrings.onboardingCompletedPrefKey), isTrue);
    });

    testWidgets('skip on onboarding goes straight to login', (tester) async {
      await TestBackend(loggedIn: false).install(onboardingCompleted: false);
      await launchApp(tester);

      await tapOn(tester, find.text(t('skip')));

      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('login validates input, then opens the shop', (tester) async {
      final backend = TestBackend(loggedIn: false);
      await backend.install();
      await launchApp(tester);
      final loginButton = find.widgetWithText(ElevatedButton, t('login'));

      await tapOn(tester, loginButton);
      expect(find.text('Please fill in all fields'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'omar@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'secret1');
      await tapOn(tester, loginButton, wait: const Duration(seconds: 1));

      expect(find.byType(MainWrapper), findsOneWidget);
      expect(find.textContaining('Omar'), findsWidgets);
      expect(
        rootNavigator(tester).canPop(),
        isFalse,
        reason: 'back must not return to the login screen',
      );
    });

    testWidgets('wrong password shows a translated error', (tester) async {
      final backend = TestBackend(loggedIn: false);
      backend.auth.loginError = Exception('Invalid login credentials');
      await backend.install();
      await launchApp(tester);

      await tester.enterText(find.byType(TextField).at(0), 'omar@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrong1');
      await tapOn(tester, find.widgetWithText(ElevatedButton, t('login')));

      expect(find.text(t('error_invalid_credentials')), findsOneWidget);
      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('sign up leaves no auth screens behind', (tester) async {
      final backend = TestBackend(loggedIn: false);
      await backend.install();
      await launchApp(tester);

      await tapOn(tester, find.text(t('create_account')));
      expect(find.byType(SignupView), findsOneWidget);
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Omar Adam');
      await tester.enterText(fields.at(1), 'omar@example.com');
      await tester.enterText(fields.at(2), 'secret1');
      await tester.enterText(fields.at(3), 'secret1');
      await tapOn(tester, find.byType(Checkbox));
      await tapOn(
        tester,
        find.widgetWithText(ElevatedButton, t('signup_title')),
        wait: const Duration(seconds: 1),
      );

      expect(backend.auth.calls, ['signup:omar@example.com']);
      expect(find.byType(MainWrapper), findsOneWidget);
      expect(rootNavigator(tester).canPop(), isFalse);
    });

    testWidgets('forgot password: email → code → new password → success', (
      tester,
    ) async {
      final backend = TestBackend(loggedIn: false);
      await backend.install();
      await launchApp(tester);

      await tapOn(tester, find.text(t('forgot_password')));
      await tester.enterText(find.byType(TextField), 'omar@example.com');
      await tapOn(tester, find.widgetWithText(ElevatedButton, t('send')));
      expect(find.byType(VerifyAccountView), findsOneWidget);

      for (final digit in ['1', '2', '3', '4', '5', '6']) {
        await tapOn(
          tester,
          find.text(digit).last,
          wait: const Duration(milliseconds: 200),
        );
      }
      await pumpFor(tester);
      expect(find.byType(ResetPasswordView), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'newpass1');
      await tester.enterText(find.byType(TextField).at(1), 'newpass1');
      await tapOn(
        tester,
        find.widgetWithText(ElevatedButton, t('reset_password')),
      );
      expect(find.byType(SuccessView), findsOneWidget);
    });

    testWidgets('a rejected verification code is shown to the user', (
      tester,
    ) async {
      final backend = TestBackend(loggedIn: false);
      backend.auth.otpError = Exception('Token has expired or is invalid');
      await backend.install();
      await launchApp(tester);

      await tapOn(tester, find.text(t('forgot_password')));
      await tester.enterText(find.byType(TextField), 'omar@example.com');
      await tapOn(tester, find.widgetWithText(ElevatedButton, t('send')));
      for (final digit in ['1', '2', '3', '4', '5', '6']) {
        await tapOn(
          tester,
          find.text(digit).last,
          wait: const Duration(milliseconds: 200),
        );
      }
      await pumpFor(tester);

      expect(find.byType(VerifyAccountView), findsOneWidget);
      expect(find.text(t('error_otp_invalid')), findsOneWidget);
    });
  });

  group('Shopping', () {
    testWidgets('product → add 2 → cart → +1 → swipe to delete', (
      tester,
    ) async {
      final backend = TestBackend();
      await backend.install();
      await launchApp(tester);

      // MacBook is both a flash deal and a popular product.
      await tapOn(tester, find.text('MacBook Air').last);
      expect(find.byType(ProductDetailsView), findsOneWidget);

      await tapOn(tester, find.byIcon(Icons.add));
      await tapOn(tester, find.text(t('buy_now')));
      expect(backend.cart.rows.single.quantity, 2);

      await tapOn(tester, find.byIcon(Icons.shopping_cart_outlined));
      expect(find.byType(CartView), findsOneWidget);
      expect(find.text('MacBook Air'), findsOneWidget);

      await tapOn(tester, find.byIcon(Icons.add).first);
      expect(backend.cart.rows.single.quantity, 3);
      expect(find.text('3'), findsOneWidget);

      // (The "added to cart" SnackBar is a Dismissible too.)
      await tester.drag(
        find.ancestor(
          of: find.text('MacBook Air'),
          matching: find.byType(Dismissible),
        ),
        const Offset(-500, 0),
      );
      await pumpFor(tester);
      expect(find.text(t('cart_empty')), findsOneWidget);
      expect(backend.cart.rows, isEmpty);
    });

    testWidgets('adding a product already in the cart increases its quantity', (
      tester,
    ) async {
      final backend = TestBackend();
      backend.cart.seed(backend.products.products.first, 1);
      await backend.install();
      await launchApp(tester);

      await open(
        tester,
        AppRoutes.productDetails,
        backend.products.products.first,
      );
      await tapOn(tester, find.text(t('buy_now')));

      expect(backend.cart.rows, hasLength(1));
      expect(backend.cart.rows.single.quantity, 2);
    });

    testWidgets('home hearts reflect the saved wishlist and can be toggled', (
      tester,
    ) async {
      final backend = TestBackend();
      backend.wishlist.ids.add('p3');
      await backend.install();
      await launchApp(tester);

      final macCard = find.ancestor(
        of: find.text('MacBook Air'),
        matching: find.byType(ProductCard),
      );
      expect(
        find.descendant(
          of: macCard.first,
          matching: find.byIcon(Icons.favorite),
        ),
        findsOneWidget,
      );

      final iphoneHeart = find.descendant(
        of: find.ancestor(
          of: find.text('iPhone 15'),
          matching: find.byType(ProductCard),
        ),
        matching: find.byIcon(Icons.favorite_border),
      );
      await tapOn(tester, iphoneHeart);
      expect(backend.wishlist.ids, containsAll(['p2', 'p3']));

      await tapTab(tester, 3);
      expect(find.byType(WishlistView), findsOneWidget);
      expect(find.text('iPhone 15'), findsOneWidget);
      expect(find.text('MacBook Air'), findsOneWidget);
    });

    testWidgets('tapping a home category opens that category', (tester) async {
      final backend = TestBackend();
      await backend.install();
      await launchApp(tester);

      await tapOn(tester, find.text(t('audio')));

      expect(find.byType(AllProductsView), findsOneWidget);
      expect(find.text('AirPods'), findsOneWidget);
      expect(backend.products.requestedCategories.last, 'Audio');
      // Chips to switch to everything or another category.
      expect(find.text(t('all')), findsOneWidget);
      expect(find.text(t('smartphones')), findsOneWidget);
    });

    testWidgets('filter button opens the filter screen', (tester) async {
      await TestBackend().install();
      await launchApp(tester);

      // The filter icon is the last tappable area of the home search bar.
      await tapOn(
        tester,
        find
            .descendant(
              of: find.byType(CustomSearchBar),
              matching: find.byType(InkWell),
            )
            .last,
      );

      expect(find.byType(FilterSortView), findsOneWidget);
      expect(find.text(t('smartphones')), findsWidgets);
    });

    testWidgets('search shows results and an empty state', (tester) async {
      await TestBackend().install();
      await launchApp(tester);
      await open(tester, AppRoutes.search);

      await tester.enterText(find.byType(TextField), 'galaxy');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await pumpFor(tester);
      expect(find.text('Galaxy S24'), findsOneWidget);
      expect(find.text('\$799.50'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await pumpFor(tester);
      expect(find.text(t('no_results_found')), findsOneWidget);
    });

    testWidgets('product reviews show the average rating', (tester) async {
      final backend = TestBackend();
      await backend.install();
      await launchApp(tester);
      await open(
        tester,
        AppRoutes.productDetails,
        backend.products.products.first,
      );

      await tapOn(tester, find.text(t('add_rating')));

      expect(find.byType(ReviewsView), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('Great phone'), findsOneWidget);
    });
  });

  group('Checkout', () {
    Future<void> payWithCashAndConfirm(WidgetTester tester) async {
      await tapOn(
        tester,
        find.widgetWithText(ElevatedButton, t('go_to_payment')),
      );
      await tapOn(tester, find.text(t('cash_on_delivery')));
      await tapOn(
        tester,
        find.widgetWithText(ElevatedButton, t('continue_label')),
      );
      await tapOn(tester, find.textContaining(t('place_order')));
    }

    testWidgets('cannot continue without a delivery address', (tester) async {
      final backend = TestBackend();
      backend.cart.seed(backend.products.products.first, 1);
      await backend.install();
      await launchApp(tester);
      await open(tester, AppRoutes.checkout);

      await tapOn(
        tester,
        find.widgetWithText(ElevatedButton, t('go_to_payment')),
      );

      expect(find.text(t('no_address_msg')), findsWidgets);
      expect(
        find.text(t('go_to_payment')),
        findsOneWidget,
        reason: 'still on step 1',
      );
      expect(backend.orders.orders, isEmpty);
    });

    testWidgets('cannot continue without choosing how to pay', (tester) async {
      final backend = TestBackend();
      backend.cart.seed(backend.products.products.first, 1);
      backend.addresses.addresses.add(makeAddress(isDefault: true));
      await backend.install();
      await launchApp(tester);
      await open(tester, AppRoutes.checkout);

      await tapOn(
        tester,
        find.widgetWithText(ElevatedButton, t('go_to_payment')),
      );
      await tapOn(
        tester,
        find.widgetWithText(ElevatedButton, t('continue_label')),
      );

      expect(find.text(t('error_select_payment')), findsOneWidget);
      expect(find.textContaining(t('place_order')), findsNothing);
    });

    testWidgets('cash order: uses the default address and empties the cart', (
      tester,
    ) async {
      final backend = TestBackend();
      backend.cart.seed(backend.products.products.first, 2);
      backend.addresses.addresses
        ..add(makeAddress(id: 'a1'))
        ..add(makeAddress(id: 'a2', fullName: 'Work', isDefault: true));
      await backend.install();
      await launchApp(tester);
      await open(tester, AppRoutes.checkout);

      await payWithCashAndConfirm(tester);

      final order = backend.orders.orders.single;
      expect(backend.orders.lastAddressId, 'a2');
      expect(order.paymentMethod.name, 'cash');
      expect(backend.cart.rows, isEmpty);
      expect(find.byType(OrderSuccessView), findsOneWidget);
      expect(find.textContaining(order.number), findsOneWidget);

      // Track order opens the real order.
      await tapOn(tester, find.text(t('track_order')));
      expect(find.text(t('order_status_pending')), findsWidgets);
      expect(find.textContaining('Galaxy S24'), findsOneWidget);
    });

    testWidgets('card order: a new card is added, selected and used', (
      tester,
    ) async {
      final backend = TestBackend();
      backend.cart.seed(backend.products.products.first, 1);
      backend.addresses.addresses.add(makeAddress(isDefault: true));
      await backend.install();
      await launchApp(tester);
      await open(tester, AppRoutes.checkout);

      await tapOn(
        tester,
        find.widgetWithText(ElevatedButton, t('go_to_payment')),
      );
      await tapOn(tester, find.text(t('add_new_card')));
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Omar Adam');
      await tester.enterText(fields.at(1), '4242424242424242');
      await tester.enterText(fields.at(2), '1230');
      await tester.enterText(fields.at(3), '123');
      await tapOn(tester, find.widgetWithText(ElevatedButton, t('add_card')));

      expect(find.text('**** **** **** 4242'), findsOneWidget);
      await tapOn(
        tester,
        find.widgetWithText(ElevatedButton, t('continue_label')),
      );
      await tapOn(tester, find.textContaining(t('place_order')));

      final order = backend.orders.orders.single;
      expect(order.paymentMethod.name, 'card');
      expect(order.cardLast4, '4242');
      expect(
        backend.cardStore.values.values.join(),
        isNot(contains('4242424242424242')),
      );
    });

    testWidgets('a coupon from the cart lowers the order total', (
      tester,
    ) async {
      final backend = TestBackend();
      backend.cart.seed(makeProduct(id: 'p2', price: 1000), 1);
      backend.addresses.addresses.add(makeAddress(isDefault: true));
      await backend.install();
      await launchApp(tester);
      await open(tester, AppRoutes.cart);

      await tester.enterText(find.byType(TextField), 'nope');
      await tapOn(tester, find.widgetWithText(ElevatedButton, t('apply')));
      expect(find.text(t('error_invalid_coupon')), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'welcome10');
      await tapOn(tester, find.widgetWithText(ElevatedButton, t('apply')));
      expect(find.text('-\$100.00'), findsOneWidget);

      await tapOn(tester, find.widgetWithText(ElevatedButton, t('checkout')));
      await payWithCashAndConfirm(tester);

      final order = backend.orders.orders.single;
      expect(order.discount, 100);
      expect(order.totalAmount, closeTo(1000 - 100 + 12 + 45, 1e-9));
    });

    testWidgets('a failed order keeps the user on checkout', (tester) async {
      final backend = TestBackend();
      backend.cart.seed(backend.products.products.first, 1);
      backend.addresses.addresses.add(makeAddress());
      backend.orders.error = Exception('500');
      await backend.install();
      await launchApp(tester);
      await open(tester, AppRoutes.checkout);

      await payWithCashAndConfirm(tester);

      expect(find.byType(OrderSuccessView), findsNothing);
      expect(find.byType(CheckoutView), findsOneWidget);
      expect(backend.cart.rows, hasLength(1));
    });
  });

  group('Navigation', () {
    testWidgets('categories tab back arrow never leaves a blank screen', (
      tester,
    ) async {
      await TestBackend().install();
      await launchApp(tester);

      await tapTab(tester, 1);
      expect(find.byType(CategoriesView), findsOneWidget);
      final back = find.byIcon(Icons.arrow_back);
      if (back.evaluate().isNotEmpty) await tapOn(tester, back.first);

      expect(find.byType(MainWrapper), findsOneWidget);
    });

    testWidgets('wishlist tab back arrow never leaves a blank screen', (
      tester,
    ) async {
      await TestBackend().install();
      await launchApp(tester);

      await tapTab(tester, 3);
      final back = find.byIcon(Icons.arrow_back);
      if (back.evaluate().isNotEmpty) await tapOn(tester, back.first);

      expect(find.byType(MainWrapper), findsOneWidget);
    });

    testWidgets('the chosen tab survives opening and closing another screen', (
      tester,
    ) async {
      await TestBackend().install();
      await launchApp(tester);
      await open(tester, AppRoutes.mainWrapper, 1); // e.g. "See all" categories
      expect(find.byType(CategoriesView), findsOneWidget);

      await tapTab(tester, 0);
      expect(find.byType(HomeView), findsOneWidget);
      await open(tester, AppRoutes.notifications);
      rootNavigator(tester).pop();
      await pumpFor(tester);

      expect(find.byType(HomeView), findsOneWidget);
      expect(find.byType(CategoriesView), findsNothing);
    });

    testWidgets('profile → Wishlist opens the wishlist tab', (tester) async {
      await TestBackend().install();
      await launchApp(tester);
      await open(tester, AppRoutes.profile);

      await tapOn(tester, find.text(t('wishlist')));

      expect(find.byType(WishlistView), findsOneWidget);
    });
  });

  group('Account and settings', () {
    testWidgets('logging out from settings really signs out', (tester) async {
      final backend = TestBackend();
      backend.auth.logoutDelay = const Duration(milliseconds: 600);
      await backend.install();
      await launchApp(tester);
      await open(tester, AppRoutes.settings);

      await tapOn(tester, find.text(t('logout')));
      await tapOn(
        tester,
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ElevatedButton, t('logout')),
        ),
      );
      await pumpFor(tester);

      expect(find.byType(LoginView), findsOneWidget);
      expect(backend.auth.logoutCount, 1);
      expect(backend.auth.isUserLoggedIn(), isFalse);
    });

    testWidgets('logging out from profile really signs out', (tester) async {
      final backend = TestBackend();
      backend.auth.logoutDelay = const Duration(milliseconds: 600);
      await backend.install();
      await launchApp(tester);
      await open(tester, AppRoutes.profile);

      await tapOn(tester, find.text(t('logout')));
      await tapOn(
        tester,
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ElevatedButton, t('logout')),
        ),
      );
      await pumpFor(tester);

      expect(find.byType(LoginView), findsOneWidget);
      expect(backend.auth.logoutCount, 1);
    });

    testWidgets('switching to Arabic flips the layout and texts', (
      tester,
    ) async {
      await TestBackend().install();
      await launchApp(tester);
      await open(tester, AppRoutes.settings);

      await tapOn(tester, find.text(t('language')));
      await tapOn(tester, find.text('العربية'));

      expect(
        Directionality.of(tester.element(find.byType(SettingsView))),
        TextDirection.rtl,
      );
      expect(
        find.text(AppTranslations.translations['ar']!['settings']!),
        findsOneWidget,
      );
    });

    testWidgets('dark mode switch changes the theme and is remembered', (
      tester,
    ) async {
      await TestBackend().install();
      await launchApp(tester);
      await open(tester, AppRoutes.settings);

      await tapOn(tester, find.byType(Switch).first);

      expect(
        Theme.of(tester.element(find.byType(SettingsView))).brightness,
        Brightness.dark,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), isTrue);
    });

    testWidgets('editing the name updates the profile', (tester) async {
      final backend = TestBackend();
      await backend.install();
      await launchApp(tester);
      await open(tester, AppRoutes.editProfile);

      await tester.enterText(find.byType(TextFormField).first, 'Omar Khaled');
      await tapOn(
        tester,
        find.widgetWithText(ElevatedButton, t('save_changes')),
      );

      expect(backend.profile.updates, ['Omar Khaled|']);
      expect(find.textContaining('Omar'), findsWidgets);
    });

    testWidgets('notification times are zero-padded', (tester) async {
      await TestBackend().install();
      await launchApp(tester);

      await open(tester, AppRoutes.notifications);

      expect(find.textContaining('09:05'), findsOneWidget);
      expect(find.textContaining('14:30'), findsOneWidget);
    });
  });
}
