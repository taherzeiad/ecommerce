import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce/domain/entities/address_entity.dart';
import 'package:ecommerce/domain/entities/product_entity.dart';
import 'package:ecommerce/domain/entities/product_filter.dart';
import 'package:ecommerce/presentation/auth/forgot_password/forgot_password_view.dart';
import 'package:ecommerce/presentation/auth/forgot_password/reset_password_view.dart';
import 'package:ecommerce/presentation/auth/forgot_password/verify_account_view.dart';
import 'package:ecommerce/presentation/auth/login/login_view.dart';
import 'package:ecommerce/presentation/auth/signup/signup_view.dart';
import 'package:ecommerce/presentation/auth/success/success_view.dart';
import 'package:ecommerce/presentation/address/view/add_address_view.dart';
import 'package:ecommerce/presentation/address/view/addresses_view.dart';
import 'package:ecommerce/presentation/address/view/edit_address_view.dart';
import 'package:ecommerce/presentation/cart/view/cart_view.dart';
import 'package:ecommerce/presentation/checkout/view/checkout_view.dart';
import 'package:ecommerce/presentation/checkout/view/order_success_view.dart';
import 'package:ecommerce/presentation/checkout/view/order_tracking_view.dart';
import 'package:ecommerce/presentation/categories/view_model/categories_view_model.dart';
import 'package:ecommerce/presentation/orders/view/orders_view.dart';
import 'package:ecommerce/presentation/payment/view/payment_methods_view.dart';
import 'package:ecommerce/presentation/profile/view_model/change_password_view_model.dart';
import 'package:ecommerce/presentation/reviews/view_model/reviews_view_model.dart';
import 'package:ecommerce/presentation/home/view/home_view.dart';
import 'package:ecommerce/presentation/home/view_model/home_view_model.dart';
import 'package:ecommerce/presentation/main_wrapper/main_wrapper.dart';
import 'package:ecommerce/presentation/notifications/view/notifications_view.dart';
import 'package:ecommerce/presentation/onboarding/view/onboarding_view.dart';
import 'package:ecommerce/presentation/payment/view/add_card_view.dart';
import 'package:ecommerce/presentation/product_details/view/all_products_view.dart';
import 'package:ecommerce/presentation/product_details/view/product_details_view.dart';
import 'package:ecommerce/presentation/profile/view/change_password_view.dart';
import 'package:ecommerce/presentation/profile/view/edit_profile_view.dart';
import 'package:ecommerce/presentation/profile/view/profile_view.dart';
import 'package:ecommerce/presentation/reviews/view/add_review_view.dart';
import 'package:ecommerce/presentation/reviews/view/reviews_view.dart';
import 'package:ecommerce/presentation/search/view/filter_sort_view.dart';
import 'package:ecommerce/presentation/search/view/search_view.dart';
import 'package:ecommerce/presentation/search/view_model/search_view_model.dart';
import 'package:ecommerce/presentation/settings/view/about_us_view.dart';
import 'package:ecommerce/presentation/settings/view/help_center_view.dart';
import 'package:ecommerce/presentation/settings/view/privacy_view.dart';
import 'package:ecommerce/presentation/settings/view/settings_view.dart';
import 'package:ecommerce/presentation/settings/view/terms_conditions_view.dart';
import 'package:ecommerce/presentation/splash/view/splash_view.dart';
import 'package:ecommerce/core/di/service_locator.dart';

import 'app_routes.dart';

/// Single source of truth for navigation. Views never build routes
/// inline (no `MaterialPageRoute` scattered around) — they just call
/// `Navigator.pushNamed(context, AppRoutes.x)` and this class decides
/// how to build the screen. Makes it trivial to add route guards,
/// deep-linking or transitions later without touching the views.
///
/// Arguments per route:
/// - mainWrapper: `int?` tab index
/// - allProducts: `String` category, or a [ProductCollection]
/// - productDetails, reviews, addReview: [ProductEntity]
/// - search, filterSort: `ProductFilter?` to start from
/// - editAddress: [AddressEntity]
/// - orderSuccess, orderTracking: `String` order id
/// - authSuccess: `String?` translation key of the message
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(const SplashView(), settings);
      case AppRoutes.onboarding:
        return _fade(const OnboardingView(), settings);
      case AppRoutes.login:
        return _fade(const LoginView(), settings);
      case AppRoutes.signup:
        return _fade(const SignupView(), settings);
      case AppRoutes.forgotPassword:
        return _fade(const ForgotPasswordView(), settings);
      case AppRoutes.verifyAccount:
        return _fade(const VerifyAccountView(), settings);
      case AppRoutes.resetPassword:
        return _fade(const ResetPasswordView(), settings);
      case AppRoutes.authSuccess:
        return _fade(
          SuccessView(messageKey: args as String? ?? 'account_created'),
          settings,
        );
      case AppRoutes.mainWrapper:
        return _fade(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) =>
                    HomeViewModel(productRepository: sl())..fetchHomeData(),
              ),
              // CategoriesView loads its data when the tab is first shown.
              ChangeNotifierProvider(
                create: (_) => CategoriesViewModel(productRepository: sl()),
              ),
            ],
            child: const MainWrapper(),
          ),
          settings,
        );
      case AppRoutes.home:
        return _fade(
          ChangeNotifierProvider(
            create: (_) =>
                HomeViewModel(productRepository: sl())..fetchHomeData(),
            child: const HomeView(),
          ),
          settings,
        );
      case AppRoutes.allProducts:
        return _fade(
          ChangeNotifierProvider(
            create: (_) {
              final vm = CategoriesViewModel(productRepository: sl());
              switch (args) {
                case final String category:
                  vm.fetchProductsByCategory(category);
                case ProductCollection.flashDeals:
                  vm.showFlashDeals();
                default:
                  vm.showAllProducts();
              }
              // Loads the filter chips; keeps the products chosen above.
              return vm..fetchCategories();
            },
            child: const AllProductsView(),
          ),
          settings,
        );
      case AppRoutes.productDetails:
        return _fade(
          ProductDetailsView(product: args as ProductEntity),
          settings,
        );
      case AppRoutes.notifications:
        return _fade(const NotificationsView(), settings);
      case AppRoutes.reviews:
        final product = args as ProductEntity;
        return _fade(
          ChangeNotifierProvider(
            create: (_) =>
                ReviewsViewModel(reviewRepository: sl())
                  ..fetchReviews(product.id),
            child: ReviewsView(product: product),
          ),
          settings,
        );
      case AppRoutes.addReview:
        return _fade(
          ChangeNotifierProvider(
            create: (_) => AddReviewViewModel(reviewRepository: sl()),
            child: AddReviewView(product: args as ProductEntity),
          ),
          settings,
        );
      case AppRoutes.profile:
        return _fade(const ProfileView(), settings);
      case AppRoutes.editProfile:
        return _fade(const EditProfileView(), settings);
      case AppRoutes.changePassword:
        return _fade(
          ChangeNotifierProvider(
            create: (_) => ChangePasswordViewModel(sl()),
            child: const ChangePasswordView(),
          ),
          settings,
        );
      case AppRoutes.settings:
        return _fade(const SettingsView(), settings);
      case AppRoutes.aboutUs:
        return _fade(const AboutUsView(), settings);
      case AppRoutes.helpCenter:
        return _fade(const HelpCenterView(), settings);
      case AppRoutes.privacy:
        return _fade(const PrivacyView(), settings);
      case AppRoutes.termsConditions:
        return _fade(const TermsConditionsView(), settings);
      case AppRoutes.search:
        return _fade(
          ChangeNotifierProvider(
            create: (_) => SearchViewModel(
              productRepository: sl(),
              initialFilter: args as ProductFilter?,
            ),
            child: const SearchView(),
          ),
          settings,
        );
      case AppRoutes.filterSort:
        return _fade(
          ChangeNotifierProvider(
            create: (_) =>
                CategoriesViewModel(productRepository: sl())..fetchCategories(),
            child: FilterSortView(
              initialFilter: args as ProductFilter? ?? const ProductFilter(),
            ),
          ),
          settings,
        );
      case AppRoutes.cart:
        return _fade(const CartView(), settings);
      case AppRoutes.checkout:
        return _fade(const CheckoutView(), settings);
      case AppRoutes.addresses:
        return _fade(const AddressesView(), settings);
      case AppRoutes.addAddress:
        return _fade(const AddAddressView(), settings);
      case AppRoutes.editAddress:
        return _fade(EditAddressView(address: args as AddressEntity), settings);
      case AppRoutes.paymentMethods:
        return _fade(const PaymentMethodsView(), settings);
      case AppRoutes.addCard:
        return _fade(const AddCardView(), settings);
      case AppRoutes.orders:
        return _fade(const OrdersView(), settings);
      case AppRoutes.orderSuccess:
        return _fade(OrderSuccessView(orderId: args as String), settings);
      case AppRoutes.orderTracking:
        return _fade(OrderTrackingView(orderId: args as String), settings);
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static Route<dynamic> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        final curve = Curves.easeOutQuart;

        final slideTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        final scaleTween = Tween<double>(
          begin: 0.96,
          end: 1.0,
        ).chain(CurveTween(curve: curve));
        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: SlideTransition(
              position: animation.drive(slideTween),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }
}
