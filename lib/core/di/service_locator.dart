import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/mock_product_repository.dart';
import '../../domain/repositories/product_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Supabase instance registration
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => SupabaseAuthRepository(sl<SupabaseClient>()));
  sl.registerLazySingleton<ProductRepository>(() => MockProductRepository());
}
