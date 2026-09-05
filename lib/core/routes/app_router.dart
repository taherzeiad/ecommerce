import 'package:flutter/material.dart';

import '../../presentation/auth/forgot_password/forgot_password_view.dart';
import '../../presentation/auth/forgot_password/reset_password_view.dart';
import '../../presentation/auth/forgot_password/verify_account_view.dart';
import '../../presentation/auth/login/login_view.dart';
import '../../presentation/auth/signup/signup_view.dart';
import '../../presentation/auth/success/success_view.dart';
import '../../presentation/address/view/add_address_view.dart';
import '../../presentation/address/view/edit_address_view.dart';
import '../../presentation/cart/view/cart_view.dart';
import '../../presentation/checkout/view/checkout_view.dart';
import '../../presentation/checkout/view/order_success_view.dart';
import '../../presentation/checkout/view/order_tracking_view.dart';
import '../../presentation/home/view/home_view.dart';
import '../../presentation/main_wrapper/main_wrapper.dart';
import '../../presentation/notifications/view/notifications_view.dart';
import '../../presentation/onboarding/view/onboarding_view.dart';
import '../../presentation/payment/view/add_card_view.dart';
import '../../presentation/product_details/view/all_products_view.dart';
import '../../presentation/product_details/view/product_details_view.dart';
import '../../presentation/profile/view/change_password_view.dart';
import '../../presentation/profile/view/edit_profile_view.dart';
import '../../presentation/profile/view/profile_view.dart';
import '../../presentation/reviews/view/add_review_view.dart';
import '../../presentation/reviews/view/reviews_view.dart';
import '../../presentation/search/view/filter_sort_view.dart';
import '../../presentation/search/view/search_view.dart';
import '../../presentation/settings/view/about_us_view.dart';
import '../../presentation/settings/view/help_center_view.dart';
import '../../presentation/settings/view/privacy_view.dart';
import '../../presentation/settings/view/settings_view.dart';
import '../../presentation/settings/view/terms_conditions_view.dart';
import '../../presentation/splash/view/splash_view.dart';
import 'app_routes.dart';

/// Single source of truth for navigation. Views never build routes
/// inline (no `MaterialPageRoute` scattered around) — they just call
/// `Navigator.pushNamed(context, AppRoutes.x)` and this class decides
/// how to build the screen. Makes it trivial to add route guards,
/// deep-linking or transitions later without touching the views.
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
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
        return _fade(const SuccessView(), settings);
      case AppRoutes.mainWrapper:
        return _fade(const MainWrapper(), settings);
      case AppRoutes.home:
        return _fade(const HomeView(), settings);
      case AppRoutes.allProducts:
        return _fade(const AllProductsView(), settings);
      case AppRoutes.productDetails:
        return _fade(const ProductDetailsView(), settings);
      case AppRoutes.notifications:
        return _fade(const NotificationsView(), settings);
      case AppRoutes.reviews:
        return _fade(const ReviewsView(), settings);
      case AppRoutes.addReview:
        return _fade(const AddReviewView(), settings);
      case AppRoutes.profile:
        return _fade(const ProfileView(), settings);
      case AppRoutes.editProfile:
        return _fade(const EditProfileView(), settings);
      case AppRoutes.changePassword:
        return _fade(const ChangePasswordView(), settings);
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
        return _fade(const SearchView(), settings);
      case AppRoutes.filterSort:
        return _fade(const FilterSortView(), settings);
      case AppRoutes.cart:
        return _fade(const CartView(), settings);
      case AppRoutes.checkout:
        return _fade(const CheckoutView(), settings);
      case AppRoutes.addAddress:
        return _fade(const AddAddressView(), settings);
      case AppRoutes.editAddress:
        return _fade(const EditAddressView(), settings);
      case AppRoutes.addCard:
        return _fade(const AddCardView(), settings);
      case AppRoutes.orderSuccess:
        return _fade(const OrderSuccessView(), settings);
      case AppRoutes.orderTracking:
        return _fade(const OrderTrackingView(), settings);
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
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
