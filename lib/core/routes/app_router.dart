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
        return _fade(const SplashView());
      case AppRoutes.onboarding:
        return _fade(const OnboardingView());
      case AppRoutes.login:
        return _fade(const LoginView());
      case AppRoutes.signup:
        return _fade(const SignupView());
      case AppRoutes.forgotPassword:
        return _fade(const ForgotPasswordView());
      case AppRoutes.verifyAccount:
        return _fade(const VerifyAccountView());
      case AppRoutes.resetPassword:
        return _fade(const ResetPasswordView());
      case AppRoutes.authSuccess:
        return _fade(const SuccessView());
      case AppRoutes.mainWrapper:
        return _fade(const MainWrapper());
      case AppRoutes.home:
        return _fade(const HomeView());
      case AppRoutes.allProducts:
        return _fade(const AllProductsView());
      case AppRoutes.productDetails:
        return _fade(const ProductDetailsView());
      case AppRoutes.notifications:
        return _fade(const NotificationsView());
      case AppRoutes.reviews:
        return _fade(const ReviewsView());
      case AppRoutes.addReview:
        return _fade(const AddReviewView());
      case AppRoutes.profile:
        return _fade(const ProfileView());
      case AppRoutes.editProfile:
        return _fade(const EditProfileView());
      case AppRoutes.changePassword:
        return _fade(const ChangePasswordView());
      case AppRoutes.settings:
        return _fade(const SettingsView());
      case AppRoutes.aboutUs:
        return _fade(const AboutUsView());
      case AppRoutes.helpCenter:
        return _fade(const HelpCenterView());
      case AppRoutes.privacy:
        return _fade(const PrivacyView());
      case AppRoutes.termsConditions:
        return _fade(const TermsConditionsView());
      case AppRoutes.search:
        return _fade(const SearchView());
      case AppRoutes.filterSort:
        return _fade(const FilterSortView());
      case AppRoutes.cart:
        return _fade(const CartView());
      case AppRoutes.checkout:
        return _fade(const CheckoutView());
      case AppRoutes.addAddress:
        return _fade(const AddAddressView());
      case AppRoutes.editAddress:
        return _fade(const EditAddressView());
      case AppRoutes.addCard:
        return _fade(const AddCardView());
      case AppRoutes.orderSuccess:
        return _fade(const OrderSuccessView());
      case AppRoutes.orderTracking:
        return _fade(const OrderTrackingView());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static Route<dynamic> _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
