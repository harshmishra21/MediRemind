# 💊 MediRemind — Patient Health & Medication Assistant

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/UI/UX-Custom%20Design%20System-2E7D32?style=for-the-badge" alt="UI System" />
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20macOS-E06D53?style=for-the-badge" alt="Platforms" />
</p>

**MediRemind** is a modern, patient-focused mobile health management application built with Flutter. Designed around human-centered healthcare principles, it transforms daily pill schedules, dosage tracking, prescription scanning, and lab report management into a visually engaging, effortless experience.

---

## 🎨 Comprehensive Frontend & UI/UX Architecture

The frontend of MediRemind is crafted from the ground up with a custom design system prioritizing legibility, visual warmth, fluid motion, and patient-centric ergonomics.

```
                  ┌──────────────────────────────────────────┐
                  │          RootNavShell (TabBar)           │
                  └─────────────────────┬────────────────────┘
                                        │
        ┌───────────────────┬───────────┴───────────┬────────────────────┐
        ▼                   ▼                       ▼                    ▼
 🏠 Dashboard         💊 Pillbox            📜 Prescriptions      📊 Reports
  ├─ Header Banner     ├─ Search Bar         ├─ Rx Cards List      ├─ Category Chips
  ├─ Emergency ID      ├─ Category Chips     └─ Scan Screen        ├─ Upload Sheet
  ├─ Streak Card       └─ Slidable Cards                           └─ Report Viewer
  └─ Dose Sections
```

---

### 🎨 1. Design System & Aesthetic Tokens (`AppColors` & Typography)

MediRemind shuns plain generic defaults in favor of a curated, comforting color palette and modern Google Fonts typography:

#### 🟢 Color Palette Architecture
* **Primary (Deep Forest Teal - `#2F6F62`):** Inspires medical trust, tranquility, and clarity. Used for primary buttons, active icons, and navigation highlights.
* **Primary Container (`#E3F0EC`):** Soft tint used for active chip backgrounds, icon containers, and progress rings.
* **Warm Surface Background (`#FAF7F2`):** Warm off-white canvas that reduces eye strain compared to harsh `#FFFFFF` backgrounds.
* **Accent Terracotta (`#E06D53`):** High-priority accent color used for missed dose alerts, emergency call triggers, and deletion actions.
* **Status Colors:**
  - 🟩 **Taken / Sufficient Stock:** `#2E7D32` (Muted Leaf Green)
  - 🟧 **Upcoming / Low Stock:** `#D97706` (Warm Amber)
  - 🟥 **Missed / Out of Stock:** `#D9534F` (Terracotta Red)
  - 🟦 **Skipped:** `#64748B` (Muted Slate)

#### 🔤 Typography System
* **Headings (`GoogleFonts.sora`):** Geometric sans-serif with rounded, friendly characteristics for screen titles, modal headers, and streak numbers.
* **Body & Subtitles (`GoogleFonts.inter`):** Highly legible interface typeface optimized for small screens, dose instructions, and medical report notes.

#### 🌫️ Visual Depth & Elevation
* **Glassmorphism & Layered Shadows (`cardShadow` & `heroShadow`):** Soft, multi-layered ambient shadows (`blurRadius: 16, color: 0x0A000000`) give cards a subtle floating effect above the warm background canvas.
* **Border Radii System:** Standardized rounded corners (**12px** for small badges, **14px** for cards, **20px** for containers, and **24px** for bottom sheets).

---

### 🧩 2. Reusable Modular Frontend Components

MediRemind follows strict atomic component architecture. All UI elements are broken down into reusable widgets:

#### 1. `MedicineCard` (`lib/widgets/medicine_card.dart`)
* **Visual Form Badges:** Dynamically renders icons for Tablets, Capsules, Syrups, Injections, Drops, or Inhalers.
* **Food Requirement Chips:** Color-coded pill tags showing *Before Food*, *After Food*, *With Meals*, or *No Preference*.
* **Pill Inventory Gauge:** Live counter pill badge showing remaining doses (e.g., *14 pills left*).
* **Slidable Actions (`flutter_slidable`):** Swipe right/left to edit schedules or delete records with confirmation safety.

#### 2. `ReportCard` (`lib/widgets/report_card.dart`)
* **Category Badges:** Tagged headers for *Blood Test*, *Lab Test*, *X-Ray*, and *General*.
* **Date & Notes Snippet:** Shows formatted entry dates and doctor key findings preview.
* **Preview Thumbnail:** Renders thumbnail preview icon or image scan thumbnail.

#### 3. `EmergencyIdModal` (`lib/widgets/emergency_id_modal.dart`)
* **Emergency Medical Pass Card:** A high-priority popup sheet displaying **Blood Group**, **Known Allergies**, **Chronic Conditions**, and emergency contacts.
* **One-Tap Phone Triggers:** Direct dial action buttons for emergency contacts and primary doctors.

#### 4. `EmptyState` (`lib/widgets/empty_state.dart`)
* **Contextual Empty Displays:** Used across empty pillboxes, reports, and prescriptions with clean icons, comforting copy, and direct call-to-action buttons.

---

### ✨ 3. Micro-Animations & Motion Design

* **Staggered Entrance Animations (`flutter_staggered_animations`):** Lists slide vertically upward (`verticalOffset: 30.0`) with staggered fade-ins (`375ms`), creating a smooth cascade effect when switching tabs or filtering.
* **Animated Progress Gauges (`percent_indicator`):** Circular percentage rings animate smoothly as users log doses throughout the day.
* **Interactive Bottom Sheets:** Smooth spring-animated bottom modal sheets for uploading reports, adding pills, and setting schedules.

---

### 📱 4. Detailed Screen Layout Specifications

#### 🏠 Dashboard Screen (`DashboardScreen`)
* **Header Stack:** Custom avatar photo (`user_avatar.jpg`), time-of-day greeting (*"Good Morning, Harsh 👋"*), and Emergency ID action pill.
* **Streak Card:** Prominent banner highlighting continuous adherence days with flame icons 🔥.
* **Dosage Time Sections:** Segmented daily timeline dividing medications into **Morning**, **Afternoon**, and **Evening** sections.
* **Interactive Dose Buttons:** Quick "Take" (Green) and "Skip" (Slate) dose logging buttons that update the daily progress indicator in real-time.

#### 💊 Medicine Pillbox Screen (`MedicineListScreen`)
* **Search & Filter Header:** Live text filter bar with clear button alongside horizontally scrollable category chips (*All*, *Daily*, *As Needed*).
* **Infinite Scroll List:** Staggered list view displaying active medications with remaining dose gauges.
* **Floating Action Button (`+ Add Medicine`):** Accessible floating trigger to start the 2-step medicine creation wizard.

#### ➕ 2-Step Add/Edit Medicine Wizard (`AddEditMedicineScreen` & `DosageSetupScreen`)
* **Step 1 (Medicine & Stock Details):** Form inputs for Name, Strength (mg/ml), Type selector, Food instruction chips, Initial Stock, and Low Supply Alert threshold.
* **Step 2 (Dosage Schedule & Reminders):** Days-of-week selection (Mon–Sun chips), multiple dosage time pickers, and notification sound/vibration toggles.

#### 🚨 Refill Supply Tracker Screen (`RefillAlertsScreen`)
* **Inventory Overview:** Grouped sections dividing medications into *Sufficient Stock*, *Low Supply Alert*, and *Out of Stock*.
* **One-Tap Restock Modal:** Instant modal dialog allowing users to replenish pill counts by +10, +20, or custom amounts.

#### 📊 Health Reports Cabinet (`ReportsScreen` & `ReportViewScreen`)
* **Categorized Report List:** Filter chips for Blood Tests, Lab Tests, and X-Rays.
* **Multi-Input Upload Modal Sheet:**
  - 📄 Pick PDF/Document from device storage
  - 📷 Capture lab result slip with Camera
  - 🖼️ Choose image from Photo Gallery
  - ✨ Load Sample Demo Report
* **Report View Screen:** Full-screen zoomable previewer displaying document scan images, category tags, and doctor notes.

#### 📷 Doctor Prescription Scanner (`PrescriptionScanScreen`)
* **Interactive Scan Viewport:** Alignment guidelines over live camera or image upload.
* **Doctor Info Form:** Fields for Doctor Name, Clinic Specialty, and Dosage Instructions.

---

### ♿ 5. Patient-Centric UX & Accessibility

* **Humanized Terminology:** Replaced cold warehouse jargon (*"Inventory count"*, *"Stock restock"*) with comforting patient-first phrasing (*"Pillbox"*, *"Pills Remaining"*, *"Add Pills"*).
* **Ergonomic Touch Targets:** All interactive buttons, chips, and list tiles meet a minimum target size of **48x48 dp** for easy tapping by elderly users or patients with impaired dexterity.
* **High-Contrast Text Compliance:** Strict contrast ratios between typography colors (`#1C1B1A`, `#5F5B57`) and background surfaces (`#FAF7F2`, `#FFFFFF`) to ensure maximum legibility.

---

## 🛠️ Complete Project Directory Structure

```
lib/
├── main.dart                        # Application Entry Point & Provider Setup
├── models/                          # Data Transfer Objects
│   ├── medicine.dart                # Medication Data Model
│   ├── dose_schedule.dart           # Timing & Frequency Model
│   ├── dose_log.dart                # Individual Log Status Model
│   ├── prescription.dart            # Doctor Prescription Model
│   ├── health_report.dart           # Medical Report Model
│   └── emergency_info.dart          # Emergency Pass Data Model
├── providers/                       # State Management (ChangeNotifiers)
│   ├── medicine_provider.dart       # Medicines & Schedule State
│   └── report_provider.dart         # Reports & Prescriptions State
├── services/                        # Storage & Services
│   ├── storage_service.dart         # Local Persistence & Data Seeding
│   └── notification_service.dart    # Local Alarm Notifications
├── screens/                         # Frontend Application Views
│   ├── root_nav_shell.dart          # Main Shell & Tab Navigator
│   ├── dashboard_screen.dart        # Health Dashboard View
│   ├── medicine_list_screen.dart    # Digital Pillbox View
│   ├── add_edit_medicine_screen.dart# Step 1 Medicine Creation Form
│   ├── dosage_setup_screen.dart     # Step 2 Dosage Timing Form
│   ├── medicine_detail_screen.dart  # Detailed Medicine & History View
│   ├── refill_alerts_screen.dart    # Low Supply & Restock Screen
│   ├── reports_screen.dart          # Medical Reports Cabinet View
│   ├── report_view_screen.dart      # Fullscreen Report Viewer
│   ├── prescription_list_screen.dart# Prescription List View
│   └── prescription_scan_screen.dart# Camera Rx Digitizer Screen
├── widgets/                         # Reusable Frontend Components
│   ├── medicine_card.dart           # Custom Pillbox Card
│   ├── report_card.dart             # Medical Report Card Widget
│   ├── emergency_id_modal.dart      # Emergency ID Pass Popup Modal
│   ├── empty_state.dart             # Illustrated Empty State Container
│   └── section_header.dart          # Section Header Widget
├── theme/                           # Global UI Design System Tokens
│   └── app_colors.dart              # Color Palette & Shadow Definitions
└── utils/                           # Helper Utilities
    └── date_time_helpers.dart       # Date & Time Formatter
```

---

## 👑 Author

* **Harsh Mishra** — *Lead Developer & Product Creator*

---

## 🚀 Installation & Setup Instructions

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (`v3.12.0` or later)
* Dart SDK (`v3.0.0` or later)
* Xcode (for iOS/macOS) or Android Studio (for Android)

### Quick Start Guide

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/MediRemind.git
   cd MediRemind
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run application:**
   * **macOS Desktop:**
     ```bash
     flutter run -d macos
     ```
   * **Mobile Device / Simulator:**
     ```bash
     flutter run
     ```

---

## 📜 License

This project is licensed under the **MIT License** — Copyright © 2026 **Harsh Mishra**.

---

<p align="center">
  Crafted with ❤️ for patients everywhere.
</p>
