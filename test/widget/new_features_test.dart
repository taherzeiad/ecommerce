import 'package:ecommerce/core/routes/app_routes.dart';
import 'package:ecommerce/domain/entities/order_entity.dart';
import 'package:ecommerce/presentation/auth/login/login_view.dart';
import 'package:ecommerce/presentation/auth/success/success_view.dart';
import 'package:ecommerce/presentation/main_wrapper/main_wrapper.dart';
import 'package:ecommerce/presentation/profile/view/edit_profile_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/fakes.dart';
import '../helpers/flow_helpers.dart';
import '../helpers/test_app.dart';

/// User flows for the features that were missing: addresses, orders,
/// reviews, password change, social sign-in, email confirmation,
/// "remember me", notifications and the profile photo.
void main() {
  setUpAll(() async {
    await loadAppFonts();
    useFakeNetworkImages();
  });

  testWidgets('add an address (with validation), then make it the default', (
    tester,
  ) async {
    final backend = TestBackend();
    backend.addresses.addresses.add(makeAddress(id: 'a1', isDefault: true));
    await backend.install();
    await launchApp(tester);
    await open(tester, AppRoutes.addresses);

    await tapOn(tester, find.text(t('add_new_address')));
    await tapOn(tester, find.widgetWithText(ElevatedButton, t('add')));
    expect(find.text(t('error_required')), findsWidgets);
    expect(backend.addresses.addresses, hasLength(1));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Office');
    await tester.enterText(fields.at(1), '0599123456');
    await tester.enterText(fields.at(2), 'Omar Mukhtar St');
    await tester.enterText(fields.at(3), 'Gaza');
    await tapOn(tester, find.text(t('select_country')).last);
    await tester.enterText(find.byType(TextField).last, 'Palest');
    await pumpFor(tester);
    await tapOn(tester, find.textContaining('Palestin').last);
    await tapOn(tester, find.widgetWithText(ElevatedButton, t('add')));

    expect(backend.addresses.addresses, hasLength(2));
    expect(find.text('Office'), findsOneWidget);

    await tapOn(tester, find.byIcon(Icons.more_vert).last);
    await tapOn(tester, find.text(t('set_as_default')));
    expect(
      backend.addresses.addresses.where((a) => a.isDefault).single.fullName,
      'Office',
    );
  });

  testWidgets('My Orders lists orders and opens tracking', (tester) async {
    final backend = TestBackend();
    backend.cart.seed(backend.products.products.first, 1);
    await backend.orders.placeOrder(
      addressId: 'a1',
      paymentMethod: PaymentMethod.cash,
    );
    await backend.install();
    await launchApp(tester);
    await open(tester, AppRoutes.profile);

    await tapOn(tester, find.text(t('my_orders')));
    final order = backend.orders.orders.single;
    expect(find.textContaining(order.number), findsOneWidget);

    await tapOn(tester, find.textContaining(order.number));
    expect(find.text(t('order_tracking')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(t('cash_on_delivery')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text(t('cash_on_delivery')), findsOneWidget);
  });

  testWidgets('write a review from the product page', (tester) async {
    final backend = TestBackend();
    await backend.install();
    await launchApp(tester);
    await open(
      tester,
      AppRoutes.productDetails,
      backend.products.products.first,
    );

    await tapOn(tester, find.text(t('add_rating')));
    await tapOn(tester, find.widgetWithText(ElevatedButton, t('add_rating')));
    await tapOn(tester, find.widgetWithText(ElevatedButton, t('submit')));
    expect(find.text(t('error_select_rating')), findsOneWidget);

    await tapOn(tester, find.byTooltip('5'));
    await tester.enterText(find.byType(TextField), 'Love it');
    await tapOn(tester, find.widgetWithText(ElevatedButton, t('submit')));

    expect(find.text('Love it'), findsOneWidget);
    expect(find.text(t('review_thanks')), findsOneWidget);
  });

  testWidgets('change password checks the current one', (tester) async {
    final backend = TestBackend();
    await backend.install();
    await launchApp(tester);
    await open(tester, AppRoutes.changePassword);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'wrong1');
    await tester.enterText(fields.at(1), 'newpass1');
    await tester.enterText(fields.at(2), 'newpass1');
    await tapOn(tester, find.widgetWithText(ElevatedButton, t('save_changes')));
    expect(find.text(t('error_wrong_current_password')), findsOneWidget);

    await tester.enterText(fields.at(0), 'secret1');
    await tapOn(tester, find.widgetWithText(ElevatedButton, t('save_changes')));
    expect(backend.auth.password, 'newpass1');
    expect(find.text(t('password_changed')), findsOneWidget);
  });

  testWidgets('Google sign-in opens the shop', (tester) async {
    final backend = TestBackend(loggedIn: false);
    await backend.install();
    await launchApp(tester);

    await tapOn(tester, find.byTooltip('Google'));
    await pumpFor(tester);

    expect(backend.auth.calls, contains('provider:google'));
    expect(find.byType(MainWrapper), findsOneWidget);
  });

  testWidgets('sign-up with email confirmation explains the next step', (
    tester,
  ) async {
    final backend = TestBackend(loggedIn: false);
    backend.auth.signupNeedsConfirmation = true;
    await backend.install();
    await launchApp(tester);
    await tapOn(tester, find.text(t('create_account')));

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

    expect(find.byType(SuccessView), findsOneWidget);
    expect(find.text(t('confirm_email_sent')), findsOneWidget);
    expect(find.byType(MainWrapper), findsNothing);
  });

  testWidgets('unticking "remember me" means logging in again next time', (
    tester,
  ) async {
    final backend = TestBackend(loggedIn: true);
    await backend.install(rememberMe: false);

    await launchApp(tester);

    expect(find.byType(LoginView), findsOneWidget);
    expect(backend.auth.logoutCount, 1);
  });

  testWidgets('opening an order notification reads it and shows the order', (
    tester,
  ) async {
    final backend = TestBackend();
    backend.orders.orders.add(
      OrderEntity(
        id: 'order-0001-abcdef',
        status: OrderStatus.shipped,
        subtotal: 10,
        deliveryFee: 12,
        tax: 0.5,
        totalAmount: 22.5,
        paymentMethod: PaymentMethod.cash,
        createdAt: DateTime(2026, 1, 3),
      ),
    );
    await backend.install();
    await launchApp(tester);

    await open(tester, AppRoutes.notifications);
    expect(find.textContaining('ORDER-00'), findsOneWidget);
    await tapOn(tester, find.text(t('notif_order_shipped_title')));

    expect(backend.notifications.markedRead, [1]);
    expect(find.text(t('order_status_shipped')), findsWidgets);
  });

  testWidgets('profile photo can be changed', (tester) async {
    final backend = TestBackend();
    await backend.install();
    await launchApp(tester);
    rootNavigator(tester).push(
      MaterialPageRoute<void>(
        builder: (_) => EditProfileView(imagePicker: _FakeImagePicker()),
      ),
    );
    await pumpFor(tester);

    await tapOn(tester, find.text(t('change_photo')));
    await tapOn(tester, find.text(t('gallery')));

    expect(backend.profile.uploads.single, [1, 2, 3]);
    expect(backend.profile.avatarUrl, endsWith('.png'));
  });
}

class _FakeImagePicker extends Fake implements ImagePicker {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    return XFile.fromData(
      Uint8List.fromList([1, 2, 3]),
      name: 'me.png',
      mimeType: 'image/png',
    );
  }
}
