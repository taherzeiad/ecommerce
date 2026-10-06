import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ecommerce/app.dart';
import 'package:ecommerce/core/constants/app_strings.dart';
import 'package:ecommerce/core/di/service_locator.dart';
import 'package:ecommerce/data/repositories/address_repository.dart';
import 'package:ecommerce/data/repositories/auth_repository.dart';
import 'package:ecommerce/data/repositories/local_payment_card_repository.dart';
import 'package:ecommerce/domain/repositories/cart_repository.dart';
import 'package:ecommerce/domain/repositories/coupon_repository.dart';
import 'package:ecommerce/domain/repositories/notification_repository.dart';
import 'package:ecommerce/domain/repositories/order_repository.dart';
import 'package:ecommerce/domain/repositories/payment_card_repository.dart';
import 'package:ecommerce/domain/repositories/product_repository.dart';
import 'package:ecommerce/domain/repositories/profile_repository.dart';
import 'package:ecommerce/domain/repositories/review_repository.dart';
import 'package:ecommerce/domain/repositories/wishlist_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

/// All fake backends for one test, registered in the real service locator so
/// the production `EcommerceApp`, router and providers run unchanged.
class TestBackend {
  TestBackend({bool loggedIn = true}) {
    auth.loggedIn = loggedIn;
  }

  final products = FakeProductRepository();
  late final cart = FakeCartRepository(products.products);
  late final wishlist = FakeWishlistRepository(products.products);
  final addresses = FakeAddressRepository();
  final coupons = FakeCouponRepository();
  late final orders = FakeOrderRepository(
    cart: cart,
    addresses: addresses,
    coupons: coupons,
  );
  final notifications = FakeNotificationRepository();
  final reviews = FakeReviewRepository();
  final auth = FakeAuthRepository();
  late final profile = FakeProfileRepository(auth);
  final cardStore = InMemorySecureStore();
  late final cards = LocalPaymentCardRepository(
    cardStore,
    userId: auth.getCurrentUserId,
  );

  Future<void> install({
    bool onboardingCompleted = true,
    String? languageCode,
    bool darkMode = false,
    bool? rememberMe,
  }) async {
    SharedPreferences.setMockInitialValues({
      AppStrings.onboardingCompletedPrefKey: onboardingCompleted,
      'appLocale': ?languageCode,
      'isDarkMode': darkMode,
      AppStrings.rememberMePrefKey: ?rememberMe,
    });
    await sl.reset();
    sl.registerSingleton<ProductRepository>(products);
    sl.registerSingleton<CartRepository>(cart);
    sl.registerSingleton<WishlistRepository>(wishlist);
    sl.registerSingleton<OrderRepository>(orders);
    sl.registerSingleton<AddressRepository>(addresses);
    sl.registerSingleton<NotificationRepository>(notifications);
    sl.registerSingleton<ReviewRepository>(reviews);
    sl.registerSingleton<AuthRepository>(auth);
    sl.registerSingleton<CouponRepository>(coupons);
    sl.registerSingleton<ProfileRepository>(profile);
    sl.registerSingleton<PaymentCardRepository>(cards);
  }
}

/// Simulates a 360x780 dp Android phone.
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Pumps frames for [duration] in small steps. Used instead of
/// `pumpAndSettle`, which never returns while a spinner is animating.
Future<void> pumpFor(
  WidgetTester tester, [
  Duration duration = const Duration(seconds: 1),
]) async {
  const step = Duration(milliseconds: 50);
  var elapsed = Duration.zero;
  await tester.pump();
  while (elapsed < duration) {
    await tester.pump(step);
    elapsed += step;
  }
}

/// Starts the real app and waits for the splash screen to route away.
Future<void> launchApp(WidgetTester tester) async {
  usePhoneScreen(tester);
  await tester.pumpWidget(const EcommerceApp());
  await pumpFor(tester, const Duration(milliseconds: 2500));
}

NavigatorState rootNavigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator).first);

/// Loads Roboto from the local Flutter SDK so text is measured like on a
/// real device. The default test font renders every glyph as a 1em square,
/// which makes ordinary rows look like they overflow.
Future<void> loadAppFonts() async {
  final config = File('.dart_tool/package_config.json');
  if (!config.existsSync()) return;
  final root = (jsonDecode(config.readAsStringSync()) as Map)['flutterRoot'];
  if (root is! String) return;
  final dir = Directory.fromUri(
    Uri.parse('$root/bin/cache/artifacts/material_fonts/'),
  );
  if (!dir.existsSync()) return;

  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final file = File('${dir.path}$f');
      if (file.existsSync()) {
        loader.addFont(
          Future.value(ByteData.sublistView(file.readAsBytesSync())),
        );
      }
    }
    await loader.load();
  }

  await load('Roboto', [
    'roboto-light.ttf',
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-black.ttf',
  ]);
  await load('MaterialIcons', ['materialicons-regular.otf']);
}

/// Serves a 1x1 transparent PNG for every `Image.network` / `NetworkImage`
/// request, so screens with remote images render without real HTTP.
/// Call from `setUpAll`, after the test binding installed its own mock.
void useFakeNetworkImages() {
  HttpOverrides.global = _FakeHttpOverrides();
}

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

const List<int> _transparentPng = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpRequest();
}

class _FakeHttpRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpResponse();
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
