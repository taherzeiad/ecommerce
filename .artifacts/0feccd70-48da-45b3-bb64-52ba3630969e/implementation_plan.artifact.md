# E-commerce Main Features Implementation Plan

This plan outlines the steps to implement the core shopping experience, including the main navigation shell, home screen, categories, product browsing, and wishlist.

## User Review Required

> [!IMPORTANT]
> - **Navigation Structure**: I will implement a `MainWrapper` that hosts a custom rounded **Bottom Navigation Bar** with 4 tabs: Home, Categories, Cart, and Wishlist.
> - **Data Layer**: I will use dummy data models for Products, Categories, and Notifications to make the UI runnable immediately.
> - **Image Assets**: I will use placeholder images/icons where real assets are missing.

## Proposed Changes

### Core & Data Layer
Summary: Update navigation and create data models for the shopping experience.

#### [MODIFY] [app_routes.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/core/routes/app_routes.dart)
Add routes for:
- `mainWrapper` (The shell with bottom nav)
- `productDetails`
- `notifications`
- `allProducts`
- `reviews`

#### [NEW] [Data Models](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/data/models/)
- `category_model.dart`
- `product_model.dart`
- `notification_model.dart`
- `review_model.dart`

---

### Presentation Layer: Main Shell
Summary: The container for the primary navigation.

#### [NEW] [Main Wrapper](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/main_wrapper/)
- `main_wrapper.dart`: Scaffold with `IndexedStack` for tabs.
- `widgets/custom_bottom_nav.dart`: The rounded white bar seen in the designs.

---

### Presentation Layer: Tabs
Summary: Implementation of the 4 main navigation tabs.

#### [MODIFY] [Home Screen](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/home/)
- Update `home_view.dart` with header, search, banner, and horizontal/grid sections.

#### [NEW] [Categories Screen](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/categories/)
- `categories_view.dart`: Featured wide cards and category grid.

#### [NEW] [Wishlist Screen](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/wishlist/)
- `wishlist_view.dart`: Handle empty state and favorite items list.

---

### Presentation Layer: Secondary Screens
Summary: Detail and auxiliary screens.

#### [NEW] [Product Details](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/product_details/)
- `product_details_view.dart`: Image slider, QTY selector, and description.

#### [NEW] [Notifications](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/notifications/)
- `notifications_view.dart`: Filter chips and activity list.

#### [NEW] [Reviews](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/reviews/)
- `reviews_view.dart`: Summary card, "Add Review" button, and user feedback list.

---

### Shared UI Components
- `SearchField`: Reusable search bar with filter icon.
- `ProductCard`: Grid/List item for products.
- `CategoryItem`: Circle icon for home and cards for category screen.

## Verification Plan

### Automated Tests
- Widget tests for the Bottom Navigation tab switching.
- Unit tests for the Wishlist logic (Add/Remove).

### Manual Verification
- Navigate between all 4 main tabs.
- Open Product Details from Home/Wishlist.
- Check the Custom Keypad (if still applicable) and ensure keyboard behavior doesn't break the new layouts.
- Test "Empty Wishlist" vs "Items in Wishlist" UI.
