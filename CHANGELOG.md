# Changelog

All notable changes to the **Acedex** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and [Acedex Versioning Principles](.agents/rules/versioning.md).

---

## [Unreleased]

### Fixed
- Resolved `Text shadow blur radius should be non-negative` assertion in `PinDotsIndicator` by replacing shadow interpolation with smooth `AnimatedScale` and cubic easing curves.
- Resolved `_TypeError (type 'bool' is not a subtype of type 'String?' in type cast)` when loading theme preference by supporting both legacy boolean values and string theme modes in `ThemeModeNotifier`.
- Hardened `PinService` with defensive error handling across secure storage read operations.
- Resolved Android Gradle build failure by enabling Java 8+ core library desugaring (`isCoreLibraryDesugaringEnabled = true` with `desugar_jdk_libs:2.1.4`) in `android/app/build.gradle.kts` required by `flutter_local_notifications`.

### Planned (Migrated to Next Release)
- **Supabase Authentication & Student Onboarding**: Email/password and Google Sign-In with multi-step HIG onboarding (Grade 9–12, Natural/Social stream selection, daily target hours).
- **Profile Picture Upload**: Camera & gallery selection via `image_picker` with uploads to Supabase Storage `avatars` bucket and local Drift caching.
- **Cloud Synchronization**: Two-way delta sync engine between local Drift SQLite and Supabase PostgreSQL.
- **Focus Timer & Study Activity**: Built-in Pomodoro/Stopwatch linked to curriculum units and quick manual study hours logging.
- **Consistency Analytics**: Interactive `fl_chart` weekly/monthly study graphs, consistency score, and subject breakdown.
- **Local Smart Notifications**: Offline study alarms and inactivity re-engagement reminders.
- **Unity Rewarded Ads**: Earn Streak Freezes / Recovery and custom UI perks via rewarded video placements (`Rewarded_Android` & `Rewarded_iOS`).
- **Developer Appreciation Screen**: Dedicated Apple HIG card honoring Aymen (Newton) with Telegram, GitHub, and email triggers.

---

## [1.1.0+2] - 2026-11-07

### Added
- **App PIN Security & Lock**:
  - Implemented secure hardware-backed PIN persistence via `FlutterSecureStorage`.
  - Built custom Apple HIG on-screen numeric keypad (`AcedexPinKeypad`) featuring tactile spring buttons and dialer subtext that **never opens the device soft keyboard**.
  - Built `PinDotsIndicator` with haptic feedback and error shake animations.
  - Implemented automatic app lock interception on app background/resumption lifecycle events via `WidgetsBindingObserver`.
  - Created full-screen `PinLockScreen` and two-step setup/confirmation flow (`PinSetupScreen`).
- **Smooth Navigation Transitions**:
  - Connected `AcedexFloatingNavBar` to an animated `PageView` providing smooth 320ms cubic transitions between app sections.
- **Plum Design System**:
  - Implemented `AppColors` ThemeExtension covering all specified light and dark tokens, derived colors, and status tints.
- **Apple HIG Theme**:
  - Built `AppTheme` with system typography, `BouncingScrollPhysics`, card/dialog/sheet radiuses, and zero heavy shadows.
- **Theme Mode Persistence**:
  - Created Riverpod `themeModeProvider` allowing seamless system/light/dark toggling persisted in `SharedPreferences`.
- **Reusable HIG UI Component Library**:
  - `AcedexFloatingNavBar`: Floating iOS-style pill navigation bar with blur backdrop and icon-only layout.
  - `AcedexButton`: Primary, secondary, and danger button variants with spring tap animations.
  - `AcedexToast`: Floating status overlay with Hugeicons and status-tinted borders.
  - `AcedexDialog`: iOS modal dialog with destructive action styling.
  - `AcedexSkeleton`: Shimmering skeleton loaders with reduced motion accessibility support.
  - `AcedexBadge`: Fully rounded status badges.
  - `AcedexInput`: HIG text inputs with smooth focus ring animations.
- **Drift SQLite Database**:
  - Configured `AppDatabase` with tables for students, subjects, chapters, progress, study sessions, and sync queues.
- **Curriculum Seeder & Dataset**:
  - Integrated automatic SQLite database preloading from `assets/data/ethiopian_curriculum.json` covering Grades 9–12 across Natural and Social streams.
- **Automated Test Suite**:
  - Added 14 unit and widget tests covering theme tokens, dark/light mode toggling, Drift database operations, PIN security verification, and UI showcase rendering.

### Changed
- Configured `.gitignore` to explicitly ignore `data.json` and keep raw extracted docs in `Doc/data.json`.

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
