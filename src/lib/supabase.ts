import { createClient } from '@supabase/supabase-js';

// Supabase publishable keys are intended for browser use.
// Access to user data is enforced by PostgreSQL Row Level Security.
const url = (import.meta.env.VITE_SUPABASE_URL as string | undefined) || 'https://gtizuthdhxazdetbwjie.supabase.co';
const key = (import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined) || 'sb_publishable_feI-H1KJemxd-dTjZBtaxA_u4vRdDe-';

export const supabaseConfigured = Boolean(url && key);
export const supabase = supabaseConfigured ? createClient(url, key) : null;
