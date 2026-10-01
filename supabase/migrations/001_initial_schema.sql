-- ============================================================================
-- AURACARE HOSPITAL MANAGEMENT SYSTEM - ENTERPRISE DATABASE SCHEMA
-- Migration: 001_initial_schema.sql
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. ENUMS & DOMAINS
-- ============================================================================

DO $$ BEGIN
    CREATE TYPE user_role AS ENUM (
        'super_admin',
        'hospital_admin',
        'receptionist',
        'doctor',
        'nurse',
        'pharmacist',
        'lab_technician',
        'radiologist',
        'patient',
        'accountant',
        'hr_manager',
        'ambulance_staff',
        'support_staff'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE appointment_status AS ENUM (
        'pending',
        'confirmed',
        'checked_in',
        'in_consultation',
        'completed',
        'cancelled',
        'no_show',
        'rescheduled'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE appointment_type AS ENUM (
        'in_person',
        'telemedicine_video',
        'telemedicine_audio',
        'walk_in',
        'emergency',
        'follow_up'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE triage_priority AS ENUM (
        'resuscitation_red',
        'emergent_orange',
        'urgent_yellow',
        'less_urgent_green',
        'non_urgent_blue'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE bed_status AS ENUM (
        'available',
        'occupied',
        'reserved',
        'cleaning',
        'maintenance'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM (
        'unpaid',
        'partial',
        'paid',
        'refunded',
        'cancelled'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE lab_order_status AS ENUM (
        'ordered',
        'sample_collected',
        'in_analysis',
        'results_ready',
        'verified',
        'cancelled'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ============================================================================
-- 2. CORE USERS & PROFILES
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role user_role NOT NULL DEFAULT 'patient',
    gender TEXT CHECK (gender IN ('male', 'female', 'other', 'undisclosed')),
    date_of_birth DATE,
    blood_group TEXT CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    address TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Index on role for fast RBAC lookups
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- ============================================================================
-- 3. HOSPITAL DEPARTMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    icon_name TEXT DEFAULT 'local_hospital',
    head_doctor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    phone_extension TEXT,
    location_floor TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 4. DOCTORS & SPECIALTIES
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.doctors (
    id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    department_id UUID REFERENCES public.departments(id) ON DELETE SET NULL,
    license_number TEXT UNIQUE NOT NULL,
    specialty TEXT NOT NULL,
    qualifications TEXT[] DEFAULT '{}',
    experience_years INTEGER NOT NULL DEFAULT 0,
    languages TEXT[] DEFAULT '{"English"}',
    consultation_fee NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    bio TEXT,
    rating NUMERIC(3, 2) NOT NULL DEFAULT 5.00,
    reviews_count INTEGER NOT NULL DEFAULT 0,
    is_available BOOLEAN NOT NULL DEFAULT true,
    available_days TEXT[] DEFAULT '{"Monday","Tuesday","Wednesday","Thursday","Friday"}',
    working_hours_start TIME NOT NULL DEFAULT '09:00:00',
    working_hours_end TIME NOT NULL DEFAULT '17:00:00',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_doctors_specialty ON public.doctors(specialty);
CREATE INDEX IF NOT EXISTS idx_doctors_department ON public.doctors(department_id);

-- ============================================================================
-- 5. PATIENTS & CLINICAL HISTORY
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.patients (
    id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    mr_number TEXT UNIQUE NOT NULL, -- Medical Record Number: e.g. MR-2026-0001
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    emergency_contact_relation TEXT,
    insurance_provider TEXT,
    insurance_policy_number TEXT,
    insurance_expiry DATE,
    allergies TEXT[] DEFAULT '{}',
    chronic_conditions TEXT[] DEFAULT '{}',
    past_surgeries TEXT[] DEFAULT '{}',
    family_medical_history TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_patients_mr_number ON public.patients(mr_number);

-- ============================================================================
-- 6. APPOINTMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
    department_id UUID REFERENCES public.departments(id) ON DELETE SET NULL,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    type appointment_type NOT NULL DEFAULT 'in_person',
    status appointment_status NOT NULL DEFAULT 'confirmed',
    reason TEXT NOT NULL,
    symptoms TEXT,
    notes TEXT,
    queue_number INTEGER,
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_appointments_patient ON public.appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor ON public.appointments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON public.appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON public.appointments(status);

-- ============================================================================
-- 7. ELECTRONIC MEDICAL RECORDS & VITALS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.vital_signs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    recorded_by UUID NOT NULL REFERENCES public.profiles(id),
    systolic_bp INTEGER,
    diastolic_bp INTEGER,
    heart_rate INTEGER,
    temperature_c NUMERIC(4, 1),
    oxygen_saturation INTEGER,
    respiratory_rate INTEGER,
    weight_kg NUMERIC(5, 2),
    height_cm NUMERIC(5, 2),
    bmi NUMERIC(4, 1),
    notes TEXT,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_vitals_patient ON public.vital_signs(patient_id, recorded_at DESC);

CREATE TABLE IF NOT EXISTS public.medical_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
    appointment_id UUID REFERENCES public.appointments(id) ON DELETE SET NULL,
    chief_complaint TEXT NOT NULL,
    clinical_findings TEXT,
    diagnosis TEXT NOT NULL,
    differential_diagnosis TEXT,
    treatment_plan TEXT NOT NULL,
    follow_up_date DATE,
    confidential_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_med_records_patient ON public.medical_records(patient_id);

-- ============================================================================
-- 8. PRESCRIPTIONS & MEDICATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.prescriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prescription_code TEXT UNIQUE NOT NULL, -- e.g. RX-2026-1001
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
    medical_record_id UUID REFERENCES public.medical_records(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'dispensed', 'expired', 'cancelled')),
    general_instructions TEXT,
    doctor_signature TEXT,
    issued_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.prescription_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prescription_id UUID NOT NULL REFERENCES public.prescriptions(id) ON DELETE CASCADE,
    medicine_name TEXT NOT NULL,
    form TEXT NOT NULL DEFAULT 'Tablet', -- Tablet, Capsule, Syrup, Injection, Cream
    dosage TEXT NOT NULL, -- 500mg
    frequency TEXT NOT NULL, -- e.g. "1-0-1", "Every 8 hours", "Once daily"
    timing TEXT NOT NULL DEFAULT 'after_meal' CHECK (timing IN ('before_meal', 'after_meal', 'with_meal', 'empty_stomach')),
    duration_days INTEGER NOT NULL DEFAULT 7,
    instructions TEXT,
    is_dispensed BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS public.medications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    form TEXT NOT NULL DEFAULT 'Pill',
    dosage TEXT NOT NULL,
    color_hex TEXT DEFAULT '#48C9C5',
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,
    schedule_times TEXT[] NOT NULL DEFAULT '{"08:00"}', -- e.g. ["08:00", "14:00", "20:00"]
    time_of_day TEXT[] NOT NULL DEFAULT '{"morning"}', -- morning, afternoon, evening, night
    remaining_pills INTEGER DEFAULT 30,
    refill_threshold INTEGER DEFAULT 5,
    is_active BOOLEAN NOT NULL DEFAULT true,
    instructions TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.medication_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    medication_id UUID NOT NULL REFERENCES public.medications(id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    scheduled_time TIMESTAMPTZ NOT NULL,
    taken_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('taken', 'skipped', 'missed', 'pending')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 9. PHARMACY INVENTORY & DISPENSING
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.pharmacy_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    generic_name TEXT,
    sku TEXT UNIQUE NOT NULL,
    category TEXT NOT NULL, -- Antibiotics, Analgesics, Cardiology, etc.
    form TEXT NOT NULL, -- Tablet, Syrup, Injection
    strength TEXT NOT NULL, -- 500mg, 10ml
    unit_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    cost_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    quantity_in_stock INTEGER NOT NULL DEFAULT 0,
    min_stock_alert INTEGER NOT NULL DEFAULT 20,
    batch_number TEXT NOT NULL,
    expiry_date DATE NOT NULL,
    supplier_name TEXT,
    location_shelf TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 10. LABORATORY & DIAGNOSTICS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.lab_tests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL, -- Hematology, Biochemistry, Microbiology, Pathology
    description TEXT,
    sample_type TEXT NOT NULL, -- Blood, Urine, Saliva, Swab
    price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    turnaround_hours INTEGER NOT NULL DEFAULT 24,
    reference_range TEXT,
    units TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS public.lab_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_code TEXT UNIQUE NOT NULL,
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES public.doctors(id) ON DELETE SET NULL,
    test_id UUID NOT NULL REFERENCES public.lab_tests(id) ON DELETE RESTRICT,
    technician_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    status lab_order_status NOT NULL DEFAULT 'ordered',
    priority TEXT NOT NULL DEFAULT 'normal' CHECK (priority IN ('routine', 'urgent', 'stat')),
    sample_collected_at TIMESTAMPTZ,
    results_notes TEXT,
    result_value TEXT,
    is_abnormal BOOLEAN DEFAULT false,
    report_pdf_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 11. RADIOLOGY
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.radiology_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_code TEXT UNIQUE NOT NULL,
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES public.doctors(id) ON DELETE SET NULL,
    radiologist_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    modality TEXT NOT NULL CHECK (modality IN ('X-Ray', 'CT Scan', 'MRI', 'Ultrasound', 'Mammography', 'Fluoroscopy')),
    body_part TEXT NOT NULL,
    clinical_history TEXT,
    status TEXT NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'scheduled', 'completed', 'reported', 'cancelled')),
    findings TEXT,
    impression TEXT,
    image_urls TEXT[] DEFAULT '{}',
    report_pdf_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 12. INPATIENT ADMISSIONS & BED MANAGEMENT
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.hospital_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_number TEXT UNIQUE NOT NULL,
    department_id UUID REFERENCES public.departments(id) ON DELETE SET NULL,
    ward_type TEXT NOT NULL CHECK (ward_type IN ('general', 'semi_private', 'private', 'icu', 'ccu', 'nicu', 'emergency', 'isolation')),
    floor INTEGER NOT NULL DEFAULT 1,
    daily_rate NUMERIC(10, 2) NOT NULL DEFAULT 0.00
);

CREATE TABLE IF NOT EXISTS public.hospital_beds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES public.hospital_rooms(id) ON DELETE CASCADE,
    bed_number TEXT NOT NULL,
    status bed_status NOT NULL DEFAULT 'available',
    UNIQUE (room_id, bed_number)
);

CREATE TABLE IF NOT EXISTS public.admissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    admitting_doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE RESTRICT,
    bed_id UUID NOT NULL REFERENCES public.hospital_beds(id) ON DELETE RESTRICT,
    admission_date TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    discharge_date TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'admitted' CHECK (status IN ('admitted', 'transferred', 'discharged', 'deceased')),
    admission_reason TEXT NOT NULL,
    triage_level triage_priority DEFAULT 'urgent_yellow',
    discharge_summary TEXT,
    attending_nurse_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 13. BILLING & INVOICES
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number TEXT UNIQUE NOT NULL,
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    appointment_id UUID REFERENCES public.appointments(id) ON DELETE SET NULL,
    admission_id UUID REFERENCES public.admissions(id) ON DELETE SET NULL,
    subtotal NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    tax NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    discount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    paid_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    status payment_status NOT NULL DEFAULT 'unpaid',
    due_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.invoice_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES public.invoices(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('consultation', 'lab', 'pharmacy', 'radiology', 'bed_charge', 'procedure', 'emergency', 'other')),
    unit_price NUMERIC(10, 2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    total_price NUMERIC(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES public.invoices(id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'credit_card', 'debit_card', 'bank_transfer', 'online_gateway', 'insurance')),
    transaction_reference TEXT,
    status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'failed', 'refunded', 'pending')),
    processed_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ============================================================================
-- 14. REALTIME CHAT & MESSAGING
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT,
    is_group BOOLEAN NOT NULL DEFAULT false,
    channel_type TEXT NOT NULL DEFAULT 'direct' CHECK (channel_type IN ('direct', 'support', 'department')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.conversation_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(conversation_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    attachment_url TEXT,
    attachment_type TEXT CHECK (attachment_type IN ('image', 'pdf', 'audio', 'document')),
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(conversation_id, created_at ASC);

-- ============================================================================
-- 15. NOTIFICATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('appointment', 'medication', 'lab', 'prescription', 'payment', 'chat', 'system', 'emergency')),
    reference_id UUID,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, is_read, created_at DESC);

-- ============================================================================
-- 16. AMBULANCE & EMERGENCY DISPATCH
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.ambulances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_number TEXT UNIQUE NOT NULL,
    model TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'Advanced Life Support' CHECK (type IN ('Basic Life Support', 'Advanced Life Support', 'Patient Transport', 'Neonatal')),
    driver_name TEXT NOT NULL,
    driver_phone TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'dispatched', 'en_route', 'at_hospital', 'maintenance')),
    current_latitude NUMERIC(10, 8),
    current_longitude NUMERIC(11, 8),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.ambulance_trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ambulance_id UUID NOT NULL REFERENCES public.ambulances(id) ON DELETE CASCADE,
    patient_id UUID REFERENCES public.patients(id) ON DELETE SET NULL,
    caller_name TEXT NOT NULL,
    caller_phone TEXT NOT NULL,
    pickup_address TEXT NOT NULL,
    destination TEXT NOT NULL DEFAULT 'Hospital Emergency Room',
    status TEXT NOT NULL DEFAULT 'dispatched' CHECK (status IN ('dispatched', 'patient_picked', 'arrived', 'completed', 'cancelled')),
    start_time TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    end_time TIMESTAMPTZ
);

-- ============================================================================
-- 17. STAFF, INVENTORY & AUDIT LOGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.staff (
    id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    employee_id TEXT UNIQUE NOT NULL,
    department_id UUID REFERENCES public.departments(id) ON DELETE SET NULL,
    designation TEXT NOT NULL,
    shift_timings TEXT NOT NULL DEFAULT 'Morning (08:00 - 16:00)',
    joining_date DATE NOT NULL DEFAULT CURRENT_DATE,
    salary NUMERIC(10, 2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('medical_equipment', 'ppe', 'consumables', 'surgical', 'bedding', 'other')),
    quantity INTEGER NOT NULL DEFAULT 0,
    min_quantity INTEGER NOT NULL DEFAULT 10,
    unit TEXT NOT NULL DEFAULT 'units',
    department_id UUID REFERENCES public.departments(id) ON DELETE SET NULL,
    unit_cost NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    supplier_name TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(user_id, doctor_id)
);

CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(patient_id, doctor_id)
);

CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity TEXT NOT NULL,
    entity_id UUID,
    metadata JSONB DEFAULT '{}',
    ip_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_audit_user ON public.audit_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_entity ON public.audit_logs(entity, entity_id);

-- ============================================================================
-- 18. AUTOMATED TRIGGERS (Updated at & Profile sync)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER tr_appointments_updated_at
    BEFORE UPDATE ON public.appointments
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER tr_invoices_updated_at
    BEFORE UPDATE ON public.invoices
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger to create profile when auth.users is inserted
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'patient'::user_role)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
