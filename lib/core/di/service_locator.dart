import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/mock_product_repository.dart';
import '../../data/repositories/supabase_product_repository.dart';
import '../../data/repositories/supabase_cart_repository.dart';
import '../../data/repositories/supabase_wishlist_repository.dart';
import '../../domain/repositories/product_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Supabase instance registration
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Background Prepared Supabase Repositories (Registered for future switch)
  sl.registerLazySingleton<SupabaseProductRepository>(() => SupabaseProductRepository(sl<SupabaseClient>()));
  sl.registerLazySingleton<SupabaseCartRepository>(() => SupabaseCartRepository(sl<SupabaseClient>()));
  sl.registerLazySingleton<SupabaseWishlistRepository>(() => SupabaseWishlistRepository(sl<SupabaseClient>()));

  // Active Repositories for UI (Strictly preserving Mock UI display)
  sl.registerLazySingleton<AuthRepository>(() => SupabaseAuthRepository(sl<SupabaseClient>()));
  sl.registerLazySingleton<ProductRepository>(() => MockProductRepository());
}
