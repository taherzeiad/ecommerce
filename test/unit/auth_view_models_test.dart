import 'dart:typed_data';

import 'package:ecommerce/core/constants/app_strings.dart';
import 'package:ecommerce/data/repositories/auth_repository.dart';
import 'package:ecommerce/presentation/auth/forgot_password/auth_viewmodel.dart';
import 'package:ecommerce/presentation/auth/login/login_viewmodel.dart';
import 'package:ecommerce/presentation/auth/signup/signup_viewmodel.dart';
import 'package:ecommerce/presentation/auth/social/social_login_view_model.dart';
import 'package:ecommerce/presentation/profile/view_model/change_password_view_model.dart';
import 'package:ecommerce/presentation/profile/view_model/profile_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeAuthRepository auth;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    auth = FakeAuthRepository();
  });

  group('LoginViewModel', () {
    LoginViewModel make(String email, String password) {
      return LoginViewModel(auth)
        ..emailController.text = email
        ..passwordController.text = password;
    }

    test('empty fields are rejected without calling the backend', () async {
      final vm = make('', '');

      expect(await vm.login(), isFalse);
      expect(vm.errorMessage, isNotNull);
      expect(auth.calls, isEmpty);
    });

    test('malformed email is rejected', () async {
      final vm = make('not-an-email', 'secret1');

      expect(await vm.login(), isFalse);
      expect(auth.calls, isEmpty);
    });

    for (final email in [
      'omar@example.com',
      'first.last@mail.co',
      'name+tag@gmail.com',
      'dev@company.studio',
      'user@school.education',
    ]) {
      test('accepts a valid address: $email', () async {
        final vm = make(email, 'secret1');

        expect(await vm.login(), isTrue, reason: vm.errorMessage);
        expect(auth.calls, ['login:$email']);
      });
    }

    test('trims the email before sending it', () async {
      final vm = make('  omar@example.com ', 'secret1');

      await vm.login();

      expect(auth.calls, ['login:omar@example.com']);
    });

    final errorCases = {
      'Invalid login credentials': 'error_invalid_credentials',
      'Email not confirmed': 'error_email_not_confirmed',
      'ClientException: Failed host lookup': 'error_network',
      'statusCode: 429 Too Many Requests': 'error_too_many_requests',
      'something odd': 'error_unexpected',
    };
    errorCases.forEach((message, key) {
      test('maps "$message" to $key', () async {
        auth.loginError = Exception(message);
        final vm = make('omar@example.com', 'secret1');

        expect(await vm.login(), isFalse);
        expect(vm.errorMessage, key);
        expect(vm.isLoading, isFalse);
      });
    });

    test('remember-me is on by default and is saved at login', () async {
      final vm = make('omar@example.com', 'secret1');
      expect(vm.rememberMe, isTrue);

      vm.toggleRememberMe(false);
      await vm.login();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppStrings.rememberMePrefKey), isFalse);
    });
  });

  group('SignupViewModel', () {
    SignupViewModel make({
      String name = 'Omar',
      String email = 'omar@example.com',
      String password = 'secret1',
      String? confirm,
      bool agree = true,
    }) {
      final vm = SignupViewModel(auth)
        ..nameController.text = name
        ..emailController.text = email
        ..passwordController.text = password
        ..confirmPasswordController.text = confirm ?? password;
      vm.toggleTerms(agree);
      return vm;
    }

    test('happy path signs the user up and in', () async {
      final vm = make();

      expect(await vm.signup(), isTrue);
      expect(vm.needsEmailConfirmation, isFalse);
      expect(auth.calls, ['signup:omar@example.com']);
    });

    test('reports when the email must be confirmed first', () async {
      auth.signupNeedsConfirmation = true;
      final vm = make();

      expect(await vm.signup(), isTrue);
      expect(vm.needsEmailConfirmation, isTrue);
    });

    test(
      'rejects missing fields, mismatched passwords and unchecked terms',
      () async {
        expect(await make(name: '').signup(), isFalse);
        expect(await make(confirm: 'other').signup(), isFalse);
        expect(await make(agree: false).signup(), isFalse);
        expect(await make(email: 'bad@').signup(), isFalse);
        expect(auth.calls, isEmpty);
      },
    );

    final errorCases = {
      'User already exists': 'error_user_exists',
      'Password should be at least 6 characters': 'error_weak_password',
      'email_send_rate_limit': 'error_too_many_requests',
      'Failed to fetch': 'error_network',
      '???': 'error_unexpected',
    };
    errorCases.forEach((message, key) {
      test('maps "$message" to $key', () async {
        auth.signupError = Exception(message);
        final vm = make();

        expect(await vm.signup(), isFalse);
        expect(vm.errorMessage, key);
      });
    });
  });

  group('ForgotPasswordViewModel', () {
    test('OTP input accepts 6 digits and supports delete/clear', () {
      final vm = ForgotPasswordViewModel(auth);
      for (final d in ['1', '2', '3', '4', '5', '6', '7']) {
        vm.appendOtp(d);
      }
      expect(vm.otp, '123456');

      vm.removeLastOtp();
      expect(vm.otp, '12345');

      vm.setOtp('9876543');
      expect(vm.otp, '12345', reason: 'too long, ignored');

      vm.clearOtp();
      expect(vm.otp, '');
      vm.removeLastOtp();
      expect(vm.otp, '');
      vm.dispose();
    });

    testWidgets('sendResetLink needs an email, then starts a resend timer', (
      tester,
    ) async {
      final vm = ForgotPasswordViewModel(auth);

      expect(await vm.sendResetLink(), isFalse);

      vm.emailController.text = 'omar@example.com';
      expect(await vm.sendResetLink(), isTrue);
      expect(auth.calls, ['sendResetLink:omar@example.com']);
      expect(vm.canResend, isFalse);
      expect(await vm.resendCode(), isFalse);

      await tester.pump(const Duration(seconds: 61));
      expect(vm.resendSecondsLeft, 0);
      expect(await vm.resendCode(), isTrue);
      vm.dispose();
    });

    test('verifyOtp needs the full code and sends the email with it', () async {
      final vm = ForgotPasswordViewModel(auth)
        ..emailController.text = 'omar@example.com';
      vm.setOtp('123');
      expect(await vm.verifyOtp(), isFalse);
      expect(vm.errorMessage, 'error_otp_incomplete');

      vm.setOtp('123456');
      expect(await vm.verifyOtp(), isTrue);
      expect(auth.calls.last, 'verifyOtp:omar@example.com:123456');
      vm.dispose();
    });

    test('a wrong or expired code gets a clear message', () async {
      auth.otpError = Exception('Token has expired or is invalid');
      final vm = ForgotPasswordViewModel(auth)..setOtp('123456');

      expect(await vm.verifyOtp(), isFalse);
      expect(vm.errorMessage, 'error_otp_invalid');
      vm.dispose();
    });

    test('resetPassword validates, saves, then signs out', () async {
      auth.loggedIn = true;
      final vm = ForgotPasswordViewModel(auth);
      expect(await vm.resetPassword(), isFalse);

      vm.passwordController.text = 'abc';
      vm.confirmPasswordController.text = 'abc';
      expect(await vm.resetPassword(), isFalse);
      expect(vm.errorMessage, 'error_weak_password');

      vm.passwordController.text = 'abcdef';
      vm.confirmPasswordController.text = 'abcdeg';
      expect(await vm.resetPassword(), isFalse);

      vm.confirmPasswordController.text = 'abcdef';
      expect(await vm.resetPassword(), isTrue);
      expect(auth.password, 'abcdef');
      expect(auth.isUserLoggedIn(), isFalse);
      vm.dispose();
    });
  });

  group('ChangePasswordViewModel', () {
    ChangePasswordViewModel make(
      String current,
      String next, [
      String? confirm,
    ]) {
      return ChangePasswordViewModel(auth)
        ..currentController.text = current
        ..newController.text = next
        ..confirmController.text = confirm ?? next;
    }

    test('validates before calling the backend', () async {
      expect(await make('', '').submit(), isFalse);
      expect(await make('secret1', 'abc').submit(), isFalse);
      expect(await make('secret1', 'abcdef', 'abcdeg').submit(), isFalse);

      final same = make('secret1', 'secret1');
      expect(await same.submit(), isFalse);
      expect(same.errorMessage, 'error_same_password');
      expect(auth.calls, isEmpty);
    });

    test('a wrong current password is reported', () async {
      final vm = make('nope12', 'newpass1');

      expect(await vm.submit(), isFalse);
      expect(vm.errorMessage, 'error_wrong_current_password');
    });

    test('changes the password', () async {
      expect(await make('secret1', 'newpass1').submit(), isTrue);
      expect(auth.password, 'newpass1');
    });
  });

  group('SocialLoginViewModel', () {
    testWidgets('signs in when the provider sends the user back', (
      tester,
    ) async {
      final vm = SocialLoginViewModel(auth);

      await vm.signIn(SocialProvider.google);
      expect(vm.signedIn, isFalse);
      await tester.pump(const Duration(milliseconds: 200));

      expect(auth.calls, ['provider:google']);
      expect(vm.signedIn, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppStrings.rememberMePrefKey), isTrue);
      vm.dispose();
    });

    test('a disabled provider gets a readable message', () async {
      auth.providerError = Exception(
        'Unsupported provider: provider is not enabled',
      );
      final vm = SocialLoginViewModel(auth);

      await vm.signIn(SocialProvider.facebook);

      expect(vm.errorMessage, 'error_provider_disabled');
      expect(vm.busyProvider, isNull);
      vm.dispose();
    });
  });

  group('ProfileViewModel', () {
    test('reads the signed-in user, then the full profile', () async {
      auth.loggedIn = true;
      final profile = FakeProfileRepository(auth)
        ..phone = '0599'
        ..avatarUrl = 'https://x/a.png';
      final vm = ProfileViewModel(
        authRepository: auth,
        profileRepository: profile,
      );
      expect(vm.userName, 'Omar Adam');

      await vm.refresh();

      expect(vm.phone, '0599');
      expect(vm.avatarUrl, 'https://x/a.png');
    });

    test('updateProfile validates name and phone', () async {
      auth.loggedIn = true;
      final profile = FakeProfileRepository(auth);
      final vm = ProfileViewModel(
        authRepository: auth,
        profileRepository: profile,
      );

      expect(await vm.updateProfile(name: '  '), isFalse);
      expect(vm.errorMessage, 'error_name_required');
      expect(await vm.updateProfile(name: 'Omar', phone: 'abc'), isFalse);
      expect(vm.errorMessage, 'error_invalid_phone');

      expect(
        await vm.updateProfile(name: ' Omar A. ', phone: '+970 59 123 4567'),
        isTrue,
      );
      expect(vm.userName, 'Omar A.');
      expect(profile.updates, ['Omar A.|+970 59 123 4567']);
    });

    test('uploads a new photo', () async {
      auth.loggedIn = true;
      final profile = FakeProfileRepository(auth);
      final vm = ProfileViewModel(
        authRepository: auth,
        profileRepository: profile,
      );

      expect(
        await vm.uploadAvatar(Uint8List.fromList([1, 2, 3]), 'png'),
        isTrue,
      );

      expect(vm.avatarUrl, 'https://example.com/avatar.png');
      expect(vm.isUploadingAvatar, isFalse);
    });

    test(
      'refresh picks up a user who signed in after the app started',
      () async {
        final vm = ProfileViewModel(
          authRepository: auth,
          profileRepository: FakeProfileRepository(auth),
        );
        expect(vm.userName, '');

        auth.loggedIn = true;
        await vm.refresh();

        expect(vm.userName, 'Omar Adam');
      },
    );
  });
}
