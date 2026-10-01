-- ============================================================================
-- AURACARE HOSPITAL MANAGEMENT SYSTEM - ROW LEVEL SECURITY (RLS) POLICIES
-- Migration: 002_rls_security_policies.sql
-- ============================================================================

-- Helper function to get current user role
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS user_role AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Enable RLS on all sensitive tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vital_signs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescription_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medication_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pharmacy_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lab_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lab_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.radiology_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hospital_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hospital_beds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ambulances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ambulance_trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 1. PROFILES POLICIES
-- ============================================================================

CREATE POLICY "Profiles are viewable by authenticated users"
ON public.profiles FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can update their own profile"
ON public.profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can update any profile"
ON public.profiles FOR ALL
TO authenticated
USING (public.current_user_role() IN ('super_admin', 'hospital_admin'));

-- ============================================================================
-- 2. DEPARTMENTS & DOCTORS POLICIES (Publicly readable)
-- ============================================================================

CREATE POLICY "Departments are viewable by all authenticated users"
ON public.departments FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins manage departments"
ON public.departments FOR ALL
TO authenticated
USING (public.current_user_role() IN ('super_admin', 'hospital_admin'));

CREATE POLICY "Doctors are viewable by all authenticated users"
ON public.doctors FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Doctors can update their own clinical profile"
ON public.doctors FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ============================================================================
-- 3. PATIENTS POLICIES
-- ============================================================================

CREATE POLICY "Patients view their own record"
ON public.patients FOR SELECT
TO authenticated
USING (
    auth.uid() = id OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'doctor', 'nurse', 'receptionist')
);

CREATE POLICY "Patients update their own non-clinical profile"
ON public.patients FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "Clinical staff manage patient records"
ON public.patients FOR ALL
TO authenticated
USING (public.current_user_role() IN ('super_admin', 'hospital_admin', 'doctor', 'nurse', 'receptionist'));

-- ============================================================================
-- 4. APPOINTMENTS POLICIES
-- ============================================================================

CREATE POLICY "Users view relevant appointments"
ON public.appointments FOR SELECT
TO authenticated
USING (
    patient_id = auth.uid() OR
    doctor_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'receptionist', 'nurse')
);

CREATE POLICY "Patients can book appointments"
ON public.appointments FOR INSERT
TO authenticated
WITH CHECK (
    patient_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'receptionist')
);

CREATE POLICY "Appointment participants can update status"
ON public.appointments FOR UPDATE
TO authenticated
USING (
    patient_id = auth.uid() OR
    doctor_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'receptionist')
);

-- ============================================================================
-- 5. MEDICAL RECORDS & VITALS
-- ============================================================================

CREATE POLICY "Patients view their own vitals"
ON public.vital_signs FOR SELECT
TO authenticated
USING (
    patient_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'doctor', 'nurse')
);

CREATE POLICY "Nurses and Doctors can record vitals"
ON public.vital_signs FOR INSERT
TO authenticated
WITH CHECK (
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'doctor', 'nurse')
);

CREATE POLICY "Medical records viewable by patient and clinical staff"
ON public.medical_records FOR SELECT
TO authenticated
USING (
    patient_id = auth.uid() OR
    doctor_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'doctor', 'nurse')
);

CREATE POLICY "Doctors create and manage medical records"
ON public.medical_records FOR ALL
TO authenticated
USING (
    doctor_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin')
);

-- ============================================================================
-- 6. PRESCRIPTIONS & MEDICATION REMINDERS
-- ============================================================================

CREATE POLICY "Prescriptions viewable by patient, doctor, and pharmacist"
ON public.prescriptions FOR SELECT
TO authenticated
USING (
    patient_id = auth.uid() OR
    doctor_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'pharmacist', 'nurse')
);

CREATE POLICY "Doctors create prescriptions"
ON public.prescriptions FOR INSERT
TO authenticated
WITH CHECK (
    doctor_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin')
);

CREATE POLICY "Pharmacists update dispensing status"
ON public.prescriptions FOR UPDATE
TO authenticated
USING (
    public.current_user_role() IN ('super_admin', 'pharmacist', 'doctor')
);

CREATE POLICY "Prescription items viewable with prescription"
ON public.prescription_items FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Patients manage their own medication pill reminders"
ON public.medications FOR ALL
TO authenticated
USING (patient_id = auth.uid())
WITH CHECK (patient_id = auth.uid());

CREATE POLICY "Patients manage medication adherence logs"
ON public.medication_logs FOR ALL
TO authenticated
USING (patient_id = auth.uid())
WITH CHECK (patient_id = auth.uid());

-- ============================================================================
-- 7. LABORATORY & RADIOLOGY POLICIES
-- ============================================================================

CREATE POLICY "Lab tests viewable by all"
ON public.lab_tests FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Lab orders viewable by patient and lab staff"
ON public.lab_orders FOR SELECT
TO authenticated
USING (
    patient_id = auth.uid() OR
    doctor_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'lab_technician', 'nurse')
);

CREATE POLICY "Lab technicians update lab orders"
ON public.lab_orders FOR UPDATE
TO authenticated
USING (
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'lab_technician')
);

CREATE POLICY "Radiology orders viewable by patient and radiologists"
ON public.radiology_orders FOR SELECT
TO authenticated
USING (
    patient_id = auth.uid() OR
    doctor_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'radiologist', 'nurse')
);

CREATE POLICY "Radiologists manage radiology orders"
ON public.radiology_orders FOR ALL
TO authenticated
USING (
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'radiologist')
);

-- ============================================================================
-- 8. BILLING & PAYMENTS POLICIES
-- ============================================================================

CREATE POLICY "Patients view their own invoices"
ON public.invoices FOR SELECT
TO authenticated
USING (
    patient_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'accountant', 'receptionist')
);

CREATE POLICY "Accountants manage invoices"
ON public.invoices FOR ALL
TO authenticated
USING (
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'accountant', 'receptionist')
);

CREATE POLICY "Invoice items viewable with invoice"
ON public.invoice_items FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Payments viewable by patient and accountants"
ON public.payments FOR SELECT
TO authenticated
USING (
    patient_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'accountant')
);

CREATE POLICY "Record payments"
ON public.payments FOR INSERT
TO authenticated
WITH CHECK (
    patient_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin', 'accountant', 'receptionist')
);

-- ============================================================================
-- 9. CHAT & MESSAGING POLICIES
-- ============================================================================

CREATE POLICY "Users access conversations they are member of"
ON public.conversations FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.conversation_members
        WHERE conversation_id = conversations.id AND user_id = auth.uid()
    )
);

CREATE POLICY "Users view messages in their conversations"
ON public.messages FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.conversation_members
        WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()
    )
);

CREATE POLICY "Users post messages to their conversations"
ON public.messages FOR INSERT
TO authenticated
WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
        SELECT 1 FROM public.conversation_members
        WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()
    )
);

CREATE POLICY "Users manage conversation members"
ON public.conversation_members FOR ALL
TO authenticated
USING (
    user_id = auth.uid() OR
    public.current_user_role() IN ('super_admin', 'hospital_admin')
);

-- ============================================================================
-- 10. NOTIFICATIONS, FAVORITES, AUDIT
-- ============================================================================

CREATE POLICY "Users view their own notifications"
ON public.notifications FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users manage their favorites"
ON public.favorites FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Patients write reviews"
ON public.reviews FOR ALL
TO authenticated
USING (patient_id = auth.uid())
WITH CHECK (patient_id = auth.uid());

CREATE POLICY "Admins view audit logs"
ON public.audit_logs FOR SELECT
TO authenticated
USING (public.current_user_role() IN ('super_admin', 'hospital_admin'));

CREATE POLICY "Authenticated users insert audit logs"
ON public.audit_logs FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
