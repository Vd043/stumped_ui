# Supabase setup for STUMPED (match history backend)

Follow these steps once. After this, the app will be able to save and load match history.

---

## 1. Create a Supabase project (free)

1. Go to **[supabase.com](https://supabase.com)** and sign in (or create an account).
2. Click **New project**.
3. Choose your **organization** (or create one).
4. Fill in:
   - **Name:** e.g. `stumped` or `stumped-production`
   - **Database password:** choose a strong password and **save it** (you need it for DB access).
   - **Region:** pick one close to you (e.g. Southeast Asia if in India).
5. Click **Create new project** and wait until the project is ready (1–2 minutes).

---

## 2. Get your project URL and anon key

1. In the Supabase dashboard, open your project.
2. Go to **Settings** (gear icon in the left sidebar) → **API**.
3. Copy and keep these two values:
   - **Project URL** (e.g. `https://xxxxx.supabase.co`)
   - **anon public** key (under "Project API keys" – long string starting with `eyJ...`)

You will need these in the app (see step 4).

---

## 3. Run the database schema

1. In the Supabase dashboard, go to **SQL Editor**.
2. Click **New query**.
3. Open the file **`supabase/migrations/001_initial_cricket_schema.sql`** from this project and copy its **entire** contents.
4. Paste into the SQL Editor and click **Run** (or press Cmd/Ctrl + Enter).
5. You should see "Success. No rows returned." This creates the tables:
   - **matches** – match date, venue, team names, overs, result
   - **innings** – runs, wickets, balls, extras per innings
   - **batting_scorecard** – per batsman: runs, balls, 4s, 6s, out type
   - **bowling_scorecard** – per bowler: overs, maidens, runs, wickets, wides, no-balls

---

## 4. Give the app your Supabase URL and key

The app needs your **Project URL** and **anon key** to talk to Supabase. We’ll use a config file that is **not** committed to git (so your key stays private).

1. In the project root, create a file named **`lib/config/supabase_config.dart`** (the folder `lib/config` may need to be created).
2. Put this in it (replace with your real values):

```dart
class SupabaseConfig {
  static const String url = 'YOUR_PROJECT_URL';   // e.g. https://xxxxx.supabase.co
  static const String anonKey = 'YOUR_ANON_KEY';  // e.g. eyJhbGc...
}
```

3. Replace `YOUR_PROJECT_URL` and `YOUR_ANON_KEY` with the values from step 2.
4. Add this file to **`.gitignore`** so it never gets committed:

```
lib/config/supabase_config.dart
```

After this, the app can save matches and load history. If you prefer environment variables or a different place for the key, we can adjust.

---

## 5. Verify tables (optional)

In Supabase, go to **Table Editor**. You should see:

- **matches**
- **innings**
- **batting_scorecard**
- **bowling_scorecard**

Leave them empty for now; the app will insert data when you save a match.

---

## Summary checklist

- [ ] Supabase project created
- [ ] Project URL and anon key copied from **Settings → API**
- [ ] SQL from `supabase/migrations/001_initial_cricket_schema.sql` run in **SQL Editor**
- [ ] `lib/config/supabase_config.dart` created with your URL and key
- [ ] `lib/config/supabase_config.dart` added to `.gitignore`

When these are done, tell me and we’ll wire the app to save the current match (team names, overs, runs, wickets, date) and show match history.
