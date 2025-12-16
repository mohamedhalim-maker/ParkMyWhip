-- Enable Row Level Security for all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.active_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.history_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.towing_entries ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view all users" ON public.users FOR SELECT USING (true);
CREATE POLICY "Users can insert their own record" ON public.users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update their own record" ON public.users FOR UPDATE USING (auth.uid() = id) WITH CHECK (true);
CREATE POLICY "Users can delete their own record" ON public.users FOR DELETE USING (auth.uid() = id);

-- Locations table policies
CREATE POLICY "Anyone can view locations" ON public.locations FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert locations" ON public.locations FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can update locations" ON public.locations FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can delete locations" ON public.locations FOR DELETE USING (auth.role() = 'authenticated');

-- Permits table policies
CREATE POLICY "Users can view all permits" ON public.permits FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert permits" ON public.permits FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can update permits" ON public.permits FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can delete permits" ON public.permits FOR DELETE USING (auth.role() = 'authenticated');

-- Active reports table policies
CREATE POLICY "Users can view all active reports" ON public.active_reports FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert active reports" ON public.active_reports FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can update active reports" ON public.active_reports FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can delete active reports" ON public.active_reports FOR DELETE USING (auth.role() = 'authenticated');

-- History reports table policies
CREATE POLICY "Users can view all history reports" ON public.history_reports FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert history reports" ON public.history_reports FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can update history reports" ON public.history_reports FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can delete history reports" ON public.history_reports FOR DELETE USING (auth.role() = 'authenticated');

-- Towing entries table policies
CREATE POLICY "Users can view all towing entries" ON public.towing_entries FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert towing entries" ON public.towing_entries FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can update towing entries" ON public.towing_entries FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can delete towing entries" ON public.towing_entries FOR DELETE USING (auth.role() = 'authenticated');
