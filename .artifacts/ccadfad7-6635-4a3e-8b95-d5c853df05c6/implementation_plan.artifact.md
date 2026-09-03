# Implementation Plan - Profile and Settings Screens

This plan covers the implementation of the Profile, Edit Profile, Change Password, Settings, and related support screens (About Us, Help Center, Privacy, Terms & Conditions) as shown in the provided design images.

## User Review Required

> [!IMPORTANT]
> - I am adding a 5th tab to the bottom navigation bar for the "Profile" screen.
> - Expandable sections (About Us, Help Center, etc.) will be implemented using `ExpansionTile` with custom styling to match the cards in the design.

## Proposed Changes

### Core / Routing

#### [MODIFY] [app_routes.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/core/routes/app_routes.dart)
Add constants for the new screens:
- `profile`
- `editProfile`
- `changePassword`
- `settings`
- `aboutUs`
- `helpCenter`
- `privacy`
- `termsConditions`

#### [MODIFY] [app_router.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/core/routes/app_router.dart)
Add navigation logic for the new screens.

---

### UI / Main Wrapper

#### [MODIFY] [main_wrapper.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/main_wrapper/main_wrapper.dart)
Add `ProfileView` to the screens list.

#### [MODIFY] [custom_bottom_nav.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/main_wrapper/widgets/custom_bottom_nav.dart)
Add a 5th `_NavItem` for Profile.

---

### UI / Profile & Settings

#### [NEW] [profile_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/profile/view/profile_view.dart)
The main profile screen with user info and navigation list.

#### [NEW] [edit_profile_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/profile/view/edit_profile_view.dart)
Screen to edit user details.

#### [NEW] [change_password_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/profile/view/change_password_view.dart)
Form to change user password.

#### [NEW] [settings_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/settings/view/settings_view.dart)
Settings list and logout dialog.

#### [NEW] [about_us_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/settings/view/about_us_view.dart)
#### [NEW] [help_center_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/settings/view/help_center_view.dart)
#### [NEW] [privacy_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/settings/view/privacy_view.dart)
#### [NEW] [terms_conditions_view.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/settings/view/terms_conditions_view.dart)
Information screens with expandable sections.

---

### UI / Components

#### [NEW] [profile_widgets.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/profile/widgets/profile_widgets.dart)
Common widgets like the profile picture with arc and profile list items.

#### [NEW] [expandable_card.dart](file:///C:/Users/Taher/StudioProjects/ecommerce/lib/presentation/settings/widgets/expandable_card.dart)
A reusable widget for the expandable sections in About Us, Help Center, etc.

## Verification Plan

### Manual Verification
- Navigate through all tabs in the bottom navigation.
- Open the Profile screen and tap each item to ensure it navigates to the correct view.
- Test the logout dialog in the Settings screen.
- Verify that expandable sections in info screens work as expected.
- Check the "Save Changes" and "Save Change" buttons for UI responsiveness.
