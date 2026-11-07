# Changelog

All notable changes to the **Acedex** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and [Acedex Versioning Principles](.agents/rules/versioning.md).

---

## [Unreleased]

### Added
- **App PIN Security & Lock**:
  - Implemented secure hardware-backed PIN persistence via `FlutterSecureStorage`.
  - Built custom Apple HIG on-screen numeric keypad (`AcedexPinKeypad`) featuring tactile spring buttons and dialer subtext that **never opens the device soft keyboard**.
  - Built `PinDotsIndicator` with haptic feedback and error shake animations.
  - Implemented automatic app lock interception on app background/resumption lifecycle events.
  - Created full-screen `PinLockScreen` and two-step setup/confirmation flow (`PinSetupScreen`).
- **Smooth Navigation Transitions**:
  - Connected `AcedexFloatingNavBar` to an animated `PageView` providing smooth 320ms cubic transitions between app sections.
- **Plum Design System**: Implemented `AppColors` ThemeExtension covering all specified light and dark tokens, derived colors, and status tints.
- **Apple HIG Theme**: Built `AppTheme` with system typography, `BouncingScrollPhysics`, card/dialog/sheet radiuses, and zero heavy shadows.
- **Theme Mode Persistence**: Created Riverpod `themeModeProvider` allowing seamless system/light/dark toggling persisted in `SharedPreferences`.
- **Reusable HIG UI Component Library**:
  - `AcedexFloatingNavBar`: Floating iOS-style pill navigation bar with blur backdrop and icon-only layout.
  - `AcedexButton`: Primary, secondary, and danger button variants with spring tap animations.
  - `AcedexToast`: Floating status overlay with Hugeicons and status-tinted borders.
  - `AcedexDialog`: iOS modal dialog with destructive action styling.
  - `AcedexSkeleton`: Shimmering skeleton loaders with reduced motion accessibility support.
  - `AcedexBadge`: Fully rounded status badges.
  - `AcedexInput`: HIG text inputs with smooth focus ring animations.
- **Drift SQLite Database**: Configured `AppDatabase` with tables for students, subjects, chapters, progress, and study sessions.
- **Curriculum Seeder**: Integrated automatic SQLite database preloading from `assets/data/ethiopian_curriculum.json`.
- **Quality Assurance**: Added 10 automated unit and widget tests covering theme tokens, dark/light mode toggling, Drift database operations, and widget rendering.

### Changed
- Configured `.gitignore` to explicitly ignore `data.json` and keep raw extracted docs in `Doc/data.json`.

### Planned
- Supabase Auth flow with Email/Password & Google Sign-In and student onboarding.
- Focus Timer (Pomodoro/Stopwatch) and manual study logging.
- Consistency analytics with `fl_chart`.
- Local notification schedules and inactivity detection.
- Unity Rewarded Ads streak recovery integration.
- Profile picture upload to Supabase Storage `avatars` bucket.
- Developer appreciation profile for Aymen (Newton).
- Local Drift database tables and two-way Supabase delta sync engine.
- Focus Timer (Pomodoro/Stopwatch) and manual study logging.
- Consistency analytics with `fl_chart`.
- Local notification schedules and inactivity detection.
- Unity Rewarded Ads streak recovery integration.
- Profile picture upload to Supabase Storage `avatars` bucket.
- Developer appreciation profile for Aymen (Newton).

---

## [1.0.0+1] - 2026-11-07

### Added
- **Project Initialization**: Scaffolding for Android and iOS only under package identifier `com.aymen.acedex` with app label `Acedex`.
- **State & Routing Infrastructure**: Configured `flutter_riverpod` and `go_router`.
- **Offline Persistence**: Configured `drift`, `drift_dev`, `sqlite3_flutter_libs`, and `build_runner` with verified build-engine compatibility.
- **Backend & Cloud Services**: Configured `supabase_flutter`, `flutter_secure_storage`, and `connectivity_plus`.
- **Storage Infrastructure**: Created and secured public `avatars` bucket on Supabase Storage with authenticated RLS upload policies.
- **Ads Integration**: Configured `unity_ads_plugin` with production Game IDs (Android: `6220248`, iOS: `6220249`) and rewarded placements (`Rewarded_Android`, `Rewarded_iOS`).
- **Media & Utilities**: Added `hugeicons` (stroke rounded), `fl_chart`, `image_picker`, `url_launcher`, `shared_preferences`, and `intl`.
- **Notification Services**: Integrated `flutter_local_notifications` and `timezone`.
- **Platform Permissions**:
  - Android: `INTERNET`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, and `VIBRATE`.
  - iOS: `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription`.
- **Assets Registration**: Declared `assets/data/` for Ethiopian curriculum seed data.
- **Repository & Licensing**:
  - Configured `.gitignore` ignoring documentation, agent directories, and local cache.
  - Added modern, comprehensive `README.md` and MIT `LICENSE`.
  - Connected Git origin to `https://github.com/newt-ops/Acedex.git`.

