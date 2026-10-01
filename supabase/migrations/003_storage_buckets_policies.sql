-- ============================================================================
-- AURACARE HOSPITAL MANAGEMENT SYSTEM - STORAGE BUCKETS & POLICIES
-- Migration: 003_storage_buckets_policies.sql
-- ============================================================================

-- 1. Create Storage Buckets
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('avatars', 'avatars', true),
    ('medical-documents', 'medical-documents', false),
    ('prescriptions', 'prescriptions', false),
    ('lab-reports', 'lab-reports', false),
    ('radiology-images', 'radiology-images', false),
    ('chat-attachments', 'chat-attachments', false)
ON CONFLICT (id) DO NOTHING;

-- 2. Avatars Policy (Public Read, Owner Update)
CREATE POLICY "Public Avatar Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Avatar Upload by Owner"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Avatar Update by Owner"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- 3. Medical Documents Policy (Doctor & Patient access)
CREATE POLICY "Medical Documents Access"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'medical-documents' AND (
        auth.uid()::text = (storage.foldername(name))[1] OR
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() 
            AND role IN ('super_admin', 'hospital_admin', 'doctor', 'nurse')
        )
    )
);

CREATE POLICY "Medical Documents Upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'medical-documents' AND (
        auth.uid()::text = (storage.foldername(name))[1] OR
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() 
            AND role IN ('super_admin', 'hospital_admin', 'doctor', 'nurse')
        )
    )
);

-- 4. Lab Reports & Radiology
CREATE POLICY "Lab Reports View"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'lab-reports' AND (
        auth.uid()::text = (storage.foldername(name))[1] OR
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() 
            AND role IN ('super_admin', 'hospital_admin', 'doctor', 'lab_technician')
        )
    )
);

CREATE POLICY "Radiology Images View"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'radiology-images' AND (
        auth.uid()::text = (storage.foldername(name))[1] OR
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() 
            AND role IN ('super_admin', 'hospital_admin', 'doctor', 'radiologist')
        )
    )
);

-- 5. Chat Attachments
CREATE POLICY "Chat Attachments Access"
ON storage.objects FOR ALL
TO authenticated
USING (bucket_id = 'chat-attachments');
