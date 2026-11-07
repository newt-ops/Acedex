# Changelog

All notable changes to the **Acedex** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and [Acedex Versioning Principles](.agents/rules/versioning.md).

---

## [Unreleased]

### Planned
- Complete Ethiopian Grade 9–12 EUEE syllabus integration from Google NotebookLM extraction.
- Design system implementation: Plum theme tokens, Apple HIG typography, and custom reusable widgets.
- Supabase Auth flow with Email/Password & Google Sign-In and student onboarding.
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
