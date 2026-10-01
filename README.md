# AuraCare - Enterprise Hospital Management & Patient Care Application

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture%20%2B%20Riverpod-teal)](#architecture)
[![License](https://img.shields.io/badge/License-Proprietary-red)](#)

AuraCare is a medical-grade, multi-platform Hospital Information Management System (HIMS) and Patient Portal engineered with **Flutter**, **Material 3**, **Riverpod**, and **Supabase (PostgreSQL with Row Level Security)**. Inspired by clean, trustworthy healthcare UI design philosophy, the system delivers role-based clinical, operational, diagnostic, and financial management for hospitals, clinics, physicians, and patients.

---

## Table of Contents
1. [Visual Direction & Design Philosophy](#1-visual-direction--design-philosophy)
2. [Supported Enterprise Roles (RBAC)](#2-supported-enterprise-roles-rbac)
3. [Architecture Overview](#3-architecture-overview)
4. [Feature Matrix](#4-feature-matrix)
5. [Prerequisites & System Requirements](#5-prerequisites--system-requirements)
6. [Supabase Setup & Database Migration](#6-supabase-setup--database-migration)
7. [Environment Configuration](#7-environment-configuration)
8. [Local Development & Running the App](#8-local-development--running-the-app)
9. [Web, Android, iOS & Desktop Deployment](#9-web-android-ios--desktop-deployment)
10. [Row Level Security (RLS) & HIPAA Compliance](#10-row-level-security-rls--hipaa-compliance)
11. [Testing Strategy](#11-testing-strategy)
12. [Troubleshooting & FAQ](#12-troubleshooting--faq)

---

## 1. Visual Direction & Design Philosophy

AuraCare utilizes a turquoise/teal medical design system inspired by modern digital health interfaces:
- **Primary Teal**: `#48C9C5` — calm, clean, medical trust
- **Deep Forest Teal**: `#236B68` — high readability contrast
- **Clean Background**: `#F5FAFA` — clinical sterility and visual softness
- **Neutral Dark & Typography**: `#253B3B` text on white rounded surfaces (`16px–24px` radius)
- **Status Indicators**:
  - Success / Active / Verified: `#48B883`
  - Warning / Attention: `#F3B562`
  - Critical / Error / Emergency: `#E66A6A`

### Responsive Breakpoints
- **Mobile (`< 600px`)**: Bottom navigation bar with quick-access tabs, top branded teal header.
- **Tablet (`600px – 1024px`)**: Adaptive Navigation Rail with persistent access to clinical tools.
- **Desktop & Web (`> 1024px`)**: Full-width sidebar layout with KPI dashboard grids and multi-column clinical workflows.

---

## 2. Supported Enterprise Roles (RBAC)

The application enforces 13 granular hospital roles defined at both the database RLS level and Flutter route guard level:

| Role | Access Scope | Primary Actions |
|---|---|---|
| **Super Admin** | Hospital-wide | Complete system configuration, audit log inspection, all roles. |
| **Hospital Admin** | Operational | Department capacity, staff shifts, revenue analytics, beds. |
| **Doctor** | Clinical Care | Consultations, patient EMR, digital Rx creation, appointments. |
| **Nurse** | Inpatient Care | Bed rounds, vital signs recording, medication administration. |
| **Pharmacist** | Dispensary | Drug inventory, SKU batches, low-stock alerts, dispensing. |
| **Lab Technician** | Diagnostics | Blood/urine specimen collection, test processing, results. |
| **Radiologist** | Medical Imaging | X-Ray, CT, MRI, Ultrasound interpretation, DICOM reports. |
| **Receptionist** | Front Desk | Walk-in registration, appointment queueing, billing checks. |
| **Patient** | Personal Health | Appointments booking, pill reminders, telehealth, invoices. |
| **Accountant** | Financial | Invoices, payment processing, tax configuration, ledger. |
| **HR Manager** | Personnel | Staff directory, shift scheduling, credentials verification. |
| **Ambulance Staff** | Emergency | CAD dispatch, GPS route navigation, emergency triage. |
| **Support Staff** | Helpdesk | Ticket resolution, real-time messaging, patient queries. |

---

## 3. Architecture Overview

AuraCare follows **Clean Architecture** organized with a **Feature-First** structure:

```
lib/
├── core/
│   ├── config/              # App environment variables & compiler flags
│   ├── constants/           # Colors, typography, spacing, user roles, breakpoints
│   ├── localization/        # English, Urdu, Arabic RTL support
│   ├── network/             # Supabase client wrapper & exception mapper
│   ├── routing/             # GoRouter setup with auth and role route guards
│   ├── storage/             # Local cache & offline write queue
│   ├── theme/               # Material 3 light and dark theme definitions
│   ├── utils/               # Formatters, validators, HIPAA audit logger
│   └── widgets/             # Reusable UI component library
├── features/
│   ├── auth/                # Login, Register, Forgot Password, Persona Switcher
│   ├── dashboard/           # Role-based dashboards (Patient, Doctor, Nurse, Admin)
│   ├── patients/            # Patient directory, EMR profiles, demographics
│   ├── doctors/             # Doctor discovery directory, specialties, profile
│   ├── appointments/        # Booking, time slots, reschedule, queue tickets
│   ├── medical_records/     # Vitals logging, automated BMI, clinical timeline
│   ├── prescriptions/       # Digital signed Rx, medicine items, PDF generation
│   ├── medications/         # Pill reminder inspired by reference UI, adherence
│   ├── pharmacy/            # Medicine stock, batch expiry, dispensary
│   ├── laboratory/          # Diagnostic catalog, sample collection, test results
│   ├── radiology/           # X-Ray, CT, MRI imaging orders & findings
│   ├── admissions/          # Ward capacity, ICU beds, room occupancy
│   ├── emergency/           # 24/7 ER triage (Red/Yellow/Green), trauma dispatch
│   ├── billing/             # Invoices, itemized charges, partial settlements
│   ├── payments/            # Multi-channel payment gateway abstraction
│   ├── messaging/           # Real-time chat bubbles, doctor-patient messaging
│   ├── telemedicine/        # Telehealth video/audio consult, PiP camera, waiting room
│   ├── notifications/       # Multi-category clinical push notifications
│   ├── staff/               # Employee directory, shift rosters
│   ├── inventory/           # Hospital equipment & surgical consumables
│   ├── ambulance/           # Emergency ambulance dispatching & telemetry
│   ├── reports/             # Department revenue, length of stay, CSV/PDF exports
│   └── settings/            # Light/Dark mode, English/Urdu/Arabic switcher
└── main.dart
```

---

## 4. Feature Matrix

- **Electronic Medical Records (EMR)**: Vital signs history (BP, HR, SpO2, Temp, Weight, Height, automated BMI).
- **Pills Reminder (Inspired by UI Reference)**: Day-by-day pill schedule, Morning/Afternoon/Night dose grouping, interactive adherence checkmarks, remaining pill count, refill threshold alert.
- **Doctor Consultation & Booking**: Specialty filter chips, interactive time slot selector, walk-in/telehealth options, queue pass ticket generation.
- **Real-time Messaging**: Doctor-patient direct messaging with online presence, typing indicators, attachments.
- **Telemedicine Call Experience**: In-call controls (Mute, Camera toggle, Speakerphone, Duration counter, Doctor video feed, Local PiP).
- **Offline Resilience**: Local cache for profiles, doctors, appointments, and medication reminders. Writes are queued via `OfflineQueueService` when network connectivity drops.

---

## 5. Prerequisites & System Requirements

Ensure you have the following installed:
- **Flutter SDK**: `>= 3.10.0`
- **Dart SDK**: `>= 3.0.0`
- **Git**
- Optional for native builds:
  - Android Studio / Android SDK (API 33+)
  - Xcode (macOS for iOS builds)
  - Visual Studio 2022 (C++ workload for Windows desktop builds)
  - Google Chrome (for Web development)

---

## 6. Supabase Setup & Database Migration

### Step 1: Create a Supabase Project
1. Log in to [Supabase Console](https://supabase.com).
2. Create a new project (e.g. `auracare-hospital`).
3. Note down your **Project URL** and **Public `anon` key** from `Project Settings -> API`.

### Step 2: Run Database Migrations
In the Supabase SQL Editor, run the migration scripts located in `supabase/migrations/` in sequential order:

1. **`001_initial_schema.sql`**: Creates all 35 normalized hospital tables, enums, triggers, and foreign keys.
2. **`002_rls_security_policies.sql`**: Applies granular Row Level Security (RLS) policies protecting sensitive medical records.
3. **`003_storage_buckets_policies.sql`**: Configures encrypted buckets for `avatars`, `medical-documents`, `prescriptions`, `lab-reports`, and `radiology-images`.
4. **`004_seed_demo_data.sql`**: Populates 16 hospital departments, 10 verified doctors, 20 patients, 20 appointments, 10 medications, 10 lab tests, 10 invoices, notifications, and chat records.

---

## 7. Environment Configuration

Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Configure your credentials:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
APP_ENV=development
ENABLE_MOCK_FALLBACK=true
```

> **Security Mandate**: Never bundle your `service_role` key into Flutter client source code. Only the public `anon` key must be passed via `--dart-define`.

---

## 8. Local Development & Running the App

### 1. Fetch Dependencies
```bash
flutter pub get
```

### 2. Run on Chrome (Web)
```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### 3. Run on Windows Desktop
```bash
flutter run -d windows
```

### 4. Run on Android Device / Emulator
```bash
flutter run -d android
```

### Quick Demo Roles
On the Login screen, use the quick-sign-in chips for instant persona evaluation:
- **Patient**: `patient1@example.com`
- **Doctor**: `dr.sarah.watson@auracare.com`
- **Nurse**: `nurse.clara@auracare.com`
- **Hospital Admin**: `admin@auracare.com`
- **Pharmacist**: `pharmacy@auracare.com`
- *(Password for all demo personas: `password123`)*

---

## 9. Web, Android, iOS & Desktop Deployment

### Production Web Build
```bash
flutter build web --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key
```
Deploy the generated `build/web/` folder to **Vercel**, **Firebase Hosting**, **Cloudflare Pages**, or **Netlify**.

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### iOS Release Build
```bash
flutter build ipa --release
```

---

## 10. Row Level Security (RLS) & HIPAA Compliance

AuraCare enforces strict database-level authorization:
1. **Patient Data Isolation**: Patients can strictly query and modify their own EMR, prescriptions, appointments, invoices, and pill schedules.
2. **Clinical Boundaries**: Doctors and nurses can access assigned patient medical histories and vital records.
3. **Dispensary Boundary**: Pharmacists have read access to prescriptions and write access to stock dispensing, but cannot view private physician notes.
4. **Conversation Privacy**: Messages are strictly guarded by checking membership against `conversation_members`.
5. **HIPAA Audit Trail**: Every sensitive access (EMR view, prescription issue, vital change, login, logout) is recorded in `audit_logs`.

---

## 11. Testing Strategy

Run the automated test suite:
```bash
flutter test
```

Includes:
- **`role_permission_test.dart`**: Validates RBAC permissions for all 13 hospital roles.
- **`doctor_search_test.dart`**: Validates specialty filtering, keyword queries, and doctor profiles.
- **`appointment_test.dart`**: Tests booking, rescheduling, and cancellation lifecycles.
- **`medication_reminder_test.dart`**: Verifies pill schedule adherence toggles and refill alerts.
- **`auth_test.dart`**: Tests authentication, registration, and session destruction.

---

## 12. Troubleshooting & FAQ

**Q: Can I run the application without an active Supabase cloud project?**  
A: Yes. The application includes a fallback layer (`ENABLE_MOCK_FALLBACK=true`). If no Supabase connection is established, all modules load realistic medical data with full offline interactive functionality.

**Q: How do I change the application language to Urdu or Arabic?**  
A: Go to `Settings -> Language & Localization` and select Urdu or Arabic. The layout will adapt to Right-to-Left (RTL) automatically.

**Q: How are video calls handled?**  
A: The telemedicine module provides a production-ready UI/UX flow with an abstraction layer ready to connect to WebRTC, Twilio, or Agora.

---

## License
Proprietary healthcare software developed for commercial enterprise hospital deployment.
