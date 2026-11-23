# GlucoNote

A private-by-default diabetes diary for people living with type 1 or type 2 diabetes.

## Stack
- React + TypeScript + Vite
- Supabase Auth + PostgreSQL with Row Level Security
- GitHub Actions + GitHub Pages

## Features in the first release
- Email/password registration and sign-in through Supabase
- Glucose readings with mmol/L and mg/dL support
- Reading context, notes, edit and delete
- Dashboard, history and basic trends
- User profile and preferred units
- Responsive layout for phones and desktops

## Important
GlucoNote is a record-keeping tool, not a medical device and not a source of diagnosis or treatment advice. It does not calculate insulin doses or recommend treatment. Discuss personal glucose targets and treatment decisions with a qualified healthcare professional.

**Public source code does not mean public health records.** User records are protected by Supabase Row Level Security. Never put a Supabase service-role key in frontend code or GitHub.

## Setup
1. Create a Supabase project.
2. In the Supabase SQL Editor, run [supabase/schema.sql](supabase/schema.sql).
3. In Supabase Authentication settings, configure the site URL and allowed redirect URLs for your local and GitHub Pages addresses.
4. Copy `.env.example` to `.env.local` and fill in the project URL and anon/publishable key.
5. Run `npm install` and `npm run dev`.

The frontend intentionally displays a setup screen until Supabase credentials are provided; it does not silently store medical records in browser storage.

## GitHub Pages
In the repository settings, set **Pages → Build and deployment → Source** to **GitHub Actions**. Add these repository variables:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

Then push to `main`; the workflow builds and deploys the static site. These are public-client credentials, not secrets. Database access must be protected by RLS. Do not add a service-role key.

## Data and backups
Supabase stores authentication and records; GitHub Pages only hosts the static frontend. Review Supabase plan limits, inactivity/pause behavior and backup options before relying on it as the sole long-term store for important health records. Export/backup procedures should be tested regularly.

## Privacy
Each user's records are scoped to their authenticated user ID. Users should not enter information they do not want stored in their Supabase project. Configure account deletion and retention in accordance with applicable law and your chosen hosting region.
