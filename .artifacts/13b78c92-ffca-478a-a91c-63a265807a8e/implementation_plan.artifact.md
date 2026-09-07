# Preparation for Real Data Integration (Clean Architecture)

This plan outlines the steps to restructure the application to support real data integration (API/Local DB) while maintaining the current dummy data functionality. We will follow **Clean Architecture** principles.

## Proposed Changes

### 1. Domain Layer
Create the core business logic layer that is independent of any data source or UI framework.
- **[NEW]** `lib/domain/entities/product.dart`: Core data structure for products.
- **[NEW]** `lib/domain/repositories/product_repository.dart`: Interface defining how we fetch products.

### 2. Data Layer
Implement the repository interface and handle data retrieval.
- **[NEW]** `lib/data/models/product_model.dart`: (Update) Add `fromJson`/`toJson` and mapping to domain entity.
- **[NEW]** `lib/data/data_sources/product_remote_data_source.dart`: Interface for API calls.
- **[NEW]** `lib/data/repositories/product_repository_impl.dart`: Real implementation (placeholder).
- **[NEW]** `lib/data/repositories/mock_product_repository.dart`: Dummy data implementation.

### 3. Dependency Injection
Setup a central service locator to manage instances.
- **[NEW]** `lib/core/di/service_locator.dart`: Using `get_it` to register and provide dependencies.

### 4. Presentation Layer (State Management)
Switch from hardcoded lists in Views to ViewModels/Providers.
- **[NEW]** `lib/presentation/home/view_model/home_view_model.dart`: Fetch data from the repository.
- **[MODIFY]** `lib/presentation/home/view/home_view.dart`: Consume the ViewModel.
- **[NEW]** `lib/presentation/categories/view_model/categories_view_model.dart`: Fetch categories/products.
- **[MODIFY]** `lib/presentation/categories/view/categories_view.dart`: Consume the ViewModel.

## Verification Plan
### Automated Tests
- Unit tests for `MockProductRepository`.
- Unit tests for `HomeViewModel`.

### Manual Verification
- Verify the app still displays dummy data correctly.
- Check that navigation and search still work.
