import 'package:ecommerce/core/routes/app_routes.dart';
import 'package:ecommerce/domain/entities/order_entity.dart';
import 'package:ecommerce/domain/entities/product_filter.dart';
import 'package:ecommerce/presentation/auth/forgot_password/auth_viewmodel.dart';
import 'package:ecommerce/presentation/categories/view_model/categories_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// Opens every screen of the app on a phone-sized display, in English/light
/// and Arabic/dark, with data that includes the awkward cases (products
/// without images, more categories than icons, items already in the cart).
/// Any exception, layout overflow or provider error fails the test.
void main() {
  setUpAll(() async {
    await loadAppFonts();
    useFakeNetworkImages();
  });

  const orderId = 'order-0001-abcdef';

  final routes = <String, Object? Function()>{
    AppRoutes.onboarding: () => null,
    AppRoutes.login: () => null,
    AppRoutes.signup: () => null,
    AppRoutes.forgotPassword: () => null,
    AppRoutes.verifyAccount: () =>
        ForgotPasswordViewModel(FakeAuthRepository())
          ..emailController.text = 'omar@example.com',
    AppRoutes.resetPassword: () =>
        ForgotPasswordViewModel(FakeAuthRepository()),
    AppRoutes.authSuccess: () => null,
    '${AppRoutes.authSuccess}#confirm-email': () => 'confirm_email_sent',
    AppRoutes.mainWrapper: () => null,
    '${AppRoutes.mainWrapper}#categories': () => 1,
    '${AppRoutes.mainWrapper}#wishlist': () => 3,
    AppRoutes.home: () => null,
    AppRoutes.allProducts: () => null,
    '${AppRoutes.allProducts}#audio': () => 'Audio',
    '${AppRoutes.allProducts}#flash': () => ProductCollection.flashDeals,
    AppRoutes.productDetails: () => sampleCatalog().first,
    '${AppRoutes.productDetails}#no-image': () => sampleCatalog()[1],
    AppRoutes.notifications: () => null,
    AppRoutes.reviews: () => sampleCatalog().first,
    AppRoutes.addReview: () => sampleCatalog().first,
    AppRoutes.profile: () => null,
    AppRoutes.editProfile: () => null,
    AppRoutes.changePassword: () => null,
    AppRoutes.settings: () => null,
    AppRoutes.aboutUs: () => null,
    AppRoutes.helpCenter: () => null,
    AppRoutes.privacy: () => null,
    AppRoutes.termsConditions: () => null,
    AppRoutes.search: () => null,
    '${AppRoutes.search}#filtered': () =>
        const ProductFilter(sort: ProductSort.priceHighToLow),
    AppRoutes.filterSort: () => null,
    AppRoutes.cart: () => null,
    AppRoutes.checkout: () => null,
    AppRoutes.addresses: () => null,
    AppRoutes.addAddress: () => null,
    AppRoutes.editAddress: () => makeAddress(isDefault: true),
    AppRoutes.paymentMethods: () => null,
    AppRoutes.addCard: () => null,
    AppRoutes.orders: () => null,
    AppRoutes.orderSuccess: () => orderId,
    AppRoutes.orderTracking: () => orderId,
  };

  for (final (lang, dark) in [('en', false), ('ar', true)]) {
    group('[$lang${dark ? ', dark' : ''}]', () {
      for (final entry in routes.entries) {
        final route = entry.key.split('#').first;

        testWidgets('${entry.key} renders without errors', (tester) async {
          final backend = TestBackend();
          backend.cart.seed(sampleCatalog()[0], 2);
          backend.cart.seed(sampleCatalog()[1], 1); // no images
          backend.wishlist.ids.addAll({'p1', 'p2'});
          backend.addresses.addresses.add(makeAddress(isDefault: true));
          backend.orders.orders.add(
            OrderEntity(
              id: orderId,
              status: OrderStatus.shipped,
              subtotal: 1599,
              discount: 159.9,
              deliveryFee: 12,
              tax: 71.96,
              totalAmount: 1523.06,
              couponCode: 'WELCOME10',
              paymentMethod: PaymentMethod.card,
              cardLast4: '4242',
              shippingName: 'Omar Adam',
              shippingAddress: '5 Main St, Gaza, Palestine',
              shippingPhone: '0590000000',
              createdAt: DateTime(2026, 1, 3, 9, 5),
              items: const [
                OrderItemEntity(
                  productName: 'Galaxy S24',
                  imageUrl: 'https://example.com/s24.png',
                  unitPrice: 799.5,
                  quantity: 2,
                ),
              ],
            ),
          );
          await backend.install(languageCode: lang, darkMode: dark);

          await launchApp(tester);
          rootNavigator(tester).pushNamed(route, arguments: entry.value());
          await pumpFor(tester, const Duration(seconds: 2));

          expect(tester.takeException(), isNull);
        });
      }
    });
  }
}
