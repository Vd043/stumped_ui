# Fix: "Families Policy Requirements: Metadata" (App not available on Google Play)

Your app was flagged for **metadata** that doesn’t meet [Families Policy Requirements](https://support.google.com/googleplay/android-developer/answer/9883336) or the general [Metadata policy](https://support.google.com/googleplay/android-developer/answer/9859153). Fix the items below, then send the app for review again.

---

## 1. Check if STUMPED is in "Designed for families"

- In Play Console go to **Policy** → **App content** (or **Policy and programmes**).
- Look for **"Designed for families"** or **"Target audience and content"**.
- **If STUMPED is not for children:**  
  - Set **Target audience** to **13+** or **18+** only (no "Under 13").
  - If you see an option to **leave** or **opt out** of "Designed for families", do that so Families policy no longer applies.

---

## 2. Make store listing accurate and policy‑compliant

Review and adjust so everything is **clear, accurate, and not misleading**. Remove anything that looks like testimonials, exaggerations, or irrelevant content.

### App title
- **Use:** **STUMPED** (or "STUMPED - Cricket Scoring" if you want).
- Avoid extra keywords or claims that don’t match the app.

### Short description (max 80 chars)
- **Use:**  
  `Precision cricket scoring for the modern elite.`  
  Or a simpler, neutral option:  
  `Cricket scoring app. Set up matches and track runs and wickets live.`
- Keep it factual; no testimonials or "best app" style claims.

### Full description
- **Use something like (clear, no testimonials):**

```
STUMPED is a cricket scoring app. Set up matches, name teams, choose overs, and score live.

Features:
• Set up your match – Name batting and bowling teams, set number of overs.
• Live scoring – Record runs (0–6), wides, no-balls, and wickets.
• Simple, focused design for scoring during a match.

No account required. All data stays on your device.
```

- **Avoid:**  
  - Phrases like "best app", "#1", or anonymous user quotes.  
  - "Designed for elites" if it triggers Families or misleading-metadata checks; you can change to "Designed for players and fans" or remove that line.

### Developer name
- Use a clear, real name or brand (e.g. **RVTech** or **Vardan Shukla**). No misleading or impersonation-style names.

### App icon
- Must represent the app (cricket/scoring). No unrelated images, other brands, or misleading visuals. Use your STUMPED icon (green/gold, text or cricket theme).

### Screenshots and promotional images
- Show only your app’s real UI (splash, setup, live scoring).
- No fake or borrowed screens, no unrelated content, no testimonials in images.
- Add short, factual captions if you want (e.g. "Set up match", "Live scoring").

---

## 3. Save and send for review

- Save all changes in **Store presence** → **Main store listing** (and any other listing tabs you use).
- In **Publishing overview**, make sure the new store listing is included in a **release** (e.g. closed testing or production), then **Send for review** (or equivalent).
- Wait for the review result; they often re-check metadata when you fix and resubmit.

---

## 4. If it’s still rejected

- Open **Policy status** → **Issue details** and read the latest email ( **View email** ).
- Fix any specific line they mention (e.g. one screenshot, one sentence).
- Use **Submit an appeal** only if you’re sure the listing is compliant and the rejection seems wrong; explain what you changed and why you believe it now meets the [Metadata policy](https://support.google.com/googleplay/android-developer/answer/9859153) and Families policy (if it still applies).

---

## Quick checklist

- [ ] Target audience is **13+** or **18+** only (no under-13 if app isn’t for kids); opt out of "Designed for families" if applicable.
- [ ] App title is **STUMPED** (or similar), no keyword stuffing.
- [ ] Short and full descriptions are factual, no testimonials or misleading claims.
- [ ] Developer name is clear and real.
- [ ] App icon matches the app (cricket/scoring).
- [ ] Screenshots and promotional images show only your app and are accurate.
- [ ] Changes saved and new version/release sent for review.
