# Changelog

All notable changes to the **Acedex** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and [Acedex Versioning Principles](.agents/rules/versioning.md).

---

## [Unreleased]

## [1.5.0+6] - 2026-11-14

### Added
- **Acedex Unit Assessment & Examination Engine**:
  - **Phase A (Database & Immutability)**:
    - Authoritative Supabase migration (`supabase/migrations/20261115000000_create_assessment_platform_schema.sql`) and down migration.
    - Air-gapped question security: answer keys (`question_solutions`) are completely inaccessible to client queries and protected with PostgreSQL row-level security.
    - Hardened security definer RPC functions: `start_assessment_attempt`, `grade_and_submit_attempt`, `reconcile_and_grade_offline_attempt`, `publish_assessment_version` with pinned `search_path = ''`.
    - Strict idempotency validation and payload tampering rejection.
    - Verified 100% across 8 test suites on isolated local PostgreSQL 16 engine.
  - **Phase B (Backend Integration & Domain Models)**:
    - Hierarchical Dart assessment models (`Assessment`, `AssessmentVersion`, `Question`, `QuestionOption`, `SelectedAnswerSubmission`, `AssessmentSubmissionResult`, `QuestionCorrection`).
    - Repository layer (`AssessmentRepository` & `SupabaseAssessmentRepository`) handling PostgREST queries and RPC evaluation.
    - Active playback controller (`AssessmentPlayController`) with 0ms local answer selection.
  - **Phase C (Offline Drift SQLite Integration)**:
    - Drift schema bumped to v2 with 7 new tables (`LocalAssessments`, `LocalAssessmentVersions`, `LocalAssessmentVersionChapters`, `LocalQuestions`, `LocalQuestionOptions`, `LocalAssessmentAttempts`, `LocalAssessmentResults`).
    - `LocalAssessmentService` provides offline caching, in-flight attempt backup, and synchronization queue querying.
  - **Phase D (Apple HIG Assessment UI)**:
    - `CurriculumScreen`: Ethiopian Grade 9–12 subject browser, unit cards with studied toggles, and contextual assessment unlocking.
    - `AssessmentIntroScreen`: Test overview with question count, time limits, passing percentage, and rules.
    - `AssessmentPlayerScreen`: 0ms tactile option selection, horizontal `PageView` pager, question navigator sheet, countdown timer, and review & submit confirmation modal.
    - `AssessmentResultScreen`: Apple HIG score ring, pass/fail badge, breakdown metrics, and question review with NotebookLM-style pedagogical explanations.
  - **Phase E (Verification & Testing)**:
    - 62 unit and widget tests passing across all features (`flutter test`).
  - **Pre-Assessment Answer Reveal Configuration (Practice vs Exam Mode)**:
    - Added `AssessmentFeedbackMode` (`afterSubmit` vs `immediate`).
    - Added Apple-style mode selection card on `AssessmentIntroScreen` allowing students to pick their desired feedback timing before starting.
    - Built **Practice Mode (Instant Feedback)** in `AssessmentPlayerScreen`:
      - Instant visual validation on option tap: selected correct option turns soft green with checkmark badge; incorrect option turns soft red with cross badge while highlighting the true correct option green.
      - Integrated pedagogical explanation card expanding beneath the question immediately upon answer selection.
      - Option locking after initial choice to prevent retrospective gaming.
      - Dynamic question jumper map displaying green/red tiles for answered questions.
    - Maintained full support for **Exam Mode (Standard)** where answers and explanations remain strictly private until final submission.
  - **Question Bank Integration & Offline Self-Healing**:
    - Fed Grade 9 Physics Unit 1 (`PHY-G09-U01.json`, 30 questions) and Unit 2 (`PHY-G09-U02.json`, 30 questions).
    - Added self-healing eager seeding in `currentChapterAssessmentProvider` and `gradeSubjectsWithProgressProvider`.
    - Added eager startup seeding in `main()` so Drift SQLite contains all assessments and questions upon launch.
    - Added normalized chapter ID alias resolution (`PHYS_G9_U1`, `PHYS_G9_U01`, `PHY_G09_U01`, `PHY-G09-U01`) in `LocalAssessmentService`.
    - Added "Check Again" button in `AssessmentIntroScreen`.

## [1.3.0+4] - 2026-11-08

### Added
- **Official Plum Mobile Launcher App Icon**:
  - Launched the solid primary plum (`#8A2BA3`) app icon with crisp white geometric mortarboard emblem as the default mobile app launcher icon.
  - Deployed pixel-perfect legacy squircle (`ic_launcher.png`) and circular (`ic_launcher_round.png`) icons across all Android densities (`mdpi` 48px, `hdpi` 72px, `xhdpi` 96px, `xxhdpi` 144px, `xxxhdpi` 192px).
  - Deployed Android adaptive launcher icons (`mipmap-anydpi-v26/ic_launcher.xml` and `ic_launcher_round.xml`) with centered emblem conforming to Google's 66% circular safe zone.
  - Deployed complete iOS AppIcon set (`1024x1024` down to `20x20` notification badges, 100% opaque RGB without alpha transparency conforming to Apple App Store review guidelines).
- **Full-Screen Immersive Display**:
  - `IntroSplashScreen` and `IntroSlidesScreen` render edge-to-edge with transparent system status bar and navigation bar via `AnnotatedRegion<SystemUiOverlayStyle>`.
- **Acedex Design System Consistency**:
  - **Balanced Illustration Sizing**: Proportioned 3D character graphics to 180–210px (`height: (availableHeight * 0.30).clamp(160.0, 210.0)`), resolving oversized visuals and providing clean vertical rhythm.
  - **Unified Typography**: Standardized headline text size to 24px (bold, -0.5 letter spacing) and subtitle to 14.5px (regular, `textSecondary`), adhering to `AppTheme` standards.
  - **Canonical `AcedexButton`**: Replaced custom buttons with the app's standard `AcedexButton` featuring `HugeIcon` trailing arrows and zero glow.
  - **Unified Top Bar Navigation**: Added back arrow navigation, centered segmented indicator lines, and quick `Skip` action.
- **Animated Splash & Loading Screen (`IntroSplashScreen`)**:
  - Displays the official Gemini brand logo with a smooth upward fade-in animation.
  - Automatically adapts between `acedex_logo_gemini_light.jpg` (light mode) and `acedex_logo_gemini_dark.jpg` (dark mode) on seamless background tokens (`#FEFAFB` / `#130D0F`).
  - Smooth horizontal progress loading bar under the brand logo animating from 0% to 100% with pill caps and zero glow.
- **Interactive 3-Slide Intro Presentation (`IntroSlidesScreen`)**:
  - Built from Figma design specs (`UI/Slide Screen.png` and `UI/Acedex UI design.figcraft`).
  - Transparent high-resolution 3D character illustrations:
    - Slide 1: `slide_1_offline.png` — "Master Every Subject, 100% Offline"
    - Slide 2: `slide_2_mastery.png` — "Structured Mastery, Unmatched Focus"
    - Slide 3: `slide_3_streaks.png` — "Build Daily Streaks, Conquer the EUEE"
  - Top 3-segment progress indicator lines tracking active slide.
  - Staggered slide-up component animations for 3D illustration, two-tone headline, subtitle, and action button.
  - Full hand swiping gesture support (`PageView` + `BouncingScrollPhysics`) alongside tactile pressable Next / Get Started buttons.
- **Intro Flow Coordinator (`IntroFlowScreen`)**:
  - Orchestrates seamless cross-fade transitions between Splash Loading Screen, 3D Intro Slides, and Guided Student Profile Setup.
  - Wired into `AppGate` for first-launch experience.
- **Developer Test Lab Shortcuts**:
  - Added dedicated preview triggers for `Full Intro Flow`, `Splash Loading`, `Intro Slides (3D)`, and `Profile Setup` in `DeveloperShowcaseScreen`.
- **Intro & Onboarding Widget Tests (`test/onboarding/intro_slides_test.dart`)**:
  - Comprehensive test suite verifying splash loading animations, light/dark brand asset selection, 3-slide page navigation, and hand swipe gestures (39 / 39 total tests passing).
- **Brand Logo & Mobile Icon Suite**: Designed a clean, minimalist geometric emblem fusing a modern letter "A" with an academic mortarboard crown and knowledge bridge (strictly 2 flat solid colors, zero gradients, zero glow):
  - **App Launcher Icons (`1024x1024` & `512x512`)**: Light mode (`#8A2BA3` on `#FFFFFF` and `#FFFFFF` on `#8A2BA3`) and Dark mode (`#D58CF0` on `#0E0B0E`).
  - **Vector SVGs**: Exported vector files (`acedex_logo_light.svg`, `acedex_logo_dark.svg`, `acedex_logo_plum.svg`, transparent variants) for Figma design collections.
  - **In-App Transparent Logos**: Exported in Plum, Dark Plum, and White across 512, 256, 128, and 64px resolutions (`assets/logo/in_app/`). Integrated directly into `TodayScreen` floating header and `SettingsScreen`.
  - **Adaptive Android Notification Icons (`ic_notification.png`)**: Generated pure white monochrome silhouettes on 100% transparent backgrounds deployed to Android drawable mipmaps (`mdpi` 24px, `hdpi` 36px, `xhdpi` 48px, `xxhdpi` 72px, `xxxhdpi` 96px) for native adaptive status bar tinting.
  - **Android Adaptive Launcher Layers**: Foreground and background layers (`432x432`) conforming to Google's 66% circular safe zone.
- **Ethiopian Student Home Dashboard (`TodayScreen`)**: Replaced development test widgets on the primary tab with an inspiring, modern Apple HIG study hub:
  - Time-aware academic greeting ("Good morning / afternoon / evening, [Name]") with dynamic EUEE national exam countdown badge.
  - Study Streak counter (`HugeIcons.strokeRoundedFire`) and Streak Freeze protection status (`HugeIcons.strokeRoundedSnowflake`).
  - Daily Study Target progress card with quick "Start Focus Timer" and "Log Hours" action buttons.
  - "My Curriculum" quick jump section querying grade-specific subjects from Drift SQLite.
  - Ethiopian EUEE study strategy tips.
- **Dedicated Developer Test Lab (`DeveloperShowcaseScreen`)**: Transited all developmental components out of the home screen to a dedicated sandbox for testing database seeding, PIN security, auth/onboarding flows, Apple Capsule toast triggers, dialogs, buttons, inputs, badges, and skeleton shimmers.
- **Developer Lab Access**: Direct one-tap shortcut in the home screen floating header bar (`HugeIcons.strokeRoundedCommandLine`) and in the Settings screen.
- **Settings & Preferences Screen (`SettingsScreen`)**: Upgraded Settings tab with Student Profile overview, PIN Lock & Biometrics switch, Appearance theme mode picker (System/Light/Dark), Developer Test Lab link, and developer appreciation card.
- **Unit & Widget Tests**: Added `test/screens/today_screen_test.dart` (35 / 35 total tests passing).

### Changed
- **Zero Glow Enforcement**: Permanently purged all colored outer blur shadows from the UI across all widgets. `AcedexButton` now follows authentic Apple HIG flat styling with tactile press feedback and zero colored halo.
- **Clean Input Border Transitions (`AcedexInput`)**: Removed outer `boxShadow` ring halo from text inputs, replacing it with pure Apple HIG 1.5px crisp border color transitions without any spread or glow.
- **Layout Overflow Hardening (`main.dart`)**: Resolved a 16px `RenderFlex` overflow on narrow viewports in the student profile header row with responsive `Expanded` and `Flexible` constraints.
- **Redesigned PIN Lock Screen (`PinLockScreen`)**: Upgraded to match the reference design:
  - Header: `"Enter current PIN"` rendered in primary plum color (`colors.primary`).
  - **Squircle Indicator Boxes (`PinBoxesIndicator`)**: 4 rounded squircle boxes (`14px` border radius) displaying active plum borders with solid plum dots while entering, emerald green borders with green dots on successful match ("Confirm" state), and crimson red borders with shake animation on error.
  - **Minimalist Numeric Keypad (`AcedexPinKeypad`)**: Clean bold numerals, bottom-left `HugeIcons.strokeRoundedFingerprintPattern` (`FingerprintPatternIcon`), and bottom-right `HugeIcons.strokeRoundedArrowLeft02` (`ArrowLeft02Icon`).
- **Biometric Fingerprint Authentication (`BiometricService`)**:
  - Integrated `local_auth: ^3.0.2` with native `FlutterFragmentActivity` on Android and `NSFaceIDUsageDescription` on iOS.
  - Added `USE_BIOMETRIC` permission in AndroidManifest.
  - On tap: prompts fingerprint authentication; on success, transitions boxes to emerald green and unlocks immediately.
  - **Graceful Fallback**: Checks device biometric hardware and enrollment; if the device cannot perform biometrics, displays an Apple capsule HUD toast (`AcedexToast.info(...)`) instructing the user to use their PIN without interruption.
- **Biometric Unit Tests**: Added `test/security/biometric_test.dart` (32 / 32 total tests passing).
- **Supabase Cloud Schema & RLS Migrations**: Deployed PostgreSQL schema for `students`, `subjects`, `chapters`, `chapter_progress`, and `study_sessions` with strict Row-Level Security policies (`(select auth.uid()) = student_id`), foreign key indexes, and auto-updating `updated_at` triggers. Saved migration in `supabase/migrations/20261107000000_init_acedex_schema.sql`.
- **Supabase Client Service (`SupabaseService`)**: Initialized PKCE client with auto-refreshing JWTs and defensive fallbacks for offline testing.
- **Apple HIG Authentication Screens (`lib/features/auth/`)**:
  - `LoginScreen`: Email/password and Google OAuth sign-in with forgotten password reset link and guest offline continuation.
  - `SignUpScreen`: Account registration with validation and direct transition to curriculum onboarding.
  - `AuthController` & `AcedexAuthState`: Riverpod state notifier managing auth lifecycle, user sessions, and error handling.
- **5-Step Interactive Student Onboarding (`lib/features/onboarding/`)**:
  - Step 1: Welcome & Ethiopian syllabus value proposition.
  - Step 2: Student identity (Name input and Male/Female selection chips).
  - Step 3: Grade selection (Grades 9 to 12).
  - Step 4: Stream selection (Common curriculum for Grades 9–10; Natural vs Social Science for Grades 11–12).
  - Step 5: Daily study target picker (60 to 180 min) with 1 free welcome Streak Freeze award.
- **Student Profile Notifier (`studentStateProvider`)**: Local-first Drift SQLite storage with automatic cloud upsert to Supabase PostgreSQL when authenticated.
- **App Navigation Gatekeeper (`AppGate`)**: Orchestrates top-level screen priorities (PIN Lock ➔ Onboarding Flow ➔ Main Dashboard Shell).
- **Unit & Widget Tests**: Added `test/auth/auth_test.dart` and `test/onboarding/onboarding_test.dart` (27 / 27 total tests passing).

### Planned
- **Profile Picture Upload**: Camera & gallery selection via `image_picker` with uploads to Supabase Storage `avatars` bucket and local Drift caching.
- **Cloud Synchronization Engine**: Two-way delta sync between local Drift SQLite and Supabase PostgreSQL.
- **Focus Timer & Study Activity**: Built-in Pomodoro/Stopwatch linked to curriculum units and quick manual study hours logging.
- **Consistency Analytics**: Interactive `fl_chart` weekly/monthly study graphs, consistency score, and subject breakdown.
- **Local Smart Notifications**: Offline study alarms and inactivity re-engagement reminders.
- **Unity Rewarded Ads**: Earn Streak Freezes / Recovery and custom UI perks via rewarded video placements (`Rewarded_Android` & `Rewarded_iOS`).
- **Developer Appreciation Screen**: Dedicated Apple HIG card honoring Aymen (Newton) with Telegram, GitHub, and email triggers.

---

## [1.2.0+3] - 2026-11-07

### Added
- **Floating Header Bar (`AcedexFloatingHeaderBar`)**: iOS-style suspended pill header with 20px frosted backdrop filter, screen title, subtitle, leading icon badge, and action buttons matching the floating navigation bar.

### Improved
- **Apple Capsule Toast HUD (`AcedexToast`)**: Re-engineered toast notifications to exactly mirror the Apple HIG stadium HUD specification:
  - **Animatable Presets**: Dual-line stacked layout ("Done / Confirmed") with circular filled badges (Apple system blue, emerald green, orange, red) housing white glyphs.
  - **Custom Image / Standalone Icons**: Added `AcedexToast.custom` supporting standalone icons (e.g. Sun icon, Lock Open padlock) without badges or custom leading widgets.
  - **Only Title Capsule**: Added `AcedexToast.onlyTitle` for ultra-clean, icon-less compact stadium pills.
  - **Top & Bottom Presentations**: Dynamic Island / notch presentation (slides down with spring bounce, recoils up into notch) and bottom presentation (slides up above home indicator, recoils down).
  - **Apple Spring Physics & Bouncing**: Calibrated `Curves.easeOutBack` spring bounce entrance with scaling (0.78 ➔ 1.0) and tactile haptic impact (`HapticFeedback.lightImpact()`).
  - **Zero Overlap & Drag Gestures**: Single-instance controller instantly recoils prior notifications before showing new ones; drag-to-dismiss and tap-to-dismiss supported.
- **Button Styling (`AcedexButton`)**: Upgraded primary and secondary buttons with solid surface blending, distinct borders, colored elevation shadows, and responsive press states.
- **Modal Dialogs (`AcedexDialog`)**: Redesigned dialog cards with 22px squircle radiuses, frosted glass blur backdrop, circular icon header badges, and integrated theme action buttons.

### Fixed
- Resolved `Text shadow blur radius should be non-negative` assertion in `PinDotsIndicator` by replacing shadow interpolation with smooth `AnimatedScale` and cubic easing curves.
- Resolved `_TypeError (type 'bool' is not a subtype of type 'String?' in type cast)` when loading theme preference by supporting both legacy boolean values and string theme modes in `ThemeModeNotifier`.
- Hardened `PinService` with defensive error handling across secure storage read operations.
- Resolved Android Gradle build failure by enabling Java 8+ core library desugaring (`isCoreLibraryDesugaringEnabled = true` with `desugar_jdk_libs:2.1.4`) in `android/app/build.gradle.kts` required by `flutter_local_notifications`.

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
