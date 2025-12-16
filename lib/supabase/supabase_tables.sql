-- Users table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT,
  phone TEXT,
  role TEXT DEFAULT 'user',
  is_active BOOLEAN DEFAULT true,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Locations table for patrol locations
CREATE TABLE IF NOT EXISTS public.locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Permits table for parking permits
CREATE TABLE IF NOT EXISTS public.permits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  permit_type TEXT NOT NULL,
  expiry_date TIMESTAMPTZ NOT NULL,
  vehicle_model TEXT NOT NULL,
  vehicle_year TEXT NOT NULL,
  vehicle_color TEXT NOT NULL,
  plate_number TEXT NOT NULL,
  spot_number TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Active reports table
CREATE TABLE IF NOT EXISTS public.active_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reported_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  admin_role TEXT NOT NULL,
  plate_number TEXT NOT NULL,
  car_details TEXT,
  additional_notes TEXT,
  attached_image TEXT,
  submit_time TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- History reports table (archived reports)
CREATE TABLE IF NOT EXISTS public.history_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reported_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  admin_role TEXT NOT NULL,
  plate_number TEXT NOT NULL,
  car_details TEXT,
  expired_reason TEXT,
  submit_time TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Towing entries table
CREATE TABLE IF NOT EXISTS public.towing_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plate_number TEXT NOT NULL,
  location TEXT,
  tow_company TEXT,
  reason TEXT,
  notes TEXT,
  tow_date TIMESTAMPTZ,
  attached_image TEXT,
  reported_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_permits_user_id ON public.permits(user_id);
CREATE INDEX IF NOT EXISTS idx_permits_plate_number ON public.permits(plate_number);
CREATE INDEX IF NOT EXISTS idx_permits_expiry_date ON public.permits(expiry_date);
CREATE INDEX IF NOT EXISTS idx_active_reports_plate_number ON public.active_reports(plate_number);
CREATE INDEX IF NOT EXISTS idx_active_reports_reported_by ON public.active_reports(reported_by);
CREATE INDEX IF NOT EXISTS idx_active_reports_submit_time ON public.active_reports(submit_time);
CREATE INDEX IF NOT EXISTS idx_history_reports_plate_number ON public.history_reports(plate_number);
CREATE INDEX IF NOT EXISTS idx_history_reports_reported_by ON public.history_reports(reported_by);
CREATE INDEX IF NOT EXISTS idx_history_reports_submit_time ON public.history_reports(submit_time);
CREATE INDEX IF NOT EXISTS idx_towing_entries_plate_number ON public.towing_entries(plate_number);
CREATE INDEX IF NOT EXISTS idx_towing_entries_reported_by ON public.towing_entries(reported_by);
CREATE INDEX IF NOT EXISTS idx_towing_entries_tow_date ON public.towing_entries(tow_date);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at columns
CREATE TRIGGER set_updated_at_users BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_locations BEFORE UPDATE ON public.locations FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_permits BEFORE UPDATE ON public.permits FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_active_reports BEFORE UPDATE ON public.active_reports FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_history_reports BEFORE UPDATE ON public.history_reports FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_towing_entries BEFORE UPDATE ON public.towing_entries FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
