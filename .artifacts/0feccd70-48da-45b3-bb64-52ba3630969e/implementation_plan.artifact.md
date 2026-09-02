# Authentication Flow Implementation Plan

This plan outlines the steps to implement the authentication module, including Login, Sign Up, OTP Verification, Password Recovery, and Success screens, following the existing MVVM architecture.

## User Review Required

> [!IMPORTANT]
> - **Navigation Flow**: I've designed the flow as: `Splash -> Onboarding -> Login`. From Login, users can go to `Sign Up` or `Forgot Password`.
> - **Social Logins**: Social login buttons (FB, Pinterest, LinkedIn) will be implemented as UI placeholders for now.
> - **OTP Component**: I will create a custom numeric keypad as shown in the design for the `Verify Account` screen.

## Proposed Changes

### Core & Data Layer
Summary: Update routes and constants, and create a repository for auth operations.

#### [MODIFY] [app_routes.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/core/routes/app_routes.dart)
Add routes for all new screens.

#### [MODIFY] [app_router.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/core/routes/app_router.dart)
Wire up the new routes to their respective screens.

#### [MODIFY] [app_strings.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/core/constants/app_strings.dart)
Add all user-facing strings for the new screens.

#### [NEW] [auth_repository.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/data/repositories/auth_repository.dart)
Interface and implementation for authentication tasks (Login, Signup, OTP, Reset).

---

### Presentation Layer (Auth)
Summary: Create ViewModels and Views for each screen.

#### [NEW] [Login](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/auth/login/)
- `login_view.dart`: Main login screen.
- `login_viewmodel.dart`: State management for login.

#### [NEW] [Sign Up](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/auth/signup/)
- `signup_view.dart`: Account creation screen.
- `signup_viewmodel.dart`: State management for signup.

#### [NEW] [Password Recovery](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/auth/forgot_password/)
- `forgot_password_view.dart`: Email entry for reset.
- `verify_account_view.dart`: OTP entry with custom keypad.
- `reset_password_view.dart`: New password entry.
- `auth_viewmodel.dart`: Shared or separate ViewModels for the recovery flow.

#### [NEW] [Success](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/auth/success/success_view.dart)
A generic success screen that can be used after signup or password reset.

---

### Shared Components
Summary: Reusable widgets for the auth module.

#### [NEW] [Auth Header](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/auth/widgets/auth_header.dart)
The curved teal header with titles seen in the designs.

#### [NEW] [Social Logins](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/auth/widgets/social_login_bar.dart)
The "Or sign in with" section.

## Verification Plan

### Automated Tests
- Unit tests for `AuthViewModel` to verify navigation and validation logic.
- Widget tests for `LoginView` and `SignupView` to ensure UI elements are present.

### Manual Verification
- Run the app and navigate through the entire flow: `Splash -> Onboarding -> Login -> Sign Up -> Verify -> Success -> Home`.
- Verify input validation (empty fields, email format).
- Verify the custom numeric keypad in the OTP screen.
