import 'package:get_it/get_it.dart';
import '../../data/repositories/mock_product_repository.dart';
import '../../domain/repositories/product_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Repositories
  // For now we use Mock, later we can easily swap to ProductRepositoryImpl
  sl.registerLazySingleton<ProductRepository>(() => MockProductRepository());

  // Data sources (Placeholder for real API)
  // sl.registerLazySingleton<ProductRemoteDataSource>(() => ProductRemoteDataSourceImpl(client: sl()));
}
