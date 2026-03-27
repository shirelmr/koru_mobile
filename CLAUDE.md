# Kōru — Frontend PRD
*Find Your Patterns · Flutter (iOS & Android) · v1.0*

---

## 1. Product Overview

Kōru is a daily health journal with an AI engine at its core. Users write or speak freely about how they feel — the system extracts structured variables and surfaces correlations between daily habits and symptoms over time.

**Tagline:** Find Your Patterns.

**Platform:** Flutter — iOS & Android from a single codebase.

**MVP scope:** 6 screens. No AI Face Scan. No chat interface. Frontend-first build.

---

## 2. Target Users

|       Profile  | What they track |
|----------------|-----------------|
| General Health | Sleep, mood, stress, exercise, symptoms, food |
| Diabetes | Everything above + glucose (mg/dL), insulin, carb intake, meal type |

---

## 3. Screens & User Flows

### Screen 1 — Welcome & Setup (Onboarding)

The first screen a new user sees. Only runs once.

**Screen 1A — Profile Selection**
- App title + subtitle: *"Do you have a specific health condition to track?"*
- Three selectable cards: General Health, Diabetes, Hypertension
- Each card has an icon, title, and one-line description
- One card is selected at a time (tapping deselects others)
- "Continue →" CTA at the bottom — disabled until a card is selected

**Screen 1B — Profile Confirmation**
- Shows which profile was selected (e.g., "🩸 Diabetes")
- Lists what will be tracked daily (e.g., Glucose, Insulin, Carb intake, Meal type)
- Footnote: *"+ Free-text journaling · Voice diary"*
- "Start Journaling →" primary CTA
- "← Go back" text link

**Out of scope for MVP:** profile editing after onboarding, Hypertension fully wired (UI only).

---

### Screen 2 — Daily Check-In

The main entry point. Opened every day.

**Header**
- Kōru logo + "Check-In" label
- Bottom navigation bar: Check-In · Timeline · Patterns
- 7-day streak badge (e.g., "● 7 day streak")

**Step 1 — Voice Diary (optional)**
- Dark card with "Let AI scan your mood" label
- Large circular button to start recording
- Animated waveform during recording
- "Listening... 0:10" timer
- Transcribed text appears in the text field below automatically

**Step 2 — Free Text**
- Multiline text field: *"Write freely or tap the mic..."*
- Placeholder example: *"Woke up with a headache, slept 5h, had two coffees"*
- Microphone icon inside the field to trigger voice input

**Step 3 — Optional Sliders (below text field)**
- Sleep Quality: 5-dot selector
- Stress Level: 5-dot selector
- Tension: 5-dot selector
- Mood: 5-dot selector
- Focus: 5-dot selector
- Sliders are truly optional — submitting with text alone is valid

**Diabetes profile only (additional optional fields):**
- Glucose (mg/dL) numeric input
- Insulin taken toggle
- Carb intake selector (Low / Medium / High)
- Last meal selector (Breakfast / Lunch / Dinner / Snack)

**"Analyze →" primary button** at the bottom triggers AI extraction (loading state: 2–3 seconds).

---

### Screen 3 — Extraction Confirmation

Shown after submitting a check-in. The user reviews what the AI understood.

**Header**
- Green dot + "ANALYSIS COMPLETE" label
- Title: *"Here's what I found"*

**Chip grid (2 columns)**
Each cell contains:
- Category label with emoji (e.g., "😵 Symptoms", "😴 Sleep")
- One or more removable chips (chip × to delete)
- "+" button to add a custom tag

**Chip categories:**
- Symptoms, Sleep, Intake, Stress, Exercise, Mood
- Diabetes only: Glucose, Insulin, Carbs, Last Meal

**Color coding for chips:**
- Default: sage green
- Danger (symptoms, high glucose): light red
- Warning (caffeine, high carbs): light amber

**Bottom actions:**
- "Confirm & Save →" primary button
- "Edit manually" text link

---

### Screen 4 — Timeline

A chronological feed of all past check-ins.

**Header**
- "Your Timeline" title (serif, large)
- Subtitle: *"Track how you've been feeling"*
- Month navigation with ← February 2026 → arrows

**Feed rows (newest first)**
Each row shows:
- Day number + day of week abbreviation
- Mood dot (green / amber / red)
- Up to 3 chips (overflow shown as "+N more")
- First line of the original text entry

**Tapping a row expands it to show:**
- Full chip set
- All extracted fields in labeled tiles (Sleep, Stress, Exercise, Mood)
- Diabetes profile: Glucose, Insulin, Carb Intake, Last Meal tiles
- "Your Entry" section with the original free text

**Pagination:** 20 entries per page. Infinite scroll or "Load more" button.

---

### Screen 5 — Patterns

Available after 7+ days of data. Shows correlations and stats.

**Header**
- "Your Patterns" title
- Subtitle: *"Based on X entries"*

**Stat cards (2×2 grid)**
- Total Entries
- Avg Sleep (hours)
- % Exercise Days
- % Good Days

**Mood Distribution**
- Stacked horizontal bar: Good % / Neutral % / Bad %
- Color-coded legend

**Diabetes only — Glucose Over Time**
- Bar chart with daily glucose values
- Color coding: green (normal), red (high), amber (low)
- Average mg/dL shown as label

**Most Frequent Symptoms**
- Ranked list with horizontal bars showing frequency

**Correlation Cards**
Each card shows:
- "Condition A → Condition B"
- Badge: HIGH / MEDIUM / POSITIVE
- "X of Y times · Z% correlation"
- Color-coded progress bar

**Empty state (< 7 entries):**
- Progress indicator: *"X of 7 days logged to unlock your patterns"*

---

### Screen 6 — Medical Report

Only accessible from bottom nav or from the Patterns screen. Generates a PDF to bring to a doctor's appointment.

**Step 1 — Configure**
- Title: *"Generate report"* · Subtitle: *"To bring to your doctor"*
- Period selector: 7 days / 30 days / 90 days / Custom
- Entry count shown below (e.g., "Mar 1–26, 2026 · 26 entries")
- Toggle list — what to include:
  - 🩸 Detailed daily glucose
  - 💉 Insulin per day
  - 🍽 Foods consumed (day by day)
  - 😴 Sleep hours per night
  - 🤕 Reported symptoms
  - 🔗 Detected correlations
  - 📝 Patient notes (optional)
- Detail level selector: "Summary only" vs "Day by day ✓"
- Optional doctor's note text field
- "View report →" primary button

**Step 2 — Report Preview**

*Summary section (page 1):*
- Dark header card: patient name, profile, period, entry count
- Glucose stats: avg mg/dL, spikes >140, % insulin taken
- Mini bar chart (glucose over time)
- Days in range (70–140 mg/dL)
- Most frequent foods with chips (color-coded: green / amber / red)
- Detected correlations list

*Day-by-day section (page 2+):*
- One collapsible row per day
- Collapsed: date + mood dot + key chips (glucose badge, symptoms)
- Expanded:
  - Glucose badge (color: green/amber/red)
  - Meals by time: Breakfast · Lunch · Dinner · Snack with food items
  - Sleep bar (hours + quality)
  - Symptoms listed
- Footer note: *"Showing 5 of 26 days · PDF includes all"*

**Step 3 — Export**
- File preview card: filename, size, sections count
- Share options (2×2 grid):
  - 📤 Share (system share sheet: WhatsApp, Mail...)
  - 📥 Download PDF
  - 🔗 Copy link (valid 7 days)
  - 🖨 Print
- Tip card: *"Show the doctor the correlations section — it links food and sleep directly to your glucose levels."*
- Report history: previous months listed with entry count

---

## 4. Navigation

**Bottom navigation bar (persistent, 3 tabs):**

| Tab | Icon | Screen |
|---|---|---|
| Check-In | circle icon | Daily Check-In |
| Timeline | trend icon | Timeline |
| Patterns | plus/grid icon | Patterns |

The Report screen is accessed via a dedicated entry point (button in Patterns screen or separate tab in v1.1).

**Navigation flow:**
```
Onboarding (once)
  └── Check-In
        └── Extraction Confirmation
              └── Check-In (confirmed)

Bottom Nav
  ├── Check-In
  ├── Timeline
  │     └── Day Detail (expanded row)
  └── Patterns
        └── Report
              ├── Configure
              ├── Preview
              └── Export
```

---

## 5. Design System

### Colors

| Token | Hex | Usage |
|---|---|---|
| `koruDark` | `#243D1A` | Headlines, primary text, nav bar bg |
| `koruMid` | `#3D6B2A` | Primary buttons, active tabs, toggle on |
| `koruSage` | `#7AAA62` | Accents, icons, logo |
| `koruBackground` | `#EEF4EC` | App background |
| `koruCard` | `#FFFFFF` | Card surfaces |
| `koruBorder` | `#D6E8CF` | Card borders, dividers |
| `koruMuted` | `#6B7F63` | Secondary text, labels |
| `koruChip` | `#C4DAB8` | Default chip background |
| `koruChipText` | `#2A4D1C` | Default chip text |
| `koruDanger` | `#C0392B` | High-risk badges, spikes, red chips |
| `koruWarning` | `#B35C00` | Medium-risk, amber chips |
| `koruSuccess` | `#5AAA3F` | Good mood dot, positive correlation |

### Typography

| Style | Font | Usage |
|---|---|---|
| Display | Georgia, serif, Bold Italic | Screen titles ("How are you today?") |
| Headline | Georgia, serif, Bold | Section headers ("Your Timeline") |
| Title | System sans-serif, SemiBold | Card titles, nav labels |
| Body | System sans-serif, Regular | Entry text, descriptions |
| Label | System sans-serif, UPPERCASE, +1px tracking | Section labels, chip text |

### Core Components

- **KoruChip** — pill tag with × remove and + add. Variants: default, danger, warning, active (dark)
- **KoruCard** — white, 14px radius, 0.5px border, 12–14px padding
- **KoruButton (primary)** — full width, koruMid fill, 24px radius, white text
- **KoruButton (outline)** — full width, transparent, koruMid border + text
- **StatCard** — emoji icon + large number + uppercase label; koruBackground fill
- **CorrelationCard** — A → B, badge, count + %, colored progress bar
- **TimelineRow** — date + mood dot + chip preview; expandable
- **MoodDot** — 7px circle: green (good) / #E8C547 (neutral) / red (bad)
- **DayToggle** — emoji icon + label + toggle switch (report config)

---

## 6. Flutter Packages

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.5 | State management |
| `go_router` | ^13.0 | Navigation |
| `dio` | ^5.4 | HTTP client |
| `supabase_flutter` | ^2.3 | Auth + DB |
| `speech_to_text` | ^6.6 | Voice diary |
| `fl_chart` | ^0.68 | Glucose chart, mood bar |
| `pdf` | ^3.10 | Report PDF generation |
| `printing` | ^5.12 | Print + share PDF |
| `shared_preferences` | ^2.2 | Local profile + streak cache |
| `intl` | ^0.19 | Date formatting |
| `freezed` | ^2.4 | Immutable models |
| `json_serializable` | ^6.7 | JSON parsing |

---

## 7. Out of Scope (MVP)

- AI Face Scan (camera mood detection) → v2
- "Ask Your Data" chat interface → v2
- Calendar grid view in Timeline → v1.1
- Hypertension profile fully wired → v1.1
- Apple Health / Google Fit integration → v2
- Profile editing after onboarding → v1.1
- Push notification reminders → v1.1

---

*Kōru · Find Your Patterns · Frontend PRD v1.0*
