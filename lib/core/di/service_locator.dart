import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/local_payment_card_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/supabase_coupon_repository.dart';
import '../../data/repositories/supabase_product_repository.dart';
import '../../data/repositories/supabase_profile_repository.dart';
import '../../data/repositories/supabase_cart_repository.dart';
import '../../data/repositories/supabase_wishlist_repository.dart';
import '../../data/repositories/address_repository.dart';
import '../../data/repositories/supabase_address_repository.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../../domain/repositories/payment_card_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../data/repositories/supabase_notification_repository.dart';
import '../../data/repositories/supabase_review_repository.dart';
import '../../data/repositories/supabase_order_repository.dart';
import '../../domain/repositories/order_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Supabase instance registration
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  sl.registerLazySingleton<ProductRepository>(
    () => SupabaseProductRepository(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => SupabaseCartRepository(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<WishlistRepository>(
    () => SupabaseWishlistRepository(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => SupabaseAddressRepository(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => SupabaseNotificationRepository(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => SupabaseReviewRepository(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => SupabaseOrderRepository(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<CouponRepository>(
    () => SupabaseCouponRepository(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => SupabaseAuthRepository(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => SupabaseProfileRepository(sl<SupabaseClient>()),
  );
  // Cards stay on the device (masked), one list per signed-in user.
  sl.registerLazySingleton<PaymentCardRepository>(
    () => LocalPaymentCardRepository(
      FlutterSecureKeyValueStore(),
      userId: () => sl<SupabaseClient>().auth.currentUser?.id,
    ),
  );
}
