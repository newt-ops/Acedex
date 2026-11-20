# ACEDEX Design Translation Rule: Concept Wireframes to Apple-Style Production UI

This document formalizes the binding design principle for how user sketches, wireframes, and concept images are translated into production code across the Acedex platform.

---

## 1. Core Principle: Intent Over Literal Replication

When the user provides a hand-drawn diagram, low-fidelity wireframe, or whiteboard concept image (such as `media_1795186437331_374e636e.png`):

1. **User Concepts Define UX Intent & Flow:**
   The concept communicates *information hierarchy, sequence of decisions, and psychological flow* (e.g. 7 bite-sized steps, one question per screen, zero-friction progression).
2. **Never Render Literal Low-Fi Boxes:**
   Never translate a rough box or unstyled list literally into the final UI. Low-fidelity sketches are invitations to apply world-class visual design, motion physics, and tactile delight.
3. **Elevate to Apple-Grade Polish:**
   Every element must feel fluid, tactile, and premium:
   - Squircles with balanced continuous curvature (`BorderRadius.circular(18)` to `24`).
   - Smooth physical spring animations (`Curves.easeOutCubic`, 250–350ms duration).
   - Micro-tactile depression on press (`AcedexBounceable` with `0.94` scale reduction).
   - Zero dry instant cuts — all screen changes use directional slide-fades.

---

## 2. Mandatory Visual & Iconography Standards

1. **Strictly Hugeicons Stroke-Rounded:**
   - **Zero Emojis:** Never use unicode emojis (e.g., 🇪🇹, 🔬, 📚, 👋) in user-facing production UI.
   - **Zero Material Icons:** Never use generic `Icons.*` from standard Material.
   - **Always HugeIcons:** Use exclusively `HugeIcons.strokeRounded*` from the `hugeicons: ^4.4.0` Flutter package and `@hugeicons/react` on web.
2. **Royal Purple Theme Token Adherence:**
   - **Light Mode Accent:** `#8A2BA3` (contrast 7.1:1 AAA on `#FFFFFF`).
   - **Dark Mode Accent:** `#B866CF` (contrast 5.4:1 AA on `#0E0E11`).
   - **Soft Tints:** `#EFE1F2` (14% light tint) and `#271A2C` (14% dark tint).
   - **On-Accent:** `#FFFFFF` on Light Accent; `#0B0B0F` on Dark Accent.
3. **Zero Developer / Technical Bleed-Through:**
   - Production screens must NEVER display backend hostnames, database connection strings, uptime counters, status codes, or stack traces.
   - All errors must be student-friendly and contextual (e.g. *"We couldn't verify this phone number. Please double-check and try again."*).

---

## 3. Friction Elimination Rules

1. **Smart Auto-Advancement (No Redundant Continue Buttons):**
   - In fixed-length inputs like the **6-digit PIN screen**, eliminating the "Continue" button removes cognitive friction.
   - The UI auto-advances or transitions state immediately upon the 6th digit:
     - **Pass 1:** Student types 6 digits -> title cross-fades smoothly to *"Confirm your PIN"*.
     - **Pass 2:** Student re-enters the 6 digits -> automatic verification. If matching, auto-advances with subtle haptic feedback; if mismatching, triggers horizontal squircle shake and resets cleanly.
2. **Adaptive Steps Based on Academic Curriculum:**
   - In the Ethiopian educational system, streaming (Natural Science vs. Social Science) begins in **Grade 11**.
   - If a student selects **Grade 9 or Grade 10**, Step 5 (*Stream Selection*) is automatically omitted:
     - Stream is assigned `null` (General Curriculum).
     - Step counter dynamically adapts from `07` total steps to `06` total steps (`04 / 06` -> `05 / 06 [PIN]`).

---

## 4. Skeuomorphic Credential Presentation (The Digital Student ID Card)

When presenting final user registration details for review:
- Do **not** show a plain text bulleted list or standard form table.
- Display a realistic, Apple Wallet-style **Digital Student ID Card** / Exam Candidate Pass:
  - Card ratio `1.58:1` (standard ID card geometry) with deep violet mesh gradient and micro-dot security pattern.
  - Embossed candidate identification code (`ACX-26-XXXX`).
  - Holographic microchip indicator (`HugeIcons.strokeRoundedSimCard`).
  - Student avatar badge keyed to gender (`strokeRoundedGraduateMale` / `strokeRoundedGraduateFemale`).
  - Academic level & stream pill (`Grade 12 • Natural Science`).
  - Stylized digital exam hall ticket barcode graphic.
  - Interactive tap-to-edit capability on card chips to quickly adjust details.
