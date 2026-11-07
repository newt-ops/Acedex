# Acedex 📚⚡

> **Personal Academic Management Platform for Ethiopian Secondary School Students (EUEE)**

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Database%20%26%20Auth-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-4285F4)](#)
[![Design](https://img.shields.io/badge/Design-Apple%20HIG%20%7C%20Plum%20Theme-8A2BA3)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🌟 Overview

**Acedex** (`com.aymen.acedex`) is a specialized, offline-first academic management application designed specifically for Ethiopian students preparing for the **Ethiopian University Entrance Examination (EUEE)** across Grades 9 through 12.

Rather than delivering generic educational content, Acedex provides the **organizational infrastructure** students need to master their syllabus, track daily study consistency, maintain momentum with streaks, and conquer exam preparation.

---

## 🚀 Key Features

- **📖 Grades 9–12 Curriculum & Mastery Tracker**:
  - Full syllabus coverage for both **Natural Science** and **Social Science** streams.
  - 3-stage progress tracking: `Not Started` ➔ `Completed` (read) ➔ `Mastered` (revised & tested).
- **⏱️ Focus Timer & Session Logger**:
  - Built-in Pomodoro and Stopwatch timers linked directly to curriculum units.
  - Quick manual session logging for offline study hours.
- **📈 Consistency & Study Analytics**:
  - Dynamic `fl_chart` charts displaying weekly/monthly hours, streak consistency, and subject distribution.
- **🔔 Smart Local Reminders**:
  - Reliable offline alarms for daily study goals, up-next unit recommendations, and inactivity alerts.
- **🛡️ Streak Protection via Unity Rewarded Ads**:
  - Earn Streak Freezes and UI perks by viewing non-intrusive rewarded ads without disrupting focus sessions.
- **☁️ Seamless Offline-First Sync**:
  - High-performance local storage powered by **Drift + SQLite**, synchronizing automatically with **Supabase PostgreSQL & Auth** whenever connected.
- **🎨 Apple Human Interface Guidelines (HIG)**:
  - Custom Plum palette tokens, fluid `BouncingScrollPhysics`, stroke-rounded Hugeicons, and zero emoji in production code.

---

## 🏗️ Technical Architecture

Acedex adheres to a clean, decoupled layer architecture:

```
              FLUTTER APPLICATION
                       |
           PRESENTATION LAYER
      Screens / Reusable HIG Widgets
                       |
            APPLICATION LAYER
           Riverpod / Notifiers
                       |
               DOMAIN LAYER
        Entities / Repository Contracts
                       |
                DATA LAYER
                /         \
        LOCAL DATA        REMOTE DATA
       Drift (SQLite)   Supabase (Postgres)
                \         /
                SYNC ENGINE
                       |
              SUPABASE STORAGE
             (Profile Avatars)
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.41+ & Dart 3.11+ |
| **State Management** | Flutter Riverpod |
| **Navigation** | GoRouter |
| **Local Persistence** | Drift (SQLite) + sqlite3_flutter_libs |
| **Backend & Cloud** | Supabase (PostgreSQL, Auth, Storage) |
| **Ads** | Unity Ads Plugin (Rewarded Placements) |
| **Charts** | fl_chart |
| **Icons** | Hugeicons (Stroke Rounded) |
| **Notifications** | flutter_local_notifications |

---

## 👨‍💻 Developer & Credits

Designed and developed by **Aymen (Newton)**.

- 💬 **Telegram**: [@neorll7](https://t.me/neorll7)
- 🐙 **GitHub**: [@newt-ops](https://github.com/newt-ops)
- ✉️ **Email**: [aymenmubarek10@gmail.com](mailto:aymenmubarek10@gmail.com)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
