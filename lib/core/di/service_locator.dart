import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/supabase_product_repository.dart';
import '../../data/repositories/supabase_cart_repository.dart';
import '../../data/repositories/supabase_wishlist_repository.dart';
import '../../data/repositories/address_repository.dart';
import '../../data/repositories/supabase_address_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../data/repositories/supabase_notification_repository.dart';
import '../../data/repositories/supabase_review_repository.dart';
import '../../data/repositories/supabase_order_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../presentation/profile/view_model/profile_view_model.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Supabase instance registration
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Background Prepared Repositories
  sl.registerLazySingleton<SupabaseProductRepository>(
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

  // Active Repositories for UI
  sl.registerLazySingleton<AuthRepository>(
    () => SupabaseAuthRepository(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<ProfileViewModel>(
    () => ProfileViewModel(authRepository: sl()),
  );

  // Use SupabaseProductRepository for all product operations
  sl.registerLazySingleton<ProductRepository>(() => sl<SupabaseProductRepository>());
}
