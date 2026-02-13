# Backend architecture decision: Supabase

## Decision: **Supabase** (Postgres + Auth + APIs)

We use **Supabase** as the backend for match history, player stats, and future scaling. The app is designed so that "where data lives" is behind a **data layer**; swapping Supabase later is a contained change.

---

## Why Supabase over Firebase (and others)

| Criterion | Supabase | Firebase |
|-----------|----------|----------|
| **Data model** | PostgreSQL (relational). Natural fit: players, matches, batting/bowling stats, teams. One query for "top run scorers" or "player X total wickets". | NoSQL (documents). Flexible but aggregations and reporting need careful design or more reads. |
| **Scaling** | Add tables, indexes, maybe read replicas. Cost scales with DB size and plan, not per read/write. Predictable. | Scales automatically; cost is per read/write. Can get expensive for heavy reads (e.g. leaderboards). |
| **Migration / lock-in** | Open-source (Postgres + APIs). Export SQL dump → move to any Postgres (Neon, Railway, self-host). Same schema and SQL elsewhere. | Export to JSON; then reshape and reload elsewhere. App code and security rules are Firebase-specific; migration = rework. |
| **Free tier** | 500 MB DB, 1 GB storage, 2 GB bandwidth. Enough for many societies and thousands of matches. | 50K reads / 20K writes per day. Enough to start; at scale, cost less predictable. |
| **Long-term** | Standard SQL and REST. Easy to add reporting, backups, and move to another Postgres host without rewriting app logic if we keep a clear data layer. | Tied to Firestore model and APIs. Changing provider = new data model and new client code. |

**Verdict:** Supabase gives a **relational model** that matches cricket stats, **predictable scaling**, and **low migration pain** (standard SQL + pluggable backend in the app). Firebase is great for rapid prototyping but worse fit for reporting and future migration.

---

## How we keep migration pain low

1. **Data layer in the app**  
   All backend access goes through **repositories** (e.g. `MatchRepository`, `PlayerStatsRepository`). The UI and business logic call these; they don’t know if the backend is Supabase, REST, or something else.

2. **Supabase as one implementation**  
   We implement these repositories using the Supabase client. If we ever move to another backend (e.g. our own API + Postgres), we:
   - Keep the same repository interfaces and app logic.
   - Replace only the repository implementations (e.g. swap Supabase client for HTTP client to new API).
   - Export data from Supabase (SQL dump or API) and load into the new DB.

3. **Schema we control**  
   Tables (players, matches, batting_stats, etc.) are designed with normalised, standard SQL. No provider-specific structures. Same schema can be recreated on any Postgres.

So: **Supabase is the chosen backend; migration is “new implementation of the same repositories + data export/import”, not a full rewrite.**

---

## Minimal schema (for first version)

- **players** – id, name, created_at (and later: team_id if we add teams).
- **matches** – id, batting_team_name, bowling_team_name, overs, total_runs, total_wickets, balls, created_at, etc.
- **match_batting** – match_id, player_id, runs, balls_faced (and later: fours, sixes).
- **match_bowling** – match_id, player_id, wickets, runs_conceded, balls_bowled.

Player “history” (total runs, wickets) = aggregates from these tables (SUM, COUNT). No duplicate stats store; one source of truth.

---

## Next steps

1. Create Supabase project (free tier), get URL + anon key.
2. Add tables above (and RLS policies: e.g. allow read for all, write for authenticated or a “scorer” role if we add auth).
3. In the app: add `supabase_flutter`, implement repositories that call Supabase, then wire “Save match” / “Player stats” / “Match history” to these repositories.

This gives you a free, scalable backend and a path to migrate later without pain.
