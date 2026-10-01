-- ============================================================================
-- AURACARE HOSPITAL MANAGEMENT SYSTEM - PRODUCTION SEED & DEMO DATA
-- Migration: 004_seed_demo_data.sql
-- ============================================================================

-- 1. Insert 16 Core Hospital Departments
INSERT INTO public.departments (id, code, name, description, icon_name, location_floor) VALUES
    ('10000000-0000-0000-0000-000000000001', 'CARD', 'Cardiology', 'Heart, vascular disorders and interventional care', 'favorite', 'Floor 3, Wing A'),
    ('10000000-0000-0000-0000-000000000002', 'NEUR', 'Neurology', 'Brain, spinal cord and nervous system specialties', 'psychology', 'Floor 4, Wing B'),
    ('10000000-0000-0000-0000-000000000003', 'DERM', 'Dermatology', 'Advanced skin, hair and dermatological surgery', 'spa', 'Floor 1, Wing C'),
    ('10000000-0000-0000-0000-000000000004', 'PED', 'Pediatrics', 'Comprehensive child care and pediatric surgery', 'child_care', 'Floor 2, Wing A'),
    ('10000000-0000-0000-0000-000000000005', 'GYN', 'Gynecology & Obstetrics', 'Women health, maternal-fetal and prenatal care', 'pregnant_woman', 'Floor 2, Wing B'),
    ('10000000-0000-0000-0000-000000000006', 'ORTH', 'Orthopedics', 'Musculoskeletal system, joints and spine trauma', 'accessibility_new', 'Floor 3, Wing C'),
    ('10000000-0000-0000-0000-000000000007', 'GEN', 'General Medicine', 'Internal medicine and chronic disease management', 'medical_services', 'Floor 1, Wing A'),
    ('10000000-0000-0000-0000-000000000008', 'SURG', 'General Surgery', 'Minimally invasive and laparoscopic surgery', 'healing', 'Floor 5, Operating Suites'),
    ('10000000-0000-0000-0000-000000000009', 'ENT', 'Otolaryngology (ENT)', 'Ear, nose, throat and head-neck surgery', 'hearing', 'Floor 1, Wing B'),
    ('10000000-0000-0000-0000-000000000010', 'DENT', 'Dentistry & Maxillofacial', 'Oral health, orthodontics and restorative surgery', 'sentiment_satisfied', 'Floor 1, Wing D'),
    ('10000000-0000-0000-0000-000000000011', 'RAD', 'Radiology & Imaging', 'MRI, 128-slice CT scan, Digital X-Ray and Ultrasound', 'camera', 'Basement 1, Diagnostic Center'),
    ('10000000-0000-0000-0000-000000000012', 'PATH', 'Pathology & Laboratory', 'Automated hematology, biochemistry and microbiology', 'biotech', 'Floor 2, Central Lab'),
    ('10000000-0000-0000-0000-000000000013', 'EMERG', 'Emergency & Trauma (ER)', '24/7 Level 1 Resuscitation and acute care', 'emergency', 'Ground Floor, ER Bay'),
    ('10000000-0000-0000-0000-000000000014', 'ICU', 'Intensive Care Unit', 'Critical cardiac and surgical multi-organ monitoring', 'monitor_heart', 'Floor 4, Critical Care Block'),
    ('10000000-0000-0000-0000-000000000015', 'PHARM', 'Central Pharmacy', 'Inpatient dispensing, outpatient retail and compounding', 'medication', 'Ground Floor, Lobby'),
    ('10000000-0000-0000-0000-000000000016', 'PHYS', 'Physiotherapy & Rehab', 'Post-operative recovery and physical mobility', 'fitness_center', 'Floor 3, Rehab Center')
ON CONFLICT (id) DO NOTHING;

-- 2. Insert 10 Professional Doctors (Profiles + Doctor Details)
INSERT INTO public.profiles (id, email, full_name, phone, role, gender, blood_group, avatar_url) VALUES
    ('20000000-0000-0000-0000-000000000001', 'dr.sarah.watson@auracare.com', 'Dr. Sarah Watson', '+1 (555) 234-5671', 'doctor', 'female', 'O+', 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300'),
    ('20000000-0000-0000-0000-000000000002', 'dr.marcus.vance@auracare.com', 'Dr. Marcus Vance', '+1 (555) 234-5672', 'doctor', 'male', 'A+', 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300'),
    ('20000000-0000-0000-0000-000000000003', 'dr.elena.rostova@auracare.com', 'Dr. Elena Rostova', '+1 (555) 234-5673', 'doctor', 'female', 'B+', 'https://images.unsplash.com/photo-1594824813571-638f02634417?auto=format&fit=crop&q=80&w=300'),
    ('20000000-0000-0000-0000-000000000004', 'dr.james.chen@auracare.com', 'Dr. James Chen', '+1 (555) 234-5674', 'doctor', 'male', 'AB+', 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&q=80&w=300'),
    ('20000000-0000-0000-0000-000000000005', 'dr.amira.khan@auracare.com', 'Dr. Amira Khan', '+1 (555) 234-5675', 'doctor', 'female', 'O-', 'https://images.unsplash.com/photo-1614608682850-e0d6ed316d47?auto=format&fit=crop&q=80&w=300'),
    ('20000000-0000-0000-0000-000000000006', 'dr.david.miller@auracare.com', 'Dr. David Miller', '+1 (555) 234-5676', 'doctor', 'male', 'A-', 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=300'),
    ('20000000-0000-0000-0000-000000000007', 'dr.sophia.taylor@auracare.com', 'Dr. Sophia Taylor', '+1 (555) 234-5677', 'doctor', 'female', 'B-', 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?auto=format&fit=crop&q=80&w=300'),
    ('20000000-0000-0000-0000-000000000008', 'dr.tariq.mahmood@auracare.com', 'Dr. Tariq Mahmood', '+1 (555) 234-5678', 'doctor', 'male', 'O+', 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?auto=format&fit=crop&q=80&w=300'),
    ('20000000-0000-0000-0000-000000000009', 'dr.olivia.blake@auracare.com', 'Dr. Olivia Blake', '+1 (555) 234-5679', 'doctor', 'female', 'A+', 'https://images.unsplash.com/photo-1527613426441-4da17471b66d?auto=format&fit=crop&q=80&w=300'),
    ('20000000-0000-0000-0000-000000000010', 'dr.alexander.wright@auracare.com', 'Dr. Alexander Wright', '+1 (555) 234-5680', 'doctor', 'male', 'AB-', 'https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?auto=format&fit=crop&q=80&w=300')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.doctors (id, department_id, license_number, specialty, qualifications, experience_years, consultation_fee, rating, reviews_count, bio) VALUES
    ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'MD-CARD-9841', 'Cardiologist', '{"MD (Harvard Medical)", "FACC", "Board Certified Interventional Cardiology"}', 14, 150.00, 4.95, 238, 'Specialist in non-invasive cardiac imaging, heart failure prevention and coronary interventions.'),
    ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', 'MD-NEUR-7712', 'Neurologist', '{"MD (Johns Hopkins)", "FAAN"}', 12, 175.00, 4.88, 184, 'Expert in migraine management, cerebrovascular diseases, epilepsy and neuro-rehabilitation.'),
    ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000003', 'MD-DERM-4491', 'Dermatologist', '{"MD (Columbia)", "FAAD"}', 9, 120.00, 4.92, 310, 'Leading specialist in clinical dermatology, acne treatments, eczema therapies and laser skin rejuvenation.'),
    ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000004', 'MD-PED-5521', 'Pediatrician', '{"MD (Stanford)", "FAAP"}', 11, 100.00, 4.98, 412, 'Gentle, compassionate pediatric doctor dedicated to newborn care, adolescent health and preventative wellness.'),
    ('20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000005', 'MD-GYN-8812', 'Gynecologist & Obstetrician', '{"MD (Oxford)", "FRCOG"}', 15, 140.00, 4.91, 275, 'Comprehensive prenatal care, high-risk obstetrics, endocrine gynecology and fertility consultation.'),
    ('20000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000006', 'MD-ORTH-3310', 'Orthopedic Surgeon', '{"MS Ortho (Mayo Clinic)", "AAOS"}', 16, 160.00, 4.87, 195, 'Specialized in arthroscopic joint replacement, sports injury surgery and spine reconstruction.'),
    ('20000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000007', 'MD-GEN-1029', 'Internal Medicine Physician', '{"MD (UCLA)", "FACP"}', 10, 90.00, 4.89, 320, 'Preventative adult health, hypertensive control, diabetes management and geriatric wellness.'),
    ('20000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000008', 'MD-SURG-6019', 'General & Laparoscopic Surgeon', '{"MS (Edinburgh)", "FACS"}', 18, 180.00, 4.96, 260, 'Pioneer in minimally invasive abdominal procedures, hernia repairs and surgical oncology.'),
    ('20000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000009', 'MD-ENT-2940', 'ENT Surgeon', '{"MD (King College London)", "FRCS"}', 8, 110.00, 4.85, 142, 'Specialist in sinus endoscopy, hearing disorders, pediatric tonsillectomy and sleep apnea treatment.'),
    ('20000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000010', 'MD-DENT-8123', 'Dental Surgeon', '{"DDS (Penn Dental)", "FICOI"}', 13, 115.00, 4.90, 204, 'Advanced dental implants, aesthetic smile design, periodontal therapies and oral surgery.')
ON CONFLICT (id) DO NOTHING;

-- 3. Insert 20 Patients (Profiles + Patient Records)
INSERT INTO public.profiles (id, email, full_name, phone, role, gender, blood_group, date_of_birth, address) VALUES
    ('30000000-0000-0000-0000-000000000001', 'patient1@example.com', 'Emma Stonehurst', '+1 (555) 101-0001', 'patient', 'female', 'A+', '1992-04-12', '742 Evergreen Terrace, Springfield'),
    ('30000000-0000-0000-0000-000000000002', 'patient2@example.com', 'Lucas Montgomery', '+1 (555) 101-0002', 'patient', 'male', 'O+', '1985-08-25', '124 Conch Street, Pacific Bay'),
    ('30000000-0000-0000-0000-000000000003', 'patient3@example.com', 'Aaliyah Peterson', '+1 (555) 101-0003', 'patient', 'female', 'B-', '1998-11-03', '88 Maple Boulevard, Austin'),
    ('30000000-0000-0000-0000-000000000004', 'patient4@example.com', 'Ethan Harper', '+1 (555) 101-0004', 'patient', 'male', 'AB+', '1979-02-18', '512 Oak Ridge Road, Denver'),
    ('30000000-0000-0000-0000-000000000005', 'patient5@example.com', 'Sophia Ramirez', '+1 (555) 101-0005', 'patient', 'female', 'O-', '2001-09-14', '304 Sunset Way, Miami'),
    ('30000000-0000-0000-0000-000000000006', 'patient6@example.com', 'Liam Gallagher', '+1 (555) 101-0006', 'patient', 'male', 'A-', '1990-06-30', '19 Victoria Lane, Boston'),
    ('30000000-0000-0000-0000-000000000007', 'patient7@example.com', 'Isabella Morales', '+1 (555) 101-0007', 'patient', 'female', 'B+', '1995-12-05', '901 Grand Avenue, San Diego'),
    ('30000000-0000-0000-0000-000000000008', 'patient8@example.com', 'Noah Sinclair', '+1 (555) 101-0008', 'patient', 'male', 'O+', '1988-03-22', '440 Pine Crest Dr, Seattle'),
    ('30000000-0000-0000-0000-000000000009', 'patient9@example.com', 'Mia Thorne', '+1 (555) 101-0009', 'patient', 'female', 'A+', '1999-07-19', '611 Harbor View, Portland'),
    ('30000000-0000-0000-0000-000000000010', 'patient10@example.com', 'William Drake', '+1 (555) 101-0010', 'patient', 'male', 'AB-', '1967-10-11', '802 Elm Street, Chicago'),
    ('30000000-0000-0000-0000-000000000011', 'patient11@example.com', 'Ava Jenkins', '+1 (555) 101-0011', 'patient', 'female', 'O+', '2003-01-29', '14 Rosewood Lane, Dallas'),
    ('30000000-0000-0000-0000-000000000012', 'patient12@example.com', 'Jameson Reed', '+1 (555) 101-0012', 'patient', 'male', 'B+', '1994-05-16', '230 Horizon Blvd, Phoenix'),
    ('30000000-0000-0000-0000-000000000013', 'patient13@example.com', 'Charlotte Bell', '+1 (555) 101-0013', 'patient', 'female', 'A-', '1983-09-08', '405 Magnolia Court, Atlanta'),
    ('30000000-0000-0000-0000-000000000014', 'patient14@example.com', 'Benjamin Hayes', '+1 (555) 101-0014', 'patient', 'male', 'O-', '1975-12-24', '770 Cedar Hill, Nashville'),
    ('30000000-0000-0000-0000-000000000015', 'patient15@example.com', 'Amelia Foster', '+1 (555) 101-0015', 'patient', 'female', 'AB+', '1996-03-04', '312 Willow Creek, Charlotte'),
    ('30000000-0000-0000-0000-000000000016', 'patient16@example.com', 'Daniel Brooks', '+1 (555) 101-0016', 'patient', 'male', 'A+', '1989-11-20', '588 River Road, Minneapolis'),
    ('30000000-0000-0000-0000-000000000017', 'patient17@example.com', 'Harper Bennett', '+1 (555) 101-0017', 'patient', 'female', 'O+', '1997-08-07', '109 Birchwood Dr, Detroit'),
    ('30000000-0000-0000-0000-000000000018', 'patient18@example.com', 'Henry Lawson', '+1 (555) 101-0018', 'patient', 'male', 'B-', '1962-04-15', '920 Aspen Terrace, Salt Lake City'),
    ('30000000-0000-0000-0000-000000000019', 'patient19@example.com', 'Evelyn Gray', '+1 (555) 101-0019', 'patient', 'female', 'A-', '2000-10-31', '414 Sycamore Pass, Las Vegas'),
    ('30000000-0000-0000-0000-000000000020', 'patient20@example.com', 'Mason Cole', '+1 (555) 101-0020', 'patient', 'male', 'AB+', '1981-06-27', '650 Crestline St, Orlando')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.patients (id, mr_number, emergency_contact_name, emergency_contact_phone, insurance_provider, insurance_policy_number, allergies, chronic_conditions) VALUES
    ('30000000-0000-0000-0000-000000000001', 'MR-2026-0001', 'David Stonehurst', '+1 555-9011', 'BlueCross BlueShield', 'BC-8899214', '{"Penicillin", "Peanuts"}', '{"Mild Asthma"}'),
    ('30000000-0000-0000-0000-000000000002', 'MR-2026-0002', 'Sarah Montgomery', '+1 555-9012', 'Aetna Healthcare', 'AET-401928', '{}', '{"Hypertension"}'),
    ('30000000-0000-0000-0000-000000000003', 'MR-2026-0003', 'Kareem Peterson', '+1 555-9013', 'UnitedHealthcare', 'UHC-772910', '{"Sulfa Drugs"}', '{}'),
    ('30000000-0000-0000-0000-000000000004', 'MR-2026-0004', 'Clara Harper', '+1 555-9014', 'Cigna Global', 'CG-118274', '{}', '{"Type 2 Diabetes"}'),
    ('30000000-0000-0000-0000-000000000005', 'MR-2026-0005', 'Carlos Ramirez', '+1 555-9015', 'Humana Health', 'HUM-992812', '{"Latex"}', '{}'),
    ('30000000-0000-0000-0000-000000000006', 'MR-2026-0006', 'Fiona Gallagher', '+1 555-9016', 'Kaiser Permanente', 'KP-449102', '{}', '{}'),
    ('30000000-0000-0000-0000-000000000007', 'MR-2026-0007', 'Mateo Morales', '+1 555-9017', 'BlueCross BlueShield', 'BC-294018', '{"Aspirin"}', '{"Migraine"}'),
    ('30000000-0000-0000-0000-000000000008', 'MR-2026-0008', 'Gemma Sinclair', '+1 555-9018', 'Anthem Insurance', 'ANT-662914', '{}', '{}'),
    ('30000000-0000-0000-0000-000000000009', 'MR-2026-0009', 'Julian Thorne', '+1 555-9019', 'Aetna Healthcare', 'AET-551923', '{}', '{"Hypothyroidism"}'),
    ('30000000-0000-0000-0000-000000000010', 'MR-2026-0010', 'Miriam Drake', '+1 555-9020', 'Medicare Part B', 'MC-102938', '{"Iodine Contrast"}', '{"Coronary Artery Disease"}'),
    ('30000000-0000-0000-0000-000000000011', 'MR-2026-0011', 'Robert Jenkins', '+1 555-9021', 'UnitedHealthcare', 'UHC-881920', '{}', '{}'),
    ('30000000-0000-0000-0000-000000000012', 'MR-2026-0012', 'Elena Reed', '+1 555-9022', 'Cigna Global', 'CG-401928', '{}', '{}'),
    ('30000000-0000-0000-0000-000000000013', 'MR-2026-0013', 'Jonathan Bell', '+1 555-9023', 'BlueCross BlueShield', 'BC-381920', '{"Codeine"}', '{"Osteoarthritis"}'),
    ('30000000-0000-0000-0000-000000000014', 'MR-2026-0014', 'Rachel Hayes', '+1 555-9024', 'Humana Health', 'HUM-771239', '{}', '{"Gout"}'),
    ('30000000-0000-0000-0000-000000000015', 'MR-2026-0015', 'Thomas Foster', '+1 555-9025', 'Kaiser Permanente', 'KP-881920', '{}', '{}'),
    ('30000000-0000-0000-0000-000000000016', 'MR-2026-0016', 'Natalie Brooks', '+1 555-9026', 'Aetna Healthcare', 'AET-992145', '{"Erythromycin"}', '{}'),
    ('30000000-0000-0000-0000-000000000017', 'MR-2026-0017', 'Samuel Bennett', '+1 555-9027', 'UnitedHealthcare', 'UHC-331029', '{}', '{}'),
    ('30000000-0000-0000-0000-000000000018', 'MR-2026-0018', 'Margaret Lawson', '+1 555-9028', 'Medicare Advantage', 'MA-551029', '{}', '{"Atrial Fibrillation"}'),
    ('30000000-0000-0000-0000-000000000019', 'MR-2026-0019', 'Phillip Gray', '+1 555-9029', 'Cigna Global', 'CG-661029', '{}', '{}'),
    ('30000000-0000-0000-0000-000000000020', 'MR-2026-0020', 'Samantha Cole', '+1 555-9030', 'BlueCross BlueShield', 'BC-991029', '{"Shellfish"}', '{"Hyperlipidemia"}')
ON CONFLICT (id) DO NOTHING;

-- 4. Insert 20 Realistic Appointments
INSERT INTO public.appointments (id, patient_id, doctor_id, department_id, appointment_date, start_time, end_time, type, status, reason, queue_number) VALUES
    ('40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', CURRENT_DATE + INTERVAL '1 day', '09:30:00', '10:00:00', 'in_person', 'confirmed', 'Annual cardiac checkup & ECG review', 1),
    ('40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', CURRENT_DATE + INTERVAL '1 day', '10:00:00', '10:30:00', 'telemedicine_video', 'confirmed', 'Chronic migraine aura follow-up', 2),
    ('40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000003', CURRENT_DATE + INTERVAL '2 days', '11:00:00', '11:30:00', 'in_person', 'confirmed', 'Persistent allergic eczema on arms', 3),
    ('40000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000004', CURRENT_DATE + INTERVAL '2 days', '14:00:00', '14:30:00', 'in_person', 'confirmed', 'Pediatric developmental milestone review', 4),
    ('40000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000005', CURRENT_DATE + INTERVAL '3 days', '09:00:00', '09:30:00', 'in_person', 'confirmed', 'Second trimester antenatal ultrasound', 5),
    ('40000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000006', CURRENT_DATE + INTERVAL '3 days', '10:30:00', '11:00:00', 'in_person', 'confirmed', 'Right knee pain after sports training', 6),
    ('40000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000007', CURRENT_DATE, '09:00:00', '09:30:00', 'in_person', 'checked_in', 'High blood pressure titration review', 7),
    ('40000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000008', CURRENT_DATE, '10:00:00', '10:30:00', 'in_person', 'in_consultation', 'Post-appendectomy incision evaluation', 8),
    ('40000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000009', CURRENT_DATE, '11:30:00', '12:00:00', 'telemedicine_audio', 'confirmed', 'Chronic sinusitis nasal congestion', 9),
    ('40000000-0000-0000-0000-000000000010', '30000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000010', CURRENT_DATE, '14:00:00', '14:30:00', 'in_person', 'confirmed', 'Dental crown placement & cleaning', 10),
    ('40000000-0000-0000-0000-000000000011', '30000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', CURRENT_DATE - INTERVAL '1 day', '10:00:00', '10:30:00', 'in_person', 'completed', 'Chest palpitation post-exercise', NULL),
    ('40000000-0000-0000-0000-000000000012', '30000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', CURRENT_DATE - INTERVAL '2 days', '11:00:00', '11:30:00', 'telemedicine_video', 'completed', 'Tension headache consult', NULL),
    ('40000000-0000-0000-0000-000000000013', '30000000-0000-0000-0000-000000000013', '20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000003', CURRENT_DATE - INTERVAL '3 days', '15:00:00', '15:30:00', 'in_person', 'completed', 'Mole dermoscopy inspection', NULL),
    ('40000000-0000-0000-0000-000000000014', '30000000-0000-0000-0000-000000000014', '20000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000006', CURRENT_DATE - INTERVAL '4 days', '16:00:00', '16:30:00', 'in_person', 'completed', 'Sprained ankle follow-up', NULL),
    ('40000000-0000-0000-0000-000000000015', '30000000-0000-0000-0000-000000000015', '20000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000007', CURRENT_DATE - INTERVAL '5 days', '09:00:00', '09:30:00', 'in_person', 'completed', 'Routine full body checkup', NULL),
    ('40000000-0000-0000-0000-000000000016', '30000000-0000-0000-0000-000000000016', '20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000004', CURRENT_DATE + INTERVAL '4 days', '11:00:00', '11:30:00', 'in_person', 'pending', 'Childhood immunization schedule', NULL),
    ('40000000-0000-0000-0000-000000000017', '30000000-0000-0000-0000-000000000017', '20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000005', CURRENT_DATE + INTERVAL '5 days', '10:00:00', '10:30:00', 'in_person', 'pending', 'Routine Pap smear & pelvic exam', NULL),
    ('40000000-0000-0000-0000-000000000018', '30000000-0000-0000-0000-000000000018', '20000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000008', CURRENT_DATE + INTERVAL '6 days', '14:30:00', '15:00:00', 'in_person', 'pending', 'Gallbladder consultation', NULL),
    ('40000000-0000-0000-0000-000000000019', '30000000-0000-0000-0000-000000000019', '20000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000009', CURRENT_DATE + INTERVAL '7 days', '15:30:00', '16:00:00', 'telemedicine_video', 'pending', 'Tinnitus hearing assessment', NULL),
    ('40000000-0000-0000-0000-000000000020', '30000000-0000-0000-0000-000000000020', '20000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000010', CURRENT_DATE + INTERVAL '8 days', '16:00:00', '16:30:00', 'in_person', 'cancelled', 'Teeth whitening procedure', NULL)
ON CONFLICT (id) DO NOTHING;

-- 5. Insert 10 Medications (Pill Reminders inspired by reference)
INSERT INTO public.medications (id, patient_id, name, form, dosage, color_hex, schedule_times, time_of_day, remaining_pills, refill_threshold, instructions) VALUES
    ('50000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Atorvastatin (Lipitor)', 'Pill', '20mg', '#48C9C5', '{"21:00"}', '{"night"}', 28, 5, 'Take once daily before bed with water'),
    ('50000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', 'Metformin HCl', 'Tablet', '500mg', '#48B883', '{"08:00","20:00"}', '{"morning","night"}', 44, 10, 'Take with meals to minimize gastrointestinal discomfort'),
    ('50000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000001', 'Lisinopril', 'Tablet', '10mg', '#F3B562', '{"08:00"}', '{"morning"}', 18, 5, 'Take in the morning for blood pressure control'),
    ('50000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000002', 'Amlodipine', 'Tablet', '5mg', '#48C9C5', '{"08:30"}', '{"morning"}', 22, 7, 'Take daily with or without food'),
    ('50000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000002', 'Sumatriptan Succinate', 'Tablet', '50mg', '#E66A6A', '{"14:00"}', '{"afternoon"}', 6, 2, 'Take at initial onset of migraine attack'),
    ('50000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000003', 'Cetirizine HCl', 'Tablet', '10mg', '#7B9191', '{"20:00"}', '{"night"}', 14, 4, 'Non-drowsy antihistamine for eczema relief'),
    ('50000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000004', 'Amoxicillin Trihydrate', 'Capsule', '500mg', '#236B68', '{"08:00","14:00","20:00"}', '{"morning","afternoon","night"}', 12, 0, 'Finish entire antibiotic course over 7 days'),
    ('50000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000005', 'Prenatal Multivitamins', 'Tablet', '1 tab', '#F3B562', '{"09:00"}', '{"morning"}', 60, 15, 'Contains folic acid and DHA for pregnancy support'),
    ('50000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000006', 'Celecoxib', 'Capsule', '200mg', '#48C9C5', '{"12:00"}', '{"afternoon"}', 15, 5, 'Anti-inflammatory for knee joint cartilage support'),
    ('50000000-0000-0000-0000-000000000010', '30000000-0000-0000-0000-000000000007', 'Omeprazole DR', 'Capsule', '20mg', '#48B883', '{"07:30"}', '{"morning"}', 25, 7, 'Take 30 minutes before morning breakfast')
ON CONFLICT (id) DO NOTHING;

-- 6. Insert 10 Laboratory Tests
INSERT INTO public.lab_tests (id, code, name, category, sample_type, price, turnaround_hours, reference_range, units) VALUES
    ('60000000-0000-0000-0000-000000000001', 'CBC-01', 'Complete Blood Count (CBC) with Differential', 'Hematology', 'Blood', 35.00, 4, 'WBC: 4.5-11.0, RBC: 4.2-5.9', '10^3/uL'),
    ('60000000-0000-0000-0000-000000000002', 'LIPID-02', 'Comprehensive Lipid Panel', 'Biochemistry', 'Blood', 45.00, 6, 'Total Chol: < 200, LDL: < 100, HDL: > 40', 'mg/dL'),
    ('60000000-0000-0000-0000-000000000003', 'HBA1C-03', 'Glycated Hemoglobin (HbA1c)', 'Biochemistry', 'Blood', 40.00, 6, '< 5.7 Normal, 5.7-6.4 Pre-diabetes, >= 6.5 Diabetes', '%'),
    ('60000000-0000-0000-0000-000000000004', 'LFT-04', 'Liver Function Panel (LFT)', 'Biochemistry', 'Blood', 55.00, 8, 'ALT: 7-56, AST: 10-40, Bilirubin: 0.1-1.2', 'U/L'),
    ('60000000-0000-0000-0000-000000000005', 'RFT-05', 'Renal Function Panel (BUN/Creatinine)', 'Biochemistry', 'Blood', 50.00, 6, 'Creatinine: 0.7-1.3, BUN: 7-20, eGFR: > 90', 'mg/dL'),
    ('60000000-0000-0000-0000-000000000006', 'TSH-06', 'Thyroid Stimulating Hormone (TSH)', 'Endocrinology', 'Blood', 42.00, 12, '0.45 - 4.50', 'uIU/mL'),
    ('60000000-0000-0000-0000-000000000007', 'URINE-07', 'Urinalysis Complete Routine', 'Microbiology', 'Urine', 25.00, 3, 'Protein: Negative, Glucose: Negative', 'dipstick'),
    ('60000000-0000-0000-0000-000000000008', 'VITD-08', 'Vitamin D 25-Hydroxy', 'Biochemistry', 'Blood', 65.00, 24, '30 - 100', 'ng/mL'),
    ('60000000-0000-0000-0000-000000000009', 'CRP-09', 'High-Sensitivity C-Reactive Protein (hs-CRP)', 'Immunology', 'Blood', 38.00, 6, '< 1.0 Low risk, 1.0-3.0 Average, > 3.0 High risk', 'mg/L'),
    ('60000000-0000-0000-0000-000000000010', 'ELEC-10', 'Electrolytes Panel (Na, K, Cl, CO2)', 'Biochemistry', 'Blood', 48.00, 4, 'Sodium: 135-145, Potassium: 3.5-5.0', 'mEq/L')
ON CONFLICT (id) DO NOTHING;

-- 7. Insert 10 Invoices
INSERT INTO public.invoices (id, invoice_number, patient_id, appointment_id, subtotal, tax, discount, total_amount, paid_amount, status, due_date) VALUES
    ('70000000-0000-0000-0000-000000000001', 'INV-2026-0001', '30000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 150.00, 7.50, 0.00, 157.50, 157.50, 'paid', CURRENT_DATE),
    ('70000000-0000-0000-0000-000000000002', 'INV-2026-0002', '30000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000002', 175.00, 8.75, 15.00, 168.75, 0.00, 'unpaid', CURRENT_DATE + INTERVAL '14 days'),
    ('70000000-0000-0000-0000-000000000003', 'INV-2026-0003', '30000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000003', 210.00, 10.50, 0.00, 220.50, 100.00, 'partial', CURRENT_DATE + INTERVAL '7 days'),
    ('70000000-0000-0000-0000-000000000004', 'INV-2026-0004', '30000000-0000-0000-0000-000000000004', '40000000-0000-0000-0000-000000000004', 100.00, 5.00, 0.00, 105.00, 105.00, 'paid', CURRENT_DATE - INTERVAL '1 day'),
    ('70000000-0000-0000-0000-000000000005', 'INV-2026-0005', '30000000-0000-0000-0000-000000000005', '40000000-0000-0000-0000-000000000005', 340.00, 17.00, 20.00, 337.00, 337.00, 'paid', CURRENT_DATE - INTERVAL '2 days'),
    ('70000000-0000-0000-0000-000000000006', 'INV-2026-0006', '30000000-0000-0000-0000-000000000006', '40000000-0000-0000-0000-000000000006', 160.00, 8.00, 0.00, 168.00, 0.00, 'unpaid', CURRENT_DATE + INTERVAL '10 days'),
    ('70000000-0000-0000-0000-000000000007', 'INV-2026-0007', '30000000-0000-0000-0000-000000000007', '40000000-0000-0000-0000-000000000007', 90.00, 4.50, 0.00, 94.50, 94.50, 'paid', CURRENT_DATE - INTERVAL '3 days'),
    ('70000000-0000-0000-0000-000000000008', 'INV-2026-0008', '30000000-0000-0000-0000-000000000008', '40000000-0000-0000-0000-000000000008', 180.00, 9.00, 10.00, 179.00, 179.00, 'paid', CURRENT_DATE - INTERVAL '4 days'),
    ('70000000-0000-0000-0000-000000000009', 'INV-2026-0009', '30000000-0000-0000-0000-000000000009', '40000000-0000-0000-0000-000000000009', 110.00, 5.50, 0.00, 115.50, 0.00, 'unpaid', CURRENT_DATE + INTERVAL '21 days'),
    ('70000000-0000-0000-0000-000000000010', 'INV-2026-0010', '30000000-0000-0000-0000-000000000010', '40000000-0000-0000-0000-000000000010', 115.00, 5.75, 0.00, 120.75, 120.75, 'paid', CURRENT_DATE - INTERVAL '5 days')
ON CONFLICT (id) DO NOTHING;

-- 8. Insert 10 Notifications
INSERT INTO public.notifications (id, user_id, title, body, type, is_read) VALUES
    ('80000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Appointment Confirmed', 'Your consultation with Dr. Sarah Watson is scheduled for tomorrow at 09:30 AM.', 'appointment', false),
    ('80000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', 'Pill Reminder: Atorvastatin', 'Time to take your 20mg Atorvastatin pill with water before bed.', 'medication', false),
    ('80000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Lab Results Ready', 'Your Complete Blood Count (CBC) test report is now verified and available.', 'lab', true),
    ('80000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', 'Telemedicine Room Open', 'Dr. Marcus Vance has prepared your virtual consultation room.', 'chat', false),
    ('80000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003', 'Prescription Issued', 'Dr. Elena Rostova created digital prescription RX-2026-1003 for your dermatologic care.', 'prescription', true),
    ('80000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000004', 'Payment Received', 'Payment of $105.00 for pediatric consult INV-2026-0004 processed successfully.', 'payment', true),
    ('80000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000005', 'Ultrasound Reminder', 'Please arrive 15 minutes early and stay well hydrated for your scan.', 'system', false),
    ('80000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000006', 'Radiology Report Completed', 'Your Knee X-Ray imaging findings have been reviewed by Dr. Sarah Watson.', 'lab', false),
    ('80000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000007', 'Vitals Checked In', 'Your systolic/diastolic blood pressure reading was logged into your EMR.', 'system', true),
    ('80000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000008', 'Follow-up Scheduled', 'Your next surgical review is booked for next month.', 'appointment', true)
ON CONFLICT (id) DO NOTHING;

-- 9. Insert Conversations & 10 Realtime Chat Messages
INSERT INTO public.conversations (id, title, channel_type) VALUES
    ('90000000-0000-0000-0000-000000000001', 'Dr. Sarah Watson - Emma Stonehurst', 'direct'),
    ('90000000-0000-0000-0000-000000000002', 'AuraCare Clinical Support Desk', 'support')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.conversation_members (conversation_id, user_id) VALUES
    ('90000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001'),
    ('90000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001'),
    ('90000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

INSERT INTO public.messages (id, conversation_id, sender_id, message_text, is_read, created_at) VALUES
    ('91000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Hello Dr. Watson, I have been recording my morning blood pressure as requested.', true, NOW() - INTERVAL '3 hours'),
    ('91000000-0000-0000-0000-000000000002', '90000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Hi Emma, excellent! What have your average readings been over the past 3 days?', true, NOW() - INTERVAL '2 hours 45 minutes'),
    ('91000000-0000-0000-0000-000000000003', '90000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'They have averaged around 122/78 mmHg, heart rate around 68 bpm.', true, NOW() - INTERVAL '2 hours 30 minutes'),
    ('91000000-0000-0000-0000-000000000004', '90000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Those numbers are within optimal target range. Keep taking Lisinopril consistently.', true, NOW() - INTERVAL '2 hours 15 minutes'),
    ('91000000-0000-0000-0000-000000000005', '90000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Thank you Doctor, see you tomorrow morning at the clinic!', false, NOW() - INTERVAL '1 hour'),
    ('91000000-0000-0000-0000-000000000006', '90000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', 'Can I verify if my lab sample requires fasting beforehand?', true, NOW() - INTERVAL '5 hours'),
    ('91000000-0000-0000-0000-000000000007', '90000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'Yes, for the Comprehensive Lipid Panel, an 8 to 10 hour overnight water-only fast is recommended.', true, NOW() - INTERVAL '4 hours 50 minutes'),
    ('91000000-0000-0000-0000-000000000008', '90000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', 'Understood! I will schedule the blood draw for 8:00 AM.', true, NOW() - INTERVAL '4 hours 30 minutes'),
    ('91000000-0000-0000-0000-000000000009', '90000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'Perfect. We look forward to seeing you.', true, NOW() - INTERVAL '4 hours 20 minutes'),
    ('91000000-0000-0000-0000-000000000010', '90000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Please bring your previous ECG records along if possible.', false, NOW() - INTERVAL '15 minutes')
ON CONFLICT (id) DO NOTHING;
