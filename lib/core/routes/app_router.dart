import 'package:flutter/material.dart';
import '../../presentation/auth/forgot_password/forgot_password_view.dart';
import '../../presentation/auth/forgot_password/reset_password_view.dart';
import '../../presentation/auth/forgot_password/verify_account_view.dart';
import '../../presentation/auth/login/login_view.dart';
import '../../presentation/auth/signup/signup_view.dart';
import '../../presentation/auth/success/success_view.dart';
import '../../presentation/home/view/home_view.dart';
import '../../presentation/onboarding/view/onboarding_view.dart';
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
      case AppRoutes.home:
        return _fade(const HomeView());
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
